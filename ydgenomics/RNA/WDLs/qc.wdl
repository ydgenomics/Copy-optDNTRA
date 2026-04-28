version 1.0
workflow QualityFiltering {
  input {
    Array[File] fastq_1
    Array[File] fastq_2
    Array[String] sampleid
    String parameter='-6'
    Int cpu = 8
    Int mem = 32
  }
  scatter(i in range(length(fastq_1))){
    call FastqcBefore {
      input:
      fastq_1 = fastq_1[i],
      fastq_2 = fastq_2[i],
      input_cpu = cpu,
      input_memory = mem
    }
    call Fastp {
      input:
        sampleid  = sampleid[i],
        fastq_1 = fastq_1[i],
        fastq_2 = fastq_2[i],
        average_qual = average_qual,
        disable_adaptor_trimming = disable_adaptor_trimming,
        other_options = other_options,
        input_cpu = cpu,
        input_memory = mem
    }
    call FastqcAfter {
      input:
        fastq_1 = Fastp.fastq_1,
        fastq_2 = Fastp.fastq_2,
        input_cpu = cpu,
        input_memory = mem
    }
  }
  output {
     Array[File] fastp_result_1 = Fastp.html_report
     Array[File] fastp_result_2 = Fastp.fastp_1
    Array[File] fastp_result_3 = Fastp.fastp_2
     Array[File] fastqc_result_1 = FastqcBefore.fastqc_before
    Array[File] fastqc_result_2 = FastqcAfter.fastqc_after
  }
}

task FastqcBefore {
  input {
    File fastq_1
    File? fastq_2
    Int input_cpu
    Int input_memory
  }
  command <<<
    FASTQC_PATH=/opt/software/miniconda3/envs/optdntra/bin/fastqc
    mkdir -p fastqc_before
    ${FASTQC_PATH} -t ~{input_cpu} -o fastqc_before ~{fastq_1} ~{fastq_2} --memory 10000
  >>>
  runtime {
    docker_url: "stereonote_hpc/yangdong_34155ddaf01e4861a89d2fda3f0f74ef_private:latest"
    req_cpu: input_cpu
    req_memory: "~{input_memory}Gi"
  }
  output {
    Array[File] result = glob("fastqc_before/*")
  }
}

task Fastp {
 input {
    File fastq_1
    File fastq_2
    String sampleid
    String parameter
    Int input_cpu
    Int input_memory
  }
  command {
    FASTP_PATH=/opt/software/miniconda3/envs/optdntra/bin/fastp
    r1=~{fastq_1}
    r2=~{fastq_2}

    ${FASTP_PATH} -i "${r1}" \
    -I "${r2}" \
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
    --thread ~{input_cpu} \
    --html "~{sampleid}_report.html" \
    --json "~{sampleid}_report.json" ~{parameter} 
  }

  runtime {
    docker_url: "stereonote_hpc/yangdong_34155ddaf01e4861a89d2fda3f0f74ef_private:latest"
    req_cpu: input_cpu
    req_memory: "~{input_memory}Gi"
  }
  output {
    File html = "~{sampleid}_report.html"
    File fastp_1 = "~{sampleid}_clean_1.fq.gz"
    File fastp_2 = "~{sampleid}_clean_2.fq.gz"
  }
}

task FastqcAfter {
  input {
    File fastq_1
    File fastq_2
    Int input_cpu
    Int input_memory
  }
  command <<<
    FASTQC_PATH=/opt/software/miniconda3/envs/optdntra/bin/fastqc
    mkdir -p fastqc_after
    ${FASTQC_PATH} -t ~{input_cpu} -o fastqc_after ~{fastq_1} ~{fastq_2} --memory 10000
  >>>
  runtime {
    docker_url: "stereonote_hpc/yangdong_34155ddaf01e4861a89d2fda3f0f74ef_private:latest"
    req_cpu: input_cpu
    req_memory: "~{input_memory}Gi"
  }
  output {
    Array[File] result = glob("fastqc_after/*")
  }
}