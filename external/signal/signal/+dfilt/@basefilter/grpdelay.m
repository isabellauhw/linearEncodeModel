function varargout = grpdelay(Hb,varargin)
%GRPDELAY Group delay of a discrete-time filter.

%   Copyright 1988-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if nargout,
    [Gd, w] = base_resp(Hb, 'computegrpdelay', varargin{:});
    varargout = {Gd, w};
else,
    [Hb, opts] = freqzparse(Hb, varargin{:});
    fvtool(Hb, 'grpdelay', opts);    
end

% [EOF]
