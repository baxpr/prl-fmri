#!/usr/bin/env bash

echo Running $(basename "${BASH_SOURCE}")

# Files
cp "${fmri1_niigz}" "${out_dir}"/fmri1.nii.gz
cp "${fmri2_niigz}" "${out_dir}"/fmri3.nii.gz
cp "${fmri3_niigz}" "${out_dir}"/fmri3.nii.gz
cp "${fmri4_niigz}" "${out_dir}"/fmri4.nii.gz
cp "${eprime_csv}" "${out_dir}"/eprime.csv
cp "${deffwd_niigz}" "${out_dir}"/y_deffwd.nii.gz
cp "${biascorr_niigz}" "${out_dir}"/biascorr.nii.gz
cp "${biasnorm_niigz}" "${out_dir}"/biasnorm.nii.gz

# Unzip the images for SPM
gunzip "${out_dir}"/*.nii.gz
