function projectRoot = setupProject()
%SETUPPROJECT Configure MATLAB path for the SwitchComp package.
%
%   PROJECTROOT = SETUPPROJECT adds these subfolders (if present) to the
%   MATLAB path: utils, data, models — relative to this file’s directory.
%
%   Why
%   -----
%   Runnable scripts live in the project root; helpers live in utils/.
%   Models live in models/ after linkExampleModels or a manual copy.
%   Calling setupProject at the start of each script makes `which` resolve
%   utilities even if the user’s Current Folder is not the project root.
%
%   Returns
%   -------
%   PROJECTROOT — char/string, absolute path to the folder containing
%                 setupProject.m (the SwitchComp root).
%
%   Example
%   -------
%       setupProject();
%       runSwitchComp
%       % or: generate_and_save_logs
%
%   Note
%   ----
%   Scripts still expect to find setupProject.m itself (exist + error check).
%   Add the SwitchComp folder to the path once, or cd into it, before running.

here = fileparts(mfilename('fullpath'));
projectRoot = here;

subfolders = {'utils', 'data', 'models'};
for k = 1:numel(subfolders)
    p = fullfile(projectRoot, subfolders{k});
    if isfolder(p)
        addpath(p);
    end
end

end
