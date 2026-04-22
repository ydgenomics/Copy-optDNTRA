# fastqc
fastqc *.fq *.gz

# fastp
# 定义输入输出目录
INPUT_DIR="."
OUTPUT_DIR="./cleaned_data"
mkdir -p ${OUTPUT_DIR}

# 方法1: 使用数组存储双端文件对
echo "=== Method 1: Process paired-end files ==="
for r1 in *_1.fq; do
    # 提取样本名（去掉 _1.fq 后缀）
    sample_name=$(basename "$r1" _1.fq)
    r2="${sample_name}_2.fq"
    
    # 检查 R2 文件是否存在
    if [[ ! -f "$r2" ]]; then
        echo "警告: 找不到配对文件 $r2，跳过 $sample_name"
        continue
    fi
    
    echo "处理样本: ${sample_name}"
    echo "  R1: ${r1}"
    echo "  R2: ${r2}"
    
    # 运行 fastp 进行质控
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
          --thread 8 \
          --html "${OUTPUT_DIR}/${sample_name}_report.html" \
          --json "${OUTPUT_DIR}/${sample_name}_report.json"
    
    echo "完成: ${sample_name}"
    echo "---"
done

echo "所有样本处理完成！"
echo "输出目录: ${OUTPUT_DIR}"

# fastqc
cd ./cleaned_data
# 为当前目录下所有以 .fq 或 .gz 结尾的文件运行fastqc
fastqc *.fq *.gz

# multiqc
# 在包含所有fastqc报告的目录中运行
multiqc ./

