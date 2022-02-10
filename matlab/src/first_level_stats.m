function first_level_stats(inp)

%   Model T1_TrialStart, T2b_CardFlipOnset
%     (1) WinStay, WinSwitch, Lose   x   Easy, Hard
%     (2) Win, Lose                  x   Easy, Hard

% Load motion params
for r = 1:4
	tmp = readtable(inp.(['motpar' num2str(r) '_txt']),'FileType','text');
	mots{r} = zscore(table2array(tmp));
end

% Load trial timing info
ep = readtable(inp.trialreport_csv);

