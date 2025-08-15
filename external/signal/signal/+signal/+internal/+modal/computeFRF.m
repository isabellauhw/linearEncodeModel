function [FRF,f] = computeFRF(X,Y,window,winlen,Fs,opts)
%COMPUTEFRF Compute frequency response functions from inputs and outputs.
%   This function is for internal use only. It may be removed. 

%   Copyright 2016-2017 The MathWorks, Inc.

es = opts.est; mt = opts.mt; noverlap = opts.noverlap;
switch lower(es)
  case {'h1','h2'} 
      % Use 'tfestimate' for H1 and H2. 
      if strcmpi(mt,'fixed')
        [FRF,f] = tfestimate(X,Y,window,noverlap,winlen,Fs,'mimo','Estimator',lower(es));
      else
        [FRF,f] = tfestimate(X,Y,window,noverlap,winlen,Fs,'Estimator',lower(es));
      end
   case 'subspace'
      % Use stochastic subspace estimator.
      NX = opts.nx;
      if strcmpi(mt,'fixed')
         [FRF,f] = signal.internal.modal.subspaceFRF(X,Y,Fs,winlen,NX,opts.ft);
      else
         % 'rovinginput' or 'rovingoutput'
         nc = size(X,2);
         [FRF1,f] = signal.internal.modal.subspaceFRF(X(:,1),Y(:,1),Fs,winlen,NX,opts.ft);
         FRF = zeros(length(f),nc);
         FRF(:,1) = FRF1;
         for ct = 2:nc
            FRF(:,ct) = signal.internal.modal.subspaceFRF(X(:,ct),Y(:,ct),Fs,winlen,NX,opts.ft);
         end
      end
  otherwise
      % Use Hv estimator (SISO only - X and Y must have the same number of columns)
      [Gyx,f] = cpsd(Y,X,window,noverlap,winlen,Fs);
      Gyy = cpsd(Y,Y,window,noverlap,winlen,Fs);
      Gxx = cpsd(X,X,window,noverlap,winlen,Fs);
      FRF = Gyx./(abs(Gyx)).*sqrt(Gyy./Gxx);
end

if strcmpi(mt,'rovinginput')
  FRF = permute(FRF,[1 3 2]);
end
