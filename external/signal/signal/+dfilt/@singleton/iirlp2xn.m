function [Ht, anum, aden] = iirlp2xn(Ho, varargin)
%IIRLP2XN IIR lowpass to N-point frequency transformation.

%   Author(s): J. Schickler
%   Copyright 1988-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

[Ht, anum, aden] = iirxform(Ho, @iirlp2xn, varargin{:});

% [EOF]
