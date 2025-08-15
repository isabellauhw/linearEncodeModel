function varargout = freqz(Hb,varargin)
%FREQZ  Discrete-time filter frequency response.
%
%   See also DFILT, SIGNAL/FREQZ.

%   Copyright 1988-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

if nargout,
    [h,w] = base_resp(Hb, 'computefreqz', varargin{:});
    varargout = {h, w};
else,
    [Hb, opts] = freqzparse(Hb, varargin{:});
    fvtool(Hb, 'freq', opts);
end

% [EOF]
