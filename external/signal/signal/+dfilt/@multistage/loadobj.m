function this = loadobj(s)
%LOADOBJ   Load this object.

%   Author(s): J. Schickler
%   Copyright 1988-2015 The MathWorks, Inc.

% This is the COPY case.
if ~isstruct(s)
    s = saveobj(s);
    
    % Copy the filters
    for indx = 1:length(s.Stage)
        s.Stage(indx) = copy(s.Stage(indx));
    end
end

% Suppress MFILT deprecation warnings
w = warning('off', 'dsp:mfilt:mfilt:Obsolete');
restoreWarn = onCleanup(@() warning(w));

% Construct the object.
if isfield(s,'class')
    this = feval(s.class);
else
    str = getconstructorfromstructure(s.FilterStructure);
    this = feval(['dfilt.' str]);
end

if isfield(s,'PersistentMemory') || isprop(s,'PersistentMemory')
    this.PersistentMemory    = s.PersistentMemory;
end

if isfield(s,'NumSamplesProcessed') || isprop(s,'NumSamplesProcessed')
    this.NumSamplesProcessed = s.NumSamplesProcessed;
end

%Property renamed in R2018b------------------------------------------------
if (~isstruct(s) && isprop(s, 'SysObjParams')) || ...
        (isstruct(s) && isfield(s, 'SysObjParams'))
    this.SystemObjParams = s.SysObjParams;
elseif (~isstruct(s) && isprop(s, 'SystemObjParams')) || ...
        (isstruct(s) && isfield(s, 'SystemObjParams'))
    this.SystemObjParams = s.SystemObjParams;
end

% We need to do this last so that the setting of "PersistentMemory" doesn't
% set all of the contained objects as well.
if isfield(s,'Stage')
    this.Stage = s.Stage;
elseif isfield(s,'Section')
    this.Stage = s.Section;
end
if isfield(s, 'version') && s.version.number > 2
    loadmetadata(this, s);
end

end
% [EOF]
