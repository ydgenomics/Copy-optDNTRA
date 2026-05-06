# Using trinity


trinity输出两个文件和一个文件夹，由参数`--output [trinity output dir]`控制，输出[trinity output dir]文件夹放的是中间文件；[trinity output dir].Trinity.fasta的fa文件，序列名为转录本名字，去掉`_i*`即基因的名字；[trinity output dir].fasta.gene_trans_map是一个tab分隔的txt文件，两列，第一列为基因名，第二列为转录本名字。


统计组装的情况，转录本与基因数
```shell
TrinityStats.pl Trinity.fasta
```