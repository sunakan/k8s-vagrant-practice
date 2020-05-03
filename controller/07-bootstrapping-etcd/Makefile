# 本家
# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/07-bootstrapping-etcd.md
# Vagrant版
# https://github.com/kenfdev/kubernetes-the-hard-way-vagrant/tree/master/scripts/k8s-the-hard-way
# 0700-download-and-install-etcd.sh
# 0701-configure-etcd.sh
# 0702-start-etcd.sh
# 0710-verify-etcd.sh

all:
	make download-and-install-etcd
	make install-mo
	make configure-etcd
	make start-etcd

export ETCD_VERSION=v3.4.7
export GOOGLE_URL=https://storage.googleapis.com/etcd
export ETCD_URL=${GOOGLE_URL}/${ETCD_VERSION}/etcd-${ETCD_VERSION}-linux-amd64.tar.gz
download-and-install-etcd:
	( etcd --version && etcdctl version ) \
		|| ( \
			rm -f /tmp/etcd.tar.gz \
			&& rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test \
			&& curl -L ${ETCD_URL} -o /tmp/etcd.tar.gz \
			&& tar xzvf /tmp/etcd.tar.gz -C /tmp/etcd-download-test --strip-components=1 \
			&& sudo mv /tmp/etcd-download-test/etcd /usr/local/bin/ \
			&& sudo mv /tmp/etcd-download-test/etcdctl /usr/local/bin/ \
			&& rm -rf /tmp/etcd-download-test \
		)

export MO_TEST_MESSAGE=insatalled
install-mo:
	which mo \
	|| ( \
		curl -sSL https://git.io/get-mo -o mo \
		&& chmod +x mo \
		&& sudo mv mo /usr/local/bin/ \
	)
	echo 'mo is {{MO_TEST_MESSAGE}}' | mo

# 10.0.2.15を除いているのは、VirtualBoxでデフォルトで割り当てられるIPアドレスだから
define internal-ip
	ip address show \
	| grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' \
	| grep -Eo '([0-9]*\.){3}[0-9]*' \
	| grep -v 127.0.0.1 \
	| grep -v 10.0.2.15
endef
configure-etcd:
	sudo mkdir -p /etc/etcd /var/lib/etcd
	sudo cp ../pems/ca.pem             /etc/etcd/
	sudo cp ../pems/kubernetes-key.pem /etc/etcd/
	sudo cp ../pems/kubernetes.pem     /etc/etcd/
	export ETCD_NAME=`hostname --short`; export INTERNAL_IP=`$(call internal-ip)`; \
	cat etcd.service.template | mo > etcd.service
	sudo mv etcd.service /etc/systemd/system/etcd.service

start-etcd:
	sudo systemctl daemon-reload
	sudo systemctl enable etcd
	sudo systemctl start etcd

verify-etcd:
	sudo ETCDCTL_API=3 etcdctl member list \
		--endpoints=https://127.0.0.1:2379 \
		--cacert=/etc/etcd/ca.pem \
		--cert=/etc/etcd/kubernetes.pem \
		--key=/etc/etcd/kubernetes-key.pem

clean:
	sudo systemctl daemon-reload
	sudo systemctl stop etcd
	sudo systemctl disable etcd
	sudo rm -rf /etc/etcd /var/lib/etcd
	sudo rm -rf /usr/local/bin/etcd*
	sudo rm /etc/systemd/system/etcd.service
