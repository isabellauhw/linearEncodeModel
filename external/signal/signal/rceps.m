function [xhat, yhat] = rceps(x)
%RCEPS Real cepstrum.
%   RCEPS(X) returns the real cepstrum of the real sequence X.
%
%   [XHAT, YHAT] = RCEPS(X) returns both the real cepstrum XHAT and
%   YHAT which is a unique minimum-phase sequence that has the same real
%   cepstrum as X.
%
%   EXAMPLE: Show that YHAT is a unique minimum-phase sequence that has the
%            % same real cepstrum as X.
%            y = [4 1 5]; % Non-minimum phase sequence
%            [xhat,yhat] = rceps(y);
%             xhat2 = rceps(yhat);
%            [xhat' xhat2']
%
%   See also CCEPS, ICCEPS, HILBERT, FFT.

%   Copyright 1988-2019 The MathWorks, Inc.

%   References:
%     [1] A.V. Oppenheim and R.W. Schafer, Digital Signal
%         Processing, Prentice-Hall, 1975.
%     [2] Programs for Digital Signal Processing, IEEE Press,
%         John Wiley & Sons, 1979, algorithm 7.2.

%#codegen
narginchk(1,1);

% Check for valid input
validateattributes(x,{'numeric'},{'nonempty','nonsparse','real','2d'},mfilename,'x',1);

isRowX = isrow(x);
if isRowX
    xT = x(1,:).';
else
    xT = x;
end

fftxabs = abs(fft(xT,[],1));

% Check if any zeros are present in 'fftxabs' before taking log
coder.internal.assert(all(fftxabs,'all'),'signal:rceps:ZeroInFFT');

xhatT = real(ifft(log(fftxabs),[],1));

if isRowX
    % transform the result to a row vector
    xhat = xhatT(:,1).';
else
    xhat = xhatT;
end

if nargout > 1
    [nRows,nCols] = size(xhatT);
    odd = rem(nRows,2);
    wn = repmat([1; 2*ones((nRows+odd)/2-1,1); ones(1-odd,1); zeros((nRows+odd)/2-1,1)],1,nCols);
    yhatT = real(ifft(exp(fft((wn.*xhatT),[],1)),[],1));
    if isRowX
        % transform the result to a row vector
        yhat = yhatT(:,1).';
    else
        yhat = yhatT;
    end
end

end