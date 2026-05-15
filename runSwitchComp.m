function varargout = runSwitchComp(varargin)
%RUNSWITCHCOMP One-file launcher: menu, generate logs, analyze, pick scenario.
%
%   runSwitchComp
%       Guided menu (recommended for new users).
%
%   runSwitchComp('generate', scenario)
%       Batch Simulink runs and save Data/*.mat (used by generate_and_save_logs).
%
%   runSwitchComp('analyze', scenario)
%   runSwitchComp('analyze', scenario, nEstim, mapSigma2)
%       Load MAT and plot MSE/BER (used by SNRvsMSE2func).
%
%   scenario = runSwitchComp('pickScenario', defaultScenario, forceAsk, dialogTitle)
%       Optional menu / prompt (used when userSettings asks before scripts).
%
%   See also: userSettings, runConfig, generate_and_save_logs, SNRvsMSE2func

if nargin == 0
    localRunMenu();
    return
end

cmd = varargin{1};
switch cmd
    case 'generate'
        if numel(varargin) < 2
            error('runSwitchComp:Usage', 'Use runSwitchComp(''generate'',scenario).');
        end
        localGenerateLogs(varargin{2});

    case 'analyze'
        if numel(varargin) < 2
            error('runSwitchComp:Usage', 'Use runSwitchComp(''analyze'',scenario,...).');
        end
        sc = varargin{2};
        if numel(varargin) >= 4
            localAnalyzeLogs(sc, varargin{3}, varargin{4});
        elseif numel(varargin) >= 3
            localAnalyzeLogs(sc, varargin{3});
        else
            localAnalyzeLogs(sc);
        end

    case 'pickScenario'
        if nargout < 1
            error('runSwitchComp:PickScenario', ...
                'Use: scenario = runSwitchComp(''pickScenario'',default,force,title).');
        end
        if numel(varargin) < 4
            error('runSwitchComp:PickScenario', 'Expected four inputs after ''pickScenario''.');
        end
        varargout{1} = localPickScenario(varargin{2}, varargin{3}, varargin{4});

    otherwise
        error('runSwitchComp:Unknown', ...
            'Unknown command "%s". Run runSwitchComp with no arguments for the menu.', cmd);
end

end

%% -------------------------------------------------------------------------
function localRunMenu()

if exist('setupProject', 'file') ~= 2 %#ok<EXIST>
    error(['Could not find setupProject.m. Set MATLAB Current Folder to the ', ...
        'SwitchComp folder, then run runSwitchComp again.']);
end
setupProject();

root = fileparts(which('runSwitchComp'));

while true
    choice = menu('SwitchComp — what would you like to do?', ...
        'Link example models (first-time setup)', ...
        'Generate simulation logs (pick scenario)', ...
        'Run MSE / BER analysis (pick scenario)', ...
        'Open userSettings.m (edit defaults)', ...
        'Show tips / check files on disk', ...
        'Open READ_THIS_FIRST (guide for collaborators)', ...
        'Exit'); %#ok<MENU>

    if choice == 0 || choice == 7
        fprintf('\nGoodbye.\n\n');
        break;
    end

    switch choice
        case 1
            linkExampleModels;

        case 2
            opts = userSettings();
            scenario = localPickScenario(opts.scenarioGenerate, true, ...
                'Pick scenario to simulate');
            fprintf('\n=== Generating logs: %s ===\n\n', scenario);
            localGenerateLogs(scenario);

        case 3
            opts = userSettings();
            scenario = localPickScenario(opts.scenarioAnalyze, true, ...
                'Pick scenario to analyze (MAT file must already exist)');
            fprintf('\n=== Running analysis: %s ===\n\n', scenario);
            localAnalyzeLogs(scenario);

        case 4
            userFile = fullfile(root, 'userSettings.m');
            if ~isfile(userFile)
                error('Missing file: %s', userFile);
            end
            fprintf('Opening: %s\n', userFile);
            edit(userFile);

        case 5
            localPrintTips();

        case 6
            docFile = fullfile(root, 'docs', 'READ_THIS_FIRST.md');
            if ~isfile(docFile)
                error('Missing file: %s', docFile);
            end
            fprintf('Opening: %s\n', docFile);
            edit(docFile);
    end
end

end

%% -------------------------------------------------------------------------
function scenarios = localScenarioList()
% Keep identical to the name list inside runConfig.m (validatestring).

scenarios = { ...
    'clean_default', ...
    'clean_low14', ...
    'clean_voltage1', ...
    'clean_voltage14', ...
    'noisy_default', ...
    'noisy_high54', ...
    'noisy_low34', ...
    'noisy_high34'};
end

%% -------------------------------------------------------------------------
function scenario = localPickScenario(defaultScenario, forceAsk, dialogTitle)

scenarios = localScenarioList();

if ~forceAsk
    scenario = defaultScenario;
    return
end

if usejava('desktop')
    ix = menu(dialogTitle, scenarios{:}); %#ok<MENU>
    if ix < 1
        scenario = defaultScenario;
        fprintf('Using default scenario: %s\n', scenario);
    else
        scenario = scenarios{ix};
    end
    return
end

fprintf('\n%s\n', dialogTitle);
for k = 1:numel(scenarios)
    fprintf('  %2d) %s\n', k, scenarios{k});
end
r = input(sprintf('Enter 1-%d (empty = default "%s"): ', numel(scenarios), defaultScenario), 's');
if isempty(strtrim(r))
    scenario = defaultScenario;
else
    kk = str2double(r);
    if ~(isscalar(kk) && kk >= 1 && kk <= numel(scenarios) && kk == floor(kk))
        error('Invalid choice. Run again and pick a number from the list.');
    end
    scenario = scenarios{kk};
end

end

%% -------------------------------------------------------------------------
function localPrintTips()

fprintf('\n');
fprintf('--- SwitchComp: quick tips ---\n\n');
fprintf('1) Current Folder = SwitchComp (folder that contains setupProject.m).\n');
fprintf('2) First time: use menu item "Link example models" or copy .slx into models/.\n');
fprintf('3) Edit userSettings.m for default scenarios and optional script menus.\n');
fprintf('4) Documentation: docs/READ_THIS_FIRST.md, README.md, help Contents, utils/README.txt\n\n');

root = fileparts(which('runSwitchComp'));
fprintf('Project folder: %s\n', root);
fprintf('Model SerDes_Base_Link.slx present:        %d\n', ...
    isfile(fullfile(root, 'models', 'SerDes_Base_Link.slx')));
fprintf('Model Noisy_SerDes_Base_Link.slx present: %d\n', ...
    isfile(fullfile(root, 'models', 'Noisy_SerDes_Base_Link.slx')));

cfgN = runConfig('noisy_default');
pN = fullfile(root, cfgN.saveFile);
fprintf('Have noisy_default MAT:                  %d  (%s)\n', isfile(pN), pN);

cfgC = runConfig('clean_default');
pC = fullfile(root, cfgC.saveFile);
fprintf('Have clean_default MAT:                  %d  (%s)\n', isfile(pC), pC);
fprintf('\n');

end

%% -------------------------------------------------------------------------
function localGenerateLogs(scenario)

if nargin < 1 || isempty(scenario)
    error('Missing scenario (e.g. ''noisy_default'').');
end

wf = which('runSwitchComp');
if isempty(wf)
    error('runSwitchComp is not on the MATLAB path (cd into SwitchComp).');
end
projectRoot = fileparts(wf);

cfg = runConfig(scenario);
modelName   = cfg.modelName;
stimBlk     = cfg.stimBlk;
chanBlk     = cfg.chanBlk;
txVoltList = cfg.txVoltList;
dataDir     = cfg.dataDir;
saveFile    = fullfile(projectRoot, cfg.dataDir, cfg.matFile);

seeds = randi([1, 2^31-1], cfg.nSeeds, 1);

outDir = fullfile(projectRoot, dataDir);
if ~isfolder(outDir)
    mkdir(outDir);
end

rng('shuffle');

fprintf('Scenario: %s\n', scenario);
fprintf('Output file: %s\n', saveFile);
fprintf('Generated Tx voltage swing values:\n');
disp(txVoltList)

fprintf('Generated seeds:\n');
disp(seeds.')

load_system(modelName);

if isfield(cfg, 'SNR_dB')
    SNR_dB  = cfg.SNR_dB;
    loss_dB = cfg.loss_dB;
    Ts      = cfg.Ts;

    V_amp = max(txVoltList) / 4;
    P_tx = mean([V_amp^2, V_amp^2, (V_amp/3)^2, (V_amp/3)^2]) / 50;
    P_rx = P_tx * 10^(-loss_dB/10);
    noisePowerList = (P_rx / 10^(SNR_dB/10)) * Ts;

    fprintf('Generated noise power values:\n');
    disp(noisePowerList)

    noiseBlkList = find_system(modelName, ...
        'LookUnderMasks', 'all', ...
        'FollowLinks', 'on', ...
        'RegExp', 'on', ...
        'Name', 'Band-Limited.*White Noise');

    if isempty(noiseBlkList)
        error('Could not find the Band-Limited White Noise block in model "%s".', modelName);
    end

    noiseBlk = noiseBlkList{1};
    fprintf('Using noise block:\n%s\n', noiseBlk);

    fixedStep = get_param(modelName, 'FixedStep');
    fprintf('Model fixed-step size:\n%s\n', fixedStep);

    fprintf('Running simulations...\n');
    allRuns = batchSimulateNoisySerDesLink( ...
        modelName, seeds, txVoltList, noisePowerList, ...
        stimBlk, chanBlk, noiseBlk, fixedStep);

    S = struct();
    S.allRuns = allRuns;
    S.seeds = seeds;
    S.txVoltList = txVoltList;
    S.noisePowerList = noisePowerList;
    S.modelName = modelName;
    S.stimBlk = stimBlk;
    S.chanBlk = chanBlk;
    S.noiseBlk = noiseBlk;
    S.fixedStep = fixedStep;
else
    fprintf('Running simulations...\n');
    allRuns = batchSimulateSerDesLink(modelName, seeds, txVoltList);

    S = struct();
    S.allRuns = allRuns;
    S.seeds = seeds;
    S.txVoltList = txVoltList;
    S.modelName = modelName;
    S.stimBlk = stimBlk;
    S.chanBlk = chanBlk;
end

save(saveFile, '-struct', 'S', '-v7.3');

fprintf('\nSaved logs to file: %s\n', saveFile);

end

%% -------------------------------------------------------------------------
function localAnalyzeLogs(scenario, nEstim, mapSigma2)

if nargin < 1 || isempty(scenario)
    error('Missing scenario name.');
end

opts = userSettings();
if nargin < 2 || isempty(nEstim)
    nEstim = opts.nEstimAnalyze;
end
if nargin < 3 || isempty(mapSigma2)
    mapSigma2 = opts.mapSigma2;
end

if ~isfield(opts, 'crossRunFunc') || isempty(opts.crossRunFunc)
    crossFn = @(X) sum(X,1);
elseif ~isa(opts.crossRunFunc, 'function_handle')
    error('userSettings: if set, opts.crossRunFunc must be a function_handle (see userSettings.m).');
else
    crossFn = opts.crossRunFunc;
end
if ~isfield(opts, 'crossRunFuncName') || isempty(strtrim(opts.crossRunFuncName))
    crossName = 'sum';
else
    crossName = strtrim(opts.crossRunFuncName);
end

cfg = runConfig(scenario);
verbose = cfg.verbose;
B = cfg.quantizationBits;

wf = which('runSwitchComp');
if isempty(wf)
    error('runSwitchComp is not on the MATLAB path (cd into SwitchComp).');
end
projectRoot = fileparts(wf);
saveFile = fullfile(projectRoot, cfg.saveFile);
b = 2^B;

if ~isfile(saveFile)
    error(['Saved file not found:\n  %s\n\n', ...
        'Generate logs for this scenario first (runSwitchComp menu or generate_and_save_logs).'], saveFile);
end

S = load(saveFile, 'allRuns', 'seeds', 'txVoltList', 'modelName', 'stimBlk', 'chanBlk');

allRuns    = S.allRuns;
seeds      = S.seeds;
txVoltList = S.txVoltList;
modelName  = S.modelName;
stimBlk    = S.stimBlk;
chanBlk    = S.chanBlk;

fprintf('Loaded allRuns from file: %s\n', saveFile);
fprintf('Loaded %d runs.\n', numel(allRuns));

fprintf('Seeds used:\n');
disp(seeds.');

fprintf('Tx voltage values:\n');
disp(txVoltList);

fprintf('Model name: %s\n', modelName);
fprintf('Stimulus block: %s\n', stimBlk);
fprintf('Channel block: %s\n', chanBlk);

nVolt  = numel(txVoltList);

sumMSEMMSE_vs_Volt = zeros(1, nVolt);
sumMSEHard_vs_Volt = zeros(1, nVolt);
sumMSEMap_vs_Volt =  zeros(1, nVolt);

sumErrRateMMSE_vs_Volt = zeros(1, nVolt);
sumErrRateHard_vs_Volt = zeros(1, nVolt);
sumErrRateMap_vs_Volt = zeros(1, nVolt);

for iVolt = 1:nVolt

    thisVolt = txVoltList(iVolt);

    runIdxThisVolt = find(abs([allRuns.txVoltage] - thisVolt) < 1e-12);
    if isempty(runIdxThisVolt)
        runIdxThisVolt = find([allRuns.txVoltage] == thisVolt);
    end

    results = analyzeAllSerDesRuns(allRuns(runIdxThisVolt), nEstim, verbose);
    runIdxLocal = 1:numel(results);

    if strcmpi(crossName, 'max')
        % Dedicated max path (vector-observation MAP from SNRvsMSE2max / parent utils)
        maxResultHard = analyzeMaxAcrossRuns16bit(results, runIdxLocal, verbose);
        maxResultMAP = analyzeMaxAcrossRuns16bit_MAP(results, runIdxLocal, mapSigma2, verbose);

        sumMSEHard_vs_Volt(iVolt) = maxResultHard.maxMSE / b^2;
        sumMSEMap_vs_Volt(iVolt) = maxResultMAP.wordMSE / b^2;
        sumErrRateHard_vs_Volt(iVolt) = maxResultHard.ber;
        sumErrRateMap_vs_Volt(iVolt) = maxResultMAP.ber;

        sumResultMMSE = estimateMmseSum16BitAcrossRuns(results, runIdxLocal, false);
        sumMSEMMSE_vs_Volt(iVolt) = sumResultMMSE.sumMSE / b^2;
        sumErrRateMMSE_vs_Volt(iVolt) = sumResultMMSE.sumErrRate;

        fprintf('Voltage = %.4f V | Hard MSE = %.4e | MAP MSE = %.4e\n', ...
            thisVolt, sumMSEHard_vs_Volt(iVolt), sumMSEMap_vs_Volt(iVolt));
        fprintf('Voltage = %.4f V | Hard BER = %.4e | MAP BER = %.4e\n', ...
            thisVolt, sumErrRateHard_vs_Volt(iVolt), sumErrRateMap_vs_Volt(iVolt));
    else
        sumResultMMSE = estimateMmseSum16BitAcrossRuns(results, runIdxLocal, verbose);
        sumResultHard = evaluateHardSum16BitAcrossRuns(results, runIdxLocal, crossFn, crossName, verbose);
        sumResultMAP = evaluateMapSum16BitAcrossRuns(results, runIdxLocal, mapSigma2, ...
            crossFn, [], crossName, verbose);

        sumMSEMMSE_vs_Volt(iVolt) = sumResultMMSE.sumMSE/b^2;
        sumMSEHard_vs_Volt(iVolt) = sumResultHard.funcMSE/b^2;
        sumMSEMap_vs_Volt(iVolt) = sumResultMAP.funcMSE / b^2;

        sumErrRateMMSE_vs_Volt(iVolt) = sumResultMMSE.sumErrRate;
        sumErrRateHard_vs_Volt(iVolt) = sumResultHard.funcErrRate;
        if isfield(sumResultMAP, 'funcBER')
            sumErrRateMap_vs_Volt(iVolt) = sumResultMAP.funcBER;
        else
            sumErrRateMap_vs_Volt(iVolt) = sumResultMAP.funcErrRate;
        end

        fprintf('Voltage = %.4f V | Hard MSE = %.4e | MMSE MSE = %.4e | MAP MSE = %.4e\n', ...
            thisVolt, sumResultHard.funcMSE/b^2, sumResultMMSE.sumMSE/b^2, sumResultMAP.funcMSE / b^2);
        if isfield(sumResultMAP, 'funcBER')
            fprintf(['Voltage = %.4f V | Hard word err (%s) = %.4e | MMSE sum word err = %.4e | ', ...
                'MAP digit-BER (%s) = %.4e\n'], ...
                thisVolt, crossName, sumResultHard.funcErrRate, sumResultMMSE.sumErrRate, ...
                crossName, sumResultMAP.funcBER);
        else
            fprintf(['Voltage = %.4f V | Hard err (%s) = %.4e | MMSE sum word err = %.4e | ', ...
                'MAP err (%s) = %.4e\n'], ...
                thisVolt, crossName, sumResultHard.funcErrRate, sumResultMMSE.sumErrRate, ...
                crossName, sumResultMAP.funcErrRate);
        end
    end

end

figure;
if strcmpi(crossName, 'max')
    plot(txVoltList, sumMSEHard_vs_Volt, '-o', 'LineWidth', 1.5, 'DisplayName', 'Hard Decoding (Max)');
    hold on;
    plot(txVoltList, sumMSEMap_vs_Volt, '-s', 'LineWidth', 1.5, 'DisplayName', 'MAP Decoding (Max)');
else
    plot(txVoltList, sumMSEHard_vs_Volt, '-o', 'LineWidth', 1.5, 'DisplayName', 'Hard Decoding');
    hold on;
    plot(txVoltList, sumMSEMMSE_vs_Volt, '-s', 'LineWidth', 1.5, 'DisplayName', 'Soft Decoding (sum)');
    plot(txVoltList, sumMSEMap_vs_Volt, '-y', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('MAP (%s)', crossName));
end
grid on;
xlabel('Tx Voltage Swing (V)');
ylabel('MSE');
yscale('log');
if strcmpi(crossName, 'max')
    title(sprintf('Max MSE vs Voltage, nEstim = %d', nEstim));
else
    title(sprintf(['Cross-run %s — MSE vs voltage (MMSE = sum digit-fusion), nEstim = %d'], ...
        crossName, nEstim));
end
legend('Location', 'best');

figure;
if strcmpi(crossName, 'max')
    plot(txVoltList, sumErrRateHard_vs_Volt, '-o', 'LineWidth', 1.5, 'DisplayName', 'Hard Decoding (Max)');
    hold on;
    plot(txVoltList, sumErrRateMap_vs_Volt, '-s', 'LineWidth', 1.5, 'DisplayName', 'MAP Decoding (Max)');
    ylabel('BER');
    title(sprintf('Max BER vs Voltage, nEstim = %d', nEstim));
else
    plot(txVoltList, sumErrRateHard_vs_Volt, '-o', 'LineWidth', 1.5, 'DisplayName', 'Hard Decoding');
    hold on;
    plot(txVoltList, sumErrRateMMSE_vs_Volt, '-s', 'LineWidth', 1.5, 'DisplayName', 'Soft Decoding (sum)');
    plot(txVoltList, sumErrRateMap_vs_Volt, '-y', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('MAP (%s)', crossName));
    if any(strcmpi(crossName, {'prod', 'product'}))
        ylabel(sprintf('Digit-BER (%s MAP) / word err (Hard); MMSE = sum', crossName));
    else
        ylabel(sprintf('Word error rate (%s); MMSE = digit-sum', crossName));
    end
    title(sprintf('Cross-run %s — error rate vs voltage, nEstim = %d', crossName, nEstim));
end
grid on;
xlabel('Tx Voltage Swing (V)');
yscale('log');
legend('Location', 'best');

end
