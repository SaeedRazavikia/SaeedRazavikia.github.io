% SwitchComp — SerDes log batch simulation and MMSE / MAP analysis
%
% Quick start
% -----------
%   1. cd to this folder (must contain setupProject.m).
%   2. runSwitchComp       % menu: setup, generate, analyze, edit userSettings
%
% Classic scripts (after editing userSettings.m)
% ------------------------------------------------
%       generate_and_save_logs
%       SNRvsMSE2func
%
% Configuration
% ---------------
%   userSettings.m — defaults for scripts (scenarios, optional menus, nEstim, MAP sigma)
%   runConfig.m      — scenario definitions (must match scenario list in runSwitchComp)
%
% Main files (project root)
% --------------------------
%   runSwitchComp.m             — **start here**: menu + all generate/analyze code
%   userSettings.m              — edit your defaults
%   setupProject.m              — add utils, data, models to path
%   generate_and_save_logs.m    — thin wrapper → runSwitchComp('generate',...)
%   SNRvsMSE2func.m             — thin wrapper → runSwitchComp('analyze',...)
%   runConfig.m                 — named scenarios and output filenames
%   linkExampleModels.m         — copy example .slx into models/ when possible
%
% Utilities (utils/)
% ------------------
%   batchSimulateSerDesLink, batchSimulateNoisySerDesLink
%   analyzeSerDesRunLog, analyzeAllSerDesRuns
%   estimateMmseSum16BitAcrossRuns, evaluateHardSum16BitAcrossRuns
%   evaluateMapSum16BitAcrossRuns, pam4MapSumEstimator
%   analyzeMaxAcrossRuns16bit, analyzeMaxAcrossRuns16bit_MAP
%   SNRvsMSE2max, SNRvsMSE2prod
%
% Further reading
% -----------------
%   docs/READ_THIS_FIRST.md — start here for collaborators (order + FAQ)
%   README.md, models/README.txt, utils/README.txt
%   docs/SwitchComp_CrossRun_Estimators.md, docs/SwitchComp_Slides_and_Handout.md
