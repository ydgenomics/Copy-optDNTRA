version 1.0

workflow QualityFiltering {
  input {
    Array[File] fastq_1
    Array[File]? fastq_2
    Array[String]? other_options
    Int cpu = 4
    Int memory = 16
  }
  call FastqcBefore {
    input:
    sampleid  = sampleids[i],
    fastq_1 = fastq_1[i],
    fastq_2 = fastq_2[i],
    input_cpu = cpu,
    input_memory = memory
  }
  call Fastp {
    input:
      sampleid  = sampleids[i],
      fastq_1 = fastq_1[i],
      fastq_2 = fastq_2[i],
      average_qual = average_qual,
      disable_adaptor_trimming = disable_adaptor_trimming,
      other_options = other_options,
      input_cpu = cpu,
      input_memory = memory
  }
  call FastqcAfter {
    input:
      sampleid  = sampleids,
      fastq_1 = Fastp.fastp_1,
      fastq_2 = Fastp.fastp_2,
      input_cpu = cpu,
      input_memory = memory
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
  String sampleid
    File fastq_1
    File? fastq_2
    Int input_cpu
    Int input_memory
  }
  command <<<
    # run fastqc before filtering
    mkdir -p fastqc_before
    fastqc -t ~{input_cpu} -o fastqc_before ~{fastq_1} ~{fastq_2}
  >>>
  runtime {
    docker_url: "public-library/shuliping_5dd38def89904973af1683666afa4bc5_public:latest"
    req_cpu: input_cpu
    req_memory: "${input_memory}Gi"
  }
  output {
    File fastqc_before = "fastqc_before"
  }
}

task Fastp {
 input {
 String sampleid
    File fastq_1
    File? fastq_2
    Int average_qual
    Boolean disable_adaptor_trimming
    Array[String]? other_options
    Int input_cpu
    Int input_memory
  }
  
  # convert default name to just sample name
  String read_file_basename = basename(fastq_1)
  String sample_name = sub(read_file_basename, "_.*", "")
  
  command {
    echo "#!/bin/bash
    set -e
    fastp \
    --in1 ~{fastq_1} \
    ~{if defined(fastq_2) then "--in2 ~{fastq_2}" else ""} \
    --out1 ~{sample_name}_fastp_1.fq.gz \
    ~{if defined(fastq_2) then "--out2 ~{sample_name}_fastp_2.fq.gz" else ""} \
    --average_qual ~{average_qual} \
    ~{true="--disable_adapter_trimming" false="" disable_adaptor_trimming} \
    ~{sep=" " other_options} \
    --html ~{sample_name}_fastp.html" > fastp.sh
    chmod +x fastp.sh
    ./fastp.sh
  }

  runtime {
    docker_url: "stereonote_hpc/dedekurniawan_6a03a953d10d4be49922a57cb2d779b2_private:latest"
    req_cpu: input_cpu
    req_memory: "~{input_memory}Gi"
  }
  output {
    File html_report = "~{sample_name}_fastp.html"
    File fastp_1 = "~{sample_name}_fastp_1.fq.gz"
    File fastp_2 = "~{sample_name}_fastp_2.fq.gz"
  }
}

task FastqcAfter {
  input {
  String sampleid
    File fastq_1
    File? fastq_2
    Int input_cpu
    Int input_memory
  }
  command <<<
    # run fastqc after filtering
    mkdir -p fastqc_after
    fastqc -t ~{input_cpu} -o fastqc_after ~{fastq_1} ~{fastq_2}
  >>>
  runtime {
    docker_url: "public-library/shuliping_5dd38def89904973af1683666afa4bc5_public:latest"
    req_cpu: input_cpu
    req_memory: "${input_memory}Gi"
  }
  output {
    File fastqc_after = "fastqc_after"
  }
}