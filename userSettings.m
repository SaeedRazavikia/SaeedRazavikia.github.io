function opts = userSettings()
%USERSETTINGS Defaults you can edit once — used by all entry points.
%
%   Edit the values below, save the file, then run:
%     runSwitchComp          % guided menu (easiest)
%   or
%     generate_and_save_logs % batch simulation
%     SNRvsMSE2func          % analysis + figures
%
%   See also: runSwitchComp, runConfig

%% --- Generation (generate_and_save_logs / runSwitchComp option 2) ----------
opts.scenarioGenerate = 'clean_default';

% When true, the script generate_and_save_logs.m shows a scenario menu first
% (MATLAB desktop only). The launcher always asks when you pick "Generate".
opts.askScenarioWhenGenerating = false;

%% --- Analysis (SNRvsMSE2func / runSwitchComp option 3) ---------------------
opts.scenarioAnalyze = 'noisy_default';

opts.askScenarioWhenAnalyzing = false;

% Multi-sample window width passed to analyzeSerDesRunLog (see its help).
opts.nEstimAnalyze = 1;

%% --- MAP path noise variance (passed to evaluateMapSum16BitAcrossRuns) ----
opts.mapSigma2 = 1e-1;

%% --- Cross-run statistic on decoded 16-bit words (Hard + MAP only) ------------
% func(X) must accept X of size [nRuns x nWords] (double uint16 values) and
% return a 1 x nWords row (one scalar per word time). Examples:
%   sum:  @(X) sum(X,1)
%   max:  @(X) max(X,[],1)   % NOT max(X,1) — that compares each element to 1
%   min:  @(X) min(X,[],1)
%   prod: @(X) prod(X,1)
%   mean: @(X) mean(X,1)
%
% estimateMmseSum16BitAcrossRuns is NOT driven by these options: it always
% implements the digit-sum / sum-of-integers MMSE path (see docs).
% MAP: sum -> fast sum-aggregate; max -> analyzeMaxAcrossRuns16bit_MAP (SNRvsMSE2max.m);
% prod and other stats -> joint-symbol exhaustive MAP (nRuns <= 5; SNRvsMSE2prod.m).
opts.crossRunFunc = @(X) sum(X,1);
opts.crossRunFuncName = 'sum';
% opts.crossRunFunc = @(X) max(X,[],1);
% opts.crossRunFuncName = 'max';
% opts.crossRunFunc = @(X) prod(X,1);
% opts.crossRunFuncName = 'prod';

end
