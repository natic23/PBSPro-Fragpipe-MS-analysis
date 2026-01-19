#!/bin/bash
#PBS -N human_PXD061410_run_256
#PBS -l select=1:ncpus=32:mem=256gb:cpu_type=icelake
#PBS -l walltime=12:00:00

cd $HOME

unset _JAVA_OPTIONS
export LC_ALL=C
export LANG=C

TOPIC="github_fphpc_ntfy"

curl -s -X POST https://ntfy.sh/$TOPIC \
     -H "Title: PBS job started" \
     -d "Job: $PBS_JOBNAME
ID: $PBS_JOBID
Node: $(hostname)
Time: $(date)"

singularity exec --bind $HOME/FP_HPC:/data fragpipe_latest.sif \
  /data/fragpipe-23.1/bin/fragpipe --headless \
    --workflow /data/LFQ-MBR_human.workflow\  ##workflow path
    --manifest /data/manifest1.fp-manifest \  ##manifest path
    --workdir /data/result1 \ ##output directory path
    --ram 256 \ ## RAM requested
    --threads 16 \ ##parallelism
    --config-tools-folder /data/Fragpipe/tools \ ##tool path
    --config-python /data/miniconda/bin/python3.13 ##python binary path

curl -s -X POST https://ntfy.sh/$TOPIC \
     -H "Title: PBS job finished" \
     -d "Job: $PBS_JOBNAME
ID: $PBS_JOBID
Exit code: $JOB_STATUS
Time: $(date)"
