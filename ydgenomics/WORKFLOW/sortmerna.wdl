
version 1.0
workflow Hello{
  input{
    Array[File] fastq_1
    Array[File] fastq_2
    Array[String] sampleid
    File rna_fa="/Files/ReferenceData/Database/plant_ref_rRNA/plant_rRNA.fa"
    Int threads=16
    Int cpu=4
    Int mem=16
  }
  scatter(i in range(length(fastq_1))){
    call sortmerna{
      input:
      fastq_1=fastq_1[i],
      fastq_2=fastq_2[i],
      rna_fa=rna_fa,
      sampleid=sampleid[i],
      threads=threads,
      cpu=cpu,
      mem=mem,
    }
  }
  call fastqc {
    input:
    fq_1 = sortmerna.fq_1,
    fq_2 = sortmerna.fq_2,
    prefix = "sortmerna"
  }
  output{
    Array[File] fq_1=sortmerna.fq_1
    Array[File] fq_2=sortmerna.fq_2
    Array[File] log=sortmerna.result
    File html = fastqc.html
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
    req_cpu: 2
    req_memory: "8Gi"
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
    
    cp ./sortmerna_out/~{sampleid}_non_rRNA_fwd.fq.gz ./sortmerna_out/~{sampleid}_1.fq.gz
    cp ./sortmerna_out/~{sampleid}_non_rRNA_rev.fq.gz ./sortmerna_out/~{sampleid}_2.fq.gz
  }
  runtime {
    docker_url: "stereonote_hpc/yangdong_50b2433e483b4008a87e4c63648144be_private:latest"
    req_cpu: cpu
    req_memory: "~{mem}Gi"
  }
  output {
    File result = "./sortmerna_out/~{sampleid}_rRNA.log"
    File fq_1 = "./sortmerna_out/~{sampleid}_1.fq.gz"
    File fq_2 = "./sortmerna_out/~{sampleid}_2.fq.gz"
  }
}


task fastqc {
  input {
    Array[File] fq_1
    Array[File] fq_2
    String prefix
  }
  command <<<
    source /opt/software/miniconda3/bin/activate && conda activate optdntra
    fastqc -t 4 -o . ~{sep=" " fq_1} ~{sep="," fq_2} --memory 10000
    source /opt/software/miniconda3/bin/activate && conda activate tool
    multiqc . && mv multiqc_report.html ~{prefix}_multiqc.html
  >>>
  runtime {
    docker_url: "stereonote_hpc/yangdong_34155ddaf01e4861a89d2fda3f0f74ef_private:latest"
    req_cpu: 2
    req_memory: "16Gi"
  }
  output {
    File html = "~{prefix}_multiqc.html"
    Array[File] zip = glob("*.zip")
  }
}