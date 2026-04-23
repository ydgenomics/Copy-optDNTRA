# 260422
- 0-assessment
  - pre-fastqc
  - after-fastqc
- 1-fastq
- 2-sortmerna
  - output
- 3-output

PREFIX="test"
MAX_MEMORY=64G
THREADS=16
SORTMERNA_DB=/data/work/sortmerna/smr_v4.3_sensitive_db.fasta

ln -s /data/*.fq.gz .

echo "Running fastqc..."
echo "----------------------------------------"
mkdir -p ./${PREFIX}/0-assessment/pre-fastqc
fastqc *.fq *.gz -o ./${PREFIX}/0-assessment/pre-fastqc --threads ${THREADS} --memory ${MAX_MEMORY}
echo "----------------------------------------"


OUTPUT_DIR=./${PREFIX}/1-fastp
mkdir -p ${OUTPUT_DIR}

echo "[fastp] Starting quality control and trimming..."
echo "----------------------------------------"
for r1 in *_1.fq.gz; do
    sample_name=$(basename "$r1" _1.fq.gz)
    r2="${sample_name}_2.fq.gz"
    if [[ ! -f "$r2" ]]; then
        echo "WARNING: Missing R2 file for sample ${sample_name}. Skipping."
        continue
    fi
    
    echo "processing: ${sample_name}"
    echo "  R1: ${r1}"
    echo "  R2: ${r2}"

    fastp -i "${r1}" \
          -I "${r2}" \
          -o "${OUTPUT_DIR}/${sample_name}_clean_1.fq.gz" \
          -O "${OUTPUT_DIR}/${sample_name}_clean_2.fq.gz" \
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
mkdir -p ./${PREFIX}/0-assessment/after-fastqc
fastqc ./${PREFIX}/1-fastq/*_clean_*.fq.gz -o ./${PREFIX}/0-assessment/after-fastqc --threads ${THREADS} --memory ${MAX_MEMORY}
echo "----------------------------------------"

echo "Running sortmerna remove rna..."
echo "----------------------------------------"
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

    sortmerna --ref ${SORTMERNA_DB} \
          --reads "${r1}" \
          --reads "${r2}" \
          --other ./${PREFIX}/02-sortmerna/non_rRNA \
          --aligned ./${PREFIX}/02-sortmerna/rRNA \
          --paired_in \
          --fastx \
          --threads 16 \
          --out2 \
          --workdir .
    
    echo "completed: ${sample_name}"
    echo "---"
done
echo "----------------------------------------"

mkdir -p ./${PREFIX}/03-output
multiqc ./${PREFIX}/0-assessment/after-fastqc -o ./${PREFIX}/03-output