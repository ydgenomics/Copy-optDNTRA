# Get .gff3 from transcript.fasta](https://github.com/TransDecoder/TransDecoder/wiki#running-transdecoder)
source /opt/software/miniconda3/bin/activate && conda activate optdntra
# By default, TransDecoder extracts ORFs that are at least 100 amino acids long. You can lower this via -m, but the false positive rate increases substantially as the minimum length drops.
# TransDecoder -t /data/work/optDNTRA_out1/results/02-optimization/03-transEvidence/transcript.flt.final.fa -m 100 --single_best_only -O transdecoder_outdir
# The final set of candidate coding regions is written as *.transdecoder.* files, including .pep, .cds, .gff3, and .bed.

# 是的，两个命令的 -O 参数必须指向同一目录
TransDecoder.LongOrfs -t /data/work/optDNTRA_out1/results/02-optimization/03-transEvidence/transcript.flt.final.fa \
    -m 100 \
    -O transdecoder_outdir

TransDecoder.Predict -t /data/work/optDNTRA_out1/results/02-optimization/03-transEvidence/transcript.flt.final.fa \
    --single_best_only \
    -O transdecoder_outdir

# gffread 默认丢弃 gene 和 mRNA，只保留最底层的 exon/CDS，并将 mRNA 重命名为 transcript
gffread \
/data/users/yangdong/yangdong_5f5c3933d7c44a73bff0cbff6fd8db86/online/test/transdecoder_outdir/transcript.flt.final.fa.transdecoder.gff3 \
-T \
-o transdecoder.gtf

# 使用 gffread 的 -C 选项（保留编码序列完整结构）
gffread \
/data/users/yangdong/yangdong_5f5c3933d7c44a73bff0cbff6fd8db86/online/test/transdecoder_outdir/transcript.flt.final.fa.transdecoder.gff3 \
-C \
-T \
-o transdecoder.gtf