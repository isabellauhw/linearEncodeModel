function success = action(h)
%ACTION Export a filter to SPTool.

%   Author(s): P. Costa
%   Copyright 1988-2017 The MathWorks, Inc.

% Set up the sptool structure for importing
s = setupstruct(h);

shh = get(0, 'ShowHiddenHandles');
set(0, 'ShowHiddenHandles', 'On');

% Import the structure into SPTool
sptool('import',s);

set(0, 'ShowHiddenHandles', shh);

success = true;

% ---------------------------------------------------------
function s = setupstruct(h)
% Build the structure which sptool requires from an existing structure

% Need to revisit when exporting multiple filters to SPTool.
G = elementat(h.data,1);
if length(G) > 1
    error(message('signal:sigio:xp2sptool:action:NotSupported'));
end

name = h.variablename{1};
if ~isvarname(name)
    error(message('signal:sigio:xp2sptool:action:invalidVarName', name));
end

% Make sure that SPTool is open
sptool;

% Get the filter information from sptool
s = sptool('Filters');

names = {s.label};
old_name = name;
name  = genvarname(name, names);

if ~strcmp(old_name, name)
    warning(message('signal:sigio:xp2sptool:action:FilterNameChanged', name, old_name));
end

s = s(end);
s.FDAspecs = getstate(up(up(h)));
s.Fs = s.FDAspecs.currentFs;

s.type = 'imported';

% need to revisit when exporting multiple filters to SPTool.
s.label = name;

% [EOF]
