% This script will test the matlab pipeline from the matlab command line -
% very useful for making sure it works before we bother to compile.

matlab_entrypoint( ...
	'fmri1_nii','../../OUTPUTS/fmri1.nii', ...
	'fmri2_nii','../../OUTPUTS/fmri2.nii', ...
	'fmri3_nii','../../OUTPUTS/fmri3.nii', ...
	'fmri4_nii','../../OUTPUTS/fmri4.nii', ...
	'out_dir','../../OUTPUTS' ...
	);
