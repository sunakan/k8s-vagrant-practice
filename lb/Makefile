.PHONY: 02-client-tools, 03-compute-resources, 04-certificate-authority, 05-kubernetes-configuration-files, 06-data-encryption-keys

02-client-tools:
	cd 02-client-tools && make
03-compute-resources:
	cd 03-compute-resources && make
04-certificate-authority:
	cd 04-certificate-authority && make
05-kubernetes-configuration-files:
	cd 05-kubernetes-configuration-files && make
06-data-encryption-keys:
	cd 06-data-encryption-keys && make

clean:
	cd 06-data-encryption-keys && make clean
	cd 05-kubernetes-configuration-files && make clean
	cd 04-certificate-authority && make clean
	cd 03-compute-resources && make clean
	#cd 02-client-tools && make clean
