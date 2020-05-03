.PHONY: encryption-config
# 本家
# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/06-data-encryption-keys.md
#
# Vagrant版（https://github.com/kenfdev/kubernetes-the-hard-way-vagrant/blob/master/scripts/k8s-the-hard-way/）
# 0600-encryption-config.sh
all:
	make install-ytt                  # yttのインストール（オリジナルではこれは不要）
	make encryption-config            #

export YTT_VERSION=v0.27.1
export YTT_CHECKSUM=b53674a21d99576b8d69483113e1ec73d9a3ed7381170a421c9afcf8aa551f15
export YTT_URL=https://github.com/k14s/ytt/releases/download/${YTT_VERSION}/ytt-linux-amd64
install-ytt:
	ytt --version \
		|| ( \
			curl -s -L ${YTT_URL} > /tmp/ytt \
			&& echo "${YTT_CHECKSUM}  /tmp/ytt" | shasum -c - \
			&& sudo mv /tmp/ytt /usr/local/bin/ \
			&& sudo chmod +x /usr/local/bin/ytt \
		)

export ENCRYPTION_KEY=`head -c 32 /dev/urandom | base64`
encryption-config:
	ls encryption-config.yml \
		|| ytt \
			--file ./encryption-config/ \
			--data-value secret=${ENCRYPTION_KEY} \
			> encryption-config.yml

clean:
	rm -rf *.yml
