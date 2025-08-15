function varargout = phasez(Hb,varargin)
%PHASEZ Phase response of a discrete-time filter.

%   Copyright 1988-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end


if nargout,
    
    % Strings are faster than Function Handles
    [Ph, w] = base_resp(Hb, 'computephasez', varargin{:});
    varargout = {Ph, w};
else,    
    [Hb, opts] = freqzparse(Hb, varargin{:});
    fvtool(Hb, 'phase', opts);
end

% [EOF]
