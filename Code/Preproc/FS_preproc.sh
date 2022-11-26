#!/usr/bin/bash

# Get arguments
idn=$1
path=$2
#path="/imaging/henson/users/dv01/Github/BioFIND/MCIControls/sub-$idn/ses-meg1/anat"

# Go to subject dir
#cd "$path"

# Perform reconstruction
#recon-all -all -i "sub-${idn}_ses-meg1_T1w.nii.gz" -s $idn -sd /imaging/henson/users/rt01/MSc_Project/ADNI
recon-all -all -i "$path" -s $idn -sd /imaging/henson/users/rt01/MSc_Project/ADNI

