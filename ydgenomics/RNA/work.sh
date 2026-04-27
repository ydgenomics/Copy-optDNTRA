source /opt/software/miniconda3/bin/activate && conda activate tool
cd /data/work/test
LEFT_fq=/data/input/Files/yangdong/P/p-jintian/after_fastp/0A1R_w4q20m35_N_clean_1.fq.gz
RIGHT_fq=/data/input/Files/yangdong/P/p-jintian/after_fastp/0A1R_w4q20m35_N_clean_2.fq.gz
SORTMERNA_DB=/data/input/Files/ReferenceData/Database/plant_ref_rRNA/plant_rRNA.fa
SAMPLE_SIZE=10000
SAMPLE_ID=test
sh assess_rrna.sh $LEFT_fq $RIGHT_fq $SORTMERNA_DB $SAMPLE_SIZE $SAMPLE_ID 2>&1 | tee log.txt

parameter="--no_normalize_reads"
Trinity --seqType fq \
--max_memory 50G \
--left /data/work/test/test_rrna_out/non_rRNA_fwd.fq.gz \
--right /data/work/test/test_rrna_out/non_rRNA_rev.fq.gz \
--CPU 16 --output trinity_out_dir \
${parameter} 2>&1 | tee -a log.txt