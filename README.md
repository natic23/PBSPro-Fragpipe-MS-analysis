[![DOI](https://zenodo.org/badge/1123079278.svg)](https://doi.org/10.5281/zenodo.18457983)
# PBSPro-Fragpipe-MS-analysis
## a PBS Pro submission shell script for FragPipe Mass Spectometry data analysis
--- 
# Fragpipe GUI vs HPC

## GUI Fragpipe usage (referred as Fragpipe-GUI)
relies on local machine's inbuilt RAM --most laptop/PC has 16-32GB RAM, powerful-lab processing PC might have 128GB RAM
- Fragpipe will occupy the entire machine's RAM resource: laggy laptop when fragpipe is running


## HPC(PBS Pro) integration of the established Fragpipe Mass-Spec analysis tool
(referred as Fragpipe-HPC)

HPC integration offers high-RAM, multicore Fragpipe processing of large (>100GB) Mass Spec dataset
Uses HPC system, instead of local computer: less monitoring required and lower risk of terminating job due to machine power nap
You could require a lot more parallelism and RAM for a Fragpipe job on HPC -- Significantly decreases run time for each run

---
## Software used:
1. Fragpipe 23.1 \
https://github.com/Nesvilab/FragPipe.git
2. MSFragger\
https://msfragger.nesvilab.org/
3. IonQuant \
https://ionquant.nesvilab.org/
4. diaTracer \
   https://github.com/Nesvilab/diaTracer
5. Singularity \
https://github.com/sylabs/singularity.git
6. Python 3.11 
7. PBS PRO HPC queue manager

### Sample Data:
.raw file obtained from [PXD061410 (Proteome Central)](https://proteomecentral.proteomexchange.org/cgi/GetDataset?ID=PXD061410-1&test=no)
Processed with Fragpipe-HPC vs Fragpipe-GUI


---
## Steps (I am running on a windows PC)
1. Make a folder in your $HOME, i.e. FP_HPC
2. Install miniconda in $HOME/FP_HPC
3. Install latest python in $HOME/FP_HPC/miniconda with this: `conda install python` 
4. Install and unzip Fragpipe (latest) version at https://github.com/Nesvilab/FragPipe.git
5. Install MSFragger, IonQuant, diaTracer at their website, unzip and put the 3 folders into Fragpipe/tools
6. Run Fragpipe.exe, load all the files you will need to submit and change their experiment name + replicates
7. Save as manifest (.fp-manifest)
8. Download reference proteome from UniProt as .fasta
9. Adjust the settings in the entire Fragpipe run, import reference proteome in the 'Database tab'
10. Click 'Add Decoy' > Add Decoy and Contaminant
11. download the decoy-added .fas file in $HOME/FP_HPC
12. Go to 'Workflow' tab, save workflow to Custom folder > save to $HOME/FP_HPC
   Tips: I usually name the workflow by the proteome species imported, e.g. LFQ-MBR_rat.workflow or LFQ-MBR_human.workflow
13. **Note down absolute paths of**\
    i. workflow file, i.e. $HOME/FP_HPC/LFQ-MBR_rat.workflow
    ii. Manifest file, i.e. $HOME/FP_HPC/manifest1.fp-manifest \
   iii. output directory you would like the results to go, i.e. $HOME/FP_HPC/result1 \
   iv.tools folder, i.e. $HOME/FP_HPC/Fragpipe/tools \
		v. python binary (in miniconda folder), i.e. $HOME/FP_HPC/miniconda/bin/python3.13 

--- 
## Core Script
```python
singularity exec --bind $HOME/FP_HPC:/data fragpipe_latest.sif \
  /data/Fragpipe/bin/fragpipe --headless \
    --workflow /data/LFQ-MBR_human.workflow\  ##workflow path
    --manifest /data/manifest1.fp-manifest \  ##manifest path
    --workdir /data/result1 \ ##output directory path
    --ram 256 \ ## RAM requested
    --threads 16 \ ##parallelism
    --config-tools-folder /data/Fragpipe/tools \ ##tool path
    --config-python /data/miniconda/bin/python3.13 ##python binary path
```
---
### Pulling Singularity container to your HPC environment (Instruction extracted from [Fragpipe Official Singluarity](http://fragpipe.nesvilab.org/docs/tutorial_docker.html)
1. Login to your HPC
2. most HPC system should have Singularity/Apptainer installed
3. Go to path $HOME/FP-HPC
4. run `singularity pull docker://fcyucn/fragpipe:latest` or `apptainer pull docker://fcyucn/fragpipe:latest`
---
### Fixing file syntax into bash-compatible in files
#### Manifest file
1. open your manifest file (mine is manifest1.fp-manifest) in any text editor
2. replace start of the absolute path (i.e. R:\home\FP_HPC\) with /data/
3. Find and Replace all \ with **/**
4. The manifest file should look like this now:
/data/<LCMS_data_folder>/<filename>	experiment_name	replicate_no.	DDA
/data/<LCMS_data_folder>/<filename>	experiment_name	replicate_no.	DDA
/data/<LCMS_data_folder>/<filename>	experiment_name	replicate_no.	DDA
/data/<LCMS_data_folder>/<filename>	experiment_name	replicate_no.	DDA
...
- each column is tab-separated
- we replace $HOME/FP_HPC with /data/ because singularity is mount inside FP_HPC:
	all paths that will be read by the machine has to be relative to $HOME/FP_HPC

#### Workflow file
1. open the **workflow** file
2. inside workflow file:
```
# Please edit the following path to point to the correct location.
database.db-path=R:\home\FP_HPC\rat_decoy_contam.fas
```
3. Change **'R:\home\FP_HPC\'** into **/data/**
4. Save the workflow file after making changes
...
- we replace $HOME/FP_HPC with /data/ because singularity is mount inside FP_HPC:
	all paths that will be read by the machine has to be relative to $HOME/FP_HPC

---
#### ALL DONE!

log into HPC system
1. Change Directory to where your PBS submission script is (.sh script), i.e. `cd FP_HPC\`
2. `qsub pbs_fragpipe_job_ntfy.sh` to submit the script
3. `qstat -u <user_name>`

