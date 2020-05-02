all:
	make ca                                  # CA認証局を用意
	make admin-client-certificate            # Admin証明書
	make worker-client-certificate           # Worker証明書
	make kube-controller-manager-certificate # KubeControllerManager証明書
	make kube-proxy-certificate              # KubeProxy証明書
	make kube-scheduler-certificate          # KubeScheduler証明書
	make kubernetes-certificate              # KubernetesAPI証明書
	make service-account-certificate         # サービスアカウント証明書
	make check                               # 期待する証明書が全てあるか確認
	make tar-pems                            # 生成したすべての秘密鍵をアーカイブ

# CSRのjson
# $1：CN
define csr
{
  "CN": "$1",
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "US",
      "L": "Portland",
      "O": "Kubernetes",
      "OU": "CA",
      "ST": "Oregon"
    }
  ]
}
endef

# ca-config.jsonのヒアドキュメント（引数なし）
define ca-config
{
  "signing": {
    "default": {
      "expiry": "8760h"
    },
    "profiles": {
      "kubernetes": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "8760h"
      }
    }
  }
}
endef

export CA_CSR=$(call csr,Kubernetes)
export CA_CONFIG=$(call ca-config)
ca:
	echo $${CA_CSR} > ca-csr.json
	echo $${CA_CONFIG} > ca-config.json
	ls ca-key.pem ca.pem ca.csr \
		|| cfssl gencert -initca ./ca-csr.json | cfssljson -bare ca

# $1：対象となる名前（adminとかkube-proxy）
# $2：CSR.jsonの中身
define non-hostname-certificate
	echo $2 > $1-csr.json
	ls $1-key.pem $1.pem $1.csr \
		|| cfssl gencert \
			-ca=./ca.pem \
			-ca-key=./ca-key.pem \
			-config=./ca-config.json \
			-profile=kubernetes \
			$1-csr.json | cfssljson -bare $1
endef
export ADMIN_CSR=$(call csr,admin)
admin-client-certificate:
	$(call non-hostname-certificate,admin,$${ADMIN_CSR})

export WORKER_0_CSR=$(call csr,system:node:worker-0)
export WORKER_1_CSR=$(call csr,system:node:worker-1)
export WORKER_2_CSR=$(call csr,system:node:worker-2)
export EXTERNAL_IP=10.240.0.40
# Worker用の証明書（hostnameが付く）
# $1：worker名
# $2：CSR.jsonの中身
define worker-client-certificate
	echo $2 > $1-csr.json
	ls $1.pem $1.pem $1.csr \
		|| cfssl gencert \
			-ca=ca.pem \
			-ca-key=ca-key.pem \
			-config=ca-config.json \
			-hostname=$1,${EXTERNAL_IP} \
			-profile=kubernetes \
			$1-csr.json | cfssljson -bare $1
endef
worker-client-certificate:
	$(call worker-client-certificate,worker-0,$${WORKER_0_CSR})
	$(call worker-client-certificate,worker-1,$${WORKER_1_CSR})
	$(call worker-client-certificate,worker-2,$${WORKER_2_CSR})

export KUBE_CONTROLLER_MANAGER_CSR=$(call csr,system:kube-controller-manager)
kube-controller-manager-certificate:
	$(call non-hostname-certificate,kube-controller-manager,$${KUBE_CONTROLLER_MANAGER_CSR})

export KUBE_PROXY_CSR=$(call csr,system:kube-proxy)
kube-proxy-certificate:
	$(call non-hostname-certificate,kube-proxy,$${KUBE_PROXY_CSR})

export KUBE_SCHEDULER_CSR=$(call csr,system:kube-scheduler)
kube-scheduler-certificate:
	$(call non-hostname-certificate,kube-scheduler, $${KUBE_SCHEDULER_CSR})

# ここはあとでしっかりとやらないと謎過ぎる
export KUBERNETES_PUBLIC_ADDRESS=10.240.0.40
export KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local
export KUBERNETES_CSR=$(call csr,kubernetes)
kubernetes-certificate:
	echo $${KUBERNETES_CSR} > kubernetes-csr.json
	ls kubernetes.pem kubernetes.pem kubernetes.csr \
		|| cfssl gencert \
			-ca=ca.pem \
			-ca-key=ca-key.pem \
			-config=ca-config.json \
			-hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
			-profile=kubernetes \
			kubernetes-csr.json | cfssljson -bare kubernetes

export SERVICE_ACCOUNT_CSR=$(call csr,service-accounts)
service-account-certificate:
	$(call non-hostname-certificate,service-account, $${SERVICE_ACCOUNT_CSR})

check:
	ls admin-key.pem
	ls admin.pem
	ls ca-key.pem
	ls ca.pem
	ls kube-controller-manager-key.pem
	ls kube-controller-manager.pem
	ls kube-proxy-key.pem
	ls kube-proxy.pem
	ls kube-scheduler-key.pem
	ls kube-scheduler.pem
	ls kubernetes-key.pem
	ls kubernetes.pem
	ls service-account-key.pem
	ls service-account.pem
	ls worker-0-key.pem
	ls worker-0.pem
	ls worker-1-key.pem
	ls worker-1.pem
	ls worker-2-key.pem
	ls worker-2.pem

tar-pems:
	ls pems.tar \
		|| ( \
			mkdir --parents ./pems \
			&& cp *.pem ./pems/ \
			&& tar cvf ./pems.tar ./pems \
		)

clean:
	rm -rf *.csr
	rm -rf *.pem
	rm -rf *.json
	rm -rf *.tar
	rm -rf pems
