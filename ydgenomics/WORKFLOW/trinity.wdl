
version 1.0
#You need to declaration version information(version 1.0)
workflow Hello{
  input{
    Array[File] left_fq
    Array[File] right_fq
    String? parameter # '--no_normalize_reads'
    Int cpu=16
    Int max_mem=210
    Int mem=256
  }
  call sayHello{
    input:
    fq_left_list=left_fq,
    fq_right_list=right_fq,
    parameter=parameter,
    cpu=cpu,
    mem=mem,
    max_mem=max_mem,
  }
  output{
    #File result=sayHello.response
    File fa = sayHello.fa
    File g2t = sayHello.g2t
    File log = sayHello.log
  }
}
task sayHello{
  input {
    Array[File] fq_left_list
    Array[File] fq_right_list
    String? parameter
    Int cpu
    Int mem
    Int max_mem
  }
  command <<<
    set -e
    source /opt/software/miniconda3/bin/activate && conda activate optdntra
    Trinity --seqType fq --left ~{sep="," fq_left_list} --right ~{sep="," fq_right_list} \
    --max_memory ~{max_mem}G --CPU ~{cpu} --output trinity_out \
    ~{parameter} 2>&1 | tee -a log.txt
    mv trinity_out.Trinity.fasta trinity.fasta
  >>>
  runtime {
    docker_url: "stereonote_hpc/yangdong_34155ddaf01e4861a89d2fda3f0f74ef_private:latest"
    req_cpu: cpu
    req_memory: "~{mem} GB"
  }
  output {
    #File response = 'trinity_out'
    File fa = 'trinity.fasta'
    File g2t = 'trinity_out.fasta.gene_trans_map'
    File log = 'log.txt'
  }
}