%% GENERATE_AND_SAVE_LOGS  Batch SerDes simulations and save Data/*.mat
%
% Defaults live in userSettings.m. For a guided experience, run:
%     runSwitchComp
%
% See also: runSwitchComp, userSettings, runConfig

clc;
bdclose('all');
clearvars -except allRuns
clear functions

if exist('setupProject', 'file') ~= 2 %#ok<EXIST>
    error(['Could not find setupProject.m. Set the MATLAB Current Folder to the ', ...
        'SwitchComp folder (the folder that contains setupProject.m), then run this script again.']);
end
setupProject();

opts = userSettings();
scenario = runSwitchComp('pickScenario', opts.scenarioGenerate, opts.askScenarioWhenGenerating, ...
    'Pick scenario to simulate (Cancel = use default from userSettings)');

fprintf('\n=== Generating logs: %s ===\n\n', scenario);
runSwitchComp('generate', scenario);
