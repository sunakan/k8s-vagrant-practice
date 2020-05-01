.PHONY: up, rsync, provision

plugin:
	vagrant plugin install vagrant-hosts
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
		-i .vagrant/machines/lb-0/virtualbox/private_key \
		vagrant@10.240.0.40
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

clean:
	vagrant ssh lb-0 -c 'cd lb && make clean'
	vagrant ssh controller-0 -c 'cd controller && make clean'
	vagrant ssh controller-1 -c 'cd controller && make clean'
	vagrant ssh controller-2 -c 'cd controller && make clean'
	vagrant ssh worker-0 -c 'cd worker && make clean'
	vagrant ssh worker-1 -c 'cd worker && make clean'
	vagrant ssh worker-2 -c 'cd worker && make clean'
