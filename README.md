# Metacarcoding pipeline with Qiime2
A SLURM pipeline designed for paried end illumina reads analysed with qiime2 (https://amplicon-docs.qiime2.org/en/latest/). The processes includes quality assessment, ...... This pipeline is optimised explicitly for deployment on high-performance computing (HPC) clusters and executed _via_ Slurm Workload Manager.

## Key Features

- **Read Quality Assessment**: 


## Installation

1. Install the metagenome_slurm resources into your HPC cluster directory in which you will be performing the assembly:  

```
git clone https://github.com/Peter-Kille/metabarcoding.git
```

2. Put the raw reads, sample-metadata and manifest in `source_data` folder.

3. If you have trained classifiers place them in the classifier folder.  

3. Run the pipeline using `./deploy.sh -n [NAME] -p [PARTITION] -s [SAMPLE-METADATA] -m [MANIFEST] -c [CLASSIFIER]`  

4. you can you './deploy.sh -h' for help (see below)

## Available displayed arguments:git@github.com:Peter-Kille/metabarcoding.git
```
./deploy.sh -h

Usage: ./deploy.sh -n [NAME] -p [PARTITION] -m [MANIFEST] -s [SAMPLE_METADATA] -c [CLASSIFIER]

Copy your paired end sequence files as .fastq.gz files in the source_data directory. Also
copy a sample-metadata file and manifest into the source_data directory.

Manifest
sample-id forward-absolute-filepath   reverse-absolute-filepath
sample-1  /scratch/microbiome/sample1_R1.fastq.gz  /scratch/microbiome/sample1_R2.fastq.gz
sample-2  /scratch/microbiome/sample2_R1.fastq.gz  /scratch/microbiome/sample2_R2.fastq.gz

sample-metadata


  REQUIRED: a trained clasifier or file to generate traninged classier

Options:
  -n, --name          REQUIRED: Run name or deployment name - should be unique
  -p, --partition     REQUIRED: Avalible partition / hpc queue (epyc, defq, jumbo, epyc_ssd)
  -m, --manifest      REQUIRED: manifest file, sample id[tab]forward-absolute-filepath[tab]everse-absolute-filepath
  -t, --smetadata     REQUIRED: sample-metadata
  -c, --classifier    REQUIRED: reference condition
  -w, --work          Optional: working dir - default is current dir /work/
  -h, --help          Show this help message
```
 **Note:**
- You can run the pipeline multiple times simultaneously with different raw reads, simply repeat the installation process in a different directory and `./deploy` with a different run names identifier name.
- You can manually reconfigure slurm parameters as per your HPC system (e.g memory, CPUs) by going through indivudal scripts in `modules` directory.
- All the relevent outputs will be stored in `outdir` folder, and outputs for every individual steps in the pipeline can be found in `workdir`.

# Classifiers

Great guide for creating classifiers for Qiime2 by [Asa Jacabsen](https://www.firum.fo/media/3733/pipeline_taxonomic_classifiers.pdf).

Also various projects have perfromed this for you:

- [midori](https://www.reference-midori.info/download.php)
- [qiime2 data resources](https://docs.qiime2.org/2024.10/data-resources/)

Prof Peter Kille - kille@cardiff.cf.ac.uk
