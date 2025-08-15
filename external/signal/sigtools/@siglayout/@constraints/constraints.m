function this = constraints(varargin)
%BORDERCONSTRAINTS   Construct a BORDERCONSTRAINTS object.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

this = siglayout.constraints;

% set(this, 'Component', hComp);

if nargin
    set(this, varargin{:});
end

% [EOF]
