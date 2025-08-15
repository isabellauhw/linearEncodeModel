function setstate(hIT, state)
%SETSTATE Sets the state of the Import Tool.
%   SETSTATE(hIT, STATE) Sets the state of the Import Tool with the data
%   structure STATE.
%
%   See also GETSTATE.

%   Copyright 1988-2011 The MathWorks, Inc.

narginchk(2,2);

% Check for R12 & R12.1 versions
if isfield(state,'impfiltstruct')
    
    % Convert if necessary
    state = convert(state);
end

% Set the input processing option. If loading from a pre R2011b block, then
% set input processing to inherited. 
setInputProcessingState(hIT,state);

sigcontainer_setstate(hIT, state);

% ---------------------------------------------------------
function sout = convert(sin)

sout.coeffspecifier.Coefficients = convertcoeffs(sin.impfiltstruct);
sout.coeffspecifier.SelectedStructure = sin.impfiltstruct.struct;

oldFs = sin.fs;
sout.fsspecifier.Value = oldFs.Fs;
sout.fsspecifier.Units = oldFs.freqUnits;

% Inputprocessing is a new added widget.
% when convert sin to sout, keep InputProcessing info
if isfield(sin, 'InputProcessing')
    sout.InputProcessing = sin.InputProcessing;
end

% ---------------------------------------------------------
function coeffs = convertcoeffs(coeffs)

% The old method (FDATool) stored the "short" strings which did not match the
% constructors.  Convert to the constructors as fields
oldtags = fieldnames(rmfield(coeffs,{'struct','qfiltVarStrs'}));
newtags = {'tf','sos','statespace','latticearma', ...
        'latticeallpass','latticemamin','latticemamax'};

for i = 1:length(oldtags)
    value  = coeffs.(oldtags{i});
    coeffs.(newtags{i}) = value;
    coeffs = rmfield(coeffs,oldtags{i});
end

% [EOF]
