export CFSSL_URL=https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/linux/cfssl
export CFSSLJSON_URL=https://storage.googleapis.com/kubernetes-the-hard-way/cfssl/linux/cfssljson

export KUBECTL_VERSION=`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`
export KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl

# 本家
# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/02-client-tools.md
all: cfssl cfssljson kubectl
	cfssl version
	cfssljson --version
	kubectl version --client

cfssl:
	which cfssl \
		|| ( \
			wget -q --show-progress --https-only --timestamping ${CFSSL_URL} \
			&& sudo chmod +x ./cfssl \
			&& sudo mv ./cfssl  /usr/local/bin/ \
		)

cfssljson:
	which cfssljson \
		|| ( \
			wget -q --show-progress --https-only --timestamping ${CFSSLJSON_URL} \
			&& sudo chmod +x ./cfssljson \
			&& sudo mv ./cfssljson  /usr/local/bin/ \
		)

kubectl:
	which kubectl \
		|| ( \
			curl -LO ${KUBECTL_URL} \
			&& sudo chmod +x ./kubectl \
			&& sudo mv ./kubectl /usr/local/bin/ \
		)

clean:
	sudo rm -rf /usr/local/bin/cfssl
	sudo rm -rf /usr/local/bin/cfssljson
	sudo rm -rf /usr/local/bin/kubectl
