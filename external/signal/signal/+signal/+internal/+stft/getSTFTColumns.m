function varargout = getSTFTColumns(x,nx,nwin,noverlap,Fs)
%getSTFTColumns re-orders input signal into matrix with overlap
%   This function is for internal use only. It may be removed in the future. 
%
%   Copyright 2016-2020 The MathWorks, Inc.
%#codegen

% Determine the number of columns of the STFT output (i.e., the S output)
classCast = class(x); 
numChannels = size(x,2);
hopSize = nwin - noverlap;
nCol = fix((nx-noverlap)/hopSize);
if ~isreal(x)
    xin = complex(zeros(nwin,nCol,numChannels,classCast)); 
else
    xin = zeros(nwin,nCol,numChannels,classCast); 
end

% Determine the number of columns of the STFT output (i.e., the S output)
coloffsets = (0:(nCol-1))*hopSize;

for iCol = 1:nCol
    xin(:,iCol,:) = x(1+hopSize*(iCol-1):nwin+hopSize*(iCol-1),:);
end

varargout{1} = xin;

if nargout >= 1
    % Return time vector whose elements are centered in each segment
    varargout{2} = (coloffsets+(nwin/2)')/Fs;
end