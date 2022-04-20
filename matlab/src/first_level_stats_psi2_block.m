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


%% Design
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
	
	% Initialize
	thist = trials(trials.Run==r,:);
	ind = ismember(thist.Outcome,{'Win','Lose'});
	ind_win = ismember(thist.Outcome,{'Win'});
	ind_lose = ismember(thist.Outcome,{'Lose'});
	c = 0;
	
	% Session-specific scans, regressors, params
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).scans = ...
		{inp.(['swfmri' num2str(r) '_nii'])};
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi = {''};
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).regress = ...
		struct('name', {}, 'val', {});
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).multi_reg = ...
		{fullfile(inp.out_dir,['motpar' num2str(r) '.txt'])};
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).hpf = hpf_sec;
	
	% Condition: block for start-to-feedback with (psi2-2) modulator
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
	
	% Condition: feedback events split win/lose
	c = c + 1;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).name = 'Feedback Win';
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).onset = ...
		thist.T3_FeedbackOnset_fMRIsec(ind_win);
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).duration = 1;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).tmod = [];
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).pmod = ...
		struct('name', {}, 'param', {}, 'poly', {});

	c = c + 1;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).name = 'Feedback Lose';
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).onset = ...
		thist.T3_FeedbackOnset_fMRIsec(ind_lose);
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).duration = 1;
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).tmod = [];
	matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).pmod = ...
		struct('name', {}, 'param', {}, 'poly', {});
	
	% Condition: single feedback event with win/lose modulator
	%c = c + 1;
	%matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).name = 'Feedback';
	%matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).onset = ...
	%	thist.T3_FeedbackOnset_fMRIsec(ind);
	%matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).duration = 1;
	%matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).tmod = [];
	%matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).pmod(1) = ...
	%	struct( ...
	%	'name','Lose', ...
	%	'param',double(strcmp(thist.Outcome(ind),'Lose')), ...
	%	'poly',1 ...
	%	);
	%matlabbatch{1}.spm.stats.fmri_spec.sess(r).cond(c).orth = 0;
	
end

%% Estimate
matlabbatch{2}.spm.stats.fmri_est.spmmat = ...
	fullfile(matlabbatch{1}.spm.stats.fmri_spec.dir,'SPM.mat');
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;


%% Contrasts
%
% Parameters are
%   1  Main block
%   2  psi2 modulator
%   3  Feedback event (win)
%   4  Feedback event (lose)
matlabbatch{3}.spm.stats.con.spmmat = ...
	matlabbatch{2}.spm.stats.fmri_est.spmmat;
matlabbatch{3}.spm.stats.con.delete = 1;
c = 0;

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Trial Block';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [1 0 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Psi2 Modulation';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 1 0 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Feedback Win';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 0 1 0];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Feedback Lose';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 0 0 1];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

c = c + 1;
matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = 'Feedback Win gt Lose';
matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = [0 0 1 -1];
matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';

% Inverse of all existing contrasts since SPM won't show us both sides
numc = numel(matlabbatch{3}.spm.stats.con.consess);
for k = 1:numc
        c = c + 1;
        matlabbatch{3}.spm.stats.con.consess{c}.tcon.name = ...
                ['Neg ' matlabbatch{3}.spm.stats.con.consess{c-numc}.tcon.name];
        matlabbatch{3}.spm.stats.con.consess{c}.tcon.weights = ...
                - matlabbatch{3}.spm.stats.con.consess{c-numc}.tcon.weights;
        matlabbatch{3}.spm.stats.con.consess{c}.tcon.sessrep = 'replsc';
end


%% Review design
matlabbatch{4}.spm.stats.review.spmmat = ...
	matlabbatch{2}.spm.stats.fmri_est.spmmat;
matlabbatch{4}.spm.stats.review.display.matrix = 1;
matlabbatch{4}.spm.stats.review.print = false;

matlabbatch{5}.cfg_basicio.run_ops.call_matlab.inputs{1}.string = ...
        fullfile(inp.out_dir,'first_level_design_psi2_block.png');
matlabbatch{5}.cfg_basicio.run_ops.call_matlab.outputs = {};
matlabbatch{5}.cfg_basicio.run_ops.call_matlab.fun = 'spm_window_print';


%% Save batch and run
save(fullfile(inp.out_dir,'spmbatch_first_level_stats_psi2_block.mat'),'matlabbatch')
spm_jobman('run',matlabbatch);

% And save contrast names
numc = numel(matlabbatch{3}.spm.stats.con.consess);
connames = table((1:numc)','VariableNames',{'ConNum'});
for k = 1:numc
	try
		connames.ConName{k,1} = ...
			matlabbatch{3}.spm.stats.con.consess{k}.tcon.name;
	catch
		connames.ConName{k,1} = ...
			matlabbatch{3}.spm.stats.con.consess{k}.fcon.name;
	end
end
writetable(connames,fullfile(inp.out_dir,'spm_contrast_names_psi2_block.csv'));


%% Results display
% Needed to create the spmT even if we don't get the figure window
xSPM = struct( ...
    'swd', matlabbatch{1}.spm.stats.fmri_spec.dir, ...
    'title', '', ...
    'Ic', 1, ...
    'n', 0, ...
    'Im', [], ...
    'pm', [], ...
    'Ex', [], ...
    'u', 0.005, ...
    'k', 10, ...
    'thresDesc', 'none' ...
    );
[hReg,xSPM] = spm_results_ui('Setup',xSPM);

% Show on the subject MNI anat
spm_sections(xSPM,hReg,inp.biasnorm_nii)

% Jump to global max activation
spm_mip_ui('Jump',spm_mip_ui('FindMIPax'),'glmax');

