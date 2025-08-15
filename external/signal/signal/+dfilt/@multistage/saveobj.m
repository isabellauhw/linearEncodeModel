function s = saveobj(this)
%SAVEOBJ   Save this object.

%   Author(s): J. Schickler
%   Copyright 1988-2015 The MathWorks, Inc.

s = savemetadata(this);

s.class = class(this);
s.version = this.version;

s.PersistentMemory    = this.PersistentMemory;
s.NumSamplesProcessed = this.NumSamplesProcessed;

%Property renamed in R2018b------------------------------------------------
if isprop(this, 'SysObjParams')
    s.SystemObjParams = this.SysObjParams;
elseif isprop(this, 'SystemObjParams')
    s.SystemObjParams = this.SystemObjParams;
end

for indx = 1:nstages(this)
    s.Stage(indx) = this.Stage(indx);
end

% [EOF]
