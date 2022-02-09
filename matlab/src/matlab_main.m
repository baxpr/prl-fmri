function matlab_main(inp)

hpf_sec = str2double(inp.hpf_sec);
fwhm_mm = str2double(inp.fwhm_mm);

clear matlabbatch

% Realign
job_realign(inp);

% Coregister to T1


% Apply cat12 warp
% Smooth
% First level stats
%   Model T1_TrialStart, T2b_CardFlipOnset
%     (1) WinStay, WinSwitch, Lose   x   Easy, Hard
%     (2) Win, Lose                  x   Easy, Hard
% Create contrast images

