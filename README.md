# MRI-Based Detection of Alzheimer’s Disease and Mild Cognitive Impairment

### By: Roni Tibon 

This project classifies BioFIND and ADNI data based on structural complexity of brain regions 

##
## Preprocessing

Reconstruction was done with FreeSurfer (recon-all). Code is located in Code\Preproc
- FS_preproc.sh: preprocessing job
- fs_sub_job.sh: submits job to cluster

##
## FD and Group Differences

This section uses MATLAB code to calculate FD values and group differences. Code is located in Code\FD_and_GroupDiff
Outputs from this sections are in GroupData folder

- FDAD_main - main MATLAB script, calls all other functions 

- FDAD_calcFD - calculate FD values
    - Inputs: Path (in and out); Subjects to analyse; parcellation scheme; Dataset (BioFIND/ADNI)
    - Outputs: FD values for each parcellation scheme and each dataset (e.g., fdSubcort_BioFIND.mat)

- FDAD_arrangeData - organises data in a similar way for ADNI and BioFIND
    - Inputs: Participants file (with demographic data etc); FD values file (from FDAD_calcFD)
    - Outputs: One file with FD values and demographic data for each dataset (e.g., fdsubs_BioFIND.mat)

- FDAD_stats - calculates group differences and plot results
    - Inputs: Dataset; Keep/remove outliers; Display type (boxplot/histogram)
    - Outputs: One file with stats for each dataset (e.g., fdstats_BioFIND stats)

- FDAD_glm - GLM for feature selection. This section also calculates the correspondence between the datasets
    - Inputs: Datasets; Grouping type (exclude AD cases frm ADNI or use as PN v. HC); Arranged FD files (from FDAD_arrangeData)
    - Outputs: GLM model and Rs values

Additional sections in the FDAD_main file:
- Create figure: superimpose Rs values on NIFTI files from example subject 
- Use GLM to train on BioFIND and test on ADNI, to select best parcellation scheme
- Select best features 
- Create table data to use with Python

##
## ML Classification

This section uses Python for ML classification. Code is located in Code\ML
- Use setup_instructions.txt to setup the enviornment
- FDAD_ML.ipynb is a notebook that contains all code (an .html version is also available)
- Trained models are in Models folder


