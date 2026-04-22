# seqtk

## Usage

```shell
sh-4.2$ seqtk 

Usage:   seqtk <command> <arguments>
Version: 1.4-r122

Command: seq       common transformation of FASTA/Q
         size      report the number sequences and bases
         comp      get the nucleotide composition of FASTA/Q
         sample    subsample sequences
         subseq    extract subsequences from FASTA/Q
         fqchk     fastq QC (base/quality summary)
         mergepe   interleave two PE FASTA/Q files
         split     split one file into multiple smaller files
         trimfq    trim FASTQ using the Phred algorithm

         hety      regional heterozygosity
         gc        identify high- or low-GC regions
         mutfa     point mutate FASTA at specified positions
         mergefa   merge two FASTA/Q files
         famask    apply a X-coded FASTA to a source FASTA
         dropse    drop unpaired from interleaved PE FASTA/Q
         rename    rename sequence names
         randbase  choose a random base from hets
         cutN      cut sequence at long N
         gap       get the gap locations
         listhet   extract the position of each het
         hpc       homopolyer-compressed sequence
         telo      identify telomere repeats in asm or long reads
```

**老的数据使用的 Phred+64 编码，而现代工具（如 Trinity）默认只支持 Phred+33 编码**
  - Q64：明确告诉 seqtk，输入文件使用的是 Phred+64 编码。
  - V：将质量值转换为 Phred+33 编码的 Sanger/Illumina 1.9 格式
  - `Encoding=Illumina 1.5` 到 `Encoding=Sanger / Illumina 1.9`

```shell
# 循环处理所有 _1.fq 和 _2.fq 文件
for file in *_1.fq; do
    base=${file%_1.fq}
    echo "Converting ${base}..."
    seqtk seq -Q64 -V ${base}_1.fq > ${base}_converted_1.fq
    seqtk seq -Q64 -V ${base}_2.fq > ${base}_converted_2.fq
done
# 先解压，再转换，最后压缩
for file in *.fastq.gz; do
    base=${file%.fastq.gz}
    echo "处理 ${base}..."
    # 解压 -> 转换 -> 压缩
    gunzip -c "${file}" | seqtk seq -Q64 -V - | gzip > "${base}_converted.fastq.gz"
    # 验证新文件
    if gunzip -t "${base}_converted.fastq.gz" 2>/dev/null; then
        echo "✓ ${base} 转换成功（有效压缩文件）"
    else
        echo "✗ ${base} 转换失败"
    fi
done
# fastqc /data/work/TEST/fq/0A1R_w4q20m35_N_converted_1.fq -o fastqc/
```

## references
- seqtk—抽取随机序列 https://mp.weixin.qq.com/s/vCMlECtwuN_2XxA9zpYZqA