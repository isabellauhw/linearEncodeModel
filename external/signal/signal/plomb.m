function varargout = plomb(x,varargin)
% PLOMB Lomb-Scargle periodogram
%   [P,F] = PLOMB(X,T) returns the Lomb-Scargle power spectral density
%   estimate, P, of a signal, X, that has been sampled at the instants
%   specified in T. T must increase monotonically, but need not be
%   uniformly spaced. P is evaluated at the frequencies returned in F.
%  
%   If X is a vector, it is treated as a single channel. If X is a matrix,
%   then PLOMB computes the PSD independently for each column and returns
%   it in the corresponding column of P. X or T can contain NaNs. NaNs are
%   treated as missing data and are excluded from the spectrum computation.
%   If T is a datetime object, than NaTs will be ignored.
%  
%   [P,F] = PLOMB(X,Fs) treats the case where the signal has been sampled
%   uniformly, at a rate Fs, but has missing samples represented in the
%   data using NaNs. The sampling is assumed to start at time zero.
%
%   [P,F] = PLOMB(...,FMAX) estimates the PSD up to a maximum frequency,
%   FMAX. If the signal is sampled at N non-NaN instants and DT is the time
%   difference between the first and the last of them, then P is returned
%   at round(FMAX/FMIN) points, where FMIN = 1/(4*N*Ts) is the smallest
%   frequency at which P is computed and the average sample time is Ts =
%   DT/(N-1). FMAX defaults to 1/(2*Ts).
%
%   [P,F] = PLOMB(...,FMAX,OFAC) specifies an integer oversampling factor,
%   OFAC. The use of OFAC to interpolate or smooth a spectrum resembles the
%   zero-padding technique for FFT-based methods. P is again returned at
%   round(FMAX/FMIN) frequency points, but the minimum frequency considered
%   in this case is 1/(OFAC*N*Ts). OFAC defaults to 4.
%
%   [P,FVEC] = PLOMB(...,FVEC) estimates the PSD at the frequencies
%   specified in FVEC. FVEC must have at least two elements. You cannot
%   specify an oversampling factor if you use this syntax.
%
%   [P,F] = PLOMB(...,SPECTRUMTYPE) specifies the scaling of the
%   spectrum:
%     'psd'        - returns the power spectral density
%     'power'      - returns the power at each frequency
%     'normalized' - scales P by the variance of X 
%   The default value for SPECTRUMTYPE is 'psd'.
%
%   [P,F,PTH] = PLOMB(...,'Pd',PDVEC), returns the power-level threshold,
%   PTH, such that a peak with a value larger than PTH has a probability
%   PDVEC of not being the result of random fluctuations. PDVEC can be a
%   vector. Every element of PDVEC must be greater than 0 and smaller than
%   1. Each row of PTH corresponds to an element of PDVEC. PTH has the same
%   number of channels as
%   X.
%
%   [P,W] = PLOMB(X) returns the PSD estimate of X assuming a uniform
%   sample rate of 2 Hz. The result is evaluated at a set of evenly spaced
%   angular frequencies, W, spanning the Nyquist interval. Use NaNs to
%   specify missing samples. All of the above options are available for
%   angular frequencies. To access them, specify an empty array as second
%   input.
%
%   PLOMB(...) with no output arguments plots the Lomb-Scargle PSD estimate
%   in the current figure window.
%
%   % Example:
%   %   Compute the normalized spectrum of a nonuniformly sampled signal 
%   %   using the Lomb-Scargle method.
%
%   load nonuniformdata
%   plomb(x,t,'normalized')
%
%   See also PWELCH, PBURG, PCOV, PYULEAR, PMTM, PMUSIC, PMCOV, PEIG.

%   Copyright 1988-2019 The MathWorks, Inc.

%   REFERENCE
%      [1]  Press, W. H. & Rybicki, G. B. 1989 ApJ vol. 338, p. 277-280. 
%           Fast algorithm for spectral analysis of unevenly sampled data 
%#codegen

narginchk(1,7);

% Parse and Validate inputs
inputArgs = cell(size(varargin));
[inputArgs{:}] = convertStringsToChars(varargin{:});

[xp,t,f,ofac,spectrumtype,freqtype,~,ProbDet,Fs,fvecSpecified,nchannel] = parseAndValidateInputs(x,inputArgs);

% Cast to enforce precision rules
precision = [];
if isa(xp, 'single') || isa(t, 'single')       
    x1 = single(xp);
    t = single(t);
    singleFlag = true;
    precision = 'single';
else
    x1 = double(xp);
    t = double(t);
    singleFlag = false;
    precision = 'double';
end

% Check for missing data in t,x
% If any channels has missing data, return fmax inside f
[Ch,f] = MarkMissingData(x1,t,f,nchannel,fvecSpecified,ofac,spectrumtype,freqtype,Fs);


% For each channel compute periodogram
P = cast([], precision);
fr = cast(0, precision);
coder.varsize('P');
coder.varsize('fr');

PNaNPos = zeros(1,nchannel);


for i = 1:nchannel
  
  % Channel to evaluate
  sig = x1(:,i);
  tout = t(:);
  
  % NanFlag indicates if NaNs are present in Channel(sig) or time(t)
  % Return points at which time vector(t) and signal(sig) is defined 
  if Ch.NanFlag(i)    
    sig(Ch.SigAndTNanPos(i, Ch.SigAndTNanPos(i,:) > 0))  = [];
    tout(Ch.SigAndTNanPos(i, Ch.SigAndTNanPos(i,:) > 0)) = [];
  else
  % No missing data  
    tout = t(:);
  end
  
  % Remove duplicate data from each channel
  [~,tUniqueIdx] = unique(tout(:));

  % First delete NaNs and then consider only unique time stamps 
  sig  = sig(tUniqueIdx);
  tout = tout(tUniqueIdx);  
  
  p = nextpow2(length(sig))-1;
  if length(sig)== (2^p + 1)
    PNaNPos(i) = 2^(p+1);
  end
  
  % Subtract channel mean from channel
  sig  = sig-Ch.SigMean(i); 
    
  if fvecSpecified    
    % Find Power at each frequency
    Px = lombscargle(sig,f,tout);

    Px(f==0) = 0;   
    
    P = [P,Px];
    fr = cast(f, precision);
    
  else       
    % NaN-case: for the first iteration(channel) use fasper, for 2nd
    % iteration onwards use the fr to feed into slow algorithm for
    % computing power for rest of channels.     
    if i>1 && any(Ch.NanFlag(1:i))
    % Only for multichannel
      Pxl = lombscargle(sig,fr,tout);
      Px = cast(Pxl, precision);
    else
      if ~singleFlag
        f = double(f);
      end
      
      % If NaNs are present f is fmax
      [Px1,fr1] = fasper(sig,tout,ofac,f);
      
      Px = cast(Px1, precision);
      fr = cast(fr1, precision);
    end
    
    % Replace NaN occurrence for specific case
    if PNaNPos(i)>0
      fxNaN = 2^(p+1);
      if fxNaN<=length(fr)
        PxNaN = lombscargle(sig,fr(fxNaN),tout);
        Px(fxNaN) = PxNaN;
      end
    end    
    
    P = [P,Px];     
  end    
end



% Scale spectrum
switch spectrumtype
    case 'psd'
        switch freqtype
            case 'rad/samp'
                % Return Frequency               
                fr = fr*(2*pi)/Fs;
                P = P./(2*pi);
                
                if coder.target('MATLAB')
                  % Plotting Frequency
                  frqplot = fr/pi;                                            
                  xlabelstr = getfreqlbl('rad/sample');
                  ylabelstr = getString(message('signal:plomb:PsdRadYlabel'));
                end
                                            
            case 'Hz'                                                    
                P = P./Fs; %, precision);
                
                if coder.target('MATLAB')
                  % Plotting Frequency
                  [frqplot, ~, funits] = engunits(fr,'latex');                          
                  xlabelstr = getfreqlbl([funits 'Hz']);
                  ylabelstr = getString(message('signal:plomb:PsdHzYlabel'));
                end
        end
        if coder.target('MATLAB')
          titlestr  = getString(message('signal:plomb:PsdTitle'));
        end
    case 'power'       
        % Number of points for power computation(n) changes with number of
        % NaNs in each channel, use this value to scale the spectrum.
        P = bsxfun(@times,P,1./Ch.n);    
        switch freqtype
            case 'rad/samp'
                % Return Frequency               
                fr = fr*(2*pi)/Fs;
                
                if coder.target('MATLAB')
                  % Plotting Frequency
                  frqplot = fr/pi;               
                  xlabelstr = getfreqlbl('rad/sample');
                end
            case 'Hz'
                
                if coder.target('MATLAB')
                  % Return Frequency
                  [frqplot, ~, funits] = engunits(fr,'latex');
                  xlabelstr = getfreqlbl([funits 'Hz']);
                end
        end
        if coder.target('MATLAB')
          ylabelstr = getString(message('signal:plomb:PowerYlabel'));
          titlestr  = getString(message('signal:plomb:PowerTitle'));
        end
    case 'normalized'
        P = bsxfun(@times,P,1./(2*Ch.SigVar));
        switch freqtype
          case 'rad/samp'
            % Return Frequency            
            fr = fr*(2*pi)/Fs;
            
            if coder.target('MATLAB')
                % Plotting frequency
                frqplot = fr/pi;   
                xlabelstr = getfreqlbl('rad/sample');
            end
          case 'Hz'
            if coder.target('MATLAB')
                [frqplot, ~, funits] = engunits(fr,'latex');
                xlabelstr = getfreqlbl([funits 'Hz']);
            end
        end
        
        if coder.target('MATLAB')
          ylabelstr = getString(message('signal:plomb:NormYlabel'));
          titlestr  = getString(message('signal:plomb:NormTitle'));
        end
end


% Compute Probability of Detection for each channel
z  = [];
if ~isempty(ProbDet)
  z = computePd(fr,ofac,ProbDet,nchannel,Ch);
end

% Plot when no output arguments are specified 
if nargout==0       
  if coder.target('MATLAB')
     plotData(ProbDet,z,frqplot,P,titlestr,xlabelstr,ylabelstr,nchannel)
  end
else
  coder.internal.errorIf(nargout > 3, 'signal:plomb:TooManyOutputArgs');
  varargout{1} = P;
  varargout{2} = fr;          
  varargout{3} = z;
end

end

%% --------------------------------------------------------------------------
% Handles the entire plot functionality of plomb
function plotData(ProbDet,z,frqplot,P,titlestr,xlabelstr,ylabelstr,nchannel)

% Display power levels for PDVEC only for one channel
if ~isempty(ProbDet)
    
  if nchannel>1 && length(ProbDet)>1
    warning(message('signal:plomb:MultiplePdMultipleCh'));
    
    l = plot(frqplot,10*log10(P));
    hAxes = ancestor(l(1),'axes');
    
    % Update the Ylimits
    ylim = updateYlimits(10*log10(P));
    
    grid(hAxes,'on');
    set(hAxes,'Ylim',ylim,'Xlim',[frqplot(1),frqplot(end)]);
        
    title(titlestr)
    xlabel(xlabelstr)
    ylabel(ylabelstr)
    
  else
    z = 10*log10(z);
    
    l = plot(frqplot,10*log10(P));

    hFig = ancestor(l(1),'figure');
    hAxes1 = ancestor(l(1),'axes');
    hAxes2 = axes('Parent',hFig,'YAxisLocation','right','Xtick',[]);
    
    % Put the plot axes on top
    uistack(hAxes1,'top');
            
    if nchannel>1
      ProbDet = repmat(ProbDet,1,nchannel);
    end
    
    zplot = ones(length(frqplot),length(ProbDet));
    z = z(:)';
    zp = bsxfun(@times,zplot,z);
    
    % Plot Pd
    hColor = get(l,'Color');
    hold(hAxes1,'on');
    for i=1:nchannel
      if nchannel==1
        plot(hAxes1,frqplot,zp,'Color',hColor,'LineStyle','--');
      else
        plot(hAxes1,frqplot,zp(:,i),'Color',hColor{i},'LineStyle','--');
      end
    end
    hold(hAxes1,'off');
    grid(hAxes1,'on');
    
    PdNum = cellstr(num2str(ProbDet','%1.2f '));
    PdDisplay = arrayfun(@(x) sprintf('%s %s','Pd =',x{:}),PdNum,'UniformOutput',false);
    
    zpTick = z;
    [zpTick,sortIdx] = sort(zpTick);
    PdDisplay = PdDisplay(sortIdx);
    
    if all(isinf(z))
      set(hAxes2,'YTick',[])
    else
      if all(zpTick==zpTick(1))
        zpTick = zpTick(1);
      end
      set(hAxes2,'YTick',zpTick)
    end
    
    set(hAxes2,'YTickLabel',PdDisplay)
    set(hAxes2,'FontSize',8); 
    
    % Update the Ylimits
    ylim = updateYlimits(10*log10(P));
    
    set([hAxes1,hAxes2],'Ylim',ylim,'Xlim',[frqplot(1),frqplot(end)]);
    linkprop([hAxes1,hAxes2],{'XLim', 'YLim'});    
    linkaxes([hAxes1,hAxes2],'xy');
    
    title(hAxes1,titlestr)
    xlabel(hAxes1,xlabelstr)
    ylabel(hAxes1,ylabelstr)
    
    set(hFig,'NextPlot','replacechildren');
  end   
 
else
    plot(frqplot,10*log10(P))
    grid on
    set(gca,'Box','On','XGrid','On','YGrid','On','XLim',[frqplot(1) frqplot(end)]);
    title(titlestr)
    xlabel(xlabelstr)
    ylabel(ylabelstr)
end
  
end

%% --------------------------------------------------------------------
function ylim = updateYlimits(mag)
% Estimate Y-axis limits 
% Algorithm:
%  - Estimate smoothed envelope of dB response curve,
%    to avoid "falling into nulls" in ripple regions
%  - Add a little "extra space" (margin) at top and bottom
%
% Note: we do NOT use the max and min of the response itself
%     - min is an overestimate often going to -300 dB or worse
%     - max is an underestimate causing the response to hit axis
%
% Returns:
%   ylim: vector of y-axis display limits, [ymin ymax]

MarginTop = 0.03;  % 3% margin of dyn range at top
MarginBot = 0.10;  % 10% margin at bottom

% Determine default margins
% Remove non-finite values for dynamic range computation
magf = mag;
magf(~isfinite(magf)) = [];
top = max(max(magf));
bot = min(min(magf));
dr = top-bot; % "modified" dynamic range

% Handle the null case.
if isempty(dr)
  ylim = [0 1];
else
  
  % If the dynamic range is less than 60 dB, just show the full range.
  % Otherwise we want to see if we can cut out part of the display by
  % doing analysis on its shape.
  if dr > 60
    
    % Length of sliding window to compute "localized maxima" values
    % We're looking for the MINIMUM of the ENVELOPE of the input curve
    % (mag). The true envelope is difficult to compute due as it is
    % positive-only The length of the sliding window is important:
    %  - too long: envelope estimate is biased toward "global max"
    %              and we lose accuracy of envelope minimum
    %  - too short: we fall into "nulls" and we're no longer tracking
    %               the envelope
    %
    % Set window to 10% of input length, minimum of 3 samples
    Nspan = max(3, ceil(.1*numel(mag)));
    
    % Compute mag envelope, derive y-limit estimates
    env = MiniMax(mag, Nspan);
    bot = env;
    
    % When we have more than 60 dB of dynamic range, make the minimum
    % shown dynamic range 60.
    if top-env < 60
      bot = top-60;
    end
  end
  ymin = bot - dr*MarginBot;  % Lower by fraction of dynamic range
  ymax = top + dr*MarginTop;
  ylim = [ymin ymax];
end

end

%% --------------------------------------------------------------------
function spanMin = MiniMax(mag,Nspan)
%MiniMax Find the minimum of all local maxima, with each
%  maxima computed over NSPAN-length segments of input.

Nele=numel(mag);
if Nele<Nspan
  spanMin = min(mag);
else
  
  % General case
  spanMin = max(mag(1:Nspan)); % max computed over first span
  intMax = spanMin;            % interval max computed over all spans
  
  % Only allow 8192 discrete steps.  This will improve the algorithms
  % speed greatly and only lose a small amount of accuracy.
  maxSteps = 8192;
  step = ceil((Nele-Nspan-1)/maxSteps);
  for i = 1:step:Nele-Nspan  % already did first span (above!)
    % Overall equivalent code for this section:
    %   spanMin = min(spanMin,max(mag(i:i+Ns1)));
    %
    % Update intMax, the maximum found over the current interval
    % The "update" is to consider just (a) the next point to bring
    % into the interval, and (b) the last point dropped out of the
    % interval.  This produces an efficient "slide by 1" max result.
    %
    % Equivalent code:
    %   intMax = max(mag(i:i+Ns1));
    pAdd = mag(i+Nspan);  % add point
    if pAdd > intMax
      % just take pAdd as new max
      intMax = pAdd;
    elseif mag(i) < intMax  % Note: pDrop = mag(i-1)
      % just add in effect of next point
      intMax = max(intMax, pAdd);
    else
      % pDrop == last_intMax: recompute max
      intMax = max(mag(i+1 : i+Nspan));
    end
    % Equivalent code:
    %   spanMin = min(spanMin,intMax);
    if spanMin > intMax
      spanMin = intMax;
    end
  end
end

end

%% --------------------------------------------------------------------------
% Compute Detection Probability
function ScaledZ = computePd(fr,ofac,ProbDet,nchannel,Ch)

nf = length(fr);
M = 2*nf/ofac;
a = 1 - ProbDet;
z =(-log(1-(1-a).^(1/M)));
z = z(:);
z = repmat(z,1,nchannel);
ScaledZ = bsxfun(@times,z,1./Ch.Alpha);

end

%% --------------------------------------------------------------------------
% Fast Lomb-Scargle Algorithm
function [wk2,f] = fasper(x,t,ofac,f)
ofac=real(ofac(1,1));

n = numel(t);
tmin = t(1);
T = t(end)-tmin;
Ts = T/(n-1);

if numel(f) == 1
    fmax = f;
    nout = round(0.5*ofac*n);
    f = cast((1:nout)'/(n*Ts*ofac), 'like', x);
    hifac = cast(fmax(1,1)/max(f), 'like', x);
else
    hifac = cast(1, 'like', x);
end

MACC = 4;

nfreq = 2^nextpow2(ofac*hifac*n*MACC);
fndim = 2*nfreq;

% Initialize
wk1 = zeros(fndim,1);
wk2 = zeros(fndim,1);

% Extrapolate 
fac = fndim/(n*Ts*ofac);
nfac = [1 1 2 6 24 120 720 5040 40320 362880];
nden = nfac(MACC);

for j = 1:n
    ck  = 1 + mod((t(j)-tmin)*fac,fndim);
    ckk = 1 + mod(2*(ck-1),fndim);
    wk1 = spread(x(j),wk1,fndim,ck ,MACC,nden);
    wk2 = spread(1   ,wk2,fndim,ckk,MACC,nden);
end

% Take the Fast Fourier Transforms
nout = round(0.5*ofac*hifac*n); 
f = (1:nout)'/(n*Ts*ofac);

wk1 = fft(wk1);
rwk1 = real(wk1(2:nout+1)); 
iwk1 = imag(wk1(2:nout+1));

wk2 = fft(wk2);
rwk2 = real(wk2(2:nout+1));
iwk2 = imag(wk2(2:nout+1));

% Compute the Lomb-Scargle value for each frequency
hypo  = abs(wk2(2:nout+1));
if any(hypo==0)
  wk2 = lombscargle(x,f,t);
else
  hypo  = abs(wk2(2:nout+1));
  hc2wt = 0.5*rwk2./hypo;
  hs2wt = 0.5*iwk2./hypo;
  cwt   = sqrt(0.5+hc2wt);
  swt   = sign(hs2wt).*(sqrt(0.5-hc2wt));
  den   = 0.5*n + hc2wt.*rwk2 + hs2wt.*iwk2;
  cterm = (cwt.*rwk1 + swt.*iwk1).^2./den;
  sterm = (cwt.*iwk1 - swt.*rwk1).^2./(n-den);
  wk2  = cterm+sterm;
  wk2  = wk2(:);
end

end

%% --------------------------------------------------------------------------
% Extirpolate the frequency
function yy = spread(y,yy,n,x,m,nden)

ndenl = nden;

if x == round(x)
    yy(x) = yy(x) + y;
else
    ilo = min([max([floor(x-0.5*m+1),1]),n-m+1]);
    ihi = ilo+m-1;
    fac = (x-ilo)*prod(x-(ilo+1:ihi));
    yy(ihi) = yy(ihi) + y*fac/(ndenl*(x-ihi));
    for j = ihi-1:-1:ilo
        ndenl = double((ndenl/(j+1-ilo))*(j-ihi));
        yy(j) = yy(j) + y*fac/(ndenl*(x-j));
    end
    
end

end

%% --------------------------------------------------------------------------
% Conventional Lomb-Scargle Algorithm
function P = lombscargle(x,f,t)

nf = length(f);

if isrow(t)
  t1 = t(1,:).';
else
  t1 = t;
end

P = zeros(nf,1);

for i=1:nf
  wt = 2*f(i)*t1;
  swt = sinpi(wt);
  cwt = cospi(wt);
  
  Ss2wt = 2*cwt.'*swt;            
  Sc2wt = (cwt-swt).'*(cwt+swt);  
  
  wtau = 0.5 * atan2(Ss2wt,Sc2wt);  
  
  swtau = sin(wtau);
  cwtau = cos(wtau);
  
  swttau = swt*cwtau - cwt*swtau; 
  cwttau = cwt*cwtau + swt*swtau; 
  
  swttauN = swttau.'*swttau;
  cwttauN = cwttau.'*cwttau;
  
  if abs(swttauN) < eps
      swttauN = swttauN + eps;
  end
  
  if abs(cwttauN) < eps
      cwttauN = cwttauN + eps;
  end
  
  P(i) = ((x.'*cwttau)^2)/(cwttauN) + ((x.'*swttau)^2)/(swttauN);
  
end   
end


%% --------------------------------------------------------------------------
% Screen data(x) and time(T) for missing data(NaNs)
% Remove missing data from x,t,f
function [Ch,f] = MarkMissingData(x,t,f,nchannel,fvecSpecified,ofac,spectrumtype,freqtype,Fs)

% Channel fMax
fMaxChnl = zeros(1,nchannel);

% Initialize struct of Array to store channel data
sizex = size(x);
Ch.SigAndTNanPos = coder.nullcopy(ones(nchannel,sizex(1)));
Ch.NanFlag = coder.nullcopy(false(1,nchannel));
Ch.SigMean = coder.nullcopy(ones(1,nchannel));
Ch.SigVar = coder.nullcopy(ones(1,nchannel));
Ch.Alpha = coder.nullcopy(ones(1,nchannel));
Ch.n = coder.nullcopy(ones(1,nchannel));

% Collect NaN Positions from time(t) for each channel(x)
tCol = t(:);
tNanPos     = find(isnan(tCol));

% Loop to find the missing data in each channel
for i = 1:nchannel
  
  % Channel 
  sig = x(:,i);
  coder.varsize('sig');
  
  % Accumulate NaN positions across each channel alone with t-nan positions  
  SigNanPos = find(isnan(sig));
  
  % Store all nans in to remove from channel and t before computing
  % periodogram  
  
  nunique = numel(unique([tNanPos;SigNanPos]));
   
  Ch.SigAndTNanPos(i,:) = [unique([tNanPos;SigNanPos]); zeros(sizex(1)-nunique, 1)] ;
  
  % Set NanFlag to true of any Nan is detected in time(t) or channel(sig)
  Ch.NanFlag(i) = any(Ch.SigAndTNanPos(i,:));
  
  % Remove NaN from channel from t-nan and ch-nan positions for further
  % computations in the loop
  sig(Ch.SigAndTNanPos(i, Ch.SigAndTNanPos(i,:) > 0)) = [];  
  
  % n for each channel
  Ch.n(i) = numel(sig);  
  
  % Get fmax for channel, assume hifac=1. Use T & n (after removing NaNs)
  % to compute fmax for each channel and store in fMaxChnl
  temp = t;
  temp(Ch.SigAndTNanPos(i, Ch.SigAndTNanPos(i,:) > 0)) = [];
  n = numel(temp);
  
  if isempty(temp)
    coder.internal.error('signal:plomb:NotEnoughDataPoints');
  end  
  
  T = temp(end)-temp(1);
  nout = round(0.5*ofac*n);
  
  if nout==0
    coder.internal.error('signal:plomb:OfacTooSmall');    
  end
  
  Ts = T/(n-1);
  fr = (1:nout)'/(n*Ts*ofac);
  fMaxChnl(i) = max(fr);
  
  % Check if available non-nan samples in Channels is non-empty 
  if isempty(sig)
    coder.internal.error('signal:plomb:NotEnoughPoints');
  end
  
  % Channel mean and variance
  Ch.SigMean(i)  = mean(sig);
  Ch.SigVar(i)   = var(sig);
  Ch.Alpha(i)    = getChAlpha(length(sig),spectrumtype,freqtype,Fs,Ch.SigVar(i));
  
  if Ch.SigVar(i)==0         
        coder.internal.warning('signal:plomb:SignalZeroVariance');     
  end 
  
end

% If any channels contain NaNs, and if frequency vector is not empty, and
% frequency vector is not specified then compute the new fmax after
% removing all NaNs from channels.
if any(Ch.NanFlag) && isempty(f) && ~fvecSpecified
  % Fmax, number of data excluding NaN - across all channels
  f = max(fMaxChnl);
end

end

%% --------------------------------------------------------------------------
% Returns Scaling factor(Alpha) for Detection Probability(Pd) 
function Alpha = getChAlpha(n,spectrumtype,freqtype,Fs,SigVar)

% Default(normalized) 
Alpha = 1;

if strcmpi(spectrumtype,'psd')
  if strcmpi(freqtype,'rad/samp')
    Alpha = pi/SigVar;
  else
    Alpha = double(Fs/(2*SigVar));
  end
elseif strcmpi(spectrumtype,'power')
  Alpha = n/(2*SigVar);
end

end

%% --------------------------------------------------------------------------
% Validate and Parse Inputs 
function [x1,t,f,ofac,spectrumtype,freqtype,tflag,ProbDet,Fs,fvecSpecified,nchannel] = parseAndValidateInputs(x,arglist)

% Initialize variables
tflag         = false;      % Time vector specified
ProbDet       = [];         % Detection Probability
spectrumtype  = 'psd';      % Set spectrumtype to default
freqtype      = 'rad/samp'; % Set freqtype to default
fvecSpecified = false;      % Frequency Vector specified flag

% Signal: Check for multidimensional array
% Validate signal (NaN is numeric and real)
validateattributes(x, {'numeric'}, {'real', '2d'}, mfilename, 'x', 1);

xtemp = x(:);
% Check if non-nan elements are finite
validateattributes(xtemp(~isnan(xtemp)),{'numeric'},{'finite'}, mfilename,'x',1);

% Convert signal to column vector if its not 
if isrow(x)
  x1 = x(1,:).';
elseif iscolumn(x)
  x1 = x(:,1);
else
  x1 = x;
end

% Parse through rest of arguments
if ~isempty(arglist)
  
  % Validate all flags, if incomplete - return valid values.  
  ignoreArgsIdx = false(1, numel(arglist)); 
  
  [ignoreArgsIdx,spectrumtype] = getSpectrumType(arglist,ignoreArgsIdx);       
  [ProbDet, ignoreArgsIdx] = getProbDensity(arglist, ignoreArgsIdx);  
  
  if ~isempty(ProbDet)
    validateattributes(ProbDet,{'numeric'},{'real','finite','positive','>=',0,'<=',1}, mfilename,'Pd')
  end
  
  % Parse through all the numeric arguments--------------------------------
  % Time Vector(t): Validate and cache
  if ~isempty(arglist)    
    [t,~,tflag,Fs,ignoreArgsIdx] = parseAndCacheTimeVector(x1,arglist,ignoreArgsIdx); 

    if tflag || ~isempty(Fs)
      freqtype = 'Hz';
    end
  end
  
  % Frequency Vector(t): Validate and cache
  if ~isempty(arglist)    
    [f,~,fvecSpecified,ignoreArgsIdx] = parseAndCacheFrequencyVector(arglist,ProbDet,ignoreArgsIdx); 
  else
    f = [];
  end
  
  % Oversampling factor: Validate and cache
  if ~isempty(arglist)
    [ofac,~,ignoreArgsIdx] = parseAndCacheOfac(arglist,ignoreArgsIdx);
  end
else
   ignoreArgsIdx=[];
   t = [];
   Fs = [];
   f = [];   
   ofac = [];
end

coder.varsize('t');
coder.varsize('f');
coder.varsize('ofac');

% Create time vector if empty
if isempty(t)
  if ~isempty(Fs)
    t = cast((0:size(x1,1)-1)*(1/Fs(1,1)), 'like', t);
  else
    t = cast((0:size(x1,1)-1), 'like', t);
  end
end

unparsedArgs = find(~ignoreArgsIdx);
if ~isempty(unparsedArgs)
   ambArgs = unparsedArgs + 1;
   errAmbParams(ambArgs);   
end

% Find signal length(n), Assume same Fs for every channel
tCol = t(:);
temp = tCol(~isnan(tCol));
n = numel(temp);
T = temp(end)-temp(1);
Fs = (n-1)/T;

% Check Minimum value for fmax
if numel(f)==1 
  if isempty(ofac)
    ofac=4; 
  end
  if strcmpi(freqtype,'Hz')
    minVal = 1/(T*ofac);
  else
    minVal = cast((2*pi)/(ofac*n), 'like', T);
  end
  if f<minVal
    coder.internal.error('signal:plomb:FmaxTooLow');
  end
end

if fvecSpecified && ~isempty(ofac)
   coder.internal.error('signal:plomb:CannotSpecifyOfac');
end

% After all the above checks, if assign default to ofac if empty
if isempty(ofac)
  ofac = 4;
end

% frequency in rad/samp
if ~isempty(f) && strcmpi(freqtype,'rad/samp')
  % Convert to Hz
  f = cast(f.*(Fs/(2*pi)), 'like', f);  
end

% Number of channels in the data
nchannel = size(x1,2);

end

%% --------------------------------------------------------------------------
% get probability density
function [pd,ignoreArgsIdx] = getProbDensity(arglist, ignoreArgsIdx)
  pdFlags = {'Pd'};
  ambiguousInput = false;  

  pd = [];
  coder.varsize('pd');

  for i = 1:length(arglist)
    if ignoreArgsIdx(i)
      continue;
    end

    idx = strcmpi(pdFlags, arglist{i});
   
    if any(idx)
      if length(arglist) > i
        ignoreArgsIdx([i i+1]) = true;
      else
        ignoreArgsIdx(i) = true;
        coder.internal.error('signal:plomb:PdValuesMissing');
        break;
      end

      if isempty(arglist{i+1})        
        coder.internal.error('signal:plomb:PdValuesMissing');
        break;
      end
      
      if isempty(pd)
        pd = double(arglist{i+1});
      else
        ambiguousInput = true;
      end
    end
  end

  coder.internal.errorIf(ambiguousInput, 'signal:plomb:AmbiguousInputs', 'probability density');
end


%% --------------------------------------------------------------------------
% Parse and cache time vector(t)
function [t,arglist,tflag,Fs,ignoreArgsIdx] = parseAndCacheTimeVector(x,arglist,ignoreArgsIdx)

% Initialize tflag
tflag = false;
hasTf = false;

timeVecArgIdx = 1;
if ~isempty(arglist) && ~ignoreArgsIdx(timeVecArgIdx)
    if isa(arglist{timeVecArgIdx}, 'single')
        t1 = cast(arglist{timeVecArgIdx}, 'single');
        hasTf = true;        
    elseif isa(arglist{timeVecArgIdx}, 'double')
        t1 = cast(arglist{timeVecArgIdx}, 'double');
        hasTf = true;
    else
        if coder.target('MATLAB')
            t1 = arglist{timeVecArgIdx};
            hasTf = true;
        end
    end
else
    if ~coder.target('MATLAB')
        validateattributes(arglist{timeVecArgIdx}, {'double', 'single'}, ...
            {'real', 'finite', '>', 0}, 'plomb', 't', 2);
        t1 = zeros(0, 'like', arglist{timeVecArgIdx});
        Fs = zeros(0, 'like', arglist{timeVecArgIdx});
    else
        t1 = [];
        Fs = [];
    end    
end


% check for datetime
if ~isempty(t1)
  if coder.target('MATLAB')
    if isdatetime(t1)
      t1 = seconds(t1-t1(1));
    elseif isduration(t1)
      t1 = seconds(t1);
    end
  else
    % timetable inputs are not supported for codegen    
    if ~isnumeric(t1)
      coder.internal.error('signal:plomb:TimeVectorNumeric');
    end
  end
end

if isnumeric(t1)
  if numel(t1) == 1
    % Treat the argument as Fs
    Fs = t1;    
    validateattributes(Fs,{'numeric'},{'real','finite','>',0},'PLOMB','Fs',2);
    t = zeros(0, 'like', arglist{timeVecArgIdx});
  else       
    % Validate time vector if not empty
    if ~isempty(t1)
      
      % Set time vector flag
      tflag = true;
      % Check if t is vector, multi-channel time(t) not supported
      validateattributes(t1,{'numeric'},{'vector','real'},'PLOMB','T',2);      
      t2 = t1(:);      
      % Check if t values are positive and values other nan are finite    
      validateattributes(t2(~isnan(t2)),{'numeric'},{'real','increasing','finite','>=',0}, ...
        'PLOMB','T',2);
    end
        
    % Check if signal (1st channel) and time are of same length    
    coder.internal.errorIf(~isempty(t1) && size(x,1)~=length(t1), ...
        'signal:plomb:SignalTimeSameSize');
    
    % Force to be column vector    
    t = t1(:); 
    
    if ~coder.target('MATLAB')
        Fs = zeros(0, 'like', arglist{timeVecArgIdx});
    else
        Fs = [];
    end
  end
  
  if hasTf
    ignoreArgsIdx(timeVecArgIdx) = true;
  else
    ignoreArgsIdx(1) = true;
  end
else
  coder.internal.error('signal:plomb:TimeVectorNumeric');
end
end


%% --------------------------------------------------------------------------
% Parse and cache frequency vector(t)
function [f,arglist,fvecSpecified,ignoreArgsIdx] = parseAndCacheFrequencyVector(arglist,ProbDet,ignoreArgsIdx)

% Initialize flag
fvecSpecified = false;
f=[];
coder.varsize('f');

% Frequency Vector Validate and Parse
hasFreq=false;
for i=1:numel(arglist)
  if ignoreArgsIdx(i)        
     continue;
  else                    
     ignoreArgsIdx(i) = true;
     f = double(arglist{i});
     hasFreq=true;
     break;        
  end
end    

if ~hasFreq
  f = [];
  return;
end

if numel(f)==1
  % Single value f is treated as fmax, validate its attributes
  validateattributes(f,{'numeric'},{'real','finite'},'PLOMB','FMAX',3);
elseif numel(f)> 1
  % Frequency vector specified
  % % f([]-fasper), f(1x1-fasper,fmax), f(1xn-slow,fvev)
  fvecSpecified = true;
  % Check signal channel is real, numeric and single channel
  validateattributes(f,{'numeric'},{'real','finite','vector'},'PLOMB','FVEC',3);
  
  % Pd feature not available when f specified
  if ~isempty(ProbDet)
    coder.internal.error('signal:plomb:PdFreqSpecErr');
  end
  
  % Sort f is necessary
  if ~issorted(f)
    f = sort(f);
  end
end

% Force to be column vector
f = f(:);

end
        
%% --------------------------------------------------------------------------
% Parse and cache oversampling factor(ofac)
function [ofac,arglist,ignoreArgsIdx] = parseAndCacheOfac(arglist,ignoreArgsIdx)

% of = arglist{1};
of = [];
ofac = [];

hasOfac=false;
for i=1:numel(arglist)
  if ignoreArgsIdx(i)
     continue;
  else        
     of = double(arglist{i});
     hasOfac=true;
     ignoreArgsIdx(i) = true;
     break;        
  end
end

if ~hasOfac
  ofac = [];
  return;
end

if ~isnumeric(of)
  coder.internal.error('signal:plomb:OfacNumeric');
end

if ~isempty(of)
  ofac = of;
  validateattributes(ofac,{'numeric'},{'scalar', 'real','finite','positive','integer','>',0},'PLOMB','OFAC',4);
end

end

%% --------------------------------------------------------------------------
% Validate all the strings against the list of valid flags
function [ignoreArgsIdx,spectrumtype] = getSpectrumType(testString,ignoreArgsIdx)

listString = {'psd', 'power', 'normalized', 'Pd'};
ambInputs = [];
coder.varsize('ambInputs');

if ~iscell(testString)
  testString = {testString};
end

% default spectrum flag
spectrumtype = 'psd';

for i = 1:length(testString)  
  % Skip scalars
  if ischar(testString{i})
    
    % Check for full match
    idx = strcmpi(listString,testString{i});
    
    if ~any(idx)
      % Check for partial match
      idx = strncmpi(listString,testString{i},length(testString{i}));
    end

    numMatches = sum(idx);
    if numMatches == 0
      coder.internal.error('signal:plomb:InvalidInput',testString{i});
    elseif numMatches > 1
      ambInputs = [ambInputs i+1]; %#ok
    else
      if idx(1) == true   
        ignoreArgsIdx(i) = true;
        spectrumtype = listString{1};
      elseif idx(2) == true          
        ignoreArgsIdx(i) = true;
        spectrumtype = listString{2};
      elseif idx(3) == true
        ignoreArgsIdx(i) = true;
        spectrumtype = listString{3};
      end      
    end    
  end  
end

if ~isempty(ambInputs)
  errAmbParams(ambInputs);
end

end

%% --------------------------------------------------------------------------
% Print error for ambiguous inputs
function errAmbParams(ambInputs)  
  str = list2str(ambInputs);
  if numel(ambInputs) > 1
    coder.internal.error('signal:plomb:AmbiguousInputs',str);
  else
    coder.internal.error('signal:plomb:AmbiguousSingleInput',str);
  end
end

%% --------------------------------------------------------------------------
% Return string for numeric list.
function str = list2str(n)
    validateattributes(n, {'numeric'}, {'finite', 'real', 'positive'}, 'plomb');
    str = '';
    coder.varsize('str');
    for i = 1:numel(n)
        str = [str sprintf('%d', int64(n(i))) ' '];
    end
end
