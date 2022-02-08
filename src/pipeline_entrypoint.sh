#!/usr/bin/env bash
#
# Primary entrypoint

echo Running $(basename "${BASH_SOURCE}")

# Initialize defaults
export hpf_sec=200
export out_dir=/OUTPUTS

# Parse input options
while [[ $# -gt 0 ]]; do
    key="${1}"
    case $key in   
        --fmri1_niigz) export fmri1_niigz="${2}"; shift; shift ;;
        --fmri2_niigz) export fmri2_niigz="${2}"; shift; shift ;;
        --fmri3_niigz) export fmri3_niigz="${2}"; shift; shift ;;
        --fmri4_niigz) export fmri4_niigz="${2}"; shift; shift ;;
        --eprime_csv) export eprime_csv="${2}"; shift; shift ;;
        --hpf_sec) export hpf_sec="${2}"; shift; shift ;;
        --out_dir) export out_dir="${2}"; shift; shift ;;
        *) echo "Input ${1} not recognized" ; shift ;;
    esac
done

# Run the pipeline
xvfb-run -n $(($$ + 99)) -s '-screen 0 1600x1200x24 -ac +extension GLX' \
    bash pipeline_main.sh
