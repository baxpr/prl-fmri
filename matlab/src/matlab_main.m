function matlab_main(inp)

% Matlab processing would go here. This example just shows two ways of
% using SPM12 to display an image and print the resulting window. Note that
% uicontrols do not appear on the printed figure this way - an additional
% argument in favor of making QA PDFs in freeview later, instead.

% Convert the numerical parameter from string - matlab executables called
% from the command line have string arguments only.
param = str2double(inp.parameter_val);

% Use the batch facility
clear matlabbatch
matlabbatch{1}.spm.util.disp.data = {inp.img_nii};
matlabbatch{2}.spm.util.print.fname = fullfile(inp.out_dir,'batchfigure.pdf');
matlabbatch{2}.spm.util.print.fig.figname = 'Graphics';
matlabbatch{2}.spm.util.print.opts = 'pdf';
spm_jobman('run',matlabbatch);

% Use SPM functions directly
spm_image('Display',inp.img_nii);
spm_orthviews('Caption',1,sprintf('%s. Par=%0.2f',inp.label_info,param));
spm_print(fullfile(inp.out_dir,'funcfigure.pdf'),'Graphics','pdf');

