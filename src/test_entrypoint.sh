#!/usr/bin/env bash

export fmri1_niigz=../INPUTS/fmri1.nii.gz
export fmri2_niigz=../INPUTS/fmri2.nii.gz
export fmri3_niigz=../INPUTS/fmri3.nii.gz
export fmri4_niigz=../INPUTS/fmri4.nii.gz
export fmritopup_niigz=../INPUTS/fmritopup.nii.gz
export seg_niigz=../INPUTS/seg.nii.gz
export icv_niigz=../INPUTS/icv.nii.gz
export deffwd_niigz=../INPUTS/y_deffwd.nii.gz
export biascorr_niigz=../INPUTS/biascorr.nii.gz
export biasnorm_niigz=../INPUTS/biasnorm.nii.gz
export trialreport_csv=../INPUTS/trialreport.csv
export out_dir=../OUTPUTS

export vox_mm=2
export hpf_sec=200
export fwhm_mm=6
export refimg_nii=avg152T1.nii

# Initialize Freesurfer
. $FREESURFER_HOME/SetUpFreeSurfer.sh

# Copy inputs to the working directory
copy_inputs.sh

# FSL based motion correction, topup, registration
fsl_processing.sh

# Unzip .nii for matlab/spm
gunzip "${out_dir}"/ctrrfmri?.nii.gz \
    "${out_dir}"/ctrrfmri_mean_all.nii.gz \
    "${out_dir}"/biasnorm.nii.gz \
    "${out_dir}"/y_deffwd.nii.gz
