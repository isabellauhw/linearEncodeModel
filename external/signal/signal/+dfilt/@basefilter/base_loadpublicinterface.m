function base_loadpublicinterface(this, s)
%BASE_LOADPUBLICINTERFACE

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

if s.version.number < 2
    if isfield(s, 'PersistentMemory')||isprop(s, 'PersistentMemory')
        this.PersistentMemory = s.PersistentMemory;
    elseif isfield(s,'ResetBeforeFiltering') || isprop(s,'ResetBeforeFiltering')
        this.PersistentMemory = strcmpi(s.ResetBeforeFiltering, 'off');
    end
else
    if isfield(s, 'PersistentMemory')||isprop(s, 'PersistentMemory')
        this.PersistentMemory = s.PersistentMemory;
    end
end

if isfield(s,'NumSamplesProcessed') || isprop(s,'NumSamplesProcessed')
    this.NumSamplesProcessed = s.NumSamplesProcessed;
end


% [EOF]
