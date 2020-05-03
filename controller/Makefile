.PHONY: 03-compute-resources, 07-bootstrapping-etcd
03-compute-resources:
	cd 03-compute-resources && make

07-bootstrapping-etcd:
	cd 07-bootstrapping-etcd && make

clean:
	cd 03-compute-resources && make clean
	cd 07-bootstrapping-etcd && make clean
	rm -rf *.tar pems kubeconfigs
