function h = computeIR(FRF,f,fs)
%COMPUTEIR Compute an impulse response for an FRF.
%   This function is for internal use only. It may be removed. 

%   Copyright 2016 The MathWorks, Inc.

% Compute fft block size
N = round(fs/(f(3)-f(2)));

% Compute impulse response h 
if mod(N,2)
  h = real(ifft([FRF; flipud(conj(FRF(2:end)))]));
else
  h = real(ifft([FRF; flipud(conj(FRF(2:end-1)))]));
end


