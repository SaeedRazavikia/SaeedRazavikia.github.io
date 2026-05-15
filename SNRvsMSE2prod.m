%% SNRVSMSE2PROD  Hard product vs joint-symbol MAP product across runs
%
% Defaults: userSettings.m (set crossRunFuncName = 'prod') and scenarioAnalyze.
% Equivalent to runSwitchComp('analyze', ...) when product is configured.
%
% MAP uses joint-symbol exhaustive inference (full y = [y_1,...,y_K] per symbol),
% then prod on decoded 16-bit words. Requires nRuns <= 5 (seeds per voltage).
%
% See also: runSwitchComp, evaluateHardSum16BitAcrossRuns, evaluateMapSum16BitAcrossRuns

if exist('setupProject', 'file') ~= 2 %#ok<EXIST>
    error(['Could not find setupProject.m. Set the MATLAB Current Folder to the ', ...
        'SwitchComp folder, then run this script again.']);
end
setupProject();

opts = userSettings();
if ~any(strcmpi(strtrim(opts.crossRunFuncName), {'prod', 'product'}))
    warning('SNRvsMSE2prod:NotProd', ...
        ['userSettings.crossRunFuncName is not ''prod''; analysis still uses ', ...
        'crossRunFunc / crossRunFuncName from userSettings via runSwitchComp.']);
end

scenario = runSwitchComp('pickScenario', opts.scenarioAnalyze, opts.askScenarioWhenAnalyzing, ...
    'Pick scenario to analyze (Cancel = default from userSettings)');

fprintf('\n=== Running product analysis: %s ===\n\n', scenario);
runSwitchComp('analyze', scenario, opts.nEstimAnalyze, opts.mapSigma2);
