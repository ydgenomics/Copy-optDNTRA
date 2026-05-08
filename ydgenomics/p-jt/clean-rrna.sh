mkdir -p sortmerna_out
/opt/software/miniconda3/envs/tool/bin/sortmerna \
--ref /Files/ReferenceData/Database/plant_ref_rRNA/plant_rRNA.fa \
--reads /data/users/yangdong/yangdong_5b07fc5c978d4acb9b44c83305ac3a2b/online/TEST/optDNTRA_out2/results/02-optimization/03-transEvidence/transcript.flt.final.fa \
--other ./sortmerna_out/non_rRNA \
--aligned ./sortmerna_out/rRNA \
--fastx \
--threads 36 \
--out2 \
--workdir .