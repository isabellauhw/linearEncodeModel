function success = action(hCD)
%ACTION Perform the action of exporting to a MAT-file.

%   Author(s): P. Costa
%   Copyright 1988-2017 The MathWorks, Inc.

[file, path] = uiputfile('*.mat', hCD.DialogTitle, hCD.FileName);

if any(file == 0)
    success = false;
else
    file = fullfile(path, file);
    save2matfile(hCD,file);
    success = true;
end


%------------------------------------------------------------------------
function save2matfile(hCD,f_i_l_e)
%SAVE2MATFILE Save filter coefficients to a MAT-file
%
% Inputs:
%   hXP - Handle to the destination object
%   f_i_l_e - String containing the MAT-file name.

% variables & tnames are cell arrays of the same length.
variables = formatexportdata(hCD);

tnames  = get(hCD,'VariableNames');
if ~iscell(tnames), tnames = {tnames}; end

for i = 1:length(tnames)
    if isvarname(tnames{i})
        assign2wkspace('caller',tnames{i},variables{i});
    else
        error(message('signal:sigio:xp2matfile:action:InvalidVarName', tnames{ i }))    
    end
end

% Create the MAT-file
save(f_i_l_e,tnames{:},'-mat');


%-------------------------------------------------------------------
function assign2wkspace(wkspace, name, variable)

assignin(wkspace, name, variable);

% [EOF]
