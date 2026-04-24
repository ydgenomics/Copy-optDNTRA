# [sortmerna](https://github.com/sortmerna/sortmerna)
SortMeRNA is a local sequence alignment tool for filtering, mapping and clustering.

The core algorithm is based on approximate seeds and allows for sensitive analysis of NGS reads. The main application of SortMeRNA is filtering rRNA from metatranscriptomic data. SortMeRNA takes as input files of reads (fasta, fastq, fasta.gz, fastq.gz) and one or multiple rRNA database file(s), and sorts apart aligned and rejected reads into two files. SortMeRNA works with Illumina, Ion Torrent and PacBio data, and can produce SAM and BLAST-like alignments.


##  Usage

```shell
# https://github.com/sortmerna/sortmerna/tree/master/data/rRNA_databases
sortmerna --index --ref smr_v4.3_sensitive_db.fasta --workdir /data/work/sortmerna/tmp

# 进入数据库目录
cd /data/work/sortmerna

# 只运行一次，用于构建/验证索引
mkdir -p ./my_index
sortmerna \
--ref ${SORTMERNA_DB} \
--idx-dir ./my_index \
--workdir .

# 确保索引文件存在（如果还没有 .idx 文件）
for db in *.fasta; do
    indexdb_rna --ref "$db"
done

# 运行 SortMeRNA 过滤
sortmerna --ref /data/work/sortmerna/smr_v4.3_sensitive_db.fasta,/data/work/sortmerna/smr_v4.3_sensitive_db.idx \
          --reads /path/to/your_clean_R1.fastq.gz \
          --reads /path/to/your_clean_R2.fastq.gz \
          --other /path/to/output/non_rRNA \
          --aligned /path/to/output/rRNA \
          --paired_in \
          --fastx \
          --threads 8 \
          --out2 \
          --workdir /data/work/sortmerna/temp_run

# wget https://github.com/sortmerna/sortmerna/tree/master/data/rRNA_databases/rfam-5s-database-id98.fasta
sortmerna --ref ${SORTMERNA_REF}/rfam-5.8s-database-id98.fasta \
--ref ${SORTMERNA_REF}/rfam-5s-database-id98.fasta \
--ref ${SORTMERNA_REF}/silva-euk-18s-id95.fasta \
--ref ${SORTMERNA_REF}/silva-euk-28s-id98.fasta \
--reads ${INPUT_FOR_SORTMERNA}_R1_val_1.fq.gz \
--reads ${INPUT_FOR_SORTMERNA}_R2_val_2.fq.gz \
--paired_in \
--fastx \
--out2 \
--other ${OUTPUT_DIR}/7.sortmerna/${SAMPLE}_norrna \
--workdir ${OUTPUT_DIR}/7.sortmerna/${SAMPLE} \
--threads ${THREADS}"
```

```shell
#!/bin/bash

# 定义基础 URL
BASE_URL="https://raw.githubusercontent.com/sortmerna/sortmerna/master/data/rRNA_databases"

# 定义缺失的数据库文件列表
missing_dbs=(
    "silva-bac-16s-id90.fasta"
    "silva-arc-16s-id95.fasta"
    "silva-euk-18s-id95.fasta"
    "rfam-5.8s-database-id98.fasta"
)

# 创建数据库目录
mkdir -p sortmerna_db
cd sortmerna_db

# 下载缺失的数据库
for db in "${missing_dbs[@]}"; do
    echo "正在下载: ${db}"
    
    if ! wget --tries=3 --timeout=30 "${BASE_URL}/${db}" -O "${db}"; then
        echo "[ERROR] 下载失败: ${db}"
        echo "请检查网络连接或手动下载"
        exit 1
    fi
    
    echo "✓ 下载完成: ${db}"
done

echo "所有数据库下载完成！"
```

## references
- 生信必备工具解析：SortMeRNA——高效剔除rRNA的“数据清道夫” https://mp.weixin.qq.com/s/Ny-Qf7Q0jBbvwMW4Y0-agQ