transcript_fa=
left_fq=
right_fq=

swiss_prot=
pfam_hmm=
busco_lineage=
omark_database=
emapper_database=


mkdir -p db
cp $swiss_prot db
cp $pfam_hmm db
tar -zxvf $busco_lineage -C ./db
cp $omark_database db
cp $emapper_database db


export PATH=~/optDNTRA:$PATH
source /opt/software/miniconda3/bin/activate && conda activate optdntra
optDNTRA.py -h



optDNTRA.py \
 --config /data/WORKFLOW/optDNTRA/defaults.yml \
 --transcript $transcript_fa \
 --left $left_fq \
 --right $right_fq \
 --outDir optDNTRA_out \
 --trim \
 --qc \
 --buscoAsmt \
 --threads 8