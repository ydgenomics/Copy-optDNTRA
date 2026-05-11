# [optDNTRA](https://github.com/zywu2002/optDNTRA)

- batch模式下的1-procession会有问题，后面debug

to-do
- data # 10A2R有问题，则只有B的数据，即两个组织两个镉处理即2x2
- check-fq 排队fq数据的序列名一定要一一对应，只接受末尾的差别/1和/2
- fq-qc 对原始的二代fq数据进行质控 fastqc-fastp-fastqc-multiqc
  > - 做好输出的记录，log file
- clean-fq 可选去除环境污染和rRNA，以减少组装的复杂度和资源消耗
  - "/Files/ReferenceData/Database/plant_ref_rRNA/plant_rRNA.fa"
  - 植物的rRNA在各个物种的保守性如何？
  > - 也要重命名，sortmerna的后缀不是_1和_2
- assemble-trinity 无参考de novo组装
  > - 组装后对Trinity.fasta做重命名，解决多.的问题，另外添加'_'check，序列名存在_则全部替换为-，规避后续Seurat的问题
  `sed -i '/^>/s/_/-/g' trinity.fasta`
- clean-rrna 组装之后拿到Trinity.fasta，一条序列一个名字，通过比对去掉rrna的序列，设置一个cutoff (bowtie2?)
- optdntra 去冗余、组装质量评估和功能注释
  > - 文件名只能包含后缀的一个.
  > - batch模式不要参数`--trim` & `--qc`
- transdecoder-gffread 拿到结构注释的gtf文件用于后面跑dnbc4


## Note
- agat 解决gffread转换gff为gtf时类别丢失的问题
- seqkit解决fastp处理后存在非配对reads的情况，其实fastp自带参数保证reads配对``
- seqtk用于随机取fq的reads，提供小样本的测试文件
- transcript, exon, CDS：transcript一般包括exon和intron，exon一般和CDS是一致的，但是因为存在两端的UTR区域，exon存在大于CDS的情况，包含UTR注释的gtf，可以有利于转录本定量比对，因为转录本捕获依赖于polyA，那么3UTR的注释有利于提高比对率
- 对Trinity组装后的结果运行transdecoder，其注释到的$3类型包含transcript，exon和CDS这三类，测试dnbc4tools的build-index是可以运行的
- optDNTRA不能只输入fq.gz，必须事先用trinity组装一版出来
- Trinity多样本组装可以使用`--samples_file`的tab分隔的文本文件传递，也可以选择在`--left`和`--right`多个文件通过`,`连接来跑
- multiqc默认是去寻找报告文件，可以指定文件夹，也可以指定多个具体的文件通过" "连接，最后输出的是一个中间文件目录`multiqc_data`和`multiqc_report.html`。MultiQC报告中显示的 Seqs 列，通常来源于其集成的 FastQC 工具。而 FastQC 为了计算效率，默认只分析每个测序文件的前 100,000 到 200,000 条 reads
- fastqc也是可以指定多个文件通过空格连接来跑
- de novel transcriptome assemble: 无参考转录组组装
  > - 1)转录组数据能够提供高质量的编码序列，用于同源基因鉴定、基因家族扩张与收缩分析，以及跨物种功能注释比对; 2)即便已有基因组序列，转录组仍可用于优化注释、补充低表达或组织特异基因，提高比较分析的准确性; 3)在系统发育研究中，转录组组装为筛选直系同源基因和构建大规模核基因数据矩阵提供关键资源。
  > - ~1GB 内存 / 百万条 reads（100bp）
- 云平台跑trinity流程，双端碱基共10G的数据，最大占用内存约为110G，运行时间大约3天，注意是normalize_read的模式，如果选了--no_normalize的话内存会激增，这也是前几次运行内存常常不够的原因。

## References
- Trinity 实战指南：无参考转录组组装从原理到实操 [wechat](https://mp.weixin.qq.com/s/1GZBS58SY2UnBwY29rHj0w)
- 组装出的转录本太多，咋办？[wechat](https://mp.weixin.qq.com/s/6fT53eTED375OlsepdqmFw)
- 转录组的组装|三种方式 [wechat](https://mp.weixin.qq.com/s/6exQwZefVkyLI1unI4XvMA)
- 转录组无参比对教程 | Trinity https://mp.weixin.qq.com/s/UAnaiSMxrUeI6bBGnfIcZQ
- 2026 | Genome Biology | 三代测序无参转录组组装哪家强？ [wechat](https://mp.weixin.qq.com/s/p32k2lDOXzBOczqiAElhlw)
- 生信软件| 一文拿捏2种gff/gtf格式转换工具 https://mp.weixin.qq.com/s/japP5gZYOtgJXQCevduIKw
- https://biohpc.cornell.edu/lab/doc/trinity_workshop_part1.pdf
- https://training.galaxyproject.org/training-material/topics/transcriptomics/tutorials/full-de-novo/tutorial.html
- 2022 | https://academic.oup.com/bib/article/23/2/bbab563/6514404
- 长文解析！de novo转录组组装和注释的简单指南（一）：下机数据质控、转录组组装和组装后质控 https://mp.weixin.qq.com/s/C_wvVsaVDgum5u0bgY9OlA
- 2022 生信宝库推荐 | RiboDetector：高通量测序数据鉴别和去除rRNA序列利器 https://mp.weixin.qq.com/s/EJb9UsorqwZzXkxXJU5LCw



## Env

**install mamba**
```shell
conda update -n base -c defaults conda -y
conda install -n base -c conda-forge mamba -y
```

**build optdntra**
```shell
cd / && git clone --depth 1 https://github.com/ydgenomics/Copy-optDNTRA.git
source /opt/software/miniconda3/bin/activate
mamba env create -n optdntra -f ./Copy-optDNTRA/environment.yml -y
conda activate optdntra
export PATH=/Copy-optDNTRA:$PATH && optDNTRA.py -h
conda create -n tool gffread multiqc sortmerna agat seqkit -y
```

## fq
```shell
$ less 0A1R_clean_1.fq.gz | head -n 2
@HWI-ST507:81:B0605ABXX:5:1101:1244:2125:1:1:0:ATCACG:1
TTGAAACTTGAAAGCAGTGAAGCACACTTACACACAGGTACGCAAAAGGAACTT
```

好的，我来详细解释这个 FASTQ 序列名的含义。

## 序列名完整解析

```
@HWI-ST507:81:B0605ABXX:5:1101:1244:2125:1:1:0:ATCACG:1
```

这是标准的 **Illumina Casava 1.8+** 格式的序列标识符，各个字段用冒号 `:` 分隔。

| 字段 | 示例值 | 含义 |
|------|--------|------|
| **仪器** | `HWI-ST507` | 测序仪ID (HiSeq 2000) |
| **运行ID** | `81` | 流动槽上的运行编号 |
| **流动槽ID** | `B0605ABXX` | 流动槽唯一标识 |
| **泳道号** | `5` | 流动槽上的泳道编号 (1-8) |
| **Tile编号** | `1101` | 流动槽上的tile坐标 |
| **X坐标** | `1244` | 簇在tile上的X坐标 |
| **Y坐标** | `2125` | 簇在tile上的Y坐标 |
| **配对成员** | `1` | **双端标识**: 1=R1, 2=R2 |
| **过滤状态** | `1` | 1=通过过滤, 0=未通过 |
| **控制位** | `0` | 0=常规read |
| **Index序列** | `ATCACG` | 样本index/barcode |
| **Read编号** | `1` | 该read在lane中的序号 |

最关键的是第8个字段（配对成员）
- **值为 `1`**: 这是 Read 1 (正向/左端)
- **值为 `2`**: 这是 Read 2 (反向/右端)

```bash
# 正确配对检查：比较除第8字段外的所有字段
zcat 0A1R_clean_1.fq.gz | head -n 1 | cut -d: -f1-7
zcat 0A1R_clean_2.fq.gz | head -n 1 | cut -d: -f1-7
```

### 2. **为什么你的 seqkit pair 失败**

`seqkit pair` 默认要求整个ID（包括第8字段）除了末尾的 `/1`、`/2` 外完全相同。但你的数据中**第8字段也不同**（1 vs 2），所以被判定为不匹配。

### 3. **如何修复供 seqkit 使用**

需要将 R2 的第8字段改为1，使其与 R1 的第8字段一致：

```bash
zcat /data/work/TEST/test/0A1R_clean_2.fq.gz | \
sed 's/^\(@\([^:]*:\)\{7\}\)[^:]*/\11/' | \
gzip > /data/work/TEST/test/0A1R_clean_1_modified.fq.gz
```


## Run
```shell
source /opt/software/miniconda3/bin/activate && conda activate optdntra
export PATH=/data/work/optDNTRA:$PATH
optDNTRA.py \
--config /data/work/optDNTRA/defaults.yml \
--transcript /data/work/optDNTRA/test_data/trinity.fasta \
--left /data/work/optDNTRA/test_data/reads_1.fq.gz \
--right /data/work/optDNTRA/test_data/reads_2.fq.gz \
--outDir /data/work/optDNTRA_out1 \
--trim \
--qc \
--omarkAsmt \
--buscoAsmt \
--emapperAnno \
--threads 8
```

[Get .gff3 from transcript.fasta](https://github.com/TransDecoder/TransDecoder/wiki#running-transdecoder)
```shell
# By default, TransDecoder extracts ORFs that are at least 100 amino acids long. You can lower this via -m, but the false positive rate increases substantially as the minimum length drops.
TransDecoder -t target_transcripts.fasta -m 100 --single_best_only -O transdecoder_outdir
# The final set of candidate coding regions is written as *.transdecoder.* files, including .pep, .cds, .gff3, and .bed.

agat_convert_sp_gff2gtf.pl
```