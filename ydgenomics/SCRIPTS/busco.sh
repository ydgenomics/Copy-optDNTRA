# https://busco-data.ezlab.org/v5/data/lineages/eukaryota_odb10.2024-01-08.tar.gz
# busco --download eukaryota_odb10

source /opt/software/miniconda3/bin/activate && conda activate optdntra

busco \
--in /data/work/optDNTRA_out1/results/01-preprocess/transcript.fa \
--out buscoPreFlt \
--mode transcriptome \
--lineage_dataset /data/work/optDNTRA/db/busco_downloads \
--cpu 8 \
--force \
--out_path /data/work/test/ \
--quiet \
--offline


busco \
--in /data/work/optDNTRA_out1/results/01-preprocess/transcript.fa \
--out buscoPreFlt \
--mode transcriptome \
--lineage_dataset /data/work/optDNTRA/db/busco_downloads \
--cpu 8 \
--force \
--out_path /data/work/test/ \
--quiet \
--offline

busco \
--in /data/work/optDNTRA_out1/results/01-preprocess/transcript.fa \
--out buscoPreFlt \
--mode transcriptome \
--lineage_dataset eukaryota_odb10 \
--cpu 8 \
--download_path /data/work/optDNTRA_out1/results/03-assessment/Busco/busco_downloads \ # will add ./lineages/eukaryota_odb10
--force \
--out_path /data/work/optDNTRA_out1/results/03-assessment/Busco/busco_downloads \
--quiet \
--offline
&> busco.log