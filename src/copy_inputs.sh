#!/usr/bin/env bash
#
# Copy input files to the output/working directory so we don't mess them up. We
# generally assume the output directory starts out empty and will not be 
# interfered with by any other processes - certainly this is true for XNAT/DAX.

echo Running $(basename "${BASH_SOURCE}")

# Copy the input nifti to the working directory (out_dir) with a hard-coded
# filename. Hardcoding filenames like this makes programming a lot easier, and
# the loss of flexibility is usually not a problem for a containerized pipeline
# working in its own private directory.
cp "${img_niigz}" "${out_dir}"/img.nii.gz
cp "${mask_niigz}" "${out_dir}"/mask.nii.gz

# Unzip the images for SPM
gunzip "${out_dir}"/img.nii.gz "${out_dir}"/mask.nii.gz
