function [FRF, F, sys] = subspaceFRF(U,Y,Fs,Npts,Orders,Ft)
%SUBSPACEFRF Compute frequency response using subspace identification.
%   This function is for internal use only. It may be removed. 

% Inputs:
%       U:  Input matrix    Ns-by-Ny
%       Y:  Response matrix Ns-by-Nu
%      Fs:  Sampling frequency (Hz)
%    Npts:  Number of points in the frequency grid between 0 and Nyquist
%  Orders:  Order of estimated state-space model. Positive scalar or a row
%           vector of positive scalars (e.g.: 1:10)
%     Ft:   Feedthrough in the estimated model. Logical row vector of
%           length Nu.
%
% where: Ns = number of observations; Ny = number of outputs and Nu =
%        number of inputs. Ny>=1, Nu>=1.
%
% Outputs:
%    FRF:   Frequency response. Complex matrix Npts-by-Ny-by-Nu.
%     F:    Frequency column vector of length Npts. 
%   SYS:    Estimated state-space model matrices (struct).

%   Copyright 2016-2017 The MathWorks, Inc.

sys = controllib.internal.subspaceID.subspaceid(Y,U,Orders,Ft);
F = psdfreqvec('npts',Npts,'Fs',Fs,'Range','half');
ny = size(Y,2); nu = size(U,2);
FRF = zeros(length(F),ny,nu);
for ku = 1:nu
   [Bku, Aku] = ss2tf(sys.A, sys.B, sys.C, sys.D, ku);
   for ky = 1:ny
      FRF(:,ky,ku) = freqz(Bku(ky,:), Aku, F, Fs);
   end
end
