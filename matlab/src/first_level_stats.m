function first_level_stats(inp)

%   Model T1_TrialStart, T2b_CardFlipOnset
%     (1) WinStay, WinSwitch, Lose   x   Easy, Hard
%     (2) Win, Lose                  x   Easy, Hard

% Filter param
hpf_sec = str2double(inp.hpf_sec);

% Save motion params as .mat
for r = 1:4
	mot = readtable(inp.(['motpar' num2str(r) '_txt']),'FileType','text');
	mot = zscore(table2array(mot));
	writematrix(mot, fullfile(inp.out_dir,['motpar' num2str(r) '.txt']))
end

% Load trial timing info
trials = readtable(inp.trialreport_csv);

% Get TRs and check
N = nifti(inp.swfmri1_nii);
tr = N.timing.tspace;
for r = 2:4
	N = nifti(inp.(['swfmri' num2str(r) '_nii']));
	if abs(N.timing.tspace-tr) > 0.001
		error('TR not matching for run %d',r)
	end
end
fprintf('ALERT: USING TR OF %0.3f sec FROM FMRI NIFTI\n',tr)


%% Win vs Lose design and estimate
clear matlabbatch
matlabbatch{1}.spm.stats.fmri_spec.dir = ...
	{fullfile(inp.out_dir,'spm_stayswitchlose')};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = tr;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = -Inf;
matlabbatch{1}.spm.stats.fmri_spec.mask = {[spm('dir') '/tpm/mask_ICV.nii']};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

for r = 1:4
	
	thist = trials(trials.Run==r,:);
	c = 0;
	
	c = c + 1;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).scans = ...
		{inp.(['swfmri' num2str(r) '_nii'])};
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).name = 'Win_TrialStart';
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).onset = ...
		thist.T1_TrialStart_fMRIsec(ismember(thist.Outcome,'Win'));
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).duration = 0;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).tmod = 0;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).pmod = ...
		struct('name', {}, 'param', {}, 'poly', {});
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).orth = 1;
	
	c = c + 1;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).name = 'Win_CardFlip';
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).onset = ...
		thist.T2b_CardFlipOnset_fMRIsec(ismember(thist.Outcome,'Win'));
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).duration = 0;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).tmod = 0;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).pmod = ...
		struct('name', {}, 'param', {}, 'poly', {});
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).orth = 1;

	c = c + 1;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).scans = ...
		{inp.(['swfmri' num2str(r) '_nii'])};
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).name = 'Lose_TrialStart';
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).onset = ...
		thist.T1_TrialStart_fMRIsec(ismember(thist.Outcome,'Lose'));
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).duration = 0;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).tmod = 0;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).pmod = ...
		struct('name', {}, 'param', {}, 'poly', {});
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).orth = 1;
	
	c = c + 1;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).name = 'Lose_CardFlip';
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).onset = ...
		thist.T2b_CardFlipOnset_fMRIsec(ismember(thist.Outcome,'Lose'));
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).duration = 0;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).tmod = 0;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).pmod = ...
		struct('name', {}, 'param', {}, 'poly', {});
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).orth = 1;

	matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi = {''};
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).regress = ...
		struct('name', {}, 'val', {});
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi_reg = ...
		{fullfile(inp.out_dir,['motpar' num2str(r) '.txt'])};
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).hpf = hpf_sec;
	
end

matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
	fullfile(matlabbatch{1}.spm.stats.fmri_spec.dir,'SPM.mat');
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

spm_jobman('run',matlabbatch);


