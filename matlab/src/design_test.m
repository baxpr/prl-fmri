% Scratchpad for model design

% Trial by trial stimulus/response data and trajectories, from eprime-3PRL
info = readtable('../../INPUTS/trialreport.csv');

% Just one run
D = info(info.Run==2,:);

% Trial duration from T1 to T3
D.T1_T3_Duration_fMRIsec = D.T3_FeedbackOnset_fMRIsec - D.T1_TrialStart_fMRIsec;


% Stats design job
clear matlabbatch
matlabbatch{1}.spm.stats.fmri_design.dir = {'../../OUTPUTS/spmtest'};
matlabbatch{1}.spm.stats.fmri_design.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_design.timing.RT = 1.3;
matlabbatch{1}.spm.stats.fmri_design.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_design.timing.fmri_t0 = 8;
matlabbatch{1}.spm.stats.fmri_design.sess.nscan = 297;

ind = ismember(D.Outcome,{'Win','Lose'});
matlabbatch{1}.spm.stats.fmri_design.sess.cond(1).name = 'Trial';
matlabbatch{1}.spm.stats.fmri_design.sess.cond(1).onset = D.T1_TrialStart_fMRIsec(ind);
matlabbatch{1}.spm.stats.fmri_design.sess.cond(1).duration = D.T1_T3_Duration_fMRIsec(ind);
matlabbatch{1}.spm.stats.fmri_design.sess.cond(1).tmod = [];
matlabbatch{1}.spm.stats.fmri_design.sess.cond(1).pmod(1) = ...
	struct('name','Psi2','param',D.traj_psi_2(ind)-2,'poly',1);
%matlabbatch{1}.spm.stats.fmri_design.sess.cond(1).pmod(2) = ...
%	struct('name','Win','param',double(strcmp(D.Outcome(ind),'Win')),'poly',1);
matlabbatch{1}.spm.stats.fmri_design.sess.cond(1).orth = 0;

matlabbatch{1}.spm.stats.fmri_design.sess.cond(2).name = 'Feedback';
matlabbatch{1}.spm.stats.fmri_design.sess.cond(2).onset = D.T3_FeedbackOnset_fMRIsec(ind);
matlabbatch{1}.spm.stats.fmri_design.sess.cond(2).duration = 1;
matlabbatch{1}.spm.stats.fmri_design.sess.cond(2).tmod = [];
matlabbatch{1}.spm.stats.fmri_design.sess.cond(2).pmod(1) = ...
	struct('name','Lose','param',double(strcmp(D.Outcome(ind),'Lose')),'poly',1);
matlabbatch{1}.spm.stats.fmri_design.sess.cond(2).orth = 0;


%matlabbatch{1}.spm.stats.fmri_design.sess.multi = {'../../OUTPUTS/spmtest_conds.mat'};
%matlabbatch{1}.spm.stats.fmri_design.sess.regress = struct('name', {}, 'val', {});
%matlabbatch{1}.spm.stats.fmri_design.sess.multi_reg = {motion_txt};
matlabbatch{1}.spm.stats.fmri_design.sess.hpf = 300;
matlabbatch{1}.spm.stats.fmri_design.fact = struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_design.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_design.volt = 1;
matlabbatch{1}.spm.stats.fmri_design.global = 'None';
matlabbatch{1}.spm.stats.fmri_design.mthresh = -Inf;
matlabbatch{1}.spm.stats.fmri_design.cvi = 'AR(1)';
save('../../OUTPUTS/spmtest_batch.mat','matlabbatch');
spm_jobman('run',matlabbatch)


