# Trinity

## Usage
基于`--samples_file`输入如何构建tab文本
```shell
printf "R\tA\t/data/work/TEST/fq/0A1R_w4q20m35_N_converted_1.fq\t/data/work/TEST/fq/0A1R_w4q20m35_N_converted_2.fq\n" > output.txt
printf "S\tB\t/data/work/TEST/fq/0B1R_w4q20m35_N_converted_1.fq\t/data/work/TEST/fq/0B1R_w4q20m35_N_converted_2.fq\n" >> output.txt
```

非链特异性数据（默认）：不需要额外参数
```shell
Trinity -h

Trinity --seqType fq --left left.fq --right right.fq ...

Trinity --seqType fq \
--max_memory 64G \
--samples_file output.txt \
--CPU 8 \
--output /data/work/TEST/trinity_out
# 链特异性数据：必须添加 --SS_lib_type 参数，并指定reads相对于转录本的方向
```

链特异性数据: 链特异性标识的典型特征——如果建库是链特异性的，read ID 通常会包含类似 YF（正向链）或 YR（反向链）的标记
如何确定方向参数`--SS_lib_type`（RF 还是 FR）？
这是最关键的步骤，也是出错率最高的地方。参数设置错误会导致组装结果几乎完全错误。最常用的建库方法：dUTP 方法。如果你用的是dUTP链特异性建库（目前主流），文库类型为 RF。其他方法（如Ligation法）可能为 FR
```shell
Trinity --seqType fq \
        --max_memory 50G \
        --left reads_1.fq \
        --right reads_2.fq \
        --SS_lib_type RF \       # 关键参数！dUTP法用RF
        --CPU 10 \
        --output trinity_out_dir
```


```shell
$ Trinity -h



###############################################################################
#

     ______  ____   ____  ____   ____  ______  __ __
    |      ||    \ |    ||    \ |    ||      ||  |  |
    |      ||  D  ) |  | |  _  | |  | |      ||  |  |
    |_|  |_||    /  |  | |  |  | |  | |_|  |_||  ~  |
      |  |  |    \  |  | |  |  | |  |   |  |  |___, |
      |  |  |  .  \ |  | |  |  | |  |   |  |  |     |
      |__|  |__|\_||____||__|__||____|  |__|  |____/

    Trinity-v2.15.2


#
#
# Required:
#
#  --seqType <string>      :type of reads: ('fa' or 'fq')
#
#  --max_memory <string>      :suggested max memory to use by Trinity where limiting can be enabled. (jellyfish, sorting, etc)
#                            provided in Gb of RAM, ie.  '--max_memory 10G'
#
#  If paired reads:
#      --left  <string>    :left reads, one or more file names (separated by commas, no spaces)
#      --right <string>    :right reads, one or more file names (separated by commas, no spaces)
#
#  Or, if unpaired reads:
#      --single <string>   :single reads, one or more file names, comma-delimited (note, if single file contains pairs, can use flag: --run_as_paired )
#
#  Or,
#      --samples_file <string>         tab-delimited text file indicating biological replicate relationships.
#                                   ex.
#                                        cond_A    cond_A_rep1    A_rep1_left.fq    A_rep1_right.fq
#                                        cond_A    cond_A_rep2    A_rep2_left.fq    A_rep2_right.fq
#                                        cond_B    cond_B_rep1    B_rep1_left.fq    B_rep1_right.fq
#                                        cond_B    cond_B_rep2    B_rep2_left.fq    B_rep2_right.fq
#
#                      # if single-end instead of paired-end, then leave the 4th column above empty.
#
####################################
##  Misc:  #########################
#
#  --SS_lib_type <string>          :Strand-specific RNA-Seq read orientation.
#                                   if paired: RF or FR,
#                                   if single: F or R.   (dUTP method = RF)
#                                   See web documentation.
#
#  --CPU <int>                     :number of CPUs to use, default: 2
#  --min_contig_length <int>       :minimum assembled contig length to report
#                                   (def=200, must be >= 100)
#
#  --long_reads <string>           :fasta file containing error-corrected or circular consensus (CCS) pac bio reads
#                                   (** note: experimental parameter **, this functionality continues to be under development)
#
#  --genome_guided_bam <string>    :genome guided mode, provide path to coordinate-sorted bam file.
#                                   (see genome-guided param section under --show_full_usage_info)
#
#  --long_reads_bam <string>       :long reads to include for genome-guided Trinity
#                                  (bam file consists of error-corrected or circular consensus (CCS) pac bio read aligned to the genome)
#
#  --jaccard_clip                  :option, set if you have paired reads and
#                                   you expect high gene density with UTR
#                                   overlap (use FASTQ input file format
#                                   for reads).
#                                   (note: jaccard_clip is an expensive
#                                   operation, so avoid using it unless
#                                   necessary due to finding excessive fusion
#                                   transcripts w/o it.)
#
#  --trimmomatic                   :run Trimmomatic to quality trim reads
#                                        see '--quality_trimming_params' under full usage info for tailored settings.
#
#  --output <string>               :name of directory for output (will be
#                                   created if it doesn't already exist)
#                                   default( your current working directory: "/data/work/TEST/trinity_out_dir" 
#                                    note: must include 'trinity' in the name as a safety precaution! )
#  
#  --full_cleanup                  :only retain the Trinity fasta file, rename as ${output_dir}.Trinity.fasta
#
#  --cite                          :show the Trinity literature citation
#
#  --verbose                       :provide additional job status info during the run.
#
#  --version                       :reports Trinity version (Trinity-v2.15.2) and exits.
#
#  --show_full_usage_info          :show the many many more options available for running Trinity (expert usage).
#
#
###############################################################################
#
#  *Note, a typical Trinity command might be:
#
#        Trinity --seqType fq --max_memory 50G --left reads_1.fq  --right reads_2.fq --CPU 6
#
#            (if you have multiple samples, use --samples_file ... see above for details)
#
#    and for Genome-guided Trinity, provide a coordinate-sorted bam:
#
#        Trinity --genome_guided_bam rnaseq_alignments.csorted.bam --max_memory 50G
#                --genome_guided_max_intron 10000 --CPU 6
#
#     see: /opt/software/miniconda3/envs/optdntra/bin/sample_data/test_Trinity_Assembly/
#          for sample data and 'runMe.sh' for example Trinity execution
#
#     For more details, visit: http://trinityrnaseq.github.io
#
###############################################################################
```

## Workflow
> - 总结一下：你的覆盖度过高问题，主要应归咎于PCR重复或高丰度RNA，而非接头污染。建议先通过FastQC报告确认接头情况，然后将重心放在去除重复序列上，这很可能直接解决你的问题
> - 备选方案：如果你的确是RNA-seq数据，在Trinity组装前，应使用sortmerna或bowtie2等工具去除rRNA。如果去除rRNA后问题依旧，再考虑去重。
> - 确认rRNA含量：建议先用比对工具（如Bowtie2或STAR）将你的reads比对到该植物的rRNA参考序列上（如果不知道具体物种，可以选用近缘种或通用的植物rRNA序列）。如果比对率超过50%，就证实了rRNA是“元凶”之一 `/Files/ReferenceData/Database/plant_ref_rRNA/plant_rRNA.fa`

fastqc (optional seqtk) fastp fastqc trinity optdntra
```shell
# 进入存放fastq文件的目录
cd /data/work/TEST/fq

# 为当前目录下所有以 .fq 或 .gz 结尾的文件运行fastqc
fastqc *.fq *.gz

# 在包含所有fastqc报告的目录中运行
multiqc ./



#!/bin/bash

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

cd ./cleaned_data
# 为当前目录下所有以 .fq 或 .gz 结尾的文件运行fastqc
fastqc *.fq *.gz

# 在包含所有fastqc报告的目录中运行
multiqc ./



fastp -i R1.fastq.gz -I R2.fastq.gz \
-o clean_R1.fastq.gz -O clean_R2.fastq.gz \
--detect_adapter_for_pe \       # 双端自动检测接头
--cut_front --cut_tail \        # 滑动窗口切除首尾低质量碱基
--cut_window_size 4 \           # 窗口大小为4bp # default: 4 (int [=4])
--cut_mean_quality 20 \         # 窗口平均质量低于20则切除 # Range: 1~36 default: 20 (Q20) (int [=20])
--length_required 15 \          # 丢弃长度小于50bp的reads # default is 15. (int [=15])
--average_qual 20 \             # 整条reads平均质量低于20则丢弃 # Default 0 means no requirement
--correction \                  # 通过重叠区校正碱基
--thread 8 \                    # 启用8线程
--html report.html \            # 输出网页报告
--json report.json              # 输出JSON数据


# 为什么加 --no_normalize_reads 能解决？标准化步骤对长度一致性要求严格，跳过即可
Trinity --seqType fq \
--left /data/work/TEST/test/cleaned_data/0A1R_w4q20m35_N_clean_R1_converted.fastq.gz \
--right /data/work/TEST/test/cleaned_data/0A1R_w4q20m35_N_clean_R2_converted.fastq.gz \
--no_normalize_reads \
--max_memory 64G --CPU 4 --output /data/work/TEST/trinity_out


```



## Q&A
>   - YYY数据是双端测序？是否做过fq质控？是否链特异性建库？（如果是其建库方法是什么）
>   - /Files/RawData/ML150007317_L01

> 对于老版本的测序数据，其质量分数体系可能已经被废弃，例如景天的RNAseq数据，我们需要先用`fastqc`看一下encoding的模式，然后确定是否要用`seqtk`做模式转换。






## references
- 转录组无参比对教程 | Trinity https://mp.weixin.qq.com/s/UAnaiSMxrUeI6bBGnfIcZQ
- Trinity 实战指南：无参考转录组组装从原理到实操 https://mp.weixin.qq.com/s/1GZBS58SY2UnBwY29rHj0w
- 转录组⑦｜RNA-seq数据预处理 https://mp.weixin.qq.com/s/mD81EtJevp-l8I1DTnpGZg
  > - 原始 FASTQ 的质量、接头污染、rRNA 残留、重复率、GC 偏倚
  > - 预处理宗旨很简单：把可控的噪声挡在流程入口。我们将按“质量控制 → 接头去除/低质修剪 → rRNA 过滤（可选）→ 复查”的顺序，给出可落地的做法与判读要点
- 生信必备工具解析：SortMeRNA——高效剔除rRNA的“数据清道夫” https://mp.weixin.qq.com/s/Ny-Qf7Q0jBbvwMW4Y0-agQ
- [转录组系列](https://mp.weixin.qq.com/mp/appmsgalbum?__biz=MzU5MDAwODY2MA==&action=getalbum&album_id=4159313145078710284&subscene=7&scenenote=https%3A%2F%2Fmp.weixin.qq.com%2Fs%3Fsearch_click_id%3D12586838283104133470-1776760940937-3746692244%26__biz%3DMzU5MDAwODY2MA%3D%3D%26mid%3D2247483961%26idx%3D1%26sn%3D56ce69f9c2446c50f5e04a065e249674%26chksm%3Dfcca1a22934043408b33f6a45e2e847e9c5fffffaf2b5c16ec174487ac912babb8b802f9781f%26scene%3D7%26key%3Ddaf9bdc5abc4e8d0dc48ecac6349e2f7a533c52deb023536a58b02af7f80d74ba1f1ea3007a57439dc904a706c05bdfeecc4476cb41eb35437c98255b7216ce5617f61e646368722cedb9f3261cc87fbda4e27e9c76ed1f9b8cb97b0d97e550914659d023102201ea2035e8e7d0dc4c7fd383b77376d22b7dfc197b39d48f15d%26ascene%3D7%26uin%3DNDIxMzk4MTk3%26devicetype%3DUnifiedPCWindows%26version%3Df2541917%26lang%3Den%26countrycode%3DCN%26exportkey%3Dn_ChQIAhIQFI%252FEQB2WIAm7ZjePKidsXhLlAQIE97dBBAEAAAAAAAcGCkXepXgAAAAOpnltbLcz9gKNyK89dVj0G5lOEkqQRRbGfOlPMCQy9ylAtCGGeZKjcnOcNAZ4UEZYg%252FZbbQ8OjT%252Fxn69btm2rxQvsDJQ8DBSyuzwnTPohzKjCAQRK3IEZIuR%252Bi%252BYIPsidzNvxl2I3vE4exQYq77ZJK2YbhCGLpSKQz79tfLgNvNMD1M64NQ9SW%252BFWnoJOZL0T6Xi1jpnedQlXLLzMfsTlU6W0KX5awX8Umr8q5iIVs%252FEh4qb64jpbFgQ%252BZo3fk3DrT2t67uTSTPJ6BXu1Gho%253D%26acctmode%3D0%26pass_ticket%3D57trCZ7iw7V%252BVNVXQsTydhLc7HyydIPjqX1UjRgIiLB%252BJJ5lqeXyQwhoiDF2kKVa%26wx_header%3D0&nolastread=1&sessionid=#wechat_redirect)
- RNAseq上游分析全流程详解 https://mp.weixin.qq.com/s/ieqYQwabaYzu62wC6z9stQ

<details> <summary> 链特异性建库的方法和优势 </summary>

这是一个很深入的问题。理解链特异性建库的原理，能帮你从根本上明白为什么Trinity需要`--SS_lib_type`参数，以及设错参数为什么会导致结果完全错误。

简单来说，链特异性建库的核心就是**在测序文库中，给原始RNA的“方向”做一个永久性的化学标记**，使得最终测出的序列能区分它来自基因的正义链还是反义链。

### 🧬 链特异性建库是如何实现的？

目前主流的方法是**dUTP法**，它巧妙地利用了碱基替换。

1.  **反转录**：用随机引物将RNA反转录成cDNA。此时，cDNA第一链的方向与原始RNA是反向互补的。
2.  **合成第二链**：在合成cDNA第二链时，用**dUTP**（脱氧尿苷三磷酸）来替代一部分dTTP（脱氧胸苷三磷酸）。这使得**第二链cDNA中掺入了尿嘧啶（U）**，而第一链没有。
3.  **选择性降解**：使用**UDG酶（尿嘧啶-DNA糖基化酶）**，它会特异性地识别并降解含有尿嘧啶（U）的cDNA链。
4.  **最终结果**：含有U的第二链cDNA被降解，只剩下**第一链cDNA**。文库中最终保留的，是**与原始RNA方向互补的第一链cDNA**。测序时，Read1就从这个第一链开始测。

> **你的数据对应的参数 `RF`，正是源于此**：
> 在dUTP法中，最终测得的Read1与原始RNA链方向**相反 (Reverse)**，而Read2与之方向**相同 (Forward)**，因此Trinity的参数是 `RF`。

### 🧩 这个方向标记如何影响Trinity组装？

Trinity在组装时，会利用这个化学标记的信息来构建一个**有向的De Bruijn图**。这个“方向”信息，是它解决以下三大难题的关键。

#### 1. 区分基因组上重叠的转录本（反义转录）
这是最大的影响。在没有方向信息时，Trinity会把来自不同链的reads当成同一个基因的reads来组装，产生错误的“嵌合体”。

-   **无链特异性**：Trinity看到来自两条链的reads，会把它们“揉”在一起，强行拼成一个假基因。
-   **有链特异性**：Trinity能根据方向信息，清晰地将来自不同链的reads分开，各自组装成独立的、正确的转录本。

#### 2. 准确识别真正的反义转录本
反义RNA是真核生物中重要的调控分子。没有链特异性信息，Trinity就无法区分一个反义转录本是真实的调控RNA，还是实验污染或组装错误，导致真实的反义RNA被埋没或被错误注释。

#### 3. 精确定量转录本表达量
这是Trinity下游分析中至关重要的一环。表达量定量需要将reads准确地“归属”到其来源的转录本上。

-   **无链特异性**：由于不知道reads的方向，软件无法区分一个重叠区域里的read到底属于哪个基因，导致定量结果不准确。
-   **有链特异性**：软件可以明确地将一个read分配给正义链或反义链上的基因，从而实现**独立、无干扰的定量**。

### 💎 总结

-   **建库本质**：通过**化学方法（dUTP标记+酶切）**，选择性地只保留cDNA第一链，从而永久性地标记了转录本的方向。
-   **对组装的影响**：这个方向标记是Trinity的“导航地图”。它帮助算法：
    -   **分得清**：区分并正确组装来自不同链的重叠转录本。
    -   **看得见**：识别和重建真实的、具有调控功能的反义RNA。
    -   **算得准**：为下游的基因和转录本表达定量提供无干扰的数据。

因此，对于链特异性数据，正确设置`--SS_lib_type RF`参数不是“建议”，而是**必要条件**。它能将“混乱的二维信息”转化为“有序的三维结构”，是保证后续所有分析正确性的基石。

</details>


<details> <summary> 链特异性确定 </summary>

知道链特异性方向是 Trinity 组装中最关键的一步，这个参数一旦设错，可能会导致组装出的转录本数量极少、长度极短，或者表达量估计完全错误。

要确定方向，有三种方法，最推荐的方案是“**先问清楚，再验证确认**”。

### 🔎 方法一：直接询问实验人员（最可靠）

这是最直接、最不容易出错的方法。直接联系建库或测序的负责人，问清楚一个问题即可：

> **“文库是用 dUTP 方法构建的吗？”**

*   **如果回答“是”**：那么 99% 的情况，你在 Trinity 中应设置参数为 **`--SS_lib_type RF`**。
*   **如果回答“否”或不确定**：你需要进一步追问具体的建库试剂盒名称，或直接采用下面的方法二进行验证。

> **一个简单的记忆方法**：目前绝大多数主流链特异性文库都采用 dUTP 方法，对应的 Trinity 参数就是 **`RF`**。

### 🛠️ 方法二：用 Trinity 自带脚本验证（最准确）

如果你无法从实验人员那里获得确切信息，或者想对自己下载的公共数据（如 SRA 数据）进行确认，Trinity 提供了一个非常可靠的验证脚本。

这个方法的原理是：先用默认（非链特异性）方式跑一个**迷你版的组装**，然后将你的 reads 比对回去，通过分析比对的方向来推断文库类型。虽然需要一些计算时间，但结果是决定性的。

**具体步骤如下：**

1.  **准备一个小数据集**：从你的原始数据中随机提取 20-50 万对 reads 用于测试。
2.  **运行 Trinity（暂时不加链特异性参数）**：用这个小数据集进行一个快速组装。
    ```bash
    # 使用小数据集，不加 --SS_lib_type 参数
    Trinity --seqType fq --max_memory 20G --left test_R1.fq --right test_R2.fq --CPU 4 --output trinity_test
    ```
3.  **将 reads 比对回组装结果**：使用 Bowtie2 将你用来组装的 reads 比对到刚生成的 `Trinity.fasta` 上。
4.  **运行检查脚本**：使用 Trinity 自带的 `examine_strand_specificity.pl` 脚本分析比对结果。
    ```bash
    $TRINITY_HOME/util/misc/examine_strand_specificity.pl bowtie2.coordSorted.bam
    ```
5.  **解读结果**：这个脚本会生成一个“小提琴图”（violin plot）。你需要观察图形的形状：
    *   **如果图形像一个“哑铃”或“蝴蝶结”**，中间低、两头高，这说明你的数据是**链特异性的**。此时再看 X 轴，如果主要峰在 “+” 或 “-” 一侧，则可判断具体方向。
    *   **如果图形像一个“倒U形”或“山峰”**，中间高、两头低，这说明你的数据是**非链特异性的**，不需要设置 `--SS_lib_type` 参数。

### 📖 方法三：根据建库原理推断（背景知识）

如果你了解建库原理，也可以根据下表进行推断。但此方法依赖于你对实验流程的准确了解，不如前两种方法直接。

| 建库方法/试剂盒 | 对应的链特异性类型 | Trinity 参数 (`--SS_lib_type`) |
| :--- | :--- | :--- |
| **dUTP, NSR, NNSR** | **链特异性 (fr-firststrand)** | **`RF`** (最常用)  |
| Ligation, Standard SOLiD | 链特异性 (fr-secondstrand) | `FR`  |
| Standard Illumina | 非链特异性 (fr-unstranded) | 无需设置 (或设置为 `--no_strand_check`)  |

> **关于 RF 的含义**：`RF` 代表 R1 read 与转录本方向**相反 (Reverse)**，而 R2 read 方向**相同 (Forward)**。这是 dUTP 文库的典型特征。你只需要知道 Trinity 的参数应该设置为 `RF` 即可，软件内部会自动处理。

### 💎 总结与建议

1.  **首选方案**：直接问实验人员是否是 dUTP 建库。如果是，就放心地用 `--SS_lib_type RF`。
2.  **验证方案**：如果无法确定，或者想对结果负责，一定要用 **方法二** 的 Trinity 官方脚本进行验证。虽然多花点时间，但能避免“结果全错”的风险。

确认方向后，就可以将它加到你的 Trinity 命令里了：
```bash
Trinity --seqType fq --left left.fq --right right.fq --SS_lib_type RF --CPU 10 --max_memory 50G --output trinity_out
```

</details