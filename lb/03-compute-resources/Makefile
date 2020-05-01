.PHONY: all

# オリジナルではGCP前提
# https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/03-compute-resources.md
# Vagrant版がわかりやすい
# https://github.com/kenfdev/kubernetes-the-hard-way-vagrant/blob/master/scripts/bootstrap/vagrant-setup-hosts-file.sh
# https://github.com/kenfdev/kubernetes-the-hard-way-vagrant/blob/master/scripts/bootstrap/vagrant-setup-routes.sh
#
# hostsのセットアップはVagrantのvagrant-hostsプラグインでやる
all:
	make setup-routes

# 既に追加されていたら追加しない
# 宛先IPアドレスが自分だったら追加しない
# $1：送信元CIDR
# $2：宛先IPアドレス
define add-route
	((ip route | grep $1) || (ip address show | grep $2)) \
		|| ( sudo route add -net $1 gw $2 )
endef
setup-routes:
	$(call add-route, 10.200.0.0/24, 10.240.0.20)
	$(call add-route, 10.200.1.0/24, 10.240.0.21)
	$(call add-route, 10.200.2.0/24, 10.240.0.22)

# $1：送信元CIDR
# $2：宛先IPアドレス
define del-route
	sudo route del -net $1 gw $2 || echo Nothing this route
endef
clean:
	$(call del-route, 10.200.0.0/24, 10.240.0.20)
	$(call del-route, 10.200.1.0/24, 10.240.0.21)
	$(call del-route, 10.200.2.0/24, 10.240.0.22)
