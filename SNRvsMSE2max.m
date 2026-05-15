%% SNRVSMSE2MAX  Hard max vs vector-observation MAP max (matches parent SNRvsMSE2max.m)
%
% Defaults: userSettings.m (set crossRunFuncName = 'max') and scenarioAnalyze.
% Equivalent to runSwitchComp('analyze', ...) when max is configured.
%
% See also: runSwitchComp, analyzeMaxAcrossRuns16bit, analyzeMaxAcrossRuns16bit_MAP

if exist('setupProject', 'file') ~= 2 %#ok<EXIST>
    error(['Could not find setupProject.m. Set the MATLAB Current Folder to the ', ...
        'SwitchComp folder, then run this script again.']);
end
setupProject();

opts = userSettings();
if ~strcmpi(strtrim(opts.crossRunFuncName), 'max')
    warning('SNRvsMSE2max:NotMax', ...
        'userSettings.crossRunFuncName is not ''max''; analysis still runs the max MAP path via runSwitchComp.');
end

scenario = runSwitchComp('pickScenario', opts.scenarioAnalyze, opts.askScenarioWhenAnalyzing, ...
    'Pick scenario to analyze (Cancel = default from userSettings)');

fprintf('\n=== Running max analysis: %s ===\n\n', scenario);
runSwitchComp('analyze', scenario, opts.nEstimAnalyze, opts.mapSigma2);
