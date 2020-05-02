# 本家
# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/05-kubernetes-configuration-files.md
#
# Vagrant版（https://github.com/kenfdev/kubernetes-the-hard-way-vagrant/blob/master/scripts/k8s-the-hard-way/）
# 0500-kubelet-kubeconfig.sh
# 0501-kube-proxy-kubeconfig.sh
# 0502-kube-controller-manager-kubeconfig.sh
# 0503-kube-scheduler-kubeconfig.sh
# 0504-admin-kubeconfig.sh
all:
	make copy-pems-from-04                  # 04の証明書系作っている前提なので、それらをコピー
	make kubelet-kubeconfig                 # kubelet用
	make kube-proxy-kubeconfig              # kube-proxy用
	make kube-controller-manager-kubeconfig # controller-maanger用
	make kube-scheduler-kubeconfig          # kube-scheduler用
	make admin-kubeconfig                   # Admin用
	make check                              # kubeconfigが全てあるかチェック
	make tar-kubeconfigs                    # 生成したすべてのkubeconfigをアーカイブ

copy-pems-from-04:
	ls ./pems \
	|| ( \
		ls ../04-certificate-authority/pems/ \
			|| ( cd ../04-certificate-authority/ && make ) \
		&& cp -rf ../04-certificate-authority/pems ./ \
	)

export KUBERNETES_PUBLIC_ADDRESS=10.240.0.40
export KUBERNETES_CLUSTER_NAME=kubernenetes-the-hard-way
# kubectlコマンドによるconfigファイル生成
# $1：何のためのconfigファイルを生成するか（worker-0やadmin,kube-proxy等）
# $2：cluster用serverオプションに使うURL
# $3：K8sからみたこのconfigの使用者
define kube-config
	kubectl config set-cluster kubernetes-the-hard-way \
		--certificate-authority=./pems/ca.pem \
		--embed-certs=true \
		--server=$2 \
		--kubeconfig=$1.kubeconfig

	kubectl config set-credentials $3 \
		--client-certificate=./pems/$1.pem \
		--client-key=./pems/$1-key.pem \
		--embed-certs=true \
		--kubeconfig=$1.kubeconfig

	kubectl config set-context default \
		--cluster=kubernetes-the-hard-way \
		--user=$3 \
		--kubeconfig=$1.kubeconfig

	kubectl config use-context default --kubeconfig=./$1.kubeconfig # 接続確認（ある意味が不明）
endef
kubelet-kubeconfig:
	$(call kube-config,worker-0,https://${KUBERNETES_PUBLIC_ADDRESS}:6443,system:node:worker-0)
	$(call kube-config,worker-1,https://${KUBERNETES_PUBLIC_ADDRESS}:6443,system:node:worker-1)
	$(call kube-config,worker-2,https://${KUBERNETES_PUBLIC_ADDRESS}:6443,system:node:worker-2)

kube-proxy-kubeconfig:
	$(call kube-config,kube-proxy,https://${KUBERNETES_PUBLIC_ADDRESS}:6443,system:kube-proxy)

kube-controller-manager-kubeconfig:
	$(call kube-config,kube-controller-manager,https://127.0.0.1:6443,system:kube-controller-manager)

kube-scheduler-kubeconfig:
	$(call kube-config,kube-scheduler,https://127.0.0.1:6443,system:kube-scheduler)

admin-kubeconfig:
	$(call kube-config,admin,https://127.0.0.1:6443,admin)

check:
	ls worker-0.kubeconfig
	ls worker-1.kubeconfig
	ls worker-2.kubeconfig
	ls kube-proxy.kubeconfig
	ls kube-controller-manager.kubeconfig
	ls admin.kubeconfig

tar-kubeconfigs:
	ls kubeconfigs.tar \
		|| ( \
			mkdir --parents ./kubeconfigs \
			&& cp *.kubeconfig ./kubeconfigs/ \
			&& tar cvf ./kubeconfigs.tar ./kubeconfigs \
		)

clean:
	rm -rf pems*
	rm -rf *.kubeconfig
	rm -rf kubeconfig*
