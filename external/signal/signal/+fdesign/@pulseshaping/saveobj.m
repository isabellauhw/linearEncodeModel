function s = saveobj(this)
%SAVEOBJ   Save this object.

%   Copyright 2008 The MathWorks, Inc.

s.class         = class(this);
s.Response      = this.Response;
s.PulseShape    = this.PulseShape;
s.PulseShapeObj = saveobj(this.PulseShapeObj);
s.version       = '9a';

% [EOF]
