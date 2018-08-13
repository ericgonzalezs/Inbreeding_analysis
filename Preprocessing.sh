# Starting with fastq files with names  like this ones TUM1_S1_L005_R1_001.fastq.gz  TUM1_S1_L005_R2_001.fastq.gz
#quality was checked with fastqc 

# Trimming with trimmomatic
for i in $(ls *R1_001.fastq.gz); do name=$(echo $i | cut -d "_" -f 1,2,3); java -jar trimmomatic-0.38.jar PE -threads 10 -phred33 -trimlog "$name"".log"  "$name""_R1_001.fastq.gz"  "$name""_R2_001.fastq.gz" "$name""_paired_R1_001.fastq.gz" "$name""_unpaired_R1_001.fastq.gz" "$name""_paired_R2_001.fastq.gz" "$name""_unpaired_R2_001.fastq.gz" ILLUMINACLIP:TruSeq2-PE_index.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36; done

#	Alignment BWA mem for Pair End (PE)
for i in $(ls *_paired_R1_001.fastq.gz); do nombre=$(echo $i | cut -d"_" -f 1,2,3,4); SN=$(echo $i | cut -d"_" -f 1); bwa mem -t 10 -M -R '@RG\tID:NRGENE\tSM:$SN\tPL:SE\tLB:no\tPU:unit1' Zea_mays.AGPv4.dna.toplevel.fa "$nombre""_R1_001.fastq.gz" "$nombre""_R2_001.fastq.gz" > "$nombre""B73v4_PE.sam" ; done

#	Alignment BWA mem for Single End (SE)
for i in $(ls *_unpaired_*); do nombre=$(echo $i | cut -d"_" -f 1,2,3,4,5); SN=$(echo $i | cut -d"_" -f 1); bwa mem -t 8 -M -R '@RG\tID:NRGENE\tSM:$SN\tPL:SE\tLB:no\tPU:unit1' Zea_mays.AGPv4.dna.toplevel.fa "$nombre""_001.fastq.gz"  > "$nombre""_B73v4_SE.sam" ; done

#	Sort files and convert to bam files PE using Picard tools
for i in $(ls *PE.sam); do nombre=$(echo $i | awk -F "_" -v OFS="_" '{print $1, $2, $3, $4}'); java -Xmx20g -XX:ParallelGCThreads=10 -jar picard.jar SortSam MAX_RECORDS_IN_RAM=2000000 INPUT=$i OUTPUT="$nombre""_sorted.bam" SORT_ORDER=coordinate; done

#	Sort files and convert to bam files  SE using Picard tools
for i in $(ls *SE.sam); do nombre=$(echo $i | awk -F "_" -v OFS="_" '{print $1, $2, $3, $4, $5, $6}'); java -Xmx20g -XX:ParallelGCThreads=10 -jar picard.jar SortSam MAX_RECORDS_IN_RAM=2000000 INPUT=$i OUTPUT="$nombre""_sorted.bam" SORT_ORDER=coordinate; done

#	Merge data using samtools

for i in $(ls *bam | awk -F "_" '{print $1}' | uniq);do ls $i*.bam > "$i"."txt"  ; done

for i in $(ls *txt); do nombre=$(echo $i | awk -F "." '{print $1}'); samtools merge "$nombre""_merged.bam" -b $i; done

#	Remove duplicates using picard tools

for i in $(ls *merged.bam); do nombre=$(echo $i | cut -d "." -f1); java -Xmx20g -XX:ParallelGCThreads=10 -jar picard.jar MarkDuplicates INPUT=$i OUTPUT="$nombre""_dedup.bam" REMOVE_DUPLICATES=true METRICS_FILE="$nombre""_metrics.txt"; done

#	Create index using picard tools

for i in $(ls *_dedup.bam); do java -Xmx20g -XX:ParallelGCThreads=10 -jar picard.jar BuildBamIndex INPUT=$i; done

#	Indel realignment using GATK

for i in $(ls *_dedup.bam); do nombre=$(echo $i | cut -d "." -f1) ;java -Xmx20g -jar GenomeAnalysisTK.jar -T RealignerTargetCreator -R Zea_mays.AGPv4.dna.toplevel.fa -I $i -o "$nombre""-forIndelRealigner.intervals" ; done

for i in $(ls *forIndelRealigner.intervals); do nombre=$(echo $i| cut -d "-" -f1);  java -Xmx20g -jar GenomeAnalysisTK.jar -T IndelRealigner -R Zea_mays.AGPv4.dna.toplevel.fa -I "$nombre"".bam"  -targetIntervals $i -o "$nombre""_indelrealigned.bam"; done
