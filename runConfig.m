function cfg = runConfig(scenario)
%RUNCONFIG Named scenarios for log generation and downstream analysis.
%
%   Purpose
%   -------
%   One place to define: which Simulink model to simulate, Tx voltage sweep,
%   number of random seeds, output MAT filename under Data/, and (for noisy
%   links) SNR, insertion loss, and sample time used to size additive noise.
%
%   Usage
%   -----
%   CFG = RUNCONFIG()            % same as RUNCONFIG('clean_default')
%   CFG = RUNCONFIG('noisy_default')
%
%   Scripts read CFG fields then save a MAT file; analysis scripts load the
%   same CFG.saveFile (or CFG.matFile + CFG.dataDir) so filenames stay in sync.
%
%   Scenarios (output is always <dataDir>/<matFile>, default dataDir = 'Data')
%   ---------------------------------------------------------------------------
%   Clean link (SerDes_Base_Link):
%     'clean_default'     -> saved_allRuns_with_voltage_low24.mat
%     'clean_low14'       -> saved_allRuns_with_voltage_low14.mat
%     'clean_voltage1'    -> saved_allRuns_with_voltage1.mat
%     'clean_voltage14'   -> saved_allRuns_with_voltage14.mat
%
%   Noisy link (Noisy_SerDes_Base_Link + Band-Limited White Noise):
%     'noisy_default'     -> small_with_voltage_and_noise_high64noisy.mat
%     'noisy_high54'      -> small_with_voltage_and_noise_high54noisy.mat
%     'noisy_low34'       -> small_with_voltage_and_noise_low34noisy.mat
%     'noisy_high34'      -> small_with_voltage_and_noise_high34noisy.mat
%
%   Common output fields (all scenarios)
%   --------------------------------------
%     .dataDir, .matFile, .saveFile  — folder + file + fullfile(dataDir, matFile)
%     .modelName, .stimBlk, .chanBlk — load_system target and mask paths
%     .txVoltList, .nSeeds
%     .quantizationBits — word width B for analysis (default 16).
%     .verbose          — passed into analyze* / estimate* when supported.
%
%   Extra fields for noisy_* only
%   -----------------------------
%     .SNR_dB, .loss_dB, .Ts — used by generate_and_save_logs to set noise Cov.
%     isfield(cfg,'SNR_dB') is the script’s test for “noisy scenario”.
%
%   Extending
%   ---------
%   Add a new validatestring name and switch-case; keep .matFile unique so runs
%   do not overwrite each other. Update validatestring() and localScenarioList in
%   runSwitchComp.m so the menu and scripts stay in sync.
%
%   See also: userSettings, runSwitchComp

if nargin < 1 || isempty(scenario)
    scenario = "clean_default";
elseif isstring(scenario) && strlength(scenario) == 0
    scenario = "clean_default";
end
scenario = lower(char(string(scenario)));
scenario = validatestring(scenario, { ...
    'clean_default', 'clean_low14', 'clean_voltage1', 'clean_voltage14', ...
    'noisy_default', 'noisy_high54', 'noisy_low34', 'noisy_high34'}, ...
    mfilename, 'scenario');

cfg.dataDir = 'Data';
cfg.quantizationBits = 16;
cfg.verbose = false;

switch scenario
    case 'clean_default'
        cfg.matFile = 'saved_allRuns_with_voltage_low24.mat';
        cfg.modelName = 'SerDes_Base_Link';
        cfg.txVoltList = [5 10 20 30 40 50 60 80 100] * 1e-2;
        cfg.nSeeds = 4;

    case 'clean_low14'
        cfg.matFile = 'saved_allRuns_with_voltage_low14.mat';
        cfg.modelName = 'SerDes_Base_Link';
        cfg.txVoltList = [5 10 20 30 40 50 60 80 100] * 1e-2;
        cfg.nSeeds = 4;

    case 'clean_voltage1'
        cfg.matFile = 'saved_allRuns_with_voltage1.mat';
        cfg.modelName = 'SerDes_Base_Link';
        cfg.txVoltList = [5 10 20 30 40 50 60 80 100] * 1e-2;
        cfg.nSeeds = 4;

    case 'clean_voltage14'
        cfg.matFile = 'saved_allRuns_with_voltage14.mat';
        cfg.modelName = 'SerDes_Base_Link';
        cfg.txVoltList = [5 10 20 30 40 50 60 80 100] * 1e-2;
        cfg.nSeeds = 4;

    case 'noisy_default'
        cfg.matFile = 'small_with_voltage_and_noise_high64noisy.mat';
        cfg.modelName = 'Noisy_SerDes_Base_Link';
        cfg.txVoltList = [0.6 0.8 1];
        cfg.nSeeds = 16;
        cfg.SNR_dB = 15;
        cfg.loss_dB = 24;
        cfg.Ts = 1.953125e-12;

    case 'noisy_high54'
        cfg.matFile = 'small_with_voltage_and_noise_high54noisy.mat';
        cfg.modelName = 'Noisy_SerDes_Base_Link';
        cfg.txVoltList = [0.6 0.8 1];
        cfg.nSeeds = 16;
        cfg.SNR_dB = 15;
        cfg.loss_dB = 24;
        cfg.Ts = 1.953125e-12;

    case 'noisy_low34'
        cfg.matFile = 'small_with_voltage_and_noise_low34noisy.mat';
        cfg.modelName = 'Noisy_SerDes_Base_Link';
        cfg.txVoltList = [0.6 0.8 1];
        cfg.nSeeds = 16;
        cfg.SNR_dB = 15;
        cfg.loss_dB = 24;
        cfg.Ts = 1.953125e-12;

    case 'noisy_high34'
        cfg.matFile = 'small_with_voltage_and_noise_high34noisy.mat';
        cfg.modelName = 'Noisy_SerDes_Base_Link';
        cfg.txVoltList = [0.6 0.8 1];
        cfg.nSeeds = 16;
        cfg.SNR_dB = 15;
        cfg.loss_dB = 24;
        cfg.Ts = 1.953125e-12;
end

cfg.saveFile = fullfile(cfg.dataDir, cfg.matFile);
cfg.stimBlk = [cfg.modelName '/Stimulus/Primary/MATLAB System'];
cfg.chanBlk = [cfg.modelName '/Analog Channel'];

end
