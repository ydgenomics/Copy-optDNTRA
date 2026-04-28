
version 1.0
workflow Hello{
  input{
    File fastq_1
    File fastq_2
    File rna_fa
    String sampleid
    Int threads
    Int cpu
    Int mem
  }
  call sortmerna{
    input:
    fastq_1=fastq_1,
    fastq_2=fastq_2,
    rna_fa=rna_fa,
    sampleid=sampleid,
    threads=threads,
    cpu=cpu,
    mem=mem,
  }
  call assess_rna{
    input:
    fastq_1=fastq_1,
    fastq_2=fastq_2,
    rna_fa=rna_fa,
    sampleid=sampleid,
  }
  output{
    File result=assess_rna.result
    File fq_1=sortmerna.fq_1
    File fq_2=sortmerna.fq_2
    File result2=sortmerna.result
  }
}
task assess_rna{
  input {
    File fastq_1
    File fastq_2
    File rna_fa
    String sampleid
  }
  command {
    sh /Copy-optDNTRA/ydgenomics/RNA/assess_rrna.sh \
    ~{fastq_1} ~{fastq_2} ~{rna_fa} 10000 ~{sampleid} 2>&1 | tee assess_rna.log
  }
  runtime {
    docker_url: "stereonote_hpc/yangdong_50b2433e483b4008a87e4c63648144be_private:latest"
    req_cpu: 4
    req_memory: "32Gi"
  }
  output {
    File result = "./sortmerna_out/~{sampleid}_rRNA.log"
  }
}

task sortmerna{
  input {
    File fastq_1
    File fastq_2
    File rna_fa
    String sampleid
    Int threads
    Int cpu
    Int mem
  }
  command {
    mkdir -p sortmerna_out
    /opt/software/miniconda3/envs/tool/bin/sortmerna \
    --ref ~{rna_fa} \
    --reads ~{fastq_1} \
    --reads ~{fastq_2} \
    --other ./sortmerna_out/~{sampleid}_non_rRNA \
    --aligned ./sortmerna_out/~{sampleid}_rRNA \
    --paired_in \
    --fastx \
    --threads ~{threads} \
    --out2 \
    --workdir .
  }
  runtime {
    docker_url: "stereonote_hpc/yangdong_50b2433e483b4008a87e4c63648144be_private:latest"
    req_cpu: cpu
    req_memory: "~{mem}Gi"
  }
  output {
    File result = "./sortmerna_out/~{sampleid}_rRNA.log"
    File fq_1 = "./sortmerna_out/~{sampleid}_non_rRNA_fwd.fq"
    File fq_2 = "./sortmerna_out/~{sampleid}_non_rRNA_rev.fq"
  }
}