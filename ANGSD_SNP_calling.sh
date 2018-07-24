# SNP calling with ANGSD
./angsd  -SNP_pval 1e-6 -GL 1 -doMajorMinor 1 -doMaf 1  -bam BAM_list.txt -ref Zea_mays.AGPv4.dna.toplevel.fa  -remove_bads 1 -minMapQ 30 -minQ 20 -minInd 4 -P 40 -doGeno 4 -doPost 1 -postCutoff 0.95 -out WGS_angsd_SNPs_4ind
