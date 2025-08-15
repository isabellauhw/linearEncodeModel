function constraints = getconstraints(this, varargin)
%GETCONSTRAINTS   Get the constraints.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

n = nfactors(this);

narginchk(1+n,1+n);

hComponent = getcomponent(this, varargin{:});

constraints = getappdata(hComponent, getconstraintstag(this));

% [EOF]
