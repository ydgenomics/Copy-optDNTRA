# editor：yangdong
# 260427

LEFT_fq=${1:-"/Files/RawData/ML150007317_L01/ML150007317_L01_266_1.fq.gz"}
RIGHT_fq=${2:-"/Files/RawData/ML150007317_L01/ML150007317_L01_266_2.fq.gz"}
SORTMERNA_DB=${3:-"/data/work/sortmerna/smr_v4.3_sensitive_db_rfam_seeds.fasta"}
SAMPLE_SIZE=${4:-10000}
SAMPLE_ID=${5:-"test"}


echo "----------------------------------------"
echo "Working Parameters:"
echo "LEFT_FQ:      $LEFT_fq"
echo "RIGHT_FQ:     $RIGHT_fq"
echo "DATABASE:     $SORTMERNA_DB"
echo "SAMPLE_SIZE:  $SAMPLE_SIZE"
echo "SAMPLE_ID:"   $SAMPLE_ID
echo "----------------------------------------"
SEQTK_PATH=/opt/software/miniconda3/envs/optdntra/bin/seqtk
SORTMERNA_PATH=/opt/software/miniconda3/envs/tool/bin/sortmerna
echo "Config tools:"
echo "seqtk:        $SEQTK_PATH"
echo "sortmerna:    $SORTMERNA_PATH"
echo "----------------------------------------"


# randomly sample $SAMPLE_SIZE reads from each FASTQ file for testing
$SEQTK_PATH sample -s100 $LEFT_fq $SAMPLE_SIZE | gzip > test_R1.fq.gz
$SEQTK_PATH sample -s100 $RIGHT_fq $SAMPLE_SIZE | gzip > test_R2.fq.gz

# assess rRNA contamination using SortMeRNA
echo "----------------------------------------"
start_time=$(date +%s)
echo "Starting rRNA assessment at: $(date)"
${SORTMERNA_PATH} --ref ${SORTMERNA_DB} \
          --reads test_R1.fq.gz \
          --reads test_R2.fq.gz \
          --other ./sortmerna_out/${SAMPLE_ID}_non_rRNA \
          --aligned ./sortmerna_out/${SAMPLE_ID}_rRNA \
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

cd ./sortmerna_out

# calculate rRNA percentage
total_reads=$(( 2 * SAMPLE_SIZE ))
if [ -f rRNA_fwd.fq ]; then
    rrna_count=$(cat ${SAMPLE_ID}_rRNA_fwd.fq ${SAMPLE_ID}_rRNA_rev.fq 2>/dev/null | wc -l | awk '{print $1/4}')
else
    rrna_count=$(zcat ${SAMPLE_ID}_rRNA_fwd.fq.gz ${SAMPLE_ID}_rRNA_rev.fq.gz 2>/dev/null | wc -l | awk '{print $1/4}')
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