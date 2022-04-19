function first_level_stats_psi2_block(inp)

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

% Compute trial duration from T1 to T3
trials.T1_T3_Duration_fMRIsec = ...
	trials.T3_FeedbackOnset_fMRIsec - trials.T1_TrialStart_fMRIsec;

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


%% Design and estimate
% 1. Cue-to-feedback block, all trials. Interpreted as the mean BOLD
%      response between cue and feedback, relative to baseline, at psi2 = 2.
% 2. Parametric response proportional to (psi2 - 2) for cue-to-feedback
%      block. Interpreted as additional BOLD response linear with psi2 when
%      psi2 is not = 2.
% 3. Event response to feedback, all trials. Interpreted as the response to
%      feedback for Win trials, relative to baseline. 
% 4. Additional response beyond 3 to Lose trials. Interpreted as the
%      difference in BOLD response between Lose and Win trials.
clear matlabbatch
matlabbatch{1}.spm.stats.fmri_spec.dir = ...
	{fullfile(inp.out_dir,'spm_psi2_block')};
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
	ind = ismember(thist.Outcome,{'Win','Lose'});
	c = 0;
	
	% Block for start-to-feedback with (psi2-2) modulator
	c = c + 1;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).name = 'Trial';
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).onset = ...
		thist.T1_TrialStart_fMRIsec(ind);
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).duration = ...
		thist.T1_T3_Duration_fMRIsec(ind);
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).tmod = [];
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).pmod(1) = ...
		struct('name','psi2','param',thist.traj_psi_2(ind)-2,'poly',1);
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).orth = 0;

	% Feedback event with win/lose modulator
	c = c + 1;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).name = 'Feedback';
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).onset = ...
		thist.T3_FeedbackOnset_fMRIsec(ind);
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).duration = 1;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).tmod = [];
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).pmod(1) = ...
		struct( ...
		'name','Lose', ...
		'param',double(strcmp(thist.Outcome(ind),'Lose')), ...
		'poly',1 ...
		);
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).orth = 0;

	% Other session-specific regressors and params
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


