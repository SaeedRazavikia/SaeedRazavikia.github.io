%% SNRVSMSE2FUNC  Example analysis: MSE and BER vs Tx voltage
%
% Defaults live in userSettings.m. For a guided experience, run:
%     runSwitchComp
%
% See also: runSwitchComp, userSettings, runConfig

if exist('setupProject', 'file') ~= 2 %#ok<EXIST>
    error(['Could not find setupProject.m. Set the MATLAB Current Folder to the ', ...
        'SwitchComp folder (the folder that contains setupProject.m), then run this script again.']);
end
setupProject();

opts = userSettings();
scenario = runSwitchComp('pickScenario', opts.scenarioAnalyze, opts.askScenarioWhenAnalyzing, ...
    'Pick scenario to analyze (Cancel = use default from userSettings)');

fprintf('\n=== Running analysis: %s ===\n\n', scenario);
runSwitchComp('analyze', scenario);
