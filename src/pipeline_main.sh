#!/usr/bin/env bash

echo Running $(basename "${BASH_SOURCE}")

# Initialize Freesurfer
. $FREESURFER_HOME/SetUpFreeSurfer.sh

# Copy inputs to the working directory
copy_inputs.sh

# FSL based motion correction, topup, registration
fsl_processing.sh

# Matlab/SPM for first level stats. Unzip .nii first
gunzip "${out_dir}"/ctrrfmri?.nii.gz \
    "${out_dir}"/ctrrfmri_mean_all.nii.gz \
    "${out_dir}"/biasnorm.nii.gz \
    "${out_dir}"/y_deffwd.nii.gz
run_spm12.sh "${MATLAB_RUNTIME}" function matlab_entrypoint \
    hpf_sec "${hpf_sec}" \
    fwhm_mm "${fwhm_mm}"

# Postprocessing
postprocessing.sh

# Freeview-based PDF creation
make_pdf.sh

# Finalize and organize outputs
finalize.sh
