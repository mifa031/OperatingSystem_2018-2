all: BootLoader Kernel32 Disk.img

BootLoader:
	@echo 
	@echo ============== Build Boot Loader ===============
	@echo 
	
	make -C 00.BootLoader
	
	@echo 
	@echo =============== Build Complete ===============
	@echo 

Kernel32:
	@echo
	@echo ============== Build 32bit Kernel ===============
	@echo
	
	make -C 01.Kernel32
	
	@echo 
	@echo =============== Build Complete ===============
	@echo

temp.bin: 01.Kernel32/Kernel32.bin
	split -d -a 3 -b 4 01.Kernel32/Kernel32.bin spl
	rm spl000
	cat spl* > temp.bin

Hash: 00.BootLoader/BootLoader.bin 01.Kernel32/Kernel32.bin temp.bin
	$(shell $(eval hash1=$(shell xxd -p -s +0 -l 4 temp.bin)) \
		stat -c%s temp.bin > temp_size ; \
		file_size=`cat temp_size`;\
		remain=`expr $$file_size % 4` ;\
		main=`expr $$file_size - $$remain` ;\
		aug=`expr 4 - $$remain` ;\
		aug2=`expr $$aug \* 2` ;\
		printf '0x' > hex; \
		hash=$(hash1) ;\
		for i in `seq 4 4 $$file_size`; do \
		  if [ $$i -eq $$main ];then \
		    xxd -p -s +$$i -l $$remain temp.bin > temp_file ;\
			cat hex temp_file > temp_file2 ; \
			touch last_padding ;\
			for p in `seq $$aug2`; do\
			  printf '0' >> last_padding;\
			done; \
			cat temp_file2 | tr -d '\n' > temp_file3;\
			cat temp_file3 last_padding > hash_temp;\
		  else \
		    xxd -p -s +$$i -l 4 temp.bin > temp_file ;\
			hash1=`cat temp_file`;\
			if [ $$hash1 = '00000000' ]; then\
			  continue;\
			fi;\
			cat hex temp_file > hash_temp; \
		  fi;\
		  hash2=`cat hash_temp`; \
		  printf '%x'  "$$(( $$hash ^ $$hash2 ))" | sed 's/\([0-9A-F]\{2\}\)/\\\\\\x\1/gI' |xargs printf > Hash; \
		  hash="$$(( $$hash ^ $$hash2 ))" ;\
		done; \
		)

temp2.bin: Kernel32 Hash temp.bin
	cat Hash temp.bin > temp2.bin 
	#cat 01.Kernel32/Kernel32.bin > temp.bin

Disk.img: 00.BootLoader/BootLoader.bin 01.Kernel32/Kernel32.bin temp2.bin
	@echo 
	@echo =========== Disk Image Build Start ===========
	@echo 
	
	#cat $^ > Disk.img
	cat 00.BootLoader/BootLoader.bin temp2.bin > Disk.img
	
	@echo 
	@echo ============= All Build Complete =============
	@echo
	
	rm -f Hash last_padding temp_file temp_size hash_temp temp_file2 zero hex temp.bin temp2.bin temp_file3 spl*

run:
	qemu-system-x86_64 -L . -fda Disk.img -m 64 -M pc -rtc base=localtime -s Disk.img

clean:
	make -C 00.BootLoader clean
	make -C 01.Kernel32 clean
	rm -f Disk.img	
