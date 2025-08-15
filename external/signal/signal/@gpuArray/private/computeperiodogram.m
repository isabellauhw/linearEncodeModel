function [Pxx,F,RPxx,Fc] = computeperiodogram(x,win,nfft,esttype,Fs,options)
%COMPUTEPERIODOGRAM   Periodogram spectral estimation.
%   This function is used to calculate the Power Spectrum Sxx, and the
%   Cross Power Spectrum Sxy.
%   Input X can be a matrix or a multidimensional array.

%   Copyright 2019-2020 The MathWorks, Inc.

narginchk(5,7);
if nargin<6
  reassign = false;
  range = 'twosided';
else
  reassign = options.reassign;
  range = options.range;
end

% use normalized frequencies when Fs is empty
if isempty(Fs) || isnan(Fs)
    Fs = 2*pi;
end

% Validate inputs and convert row vectors to column vectors.
[x1,~,y,is2sig,win1] = validateinputs(x,win,nfft);

% Window the data
xw = x1.*win1;


% Compute the periodogram power spectrum [Power] estimate
% A 1/N factor has been omitted since it cancels
[Xx,F] = computeDFT(xw,nfft,Fs);
realXx = real(subsref(Xx, substruct('()', {[]})));
F = cast(F,'like',realXx);
if reassign
    % dtwin not supported on the GPU
    dtwin1 = gpuArray(signal.internal.spectral.dtwin(gather(win1),Fs));
    xtw = x1.*dtwin1;
    [Xxc,~] = computeDFT(xtw,nfft,Fs);
    Fc = arrayfun(@freqCorrect,Xxc,Xx,F);
else
    Fc = zeros([0,0],'like',F);
end

% if two signals are used, we are being called from welch and are not
% performing reassignment.
if is2sig
  yw = y.*win1;
else
  yw = zeros(0,'like',y);
end

% Evaluate the window normalization constant.  A 1/N factor has been
% omitted since it will cancel below.
if any(strcmpi(esttype,{'ms','power'}))
  if reassign
    if isscalar(nfft)
      U = nfft*(win1'*win1);
    else
      U = numel(win1)*(win1'*win1);
    end
  else
    % The window is convolved with every power spectrum peak, therefore
    % compensate for the DC value squared to obtain correct peak heights.
    U = sum(win1)^2;
  end
else
    U = win1'*win1;  % compensates for the power of the window.
end

if is2sig
  [Yy,F] = computeDFT(yw,nfft,Fs);
  % Yy can be a single vector or a matrix
  Pxx = (Xx.*conj(Yy))/U;  % Cross spectrum.
else
  % We do a real cast to make Pxx real in codegen.
  Pxx = real(Xx.*conj(Xx)/U);                % Auto spectrum.
end


% Perform reassignment
if reassign
  RPxx = reassignPeriodogram(Pxx, F, Fc, nfft, range);
else
  RPxx = cast([],'like',Pxx);
  Fc = zeros([0,0],'like',F);
end
end

%--------------------------------------------------------------------------
function [fcorr] = freqCorrect(yc,y,f)
% Apply frequency correction from time derivative window

fcorr = -imag(yc ./ y);
if ~isfinite(fcorr)
    fcorr = zeros("like",f);
end
fcorr = fcorr+f;
end

%--------------------------------------------------------------------------
function [x1,Lx,y,is2sig,win1] = validateinputs(x,win,~)
% Validate the inputs to computexperiodogram and convert row vectors to
% column vectors for backwards compatiblility with R2014a and prior
% releases

% Set defaults and convert to row vectors to columns.
is2sig = false;
win1 = reshape(win, [], 1);
Lw = length(win);

% Determine if one or two signal vectors was specified.
if iscell(x)
    if length(x) > 1
        y1 = x{2};
        validateattributes(y1,{'single','double'}, {'finite','nonnan'},'periodogram','x');
        if isvector(y1)
            y = reshape(y1, [], 1);
        else
            y = y1;
        end
        is2sig = true;
    end
    x2 = x{1};
else
    y = zeros([0,0],'like',x);
    x2 = x;
end

validateattributes(x2,{'single','double'}, {'finite','nonnan'},'periodogram','x');
if isvector(x2)
    x1 = reshape(x2, [], 1);
else
    x1 = x2;
end

Lx = size(x1,1);

if is2sig
    Ly  = size(y,1);
    if Lx ~= Ly
        coder.internal.error('signal:computeperiodogram:invalidInputSignalLength');
    end
    if size(x1,2)~=1 && size(y,2)~=1 && size(x1,2) ~= size(y,2)
        coder.internal.error('signal:computeperiodogram:MismatchedNumberOfChannels');
    end
end

coder.internal.errorIf(Lx ~= Lw, 'signal:computeperiodogram:invalidWindow', 'window');

end

% -------------------------------------------------------------------------
function RP = reassignPeriodogram(P, f, fcorr, nfft, range)

% for each column input of Sxx, reassign the power additively
% independently.

nChan = size(P,2);

nf = numel(f);
fmin = head(f,1);
fmax = tail(f,1);

% compute the destination row for each spectral estimate
% allow cyclic frequency reassignment only if we have a full spectrum
fcorrVector = reshape(fcorr, [], 1);
if isscalar(nfft) && strcmp(range,'twosided')
    rowIdx = 1+mod(round((fcorrVector-fmin)*(nf-1)/(fmax-fmin)),nf);
else
    rowIdx = 1+round((fcorrVector-fmin)*(nf-1)/(fmax-fmin));
end

% compute the destination column for each spectral estimate
chanIdx = gpuArray.colon(1, nChan);
colIdx = repmat(chanIdx,nf,1);

% reassign the estimates that fit inside the frequency range
P = reshape(P, [], 1);
idx = find(rowIdx>=1 & rowIdx<=nf);
RP = accumarray([subsref(rowIdx, substruct('()', {idx})) subsref(colIdx, substruct('()', {idx}))], ...
    subsref(P, substruct('()', {idx})), [nf nChan]);
end

% -------------------------------------------------------------------------

% LocalWords:  Sxx Sxy NFFT ESTTYPE RSxx Fc Fs Yy computexperiodogram
% LocalWords:  compatiblility nonnan
