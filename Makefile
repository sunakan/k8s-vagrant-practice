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
		-i .vagrant/machines/worker-0/virtualbox/private_key \
		vagrant@10.240.0.20
#		-i .vagrant/machines/lb-0/virtualbox/private_key \
#		vagrant@10.240.0.40
#		-i .vagrant/machines/controller-0/virtualbox/private_key \
#		vagrant@10.240.0.10
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
	make 04-ca-on-lb
	make 04-dl-and-upload-pems-to-each-vm:
04-ca-on-lb:
	vagrant ssh lb-0 -c 'cd lb && make 04-certificate-authority'
04-dl-and-upload-pems-to-each-vm:
	vagrant scp lb-0:/home/vagrant/lb/04-certificate-authority/pems.tar ./pems.tar
	tar xvf ./pems.tar
	$(call provision-worker-pems,worker-0)
	$(call provision-worker-pems,worker-1)
	$(call provision-worker-pems,worker-2)
	$(call provision-controller-pems,controller-0)
	$(call provision-controller-pems,controller-1)
	$(call provision-controller-pems,controller-2)

clean:
	vagrant ssh lb-0 -c 'cd lb && make clean'
	vagrant ssh controller-0 -c 'cd controller && make clean'
	vagrant ssh controller-1 -c 'cd controller && make clean'
	vagrant ssh controller-2 -c 'cd controller && make clean'
	vagrant ssh worker-0 -c 'cd worker && make clean'
	vagrant ssh worker-1 -c 'cd worker && make clean'
	vagrant ssh worker-2 -c 'cd worker && make clean'
	rm -rf pems*
