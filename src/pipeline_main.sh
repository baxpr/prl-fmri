#!/usr/bin/env bash

echo Running $(basename "${BASH_SOURCE}")

# Initialize Freesurfer
. $FREESURFER_HOME/SetUpFreeSurfer.sh

# Copy inputs to the working directory
copy_inputs.sh

# Shell script based preprocessing
preprocessing.sh

# Matlab/SPM
run_spm12.sh "${MATLAB_RUNTIME}" function matlab_entrypoint \
    img_nii "${out_dir}"/img.nii \
    parameter_val "${parameter_val}" \
    label_info "${label_info}" \
    out_dir "${out_dir}"

# Postprocessing
postprocessing.sh

# Freeview-based PDF creation
make_pdf.sh

# Finalize and organize outputs
finalize.sh
