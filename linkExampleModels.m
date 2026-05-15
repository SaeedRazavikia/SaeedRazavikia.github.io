function ok = linkExampleModels()
%LINKEXAMPLEMODELS Locate PCIe6 example SerDes models and copy them into models/.
%
%   Run once with Current Folder = SwitchComp (this file’s directory).
%
%   Behavior
%   --------
%   Searches parent directories for SerDes_Base_Link.slx and
%   Noisy_SerDes_Base_Link.slx, copies found files into ./models/, and creates
%   ./models, ./Data, and ./data if missing. If a model is already loaded in
%   MATLAB, it is closed first so Windows can overwrite the .slx in models/.
%
%   Returns
%   -------
%   OK — true if both .slx files were copied; false if one or both are still
%        missing (copy manually; see models/README.txt).
%
%   See also: setupProject, models/README.txt

here = fileparts(mfilename('fullpath'));
dstDir = fullfile(here, 'models');
if ~isfolder(dstDir)
    mkdir(dstDir);
end

wanted = {
    'SerDes_Base_Link.slx'
    'Noisy_SerDes_Base_Link.slx'
    };

searchDirs = {
    fullfile(here, '..', '..')
    fullfile(here, '..')
    fullfile(here, '..', 'models')
    fullfile(here, '..', '..', 'models')
    };

copyCount = 0;
for wi = 1:numel(wanted)
    w = wanted{wi};
    copied = false;
    % Release file lock if this diagram is still loaded from a prior simulation.
    localCloseModelIfLoadedByName(w);
    for si = 1:numel(searchDirs)
        base = searchDirs{si};
        tryPaths = {
            fullfile(base, w)
            fullfile(base, 'models', w)
            };
        for ti = 1:numel(tryPaths)
            src = tryPaths{ti};
            if isfile(src)
                dest = fullfile(dstDir, w);
                localCopySlxWithUnlock(src, dest, w);
                fprintf('Copied:\n  %s\n  -> %s\n', src, dest);
                copyCount = copyCount + 1;
                copied = true;
                break;
            end
        end
        if copied
            break;
        end
    end
    if ~copied
        warning(['Could not locate ''%s''. Open the PCIe 6 IBIS-AMI example from ', ...
            'MATLAB Documentation Examples (or copy the .slx manually) into:\n  %s'], w, dstDir);
    end
end

dataDir = fullfile(here, 'Data');
if ~isfolder(dataDir)
    mkdir(dataDir);
end
dataLower = fullfile(here, 'data');
if ~isfolder(dataLower)
    mkdir(dataLower);
end

ok = (copyCount == numel(wanted));
if ok
    fprintf('All %d model files are in:\n  %s\n', copyCount, dstDir);
else
    fprintf('Linked %d / %d model files. Fix paths or copy by hand; see models\\README.txt\n', ...
        copyCount, numel(wanted));
end
end

function localCopySlxWithUnlock(src, dest, w)
% Close loaded block diagram so Windows releases the destination .slx, then copy.

localCloseModelIfLoadedByName(w);

if isfile(dest)
    localCloseModelIfLoadedByName(w);
end

pause(0.05);

try
    copyfile(src, dest);
catch %#ok<CTCH>
    localCloseModelIfLoadedByName(w);
    pause(0.2);
    try
        copyfile(src, dest);
    catch ME2
        [~, bdName] = fileparts(w);
        error('linkExampleModels:CopyFailed', ...
            ['Could not copy ''%s'' to models/.\n\n' ...
            'Common fix: the model is open in Simulink. Close it or run:\n' ...
            '  if bdIsLoaded(''%s''), close_system(''%s'', 0); end\n' ...
            'then run linkExampleModels again.\n\n' ...
            'Other causes: another MATLAB instance, OneDrive sync, or antivirus locking the file.\n\n' ...
            'Underlying error: %s'], ...
            w, bdName, bdName, ME2.message);
    end
end
end

function localCloseModelIfLoadedByName(slxfilename)
% SLXFILENAME may be 'SerDes_Base_Link.slx' or just the name with extension.

if nargin < 1 || isempty(slxfilename)
    return;
end

[~, bdName] = fileparts(slxfilename);
if isempty(bdName)
    return;
end

try
    if bdIsLoaded(bdName)
        close_system(bdName, 0);
    end
catch %#ok<CTCH>
    % Ignore: headless / license / name mismatch
end
end
