function [Ht, anum, aden] = iirlp2mb(Ho, varargin)
%IIRLP2MB IIR lowpass to multiband frequency transformation.

%   Author(s): J. Schickler
%   Copyright 1988-2018 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

[Ht, anum, aden] = iirxform(Ho, @iirlp2mb, varargin{:});

% [EOF]
