#!/bin/bash
#PBS -N human_PXD061410_run_256
#PBS -l select=1:ncpus=32:mem=256gb:cpu_type=icelake
#PBS -l walltime=12:00:00

cd $HOME

unset _JAVA_OPTIONS
export LC_ALL=C
export LANG=C

singularity exec --bind $HOME/FP_HPC:/data fragpipe_latest.sif \
  /data/Fragpipe/bin/fragpipe --headless \
    --workflow /data/LFQ-MBR_human.workflow\  ##workflow path
    --manifest /data/manifest1.fp-manifest \  ##manifest path
    --workdir /data/result1 \ ##output directory path
    --ram 256 \ ## RAM requested
    --threads 16 \ ##parallelism
    --config-tools-folder /data/Fragpipe/tools \ ##tool path
    --config-python /data/miniconda/bin/python3.13 ##python binary path
