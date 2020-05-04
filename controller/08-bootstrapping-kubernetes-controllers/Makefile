# 本家
# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/08-bootstrapping-kubernetes-controllers.md
# Vagrant版
# https://github.com/kenfdev/kubernetes-the-hard-way-vagrant/tree/master/scripts/k8s-the-hard-way
# 0800-download-and-install-k8s-controllers.sh
# 0801-configure-k8s-api-server.sh
# 0802-configure-k8s-controller-manager.sh
# 0803-configure-k8s-schedueler.sh
# 0804-start-controller-services.sh
# 0805-verify.sh
# 0810-rbac-for-kubelet-auth.sh
# 0820-verify-frontend-lb.sh
all:
	make download-and-install-k8s-controllers
	make configure-k8s-api-server
	make configure-k8s-controller-manager
	make configure-k8s-schedueler
	make start-controller-services
	make verify
	make rbac-for-kubelet-auth
	make verify-frontend-lb

KUBE_TOOL_VERSION=`curl --silent https://storage.googleapis.com/kubernetes-release/release/stable.txt`
KUBE_TOOL_BASE_URL=https://storage.googleapis.com/kubernetes-release/release/${KUBE_TOOL_VERSION}/bin/linux/amd64
# 既に存在しているならDL・インストールしない
# $1：tool名
define download-and-install-k8s-tool
	which $1 \
		|| ( \
			wget --quiet --show-progress --https-only --timestamping ${KUBE_TOOL_BASE_URL}/$1 \
			&& chmod +x $1 \
			&& sudo mv $1 /usr/local/bin/ \
		)
endef
download-and-install-k8s-controllers:
	$(call download-and-install-k8s-tool,kube-apiserver)
	$(call download-and-install-k8s-tool,kube-controller-manager)
	$(call download-and-install-k8s-tool,kube-scheduler)
	$(call download-and-install-k8s-tool,kubectl)

configure-k8s-api-server:
configure-k8s-controller-manager:
configure-k8s-schedueler:
start-controller-services:
verify:
rbac-for-kubelet-auth:
verify-frontend-lb:

clean:
