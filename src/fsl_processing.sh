#!/usr/bin/env bash
#
# Motion correction, topup, and registration to T1 for an fMRI time series 
# with a matched time series or volume acquired with reverse phase encoding
# direction. Optionally, skip the topup step if the reverse phase encoded
# images aren't available.
#
# Relies on env vars exported from pipeline.sh to get arguments:
#    out_dir
#    pedir
#    vox_mm
#
# Results are
#    ctrrfmri_mean_all.nii.gz    Mean of mean fmris, topup-corrected and registered with T1
#    ctrrfmri?.nii.gz            The corrected and registered fMRI time series

# Get in working dir
cd "${out_dir}"

# White matter mask from slant
echo "White matter mask"
fslmaths seg -thr 39.5 -uthr 41.5 -bin tmp
fslmaths seg -thr 43.5 -uthr 45.5 -add tmp -bin wm
rm tmp.nii.gz

# Motion correction within run, and for the short topup series
echo "Motion correction"
for n in 1 2 3 4; do
    echo "    Run ${n}"
    mcflirt -in fmri${n} -meanvol -out rfmri${n} -plots
done

echo "    Topup run"
mcflirt -in fmritopup -meanvol -out rfmritopup


# Alignment between runs and overall mean fmri
echo "Aligning runs"
cp rfmri1_mean_reg.nii.gz rrfmri1_mean_reg.nii.gz
cp rfmri1.nii.gz rrfmri1.nii.gz
opts="-usesqform -searchrx -5 5 -searchry -5 5 -searchrz -5 5"
for n in 2 3 4; do
    echo "    Run ${n} to run 1"
    flirt ${opts} -in rfmri${n}_mean_reg -ref rrfmri1_mean_reg \
        -out rrfmri${n}_mean_reg -omat r${n}to1.mat
    flirt -applyxfm -init r${n}to1.mat -in rfmri${n} -ref rrfmri1_mean_reg -out rrfmri${n}
done

echo "    Topup run to run 1"
flirt ${opts} -in rfmritopup_mean_reg -ref rrfmri1_mean_reg -out rrfmritopup_mean_reg

echo "    Computing overall mean"
fslmaths rrfmri1_mean_reg -add rrfmri2_mean_reg \
    -add rrfmri3_mean_reg -add rrfmri4_mean_reg \
    -div 4 rrfmri_mean_all


# Run topup. After this, the 'tr' prefix files always contain the data that will be further
# processed.
echo "Running TOPUP"
run_topup.sh "${pedir}" rrfmri_mean_all rrfmritopup_mean_reg rrfmri1 rrfmri2 rrfmri3 rrfmri4

# Register corrected mean fmri to T1. biascorr is the adjusted T1 from cat12, ICV is the 
# ICV_NATIVE resource from cat12 that is masked to only brain.
echo "Coregistration"
epi_reg --epi=trrfmri_mean_all --t1=biascorr --t1brain=icv --wmseg=wm --out=ctrrfmri_mean_all

# Use flirt to resample to the desired voxel size, overwriting epi_reg output image
flirt -applyisoxfm "${vox_mm}" -init ctrrfmri_mean_all.mat -in trrfmri_mean_all \
	-ref biascorr -out ctrrfmri_mean_all

# Apply coregistration to the corrected time series
for n in 1 2 3 4; do
    flirt -applyisoxfm "${vox_mm}" -init ctrrfmri_mean_all.mat \
        -in trrfmri${n} -ref biascorr -out ctrrfmri${n}
done



# FIXME we are here
exit 0





# Give things more meaningful filenames
mv ctrrfmri_mean_all.nii.gz coregistered_mean_fmri.nii.gz



mv ctrrfmri_mean_all.mat corrected_fmri_to_t1.mat


mv trfwd_mean_reg.nii.gz mean_fmriFWD.nii.gz

mv ctrfwd.nii.gz coregistered_fmriFWD.nii.gz

mv rfwd_mean_reg.nii.gz mean_fmriFWD_no_topup.nii.gz
mv crfwd_mean_reg.nii.gz coregistered_mean_fmriFWD_no_topup.nii.gz
mv crfwd_mean_reg.mat  mean_fmriFWD_no_topup_to_t1.mat

if [[ "${run_topup}" == "yes" ]] ; then
	mv trrev_mean_reg.nii.gz mean_fmriREV.nii.gz
	mv ctrrev_mean_reg.nii.gz coregistered_mean_fmriREV.nii.gz
	mv rrev_mean_reg.nii.gz mean_fmriREV_no_topup.nii.gz
	mv crrev_mean_reg.nii.gz coregistered_mean_fmriREV_no_topup.nii.gz
	mv crrev_mean_reg.mat  mean_fmriREV_no_topup_to_t1.mat
fi

