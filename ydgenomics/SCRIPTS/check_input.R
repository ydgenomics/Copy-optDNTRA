# 260414
# .fa.gz文件的组成必须为 
# [Tissue label]_[Replicate label]_1.fa.gz
# [Tissue label]_[Replicate label]_2.fa.gz


args <- commandArgs(trailingOnly = TRUE)
left_list <- strsplit(args[1], ',')[[1]] # '/data/work/TEST/leaf_r1_2.fq.gz,/data/work/TEST/leaf_r2_2.fq.gz'
if (length(args) > 2) {
  right_list <- strsplit(args[2], ',')[[1]] # '/data/work/TEST/leaf_r1_2.fq.gz,/data/work/TEST/leaf_r2_2.fq.gz'
} else {
  right_list <- c()
}


get_tsv <- function(left_list, right_list) {
  # 1. 检查长度一致性
  is_paired <- length(right_list) > 0
  if (is_paired && length(left_list) != length(right_list)) {
    stop(paste("Mismatched lengths: left_list is", length(left_list), 
               "but right_list is", length(right_list)))
  }
  # 提示用户预期的输入格式
  if (!is_paired) {
    message('!!!Check_Input!!!: Expecting Single-End format [Tissue]_[Sample]_[Read].fa.gz')
  } else {
    message('!!!Check_Input!!!: Expecting Paired-End format [Tissue]_[Sample]_1.fa.gz and [Tissue]_[Sample]_2.fa.gz')
  }
  # 2. 定义处理单条文件名的辅助函数（增强健壮性）
  parse_filename <- function(filename) {
    parts <- strsplit(basename(filename), '_')[[1]]
    if (length(parts) < 3) {
      stop(paste("Filename format error (need at least 2 underscores):", filename))
    }
    # 返回前两部分作为 Tissue 和 Sample，最后一部分作为 Fastq 路径
    return(c(tissue = parts[1], sample = parts[2], fq = filename))
  }
  # 3. 循环提取数据
  results <- lapply(seq_along(left_list), function(i) {
    res1 <- parse_filename(left_list[i])
    if (is_paired) {
      res2 <- parse_filename(right_list[i])
      # 返回一行数据
      return(data.frame(tissue = res1['tissue'], 
                        sample = res1['sample'], 
                        fq1 = res1['fq'], 
                        fq2 = res2['fq'], 
                        stringsAsFactors = FALSE))
    } else {
      return(data.frame(tissue = res1['tissue'], 
                        sample = res1['sample'], 
                        fq1 = res1['fq'], 
                        stringsAsFactors = FALSE))
    }
  })
  # 4. 合并结果
  csv_list <- do.call(rbind, results)
  return(csv_list)
}  
    

all_list <- get_tsv(left_list, right_list); print(all_list)

write.table(all_list, 
            file = "optdntra.tsv", 
            sep = "\t", 
            row.names = FALSE,   # 不写入行名 (tissue, tissue1...)
            col.names = FALSE,   # 不写入列名 (tissue, sample, fq1...)
            quote = FALSE)       # 建议加上，防止路径被加上双引号
