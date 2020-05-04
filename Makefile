.PHONY: up, rsync, provision

plugin:
	vagrant plugin install vagrant-hosts
	vagrant plugin install vagrant-scp
up:
	vagrant up
	chmod 600 .vagrant/machines/*/virtualbox/private_key
reload:
	vagrant reload
rsync:
	vagrant rsync
rsync-auto:
	vagrant rsync-auto
provision: rsync
	vagrant provision

ssh:
	ssh \
		-o StrictHostKeyChecking=no \
		-i .vagrant/machines/controller-0/virtualbox/private_key \
		vagrant@10.240.0.10
#		-i .vagrant/machines/lb-0/virtualbox/private_key \
#		vagrant@10.240.0.40
#		-i .vagrant/machines/worker-0/virtualbox/private_key \
#		vagrant@10.240.0.20

02:
	vagrant ssh lb-0 -c 'cd lb && 02-client-tools'
03:
	vagrant ssh lb-0 -c 'cd lb && make 03-compute-resources'
	vagrant ssh controller-0 -c 'cd controller && make 03-compute-resources'
	vagrant ssh controller-1 -c 'cd controller && make 03-compute-resources'
	vagrant ssh controller-2 -c 'cd controller && make 03-compute-resources'
	vagrant ssh worker-0 -c 'cd worker && make 03-compute-resources'
	vagrant ssh worker-1 -c 'cd worker && make 03-compute-resources'
	vagrant ssh worker-2 -c 'cd worker && make 03-compute-resources'

# 各Workerに秘密鍵を配布（ワイルドカードが使えなかった）
# $1：Worker名
define provision-worker-pems
	tar cvf ./pems/$1-pems.tar ./pems/ca.pem ./pems/$1-key.pem ./pems/$1.pem
	vagrant scp ./pems/$1-pems.tar $1:/home/vagrant/worker/pems.tar
	vagrant ssh $1 -c 'cd worker && tar xvf ./pems.tar'
endef
# 各Controllerに秘密鍵を配布（ワイルドカードが使えなかった）
# $1：Controller名
define provision-controller-pems
	tar cvf ./pems/controller-pems.tar ./pems/ca*.pem ./pems/kubernetes*.pem ./pems/service-account*.pem
	vagrant scp ./pems/controller-pems.tar  $1:/home/vagrant/controller/pems.tar
	vagrant ssh $1 -c 'cd controller && tar xvf ./pems.tar'
endef
04:
	vagrant ssh lb-0 -c 'cd lb && make 04-certificate-authority'
	vagrant scp lb-0:/home/vagrant/lb/04-certificate-authority/pems.tar ./pems.tar
	tar xvf ./pems.tar
	$(call provision-worker-pems,worker-0)
	$(call provision-worker-pems,worker-1)
	$(call provision-worker-pems,worker-2)
	$(call provision-controller-pems,controller-0)
	$(call provision-controller-pems,controller-1)
	$(call provision-controller-pems,controller-2)
# Windowsではmakeの入れ子ができない
#	make 04-ca
#	make 04-download-certificates
#	make 04-distribute-certificates
04-ca:
	vagrant ssh lb-0 -c 'cd lb && make 04-certificate-authority'
04-download-certificates:
	vagrant scp lb-0:/home/vagrant/lb/04-certificate-authority/pems.tar ./pems.tar
04-distribute-certificates:
	tar xvf ./pems.tar
	$(call provision-worker-pems,worker-0)
	$(call provision-worker-pems,worker-1)
	$(call provision-worker-pems,worker-2)
	$(call provision-controller-pems,controller-0)
	$(call provision-controller-pems,controller-1)
	$(call provision-controller-pems,controller-2)

# Workerにkubeconfigを配布
# $1：Worker名
define distribute-kubeconfigs-for-worker
	tar cvf ./kubeconfigs/$1-kubeconfigs.tar \
		./kubeconfigs/$1.kubeconfig \
		./kubeconfigs/kube-proxy.kubeconfig
	vagrant scp ./kubeconfigs/$1-kubeconfigs.tar $1:/home/vagrant/worker/$1-kubeconfigs.tar
	vagrant ssh $1 -c 'cd worker && tar xvf ./$1-kubeconfigs.tar'
endef

# Controllerにkubeconfigを配布
# $1：Controller名
define distribute-kubeconfigs-for-controller
	tar cvf ./kubeconfigs/controller-kubeconfigs.tar \
		./kubeconfigs/admin.kubeconfig \
		./kubeconfigs/kube-controller-manager.kubeconfig \
		./kubeconfigs/kube-scheduler.kubeconfig
	vagrant scp ./kubeconfigs/controller-kubeconfigs.tar $1:/home/vagrant/controller/controller-kubeconfigs.tar
	vagrant ssh $1 -c 'cd controller && tar xvf ./controller-kubeconfigs.tar'
endef
05:
	vagrant ssh lb-0 -c 'cd lb && make 05-kubernetes-configuration-files'
	vagrant scp lb-0:/home/vagrant/lb/05-kubernetes-configuration-files/kubeconfigs.tar ./kubeconfigs.tar
	tar xvf ./kubeconfigs.tar
	$(call distribute-kubeconfigs-for-worker,worker-0)
	$(call distribute-kubeconfigs-for-worker,worker-1)
	$(call distribute-kubeconfigs-for-worker,worker-2)
	$(call distribute-kubeconfigs-for-controller,controller-0)
	$(call distribute-kubeconfigs-for-controller,controller-1)
	$(call distribute-kubeconfigs-for-controller,controller-2)
06:
	vagrant ssh lb-0 -c 'cd lb && make 06-data-encryption-keys'
	vagrant scp lb-0:/home/vagrant/lb/06-data-encryption-keys/encryption-config.yml ./encryption-config.yml
	vagrant scp ./encryption-config.yml controller-0:/home/vagrant/controller/
	vagrant scp ./encryption-config.yml controller-1:/home/vagrant/controller/
	vagrant scp ./encryption-config.yml controller-2:/home/vagrant/controller/
07:
	vagrant ssh controller-0 -c 'cd controller && make 07-bootstrapping-etcd'
	vagrant ssh controller-1 -c 'cd controller && make 07-bootstrapping-etcd'
	vagrant ssh controller-2 -c 'cd controller && make 07-bootstrapping-etcd'
	vagrant ssh controller-0 -c 'cd controller/07-bootstrapping-etcd && make verify-etcd'
08:

clean:
	vagrant ssh lb-0 -c 'cd lb && make clean'
	vagrant ssh controller-0 -c 'cd controller && make clean'
	vagrant ssh controller-1 -c 'cd controller && make clean'
	vagrant ssh controller-2 -c 'cd controller && make clean'
	vagrant ssh worker-0 -c 'cd worker && make clean'
	vagrant ssh worker-1 -c 'cd worker && make clean'
	vagrant ssh worker-2 -c 'cd worker && make clean'
	rm -rf pems*
