all: VirtualOS.bin

temp2.bin: VirtualOS.asm
    nasm -o temp1.bin VirtualOS.asm
    printf '\00' >> zero.dat
    touch padding.dat
    for i in `seq 1 508` ; do\
      cat zero.dat >> padding.dat ;\
    done
    cat padding.dat temp1.bin > temp2.bin

Divide: temp2.bin
    $(shell printf '0x' > hex; \
        for i in `seq 508 4 1016`; do \
          xxd -p -s +$$i -l 4 temp2.bin > temp_file1; \
          cat hex temp_file1 > divide"$$i" ; \
          done \
        )
    touch Divide

Hash: temp2.bin Divide
    $(shell $(eval hash1=$(shell cat divide508)) \
        hash=$(hash1) ;\
        for i in `seq 512 4 1016`; do \
          hash2=`cat divide$$i` ; \
          printf '%x'  "$$(( $$hash ^ $$hash2 ))" | sed 's/\([0-9A-F]\{2\}\)/\\\\\\x\1/gI' |xargs printf > Hash; \
          hash="$$(( $$hash ^ $$hash2 ))" ;\
          done \
        )

VirtualOS.bin: Hash temp2.bin
    cat Hash temp2.bin > VirtualOS.bin
    rm -f temp1.bin temp2.bin padding.dat zero.dat hex Hash divide* Divide temp_file1

clean:
    rm -f VirtualOS.bin