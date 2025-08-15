function p = paths(rig)
%DAT.PATHS Returns struct containing important paths
%   p = DAT.PATHS([RIG]) Returns a struct of paths used by Rigbox.
%   The default rig is the hostname of this computer.
%
%   This version is modified for macOS with data mounted at /Volumes/Data

% Get computer hostname if not supplied
if nargin < 1 || isempty(rig)
    rig = hostname;
end

% Define base server path (where your Data and Code are stored)
server1Name = '/Volumes/Data';

%% Essential paths

% Path to the Rigbox installation
p.rigbox = fileparts(which('addRigboxPaths'));

% Repository for all saved experimental data (per animal)
p.mainRepository = fullfile(server1Name); % e.g. /Volumes/Data/AMR035/...

% Local repository (can use home directory or /tmp if desired)
p.localRepository = fullfile(getenv('HOME'), 'LocalExpData');

% Directory for global configuration (shared configs for all rigs)
p.globalConfig = fullfile(server1Name, 'Code', 'RigConfig');

% Rig-specific configuration folder
p.rigConfig = fullfile(p.globalConfig, rig);

% Folder for experiment definitions (e.g., expDef.m files)
p.expDefinitions = fullfile(server1Name, 'Code', 'ExpDefinitions');

%% Optional: Git path and auto-update schedule (macOS version)
% Modify this path if your Git installation differs
[~, gitPath] = system('which git'); % this works on macOS/Linux
p.gitExe = strtrim(gitPath);
p.updateSchedule = 0;  % 0 = update daily, 1 = Sunday, etc.

end
