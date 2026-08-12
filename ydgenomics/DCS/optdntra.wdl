
version 1.0
#You need to declaration version information(version 1.0)
workflow Hello{
  input{
    File transcript_fa="/Files/yangdong/WDL/optdntra/trinity.fasta"
    Array[File] left_fq=["/Files/yangdong/WDL/optdntra/reads_1.fq.gz","/Files/yangdong/WDL/optdntra/reads_2.fq.gz"] # "_1" and "_2"
    Array[File] right_fq
    String tools="--omarkAsmt --buscoAsmt --emapperAnno"
    File swiss_prot="/Files/yangdong/WDL/optdntra/uniprot_sprot.fasta"
    File pfam_hmm="/Files/yangdong/WDL/optdntra/Pfam-A.hmm"
    File busco_downloads="/Files/yangdong/WDL/optdntra/busco_downloads.tar.gz"
    File omark_database="/Files/yangdong/SOFTWARE/OMArk/LUCA.h5"
    File taxa_sqlite="/Files/yangdong/SOFTWARE/OMArk/taxa.sqlite"
    File eggnog_database="/Files/yangdong/SOFTWARE/eggNOGmapper/emapperDb/eggnog.db"
    File eggnog_proteins_dmnd="/Files/yangdong/SOFTWARE/eggNOGmapper/emapperDb/eggnog_proteins.dmnd"
    String outDir="optDNTRA_out"
    Int cpu=8
    Int mem=64
  }
  call optdntra{
    input:
    transcript_fa=transcript_fa,
    left_fq=left_fq,
    right_fq=right_fq,
    swiss_prot=swiss_prot,
    pfam_hmm=pfam_hmm,
    taxa_sqlite=taxa_sqlite,
    busco_downloads=busco_downloads,
    omark_database=omark_database,
    eggnog_database=eggnog_database,
    eggnog_proteins_dmnd=eggnog_proteins_dmnd,
    outDir=outDir,
    tools=tools,
    cpu=cpu,
    mem=mem,
  }
  output{
    File result=optdntra.result
  }
}
task optdntra{
  input {
    File transcript_fa
    Array[File] left_fq
    Array[File]? right_fq
    File swiss_prot
    File pfam_hmm
    File taxa_sqlite
    File busco_downloads
    File omark_database
    File eggnog_database
    File eggnog_proteins_dmnd
    String outDir
    String tools
    Int cpu
    Int mem
  }
  command <<<
    mkdir -p db
    tar -zxvf ~{busco_downloads} -C ./db
    ln -s ~{swiss_prot} ./db
    ln -s ~{pfam_hmm} ./db
    ln -s ~{omark_database} ./db
    ln -s ~{taxa_sqlite} ./db
    ln -s ~{eggnog_database} ./db
    ln -s ~{eggnog_proteins_dmnd} ./db

    source /opt/software/miniconda3/bin/activate && conda activate optdntra
    export PATH=/Copy-optDNTRA:$PATH && optDNTRA.py -h

    echo "[check input]"
    Rscript /Copy-optDNTRA/ydgenomics/SCRIPTS/check_input.R ~{sep="," left_fq} ~{sep="," right_fq}
    echo '~{sep="," left_fq}' && echo '~{sep="," right_fq}'

    FILE="optdntra.tsv"
    line_count=$(wc -l < "$FILE")
    if [ "$line_count" -eq 0 ]; then
        exit 1
    elif [ "$line_count" -eq 1 ]; then
        echo "###Single sample."
        IFS=',' read -ra ARR <<< '~{sep="," right_fq}'
        if [ ${#ARR[@]} -ge 1 ]; then
            echo "Run paired analysis..."
            optDNTRA.py \
            --config /Copy-optDNTRA/defaults-dcs.yml \
            --transcript ~{transcript_fa} \
            --left ~{sep="," left_fq} \
            --right ~{sep="," right_fq} \
            --outDir ~{outDir} \
            --trim --qc ~{tools} \
            --threads ~{cpu}
        else
            echo "Run single analysis..."
            optDNTRA.py \
            --config /Copy-optDNTRA/defaults-dcs.yml \
            --transcript ~{transcript_fa} \
            --fastq ~{sep="," left_fq} \
            --singleEnd \
            --outDir ~{outDir} \
            --trim --qc ~{tools} \
            --threads ~{cpu}
        fi
    else
        echo "Detect $line_count line..."
        optDNTRA.py \
        --config /Copy-optDNTRA/defaults-dcs.yml \
        --transcript ~{transcript_fa} \
        --sampleSheet optdntra.tsv \
        --outDir ~{outDir} \
        --trim --qc ~{tools} \
        --threads ~{cpu}
    fi
  >>>
  runtime {
    docker_url: "stereonote_hpc/yangdong_34155ddaf01e4861a89d2fda3f0f74ef_private:latest"
    req_cpu: cpu
    req_memory: "~{mem}Gi"
  }
  output {
    File result = "~{outDir}"
  }
}
