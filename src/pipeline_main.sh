#!/usr/bin/env bash
#
# Main pipeline. We'll call the matlab part from here. The benefit of wrapping
# everything in a shell script like this is that we can more easily use shell
# commands to move files around, and use freeview after the matlab has finished 
# to create a QA PDF.

echo Running $(basename "${BASH_SOURCE}")

# Initialize Freesurfer
. $FREESURFER_HOME/SetUpFreeSurfer.sh

# Copy inputs to the working directory
copy_inputs.sh

# Shell script based preprocessing
preprocessing.sh

# Then the matlab. It is written so that we must pass the inputs as command
# line arguments, although we could use matlab's getenv to pull them from the
# environment instead if desired.
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
