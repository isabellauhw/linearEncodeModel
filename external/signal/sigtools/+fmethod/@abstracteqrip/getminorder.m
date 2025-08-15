function minorder = getminorder(this, varargin)
%GETMINORDER   Get the minorder.

%   Copyright 1999-2017 The MathWorks, Inc.

n = firpmord(varargin{:});

if n < 3
    n = 3;
end

% Force the min flag to even for MinPhase filters.
if this.MinPhase || this.MaxPhase || isminordereven(this)
    minorder = 'mineven';
    
    % Make sure that we have an even order as the first guess.
    if rem(n, 2)
        n = n+1;
    end
elseif isminorderodd(this)
    minorder = 'minodd';
    
    % Make sure that we have an odd order as the first guess.
    if ~rem(n, 2)
        n = n + 1;
    end
else
    minorder = 'minorder';
end

minorder = {minorder, n};

% [EOF]
