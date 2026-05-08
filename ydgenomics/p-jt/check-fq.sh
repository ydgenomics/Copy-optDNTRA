# Casava 1.8+
# @<instrument>:<run>:<flowcell>:<lane>:<tile>:<x>:<y>:<pair>:<filtered>:<control>:<index>
# @HWI-ST507:81:B0605ABXX:5:1101:1244:2125:1:1:0:ATCACG:1
# @HWI-ST507:81:B0605ABXX:5:1101:1244:2125:2:1:0:ATCACG:2

# 10A2R有问题，则只有B的数据，即两个组织两个镉处理即2x2

#!/bin/bash

# 定义数组
fq_1_list=('/data/input/Files/yangdong/P/p-jintian/SP_reads_data/0B1R_w4q20m35_N_1.fq' 
           '/data/input/Files/yangdong/P/p-jintian/SP_reads_data/0B1S_w4q20m35_N_1.fq'
           '/data/input/Files/yangdong/P/p-jintian/SP_reads_data/10B2R_w4q20m35_N_1.fq'
           '/data/input/Files/yangdong/P/p-jintian/SP_reads_data/10B2S_w4q20m35_N_1.fq'
           )
sample_list=('0B_R' '0B_S' '10B_2R' '10B_2S')

# 循环处理每个样本
for i in "${!fq_1_list[@]}"; do
    fq_1="${fq_1_list[$i]}"
    sample="${sample_list[$i]}"
    
    cp $fq_1 "${sample}_1.fq"

    # 修改fastq的header并输出到新文件
    sed -i '1~4s/^\(@[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*\).*/\1\/1/' "${sample}_1.fq"
    
    echo "处理完成: ${fq_1} -> ${sample}_1.fq"

    grep '^@' "${sample}_1.fq" | grep -c -v -E '.*/(1|2)$'
done


fq_2_list=('/data/input/Files/yangdong/P/p-jintian/SP_reads_data/0B1R_w4q20m35_N_2.fq' 
           '/data/input/Files/yangdong/P/p-jintian/SP_reads_data/0B1S_w4q20m35_N_2.fq'
           '/data/input/Files/yangdong/P/p-jintian/SP_reads_data/10B2R_w4q20m35_N_2.fq'
           '/data/input/Files/yangdong/P/p-jintian/SP_reads_data/10B2S_w4q20m35_N_2.fq'
           )
sample_list=('0B_R' '0B_S' '10B_2R' '10B_2S')

for i in "${!fq_2_list[@]}"; do
    fq_2="${fq_2_list[$i]}"
    sample="${sample_list[$i]}"

    cp $fq_2 "${sample}_2.fq"
    
    # 处理 R2: 匹配到第 7 位坐标后，不管后面是什么，统一改为 /2
    sed -i '1~4s/^\(@[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*:[^:]*\).*/\1\/2/' "${sample}_2.fq"
    
    echo "处理完成: ${fq_2} -> ${sample}_2.fq"

    grep '^@' "${sample}_2.fq" | grep -c -v -E '.*/(1|2)$'
done