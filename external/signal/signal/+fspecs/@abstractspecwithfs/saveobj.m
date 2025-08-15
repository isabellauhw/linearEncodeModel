function s = saveobj(this)
%SAVEOBJ   Save this object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

s       = rmfield(get(this), 'ResponseType');
s.Fs    = this.privFs;
s.class = class(this);

% [EOF]
