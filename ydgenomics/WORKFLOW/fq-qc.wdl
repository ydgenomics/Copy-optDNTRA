version 1.0
workflow QualityFiltering {
  input {
    Array[File] fastq_1
    Array[File] fastq_2
    Array[String] sampleid
    String parameter='-6'
    Int cpu = 4
    Int mem = 16
  }
  call fastqc {
    input:
    fq_1 = fastq_1,
    fq_2 = fastq_2,
    prefix = "un-fastp"
  }
  scatter(i in range(length(fastq_1))){
    call Fastp {
      input:
        sampleid  = sampleid[i],
        fq_1 = fastq_1[i],
        fq_2 = fastq_2[i],
        parameter=parameter,
        cpu = cpu,
        mem = mem
    }
  }
  call fastqc as fastqc2 {
    input:
    fq_1 = Fastp.fastp_1,
    fq_2 = Fastp.fastp_2,
    prefix = "fastp"
  }
  call multiqc {
    input:
      zip = flatten([fastqc2.zip, Fastp.json]),
  }
  output {
    File result=multiqc.result
    File result0 = fastqc.html
    Array[File] fastp_1 = Fastp.fastp_1
    Array[File] fastp_2 = Fastp.fastp_2
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

task Fastp {
 input {
    File fq_1
    File fq_2
    String sampleid
    String parameter
    Int cpu
    Int mem
  }
  command {
    /opt/software/miniconda3/envs/optdntra/bin/fastp -i ~{fq_1} -I ~{fq_2} \
    -o "~{sampleid}_clean_1.fq.gz" \
    -O "~{sampleid}_clean_2.fq.gz" \
    --detect_adapter_for_pe \
    --cut_front \
    --cut_tail \
    --cut_window_size 4 \
    --cut_mean_quality 20 \
    --length_required 50 \
    --average_qual 20 \
    --correction \
    --thread ~{cpu} \
    --html "~{sampleid}_report.html" \
    --json "~{sampleid}_report.json" ~{parameter} 
  }

  runtime {
    docker_url: "stereonote_hpc/yangdong_34155ddaf01e4861a89d2fda3f0f74ef_private:latest"
    req_cpu: cpu
    req_memory: "~{mem}Gi"
  }
  output {
    File html = "~{sampleid}_report.html"
    File json = "~{sampleid}_report.json"
    File fastp_1 = "~{sampleid}_clean_1.fq.gz"
    File fastp_2 = "~{sampleid}_clean_2.fq.gz"
  }
}

task multiqc {
  input {
    Array[File] zip
  }
  command <<<
    source /opt/software/miniconda3/bin/activate && conda activate tool
    multiqc ~{sep=" " zip}
  >>>
  runtime {
    docker_url: "stereonote_hpc/yangdong_34155ddaf01e4861a89d2fda3f0f74ef_private:latest"
    req_cpu: 2
    req_memory: "8Gi"
  }
  output {
    File result = 'multiqc_report.html'
  }
}