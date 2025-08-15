function abstractlayout_construct(this, h, varargin)
%ABSTRACTLAYOUT_CONSTRUCT   Abstract constructor

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,inf);

set(this, 'Panel', h);

if nargin > 2
    set(this, varargin{:});
end

% [EOF]
