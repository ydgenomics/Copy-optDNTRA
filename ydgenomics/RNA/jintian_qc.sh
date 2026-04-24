# 260424

mkdir -p /data/work/jintian && cd /data/work/jintian
ln -s /data/input/Files/SP_reads_data/*_1.fq .
ln -s /data/input/Files/SP_reads_data/*_2.fq .

PREFIX="jintian"
THREADS=8 # fq numbers
SORTMERNA_DB=/data/users/yangdong/yangdong_5f5c3933d7c44a73bff0cbff6fd8db86/online/sortmerna/smr_v4.3_sensitive_db.fasta
SORTMERNA_DB_IDX=/data/users/yangdong/yangdong_5f5c3933d7c44a73bff0cbff6fd8db86/online/test/idx.tar.gz

FASTQC_PATH=/opt/software/miniconda3/envs/optdntra/bin/fastqc
FASTP_PATH=/opt/software/miniconda3/envs/optdntra/bin/fastp
MULTIQC_PATH=/opt/software/miniconda3/envs/tool/bin/multiqc
SORTMERNA_PATH=/opt/software/miniconda3/envs/tool/bin/sortmerna


# 对工作目录下的.fq文件转变为.gz格式，方便后续处理
for fq in ./*.fq; do
    if [[ -f "$fq" ]]; then
        gzip -c "$fq" > "${fq%.fq}.fq.gz"
        echo "Compressed $fq to ${fq%.fq}.fq.gz"
    else
        echo "No .fq files found in the current directory."
    fi
done

echo "Running fastqc..."
echo "----------------------------------------"
mkdir -p ./${PREFIX}/0-assessment/pre-fastqc
${FASTQC_PATH} ./*.fq.gz -o ./${PREFIX}/0-assessment/pre-fastqc --threads ${THREADS} --memory 10000
echo "----------------------------------------"


OUTPUT_DIR=./${PREFIX}/1-fastp
mkdir -p ${OUTPUT_DIR}

echo "[fastp] Starting quality control and trimming..."
echo "----------------------------------------"
for r1 in ./*_1.fq.gz; do
    sample_name=$(basename "$r1" _1.fq.gz)
    r2="${sample_name}_2.fq.gz"
    if [[ ! -f "$r2" ]]; then
        echo "WARNING: Missing R2 file for sample ${sample_name}. Skipping."
        continue
    fi
    
    echo "processing: ${sample_name}"
    echo "  R1: ${r1}"
    echo "  R2: ${r2}"

    ${FASTP_PATH} -i "${r1}" \
          -I "${r2}" \
          -o "${OUTPUT_DIR}/${sample_name}_clean_1.fq.gz" \
          -O "${OUTPUT_DIR}/${sample_name}_clean_2.fq.gz" \
          -6 \
          --detect_adapter_for_pe \
          --cut_front \
          --cut_tail \
          --cut_window_size 4 \
          --cut_mean_quality 20 \
          --length_required 50 \
          --average_qual 20 \
          --correction \
          --thread ${THREADS} \
          --html "${OUTPUT_DIR}/${sample_name}_report.html" \
          --json "${OUTPUT_DIR}/${sample_name}_report.json"
    
    echo "completed: ${sample_name}"
    echo "---"
done

echo "All samples processed!"
echo "Output directory: ${OUTPUT_DIR}"
echo "----------------------------------------"


echo "Running fastqc on cleaned data..."
echo "----------------------------------------"
mkdir -p ./${PREFIX}/0-assessment/after-fastp
${FASTQC_PATH} ./${PREFIX}/1-fastp/*_clean_*.fq.gz -o ./${PREFIX}/0-assessment/after-fastp --threads ${THREADS} --memory 10000
echo "----------------------------------------"

echo "Running sortmerna remove rna..."
echo "----------------------------------------"
tar -zxvf ${SORTMERNA_DB_IDX}
mkdir -p ./${PREFIX}/02-sortmerna
for r1 in ./${PREFIX}/1-fastp/*_1.fq.gz; do
    sample_name=$(basename "$r1" _1.fq.gz)
    r2="./${PREFIX}/1-fastp/${sample_name}_2.fq.gz"
    if [[ ! -f "$r2" ]]; then
        echo "WARNING: Missing R2 file for sample ${sample_name}. Skipping."
        continue
    fi
    
    echo "processing: ${sample_name}"
    echo "  R1: ${r1}"
    echo "  R2: ${r2}"

    ${SORTMERNA_PATH} \
    --ref ${SORTMERNA_DB} \
    --idx-dir ./my_index \
    --reads "${r1}" \
    --reads "${r2}" \
    --other ./${PREFIX}/02-sortmerna/non_rRNA_${sample_name} \
    --aligned ./${PREFIX}/02-sortmerna/rRNA_${sample_name} \
    --paired_in \
    --fastx \
    --threads 16 \
    --out2 \
    --workdir .
    
    echo "completed: ${sample_name}"
    echo "---"
    rm -rf kvdb && rm -rf readb
done
echo "----------------------------------------"

echo "Running fastqc on cleaned rrna data..."
echo "----------------------------------------"
mkdir -p ./${PREFIX}/0-assessment/after-sortmerna
${FASTQC_PATH} ./${PREFIX}/02-sortmerna/non_rRNA_* -o ./${PREFIX}/0-assessment/after-sortmerna --threads ${THREADS} --memory 10000
echo "----------------------------------------"

mkdir -p ./${PREFIX}/03-output
${MULTIQC_PATH} ./${PREFIX}/0-assessment/*/* -o ./${PREFIX}/03-output