function matlab_entrypoint(varargin)

% Parse inputs
P = inputParser;
addOptional(P,'fmri1_nii','/OUTPUTS/ctrrfmri1.nii')
addOptional(P,'fmri2_nii','/OUTPUTS/ctrrfmri2.nii')
addOptional(P,'fmri3_nii','/OUTPUTS/ctrrfmri3.nii')
addOptional(P,'fmri4_nii','/OUTPUTS/ctrrfmri4.nii')
addOptional(P,'deffwd_nii','/OUTPUTS/y_deffwd.nii')
addOptional(P,'biasnorm_nii','/OUTPUTS/biasnorm.nii')
addOptional(P,'eprime_csv','/OUTPUTS/eprime.csv')
addOptional(P,'hpf_sec','200')
addOptional(P,'fwhm_mm','6')
addOptional(P,'out_dir','/OUTPUTS');
parse(P,varargin{:});
disp(P.Results)

% Run the actual pipeline
matlab_main(P.Results);

% Exit
if isdeployed
	exit
end
