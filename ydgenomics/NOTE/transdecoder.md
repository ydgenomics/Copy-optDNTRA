TransDecoder输出的GTF只包含CDS（coding sequence），缺少UTR信息。手动补充UTR需要基于原始组装序列和比对证据，以下是具体操作流程：

---

## 核心思路

```
原始Trinity组装序列（含全长UTR）
    ↓
TransDecoder预测CDS位置（已知）
    ↓
将CDS坐标映射回全长序列 → 推断UTR边界
    ↓
合并为完整转录本注释
```

---

## 方法一：基于组装序列直接推断（最简单）

### 步骤1：提取TransDecoder的CDS坐标

TransDecoder输出通常包含：
- `transcripts.fasta.transdecoder.gff3`（或`.gtf`）
- `transcripts.fasta.transdecoder.cds`
- `transcripts.fasta.transdecoder.pep`

从GFF3中提取每个转录本的CDS起止位置：

```bash
# 提取CDS位置信息
grep "CDS" transcripts.fasta.transdecoder.gff3 | \
awk '{print $1,$4,$5,$7}' > cds_coordinates.txt
# 格式：transcript_id start end strand
```

### 步骤2：根据CDS位置推断UTR

对于每个转录本，UTR = 全长序列 - CDS区域：

```python
#!/usr/bin/env python3
# infer_utr.py

from Bio import SeqIO
import re

# 输入文件
assembly_fasta = "Trinity.fasta"           # 原始组装序列
cds_gff = "transcripts.fasta.transdecoder.gff3"
output_gtf = "transcripts_with_UTR.gtf"

def parse_gff(gff_file):
    """解析TransDecoder GFF，提取CDS位置"""
    cds_dict = {}
    with open(gff_file) as f:
        for line in f:
            if line.startswith("#") or line.strip() == "":
                continue
            cols = line.strip().split("\t")
            if cols[2] == "CDS":
                transcript_id = cols[0]
                start = int(cols[3])
                end = int(cols[4])
                strand = cols[6]
                if transcript_id not in cds_dict:
                    cds_dict[transcript_id] = []
                cds_dict[transcript_id].append((start, end, strand))
    return cds_dict

def infer_utr(transcript_id, seq_len, cds_list, strand):
    """
    根据CDS列表推断UTR边界
    注意：TransDecoder可能输出多个CDS（如断裂预测）
    """
    # 合并所有CDS区域
    all_cds = []
    for start, end, s in cds_list:
        all_cds.extend(range(start, end+1))
    
    if not all_cds:
        return []
    
    cds_min = min(all_cds)
    cds_max = max(all_cds)
    
    utr_regions = []
    
    # 5' UTR
    if strand == '+':
        if cds_min > 1:
            utr_regions.append((transcript_id, "5UTR", 1, cds_min-1, strand))
    else:
        if cds_max < seq_len:
            utr_regions.append((transcript_id, "5UTR", cds_max+1, seq_len, strand))
    
    # 3' UTR  
    if strand == '+':
        if cds_max < seq_len:
            utr_regions.append((transcript_id, "3UTR", cds_max+1, seq_len, strand))
    else:
        if cds_min > 1:
            utr_regions.append((transcript_id, "3UTR", 1, cds_min-1, strand))
    
    return utr_regions

# 主流程
cds_dict = parse_gff(cds_gff)

with open(output_gtf, "w") as out:
    for record in SeqIO.parse(assembly_fasta, "fasta"):
        tid = record.id
        seq_len = len(record.seq)
        
        if tid not in cds_dict:
            continue  # 无CDS预测的序列跳过（可能是非编码）
        
        # 写入gene记录（顶层）
        out.write(f'{tid}\tTransDecoder\tgene\t1\t{seq_len}\t.\t+\t.\tgene_id "{tid}_g"; transcript_id "{tid}";\n')
        
        # 写入transcript记录
        strand = cds_dict[tid][0][2]  # 取第一个CDS的链方向
        out.write(f'{tid}\tTransDecoder\ttranscript\t1\t{seq_len}\t.\t{strand}\t.\tgene_id "{tid}_g"; transcript_id "{tid}";\n')
        
        # 写入5' UTR（如果有）
        utrs = infer_utr(tid, seq_len, cds_dict[tid], strand)
        for utr in utrs:
            tid, utr_type, start, end, s = utr
            if start <= end:  # 有效区域
                out.write(f'{tid}\tTransDecoder\t{utr_type}\t{start}\t{end}\t.\t{s}\t.\tgene_id "{tid}_g"; transcript_id "{tid}";\n')
        
        # 写入CDS（保留原始）
        for start, end, s in cds_dict[tid]:
            out.write(f'{tid}\tTransDecoder\tCDS\t{start}\t{end}\t.\t{s}\t0\tgene_id "{tid}_g"; transcript_id "{tid}";\n')

print(f"输出完成：{output_gtf}")
```

**关键假设**：Trinity组装序列是**全长转录本**，即UTR已包含在组装序列中，只是TransDecoder没注释。

---

## 方法二：基于比对证据补充（更准确）

如果Trinity组装不完整（3'端缺失），需要用**原始reads比对**来推断UTR边界：

### 步骤1：将原始单细胞reads比对回组装序列

```bash
# 建立组装序列索引
minimap2 -d Trinity.mmi Trinity.fasta

# 比对原始reads（用dnbc4tools拆分前的fastq）
minimap2 -ax sr Trinity.mmi reads_R1.fq reads_R2.fq | \
samtools sort -o aligned_to_trinity.bam
samtools index aligned_to_trinity.bam
```

### 步骤2：用比对覆盖度推断UTR边界

```python
#!/usr/bin/env python3
# infer_utr_from_coverage.py

import pysam
from Bio import SeqIO

bam_file = "aligned_to_trinity.bam"
assembly = "Trinity.fasta"
cds_gff = "transcripts.fasta.transdecoder.gff3"
output_gtf = "transcripts_with_UTR_coverage.gtf"

def get_coverage(bam, contig, start, end):
    """获取某区域的reads覆盖度"""
    cov = 0
    for pileup in bam.pileup(contig, start, end):
        cov += pileup.nsegments
    return cov / (end - start + 1) if (end - start) > 0 else 0

def find_utr_boundary(bam, contig, cds_edge, seq_len, direction, strand):
    """
    从CDS边缘向外延伸，找到覆盖度显著下降的点作为UTR边界
    direction: 'upstream' or 'downstream' (相对于转录方向)
    """
    window = 20  # 滑动窗口大小
    threshold = 0.1  # 覆盖度下降阈值（相对于CDS边缘）
    
    if direction == 'upstream':
        # 向5'端搜索
        check_start = max(1, cds_edge - 500)  # 最多延伸500bp
        for pos in range(cds_edge, check_start, -window):
            cov = get_coverage(bam, contig, pos-window, pos)
            if cov < threshold:
                return pos
        return check_start
    else:
        # 向3'端搜索
        check_end = min(seq_len, cds_edge + 500)
        for pos in range(cds_edge, check_end, window):
            cov = get_coverage(bam, contig, pos, pos+window)
            if cov < threshold:
                return pos
        return check_end
    
    return cds_edge  # 默认不延伸

# 主流程（简化版，需结合方法一的GTF写入逻辑）
bam = pysam.AlignmentFile(bam_file, "rb")

for record in SeqIO.parse(assembly, "fasta"):
    tid = record.id
    seq_len = len(record.seq)
    
    # ... 解析CDS位置 ...
    # 用find_utr_boundary()替代简单推断
    # 输出GTF

bam.close()
```

---

## 方法三：使用PASA或CodingQuarry自动补充（推荐）

如果不想手动写脚本，可用专门工具：

### PASA（Program to Assemble Spliced Alignments）

```bash
# PASA可以整合EST比对和TransDecoder预测，自动推断UTR
# 配置
echo "TRINITY_DB transcriptome_db" > pasa.conf

# 运行（需要MySQL或SQLite环境）
Launch_PASA_pipeline.pl \
    -c pasa.conf \
    -C -R \
    -g Trinity.fasta \
    -t transcripts.fasta \
    --transdecoder_gff transcripts.fasta.transdecoder.gff3 \
    --ALT_SPLICE \
    -T \
    -u transcripts.fasta
```

PASA会输出包含UTR的完整GTF：`pasa_assemblies.gff3`

### CodingQuarry（如果PASA太复杂）

```bash
# CodingQuarry专门用于从组装序列预测基因结构（含UTR）
CodingQuarry -f Trinity.fasta -2 reads_R1.fq,reads_R2.fq -p 8
# 输出：out/PredictedPass.gff3（含UTR预测）
```

---

## 验证补充后的GTF质量

```bash
# 1. 检查UTR比例
grep -c "UTR" transcripts_with_UTR.gtf
grep -c "CDS" transcripts_with_UTR.gtf
# UTR记录数应接近CDS数（每个转录本通常有5'和3' UTR）

# 2. 检查GTF格式是否符合dnbc4tools
# dnbc4tools通常要求：gene → transcript → exon/CDS/UTR 层级结构
gtf_to_fasta transcripts_with_UTR.gtf Trinity.fasta test_transcripts.fa
# 如果能正常提取序列，格式基本正确

# 3. 抽样检查单个转录本
grep "your_transcript_id" transcripts_with_UTR.gtf | head -20
# 应看到：gene → transcript → 5UTR → CDS → 3UTR 的连续记录
```

---

## 给dnbc4tools的最终输入格式

dnbc4tools通常需要**基因组的FASTA + GTF**，但你的情况是de novo转录组。需要确认：

```bash
# dnbc4tools是否接受transcriptome作为"参考基因组"
# 通常需要把Trinity.fasta当作"genome.fa"，GTF中的坐标基于这个"基因组"
# 即：每个transcript就是一个"contig/chromosome"

# 修改GTF第一列（seqname）确保与Trinity.fasta的ID完全匹配
# TransDecoder输出通常已匹配，但需检查
```

---

## 总结

| 方法 | 复杂度 | 准确性 | 适用场景 |
|-----|--------|--------|---------|
| **方法一：直接推断** | 低 | 中 | Trinity组装较完整，3'端无明显缺失 |
| **方法二：覆盖度推断** | 中 | 高 | 组装有缺口，需要reads证据 |
| **方法三：PASA/CodingQuarry** | 中 | 高 | 批量处理，自动化程度高 |

**推荐**：如果数据量不大，先用**方法一快速验证**；如果UTR对分析至关重要（如3' UTR变异分析），用**PASA**或**方法二**获取更准确的边界。