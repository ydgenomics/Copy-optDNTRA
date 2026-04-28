source /opt/software/miniconda3/bin/activate && conda activate tool
cd /data/work/test
LEFT_fq=/data/input/Files/yangdong/P/p-jintian/after_fastp/0A1R_clean_1.fq.gz
RIGHT_fq=/data/input/Files/yangdong/P/p-jintian/after_fastp/0A1R_clean_2.fq.gz
SORTMERNA_DB=/data/input/Files/ReferenceData/Database/plant_ref_rRNA/plant_rRNA.fa
SAMPLE_SIZE=100000
SAMPLE_ID=test
sh assess_rrna.sh $LEFT_fq $RIGHT_fq $SORTMERNA_DB $SAMPLE_SIZE $SAMPLE_ID 2>&1 | tee log.txt
rm -rf kvdb && rm -rf readb

parameter="--no_normalize_reads"
Trinity --seqType fq \
--max_memory 50G \
--left 0A1R_clean_1.fq.gz \
--right 0A1R_clean_2.fq.gz \
--CPU 16 --output trinity_out \
${parameter} 2>&1 | tee -a log.txt

less /data/input/Files/yangdong/P/p-jintian/after_fastp/0A1R_clean_1.fq.gz | wc -l
less /data/input/Files/yangdong/P/p-jintian/after_fastp/0A1R_clean_2.fq.gz | wc -l


# 使用 seqkit 寻找配对的 reads (非常快)
seqkit pair \
-1 0A1R_clean_1.fq.gz \
-2 0A1R_clean_2.fq.gz \
-o paired_R1.fq \
-o paired_R2.fq

seqkit pair \
-1 0A1R_clean_1.fq.gz \
-2 0A1R_clean_2.fq.gz \
-O seqkit_out