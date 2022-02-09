#!/usr/bin/env bash

echo Running $(basename "${BASH_SOURCE}")

# Initialize Freesurfer
. $FREESURFER_HOME/SetUpFreeSurfer.sh

# Copy inputs to the working directory
copy_inputs.sh

# FSL based motion

# Matlab/SPM. Relies mostly on the coded default inputs in the matlab entrypoint
run_spm12.sh "${MATLAB_RUNTIME}" function matlab_entrypoint \
    hpf_sec "${hpf_sec}" \
    fwhm_mm "${fwhm_mm}"

# Postprocessing
postprocessing.sh

# Freeview-based PDF creation
make_pdf.sh

# Finalize and organize outputs
finalize.sh
