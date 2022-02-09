function matlab_main(inp)

hpf_sec = str2double(inp.hpf_sec);
fwhm_mm = str2double(inp.fwhm_mm);

clear matlabbatch

% Realign
% Coregister to T1
% Apply cat12 warp
% Smooth
% First level stats
%   Model T1_TrialStart, T2b_CardFlipOnset
%     (1) WinStay, WinSwitch, Lose   x   Easy, Hard
%     (2) Win, Lose                  x   Easy, Hard
% Create contrast images


% Realign four sessions and create mean fmri image. Creates four param
% files rp_fmri?.txt, and meanfmri1.nii
matlabbatch{1}.spm.spatial.realign.estwrite.data = {
	{inp.fmri1_nii}
	{inp.fmri2_nii}
	{inp.fmri3_nii}
	{inp.fmri4_nii}
	}';
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [0 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 0;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

spm_jobman('run',matlabbatch)

