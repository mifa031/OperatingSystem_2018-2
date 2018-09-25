all: VirtualOS.bin

temp2.bin: VirtualOS.asm
	nasm -o temp1.bin VirtualOS.asm
	printf '\00' >> zero.dat
	touch padding.dat
	for i in `seq 12` ; do\
	  cat zero.dat >> padding.dat ;\
	done
	cat padding.dat temp1.bin > temp2.bin

Hash: temp2.bin
	$(shell $(eval hash1=$(shell xxd -p -s +0 -l 4 temp2.bin)) \
		stat -c%s "temp2.bin" > temp2_size ; \
		file_size=`cat temp2_size`;\
		remain=`expr $$file_size % 4` ;\
		main=`expr $$file_size - $$remain` ;\
		aug=`expr 4 - $$remain` ;\
		aug2=`expr $$aug \* 2` ;\
		printf '0x' > hex; \
		hash=$(hash1) ;\
		stat -c%s "temp2.bin" > temp2_size ; \
		file_size=`cat temp2_size`;\
		for i in `seq 4 4 $$file_size`; do \
		  if [ $$i -eq $$main ];then \
		    xxd -p -s +$$i -l $$remain temp2.bin > temp_file ;\
			cat hex temp_file > temp_file2 ; \
			touch last_padding ;\
			for p in `seq $$aug2`; do\
			  printf '0' >> last_padding;\
			done; \
			cat temp_file2 | tr -d '\n' > temp_file3;\
			cat temp_file3 last_padding > hash_temp;\
		  else \
		    xxd -p -s +$$i -l 4 temp2.bin > temp_file ;\
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

VirtualOS.bin: Hash temp2.bin
	cat Hash temp2.bin > VirtualOS.bin
	rm -f Hash temp1.bin temp2.bin temp2_size temp_file temp_file2 temp_file3 hash_temp hex padding.dat zero.dat last_padding

clean:
	rm -f VirtualOS.bin
