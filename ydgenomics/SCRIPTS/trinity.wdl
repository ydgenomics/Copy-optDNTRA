
version 1.0
#You need to declaration version information(version 1.0)
workflow Hello{
  input{
    Array[File] left_fq
    Array[File] right_fq
    Array[String] group_list
    Array[String] sample_list
    Int threads=32
    Int cpu=16
    Int mem=128
  }
  call sayHello{
    input:
    fq_left_list=left_fq,
    fq_right_list=right_fq,
    group_list=group_list,
    sample_list=sample_list,
    threads=threads,
    cpu=cpu,
    mem=mem,
  }
  output{
    File result=sayHello.response
  }
}
task sayHello{
  input {
    Array[File] fq_left_list
    Array[File] fq_right_list
    Array[String] group_list
    Array[String] sample_list
    Int threads
    Int cpu
    Int mem
  }
  command <<<
    set -e

    # 使用 WDL 的 sep 将数组转为换行分隔的临时文件，然后用 paste 合并成 Tab 分隔的表
    paste \
        <(echo "~{sep='\n' group_list}") \
        <(echo "~{sep='\n' sample_list}") \
        <(echo "~{sep='\n' fq_left_list}") \
        <(echo "~{sep='\n' fq_right_list}") \
        > output.txt

    echo "--- Sample File ---" && cat output.txt

    Trinity --seqType fq \
        --samples_file output.txt \
        --no_normalize_reads \
        --max_memory ~{mem}G --CPU ~{threads} \
        --output trinity_out 2>&1 | tee -a log.txt
  >>>
  runtime {
    docker_url: "stereonote_hpc/yangdong_34155ddaf01e4861a89d2fda3f0f74ef_private:latest"
    req_cpu: cpu
    req_memory: "~{mem + 2} GB"
  }
  output {
    File response = 'trinity_out'
    File log = 'log.txt'
  }
}