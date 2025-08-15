function success = action(this)
%ACTION Perform the action of exporting to the Workspace.

%   Author(s): P. Costa
%   Copyright 1988-2017 The MathWorks, Inc.

tnames  = get(this,'VariableNames');
if ~iscell(tnames), tnames = {tnames}; end


% Check if VariableNames are unique
chkVarName(tnames);

overwriteVars = get(this,'Overwrite');
% Check if the variables exist in the workspace.   
chkIfVarExistInWksp(tnames,overwriteVars);
    
% variables & tnames are cell arrays of the same length.
variables = formatexportdata(this);

% Make sure that when we only have a single variable to be exported to
% the workspace, that the information we export is everything in the
% 'variables' variable. g307525
if length(tnames) == 1 && length(variables) ~= 1
  variables = {variables};
end

for i = 1:length(tnames)
  
  % Check for valid names
  if isvarname(tnames{i})
    assign2wkspace('base',tnames{i},variables{i});
  else
    error(message('signal:sigio:xp2wksp:action:InvalidVarName', tnames{ i }))    
  end
end

% Message to be displayed in the command window.
sendstatus(this, getString(message('signal:sigtools:sigio:VariablesHaveBeen')));
success = true;

%-------------------------------------------------------------------
function assign2wkspace(wkspace, name, variable)

assignin(wkspace, name, variable);


%-------------------------------------------------------------------
function chkIfVarExistInWksp(vnames, overwriteVars)
% CHKIFVAREXISTINWKSP Check if the variables exist in the workspace.
%
% Input:
%   vnames - Filter Structure specific coefficient strings stored
%               in FDATool's UserData.
%   overwriteVars - Overwrite vars flag

% Get the base workspace variable names
vars = evalin('base', 'whos');
vars = {vars.name};

% Check if there are any common names between the base workspace and the
% variable names we are going to use for export.
common = intersect(vars, vnames);

if ~isempty(common)
     if ~overwriteVars
       error(message('signal:sigio:xp2wksp:action:VarAlreadyExist', common{ 1 }))
     end
end

%-------------------------------------------------------------------
function chkVarName(tnames)
% CHKVARNAME Check if the variables names are unique 
    
[B,I,J] =  unique(tnames);
for n = 1:length(J)
    idx = find(J == J(n));
    
    if length(idx) > 1 
        % Variable Name is repeated
        error(message('signal:sigio:xp2wksp:action:VarNotUnique'))                
    end 
end

% [EOF]
