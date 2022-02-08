#!/usr/bin/env bash
#
# Postprocessing, done after the other parts of the pipeline are run.
#
# For this example, all we do is gzip the output images (required for all
# Niftis on XNAT), and move the output files around in a way that's friendly to
# XNAT/DAX.

echo Running $(basename "${BASH_SOURCE}")

# Remove copied inputs that we don't need anymore
rm "${out_dir}"/img.nii
rm "${out_dir}"/mask.nii

# The only output of this pipeline is the PDF.
mkdir "${out_dir}"/PDF
mv "${out_dir}"/demo.pdf "${out_dir}"/PDF

