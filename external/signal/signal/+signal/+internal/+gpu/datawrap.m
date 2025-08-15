function y = datawrap(x,nfft)
%DATAWRAP Wrap input data modulo nfft.
%   Y = DATAWRAP(X,NFFT) wraps each column of X modulo NFFT. Each column of
%   X represents a single channel of the signal. When multiple channels are
%   specified the result Y will have a third dimension with one page per
%   channel.
%
%   The operation consists of dividing the vector X or each column of X into segments each of
%   length NFFT (possibly padding with zeros the last segment).  Subsequently,
%   the length NFFT segments are added together to obtain a wrapped version of X.

% Copyright 1988-2019 The MathWorks, Inc.

validateattributes(x,{'single','double','logical'},{'nonempty','2d'},1);
validateattributes(nfft,{'numeric'},{'positive','scalar','integer'},2);

transpose = false;

if isrow(x) && ~isscalar(x)
    % For compatibility with CPU datawrap
    x = x.';
    transpose = true;
end

y = sum(buffer(x,nfft),2);

if transpose
    y = y.';
end

end

function y = buffer(x,nfft)
%BUFFER(X,N) Pads each column of a matrix (X) into a buffer

signalLength = size(x,1);
nChannels = size(x,2);

nPad = mod(-signalLength,nfft);

if nPad ~= 0
    y = [x;zeros(nPad,nChannels,'like',x)];
else
    y = x;
end

nColsPerChannel = (signalLength + nPad) / nfft;        % Number of columns that each signal is wrapped into
nRowsPerChannel = nfft;                                    % Number of rows that each signal is wrapped into
y = reshape(y,nRowsPerChannel,nColsPerChannel,nChannels);

end

