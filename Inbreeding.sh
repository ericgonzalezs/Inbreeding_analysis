#calculating GL with -C 50
./angsd -GL 1 -bam BAM_list.txt -ref Zea_mays.AGPv4.dna.toplevel.fa -C 50 -minInd 4 -nThreads 30 -remove_bads 1  -doGlf 3 -doMajorMinor 1 -doMaf 1 -SNP_pval 1e-6 -minMapQ 30 -minQ 20 -out all_WGS.HWE

#calculating GL without -C 50
./angsd -GL 1 -bam BAM_list.txt -minInd 4 -nThreads 30 -remove_bads 1  -doGlf 3 -doMajorMinor 1 -doMaf 1 -SNP_pval 1e-6 -minMapQ 30 -minQ 20 -out all_WGS_noC50.HWE

#inbreeding

ngsF.sh --n_threads 30 --n_ind 8 --min_epsilon 1e-6 --n_sites 15990327 --glf all_WGS.HWE.glf --out all_WGS_inb

#inbreeding no -C 50

ngsF.sh --n_threads 30 --n_ind 8 --min_epsilon 1e-6 --n_sites 42285273 --glf all_WGS_noC50.HWE.glf --out  all_WGS_noC50_inb
