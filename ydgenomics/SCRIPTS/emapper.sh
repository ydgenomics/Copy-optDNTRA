export PATH=~/optDNTRA:$PATH
source /opt/software/miniconda3/bin/activate && conda activate optdntra

emapper.py \
-m diamond \
--itype proteins \
-i {input.transcriptPep} \
--data_dir {params.emapperDB} \
--output transAsm \
--output_dir {output.emapperOut} \
--cpu {threads} \
&> {log}