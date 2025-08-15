function poles = computePoles(FRF,f,fs,mnum,opts,varargin)
%COMPUTEPOLES Compute poles from measured FRF data.
%   This function is for internal use only. It may be removed. 

%   Copyright 2016 The MathWorks, Inc.

% Compute poles for numModes modes from frequency response data FRF.
switch lower(opts.fm)
  case 'pp'
    % Reduce to frequency range requested
    fidx = (f >= opts.fr(1) & f <= opts.fr(2));
    FRF = FRF(fidx,:,:);
    f = f(fidx);

    numFRF = size(FRF,2)*size(FRF,3);
    fn = nan(mnum,size(FRF,2),size(FRF,3));
    dr = nan(mnum,size(FRF,2),size(FRF,3));
    
    % Compute natural frequencies and damping ratios
    for iFRF = 1:numFRF
      % Locate the peaks from the magnitude of the FRF in dB. Use a peak
      % prominence of 0.5 dB to filter out some spurious peaks. Peaks of
      % interest tend to have high magnitude and are returned first (lower
      % mnum), so we err on the side of allowing spurious peaks.
      [~,idx] = findpeaks(20*log10(abs(FRF(:,iFRF))),...
        'NPeaks',mnum,'MinPeakProminence',0.5,'SortStr','descend');

      % Compute damping factor for each mode and FRF.
      for imode = 1:numel(idx)
        % Choose 9 frequencies around the peak (this choice is in the range 3-9
        % suggested by Brandt)
        ilocs = max(idx(imode)-4,1):min(idx(imode)+4,length(f));
        omi = f(ilocs)*2*pi;

        % Form matrix and rhs vector in eqn 16.45 in Brandt
        b = omi.^2.*FRF(ilocs,iFRF);
        A = [FRF(ilocs,iFRF) 1i*2*omi.*FRF(ilocs,iFRF) -1*ones(length(ilocs),1)];

        % Solve for natural frequency and damping for this mode.     
        X = pinv(real(A))*real(b); 
        fn(imode,iFRF) = sqrt(X(1))/(2*pi);
        dr(imode,iFRF) = X(2)/sqrt(X(1)); 
      end
      
      % Sort the poles from lowest to highest natural frequency.
      [fn(:,iFRF),sortidx] = sort(fn(:,iFRF));
      dr(:,iFRF) = dr(sortidx,iFRF);
    end
    
    poles = signal.internal.modal.fdToPoles(fn,dr);
    
    % Remove poles that have positive real part or are real. For
    % complex-conjugate pairs, keep only the pole that has positive
    % imaginary part. Place NaN's for excluded poles. Poles should not return empty.
    poles(~(real(poles)<=0 & ~isreal(poles))) = nan; 

  case 'lsce'
    fidx = (f >= opts.fr(1) & f <= opts.fr(2));
    if ~all(fidx)
      % Reduce to frequency range requested. Trucate the FRF and f. Reduce
      % the sample rate to the effective rate.
      FRF = FRF(fidx,:,:);
      f = f(fidx);
      fs = fs*sum(fidx)/length(fidx);
    end
    
    L = 2*mnum; % polynomial order
    oFactor = 10; % number of times samples = oFactor*L
    nOut = size(FRF,2); % number of outputs
    nIn = size(FRF,3);
     
    H = zeros(L*oFactor*nOut*nIn,L,'like',FRF);
    b = zeros(L*oFactor*nOut*nIn,1,'like',FRF);
    % Form the least-squares system
    for iIn = 1:nIn
      for iOut = 1:nOut
        h = signal.internal.modal.computeIR(FRF(:,iOut,iIn),f,fs);
        H0 = hankel(h(1:L*oFactor),h(L*oFactor:L*oFactor+L));
        H((1:L*oFactor)+(iOut+(iIn-1)*nOut-1)*L*oFactor,:) = H0(:,1:end-1);
        b((1:L*oFactor)+(iOut+(iIn-1)*nOut-1)*L*oFactor,:) = -1*H0(:,end);
      end
    end
    
    % Solve for polynomial coefficients
    beta = [real(H\b);1]; 

    % Find the roots of the polynomial
    V = roots(flipud(beta));
    p = log(V)*fs;

    % Remove poles that are not in complex-conjugate pairs, have positive
    % real part, or are real. For complex-conjugate pairs, keep only the
    % pole that has positive imaginary part.
    p = intersect(p,conj(p(imag(p)<0 & real(p)<=0 & ~isreal(p)))); 

    % Place NaN's for excluded poles. Poles should not return empty.
    poles = [p;nan(mnum - size(p,1),1)];
    
    if ~all(fidx)
         % Compensate poles for frequency offset. 
        [fn,dr] = signal.internal.modal.polesTofd(poles);
        poles = signal.internal.modal.fdToPoles(fn+f(1),dr.*fn./(fn+f(1)));
    end
    
   case 'lsrf'
      fidx = (f >= opts.fr(1) & f <= opts.fr(2));
      f = 2*pi*f; % Frequency in rad/s
      FRF = FRF(fidx,:,:); f = f(fidx);
      [nf,ny,nu] = size(FRF);
      % Cut out the data in the specified frequency region and reshape
      FRF = reshape(FRF, [nf, ny*nu]);
      Order = {opts.nx, double(~opts.ft)};
      [~,p] = controllib.internal.fitRational.fitRational(f,FRF,[],1/fs,[],Order);
      p = p(imag(p)>0 & abs(p)<1);
      p = log(p)*fs; % CT poles
      % sort in the order of least damping
      d = -real(p)./abs(p);
      [~,I] = sort(d);
      poles = p(I);
      % Place NaN's for excluded poles. Poles should not return empty.
      poles = [poles; nan(mnum - size(poles,1),1)];
end
