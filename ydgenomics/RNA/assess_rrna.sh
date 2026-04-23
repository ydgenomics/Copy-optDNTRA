# 260422
#!/bin/bash

# --- 参数设置 (使用 ${N:-default} 语法) ---
# $1, $2... 代表脚本后的第1, 2...个参数
# 如果用户没有输入，则自动使用冒号后面的路径/数值
LEFT_fq=${1:-"/data/users/yangdong/yangdong_5b07fc5c978d4acb9b44c83305ac3a2b/online/TEST/test/cleaned_data/0A1R_w4q20m35_N_clean_R1.fastq.gz"}
RIGHT_fq=${2:-"/data/users/yangdong/yangdong_5b07fc5c978d4acb9b44c83305ac3a2b/online/TEST/test/cleaned_data/0A1R_w4q20m35_N_clean_R2.fastq.gz"}
SORTMERNA_DB=${3:-"/data/work/sortmerna/smr_v4.3_sensitive_db_rfam_seeds.fasta"}
SAMPLE_SIZE=${4:-10000}


echo "----------------------------------------"
echo "Working Parameters:"
echo "LEFT_FQ:      $LEFT_fq"
echo "RIGHT_FQ:     $RIGHT_fq"
echo "DATABASE:     $SORTMERNA_DB"
echo "SAMPLE_SIZE:  $SAMPLE_SIZE"
echo "----------------------------------------"
SEQTK_PATH=/opt/software/miniconda3/envs/optdntra/bin/seqtk
SORTMERNA_PATH=$(which sortmerna)
echo "Config tools:"
echo "seqtk:        $SEQTK_PATH"
echo "sortmerna:    $SORTMERNA_PATH"
echo "----------------------------------------"


# randomly sample $SAMPLE_SIZE reads from each FASTQ file for testing
$SEQTK_PATH sample -s100 $LEFT_fq $SAMPLE_SIZE > test_R1.fq
$SEQTK_PATH sample -s100 $RIGHT_fq $SAMPLE_SIZE > test_R2.fq

# assess rRNA contamination using SortMeRNA
echo "----------------------------------------"
start_time=$(date +%s)
echo "Starting rRNA assessment at: $(date)"
sortmerna --ref ${SORTMERNA_DB} \
          --reads test_R1.fq \
          --reads test_R2.fq \
          --other ./test_rrna_out/non_rRNA \
          --aligned ./test_rrna_out/rRNA \
          --paired_in \
          --fastx \
          --threads 4 \
          --out2 \
          --workdir .

end_time=$(date +%s)
elapsed_time=$((end_time - start_time))
echo "Completed rRNA assessment at: $(date)"
echo "Elapsed time: ${elapsed_time} seconds"
echo "----------------------------------------"

cd ./test_rrna_out

# calculate rRNA percentage
total_reads=$(( 2 * SAMPLE_SIZE ))
if [ -f rRNA_fwd.fq ]; then
    rrna_count=$(cat rRNA_fwd.fq rRNA_rev.fq 2>/dev/null | wc -l | awk '{print $1/4}')
else
    rrna_count=$(zcat rRNA_fwd.fq.gz rRNA_rev.fq.gz 2>/dev/null | wc -l | awk '{print $1/4}')
fi
rrna_percent=$(echo "scale=2; $rrna_count * 100 / $total_reads" | bc)

echo "========================================="
echo "Summary of rRNA Assessment:"
echo "========================================="
echo "Total reads: $total_reads"
echo "rRNA reads: $rrna_count"
echo "rRNA percentage: ${rrna_percent}%"
echo "========================================="

# rRNA 占比	判断	建议
# < 5%	✅ 优秀	无需去除，直接用于 Trinity
# 5% - 15%	⚠️ 中等	可去除也可不去，对组装影响有限
# 15% - 30%	🔶 偏高	建议去除，会明显影响组装效率和质量
# > 30%	🔴 严重	必须去除，否则组装结果会很差