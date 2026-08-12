awk -F'\t' '{
    # 提取染色体（第1列）
    chr = $1
    
    # 从第9列提取gene_id
    match($9, /gene_id "([^"]+)"/, arr)
    gene = arr[1]
    
    if(chr && gene) print chr "\t" gene
}' /data/input/Files/User/yangdong/P/p-jintian/assemble2/transcript.flt.final.fa.transdecoder.gffread.gtf | sort -u > chromosome_gene_mapping.txt

awk '
NR==FNR {
    map[$1]=$2; 
    total_map++
    next
}
/^>/ {
    id=substr($0, 2); 
    if (id in map) {
        print ">" map[id]
        matched++
    } else {
        unmatched++
        # 如果想查看未匹配的ID，取消下面一行的注释
        # print "Unmatched: " id > "/dev/stderr"
    }
    keep=id in map
    next
}
!/^>/ && keep {
    print
}
END {
    print "=== 统计结果 ===" > "/dev/stderr"
    print "映射文件总条目数: " total_map > "/dev/stderr"
    print "FASTA文件总序列数: " (matched + unmatched) > "/dev/stderr"
    print "成功匹配的序列数: " matched > "/dev/stderr"
    print "未匹配的序列数: " unmatched > "/dev/stderr"
    print "匹配率: " (matched / (matched + unmatched) * 100) "%" > "/dev/stderr"
}
' /data/work/chromosome_gene_mapping.txt /data/input/Files/User/yangdong/P/p-jintian/assemble2/transcript.flt.final.pep > renamed_transcript_filtered.pep


awk '
NR==FNR {
    map[$1]=$2; 
    total_map++
    next
}
/^>/ {
    id=substr($0, 2); 
    if (id in map) {
        print ">" map[id]
        matched++
    } else {
        unmatched++
        # 如果想查看未匹配的ID，取消下面一行的注释
        # print "Unmatched: " id > "/dev/stderr"
    }
    keep=id in map
    next
}
!/^>/ && keep {
    print
}
END {
    print "=== 统计结果 ===" > "/dev/stderr"
    print "映射文件总条目数: " total_map > "/dev/stderr"
    print "FASTA文件总序列数: " (matched + unmatched) > "/dev/stderr"
    print "成功匹配的序列数: " matched > "/dev/stderr"
    print "未匹配的序列数: " unmatched > "/dev/stderr"
    print "匹配率: " (matched / (matched + unmatched) * 100) "%" > "/dev/stderr"
}
' /data/work/chromosome_gene_mapping.txt /data/input/Files/User/yangdong/P/p-jintian/assemble2/transcript.flt.final.fa > renamed_transcript_filtered.fa