from os.path import join
import logging
import optDNTRA_utils as utils
from time import time


### Configuration Setup ### ----------------------------------------
OMARK_DB = config["omark_database"]
TAXID  = config["taxid"]
TAXA_sqlite = config["taxa_sqlite"]


### Logging Setup ### ----------------------------------------
LOG_OMARKASMT = utils.get_logger("OMARKASMT", VERBOSE)


### Rule ### ----------------------------------------
rule omark_assessment:
    """
    Perform Omark assessment to evaluate proteome completeness
    """
    input:
        transcriptPep=join(TRANSEVID_DIR, "transcript.flt.final.pep"),
    output:
        omarkOut=directory(join(OMARK_DIR, "omark_output")),
    log:
        join(ASMT_LOG_DIR, "omarkAsmt.log"),
    params:
        omarkQuery=join(OMARK_DIR, "query.omamer"),
        omarkDB=OMARK_DB,
        taxid=TAXID,
        taxa_sqlite=TAXA_sqlite,
    threads: THREADS
    run:
        LOG_OMARKASMT.info("Running omarkAsmt.smk...")
        startTime = time()

        shell(
        """
        omamer search \
         --db {params.omarkDB} \
         --query {input.transcriptPep} \
         --out {params.omarkQuery} \
         --nthreads {threads} \
         &> {log}
        mkdir -p ~/.etetoolkit
        cp {params.taxa_sqlite} ~/.etetoolkit/taxa.sqlite
        omark \
         --file {params.omarkQuery} \
         --database {params.omarkDB} \
         --outputFolder {output.omarkOut} \
         &>> {log}
        """
        )

        endTime = time()
        elapseTime = endTime - startTime
        LOG_OMARKASMT.info(
            f"Performed Omark assessment to evaluate proteome completeness in {elapseTime:.2f} seconds."
        )
