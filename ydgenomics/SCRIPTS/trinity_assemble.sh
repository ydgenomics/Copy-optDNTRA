# 转录组无参比对教程 | Trinity https://mp.weixin.qq.com/s/UAnaiSMxrUeI6bBGnfIcZQ
source /opt/software/miniconda3/bin/activate && conda activate optdntra

fq_left=/data/work/TEST/fq/*_1.fq
for fq_1 in $fq_left; do
    echo "process: ${fq_1}"
    perl -i -pe 's/:1$/\/1/ if /^@/' "$fq_1"
    head $fq_1
done

fq_right=/data/work/TEST/fq/*_2.fq
for fq_2 in $fq_right; do
    echo "process: ${fq_2}"
    perl -i -pe 's/:2$/\/2/ if /^@/' "$fq_2"
    head $fq_2
done


group_str="R,S"
sample_str="A,B"
fq_left_str="/data/work/TEST/leaf_r1_1.fq.gz,/data/work/TEST/leaf_r1_2.fq.gz"
fq_right_str="/data/work/TEST/leaf_r2_1.fq.gz,/data/work/TEST/leaf_r2_2.fq.gz"

IFS=',' read -r -a group_list <<< "$group_str"
IFS=',' read -r -a sample_list <<< "$sample_str"
IFS=',' read -r -a fq_left_list <<< "$fq_left_str"
IFS=',' read -r -a fq_right_list <<< "$fq_right_str"


length=${#group_list[@]}
for ((i=0; i<$length; i++)); do
    group=${group_list[$i]}
    sample=${sample_list[$i]}
    fq_l=${fq_left_list[$i]}
    fq_r=${fq_right_list[$i]}
    echo "正在处理组: $group, 样本: $sample"
    echo "左端文件: $fq_l"
    echo "右端文件: $fq_r"
    echo "--------------------------"
    if [ $i -eq 0 ]; then
        printf "${group}\t${sample}\t${fq_l}\t${fq_r}\n" > output.txt
    else
        printf "${group}\t${sample}\t${fq_l}\t${fq_r}\n" >> output.txt
    fi
done

Trinity --seqType fq \
--max_memory 64G \
--samples_file output.txt \
--CPU 8 \
--no_normalize_reads \
--output trinity_out



FQ_ARRAY=~{sep="," fq_list}
IFS=',' read -ra ARR <<< "$FQ_ARRAY"
read -r left_read right_read <<< "${ARR[0]} ${ARR[1]}"
echo $left_read && echo $right_read

optDNTRA.py \
--config /Copy-optDNTRA/defaults-dcs.yml \
--transcript /Copy-optDNTRA/test_data/trinity.fasta \
--sampleSheet optdntra.tsv \
--outDir optDNTRA_out1 \
--trim \
--qc \
--omarkAsmt \
--buscoAsmt \
--threads 8

ls /data/input/Files/SP_reads_data
# qc
fastp -i raw_1.fq.gz -I raw_2.fq.gz \
-o clean_1.fq.gz -O clean_2.fq.gz \
-t 8 -f 15 \
-h fastp.html -j fastp.json

/data/work/TEST/optdntra.tsv
# trinity assembly
Trinity -seqType fq \
--max_memory 64G \
--left clean_1.fq.gz \
--right clean_2.fq.gz \
--CPU 16 \
--output trinity_out_dir


Trinity --seqType fq \
 --max_memory 64G \
 --samples_file /data/work/TEST/optdntra.tsv \
 --CPU 6 \
 --output /data/work/TEST/trinity_out_dir

# 统计转录本信息
TrinityStats.pl Trinity.fasta