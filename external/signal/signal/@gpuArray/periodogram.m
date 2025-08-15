function varargout = periodogram(x,varargin)
%PERIODOGRAM  Power Spectral Density (PSD) estimate via periodogram method on the GPU.
%
%   Pxx = PERIODOGRAM(X)
%   Pxx = PERIODOGRAM(X,WINDOW)
%   Pxx = PERIODOGRAM(X,WINDOW,...,SPECTRUMTYPE)
%   [Pxx,W] = PERIODOGRAM(X,WINDOW,NFFT)
%   [Pxx,W] = PERIODOGRAM(X,WINDOW,W)
%   [Pxx,F] = PERIODOGRAM(X,WINDOW,NFFT,Fs)
%   [Pxx,F] = PERIODOGRAM(X,WINDOW,F,Fs)
%   [...] = PERIODOGRAM(X,WINDOW,NFFT,...,FREQRANGE)
%   [Pxx,F,Pxxc] = PERIODOGRAM(...,'ConfidenceLevel',P)
%   [RPxx,F] = PERIODOGRAM(X,WINDOW,...,'reassigned')
%   [RPxx,F,Pxx,Fc] = PERIODOGRAM(...,'reassigned')
%   PERIODOGRAM(...)
%
%   See also GPUARRAY, PERIODOGRAM.

%   Copyright 2020 The MathWorks, Inc.

narginchk(1,10);

onGPU = false;
if nargin > 1
    % Both input signal and window (if it is a non-empty numeric vector)
    % determine whether the calculation is done on the GPU and the output
    % datatype.
    if isa(x, "gpuArray") || ( isa(varargin{1},"gpuArray") && isnumeric(varargin{1}) && numel(varargin{1})>1 )
        onGPU = true;
        % Ensure that the input signal is on the GPU.
        x = gpuArray(x);
        % Check that a window vector has been provided. If so, ensure that
        % it is on the GPU.
        if isnumeric(varargin{1}) && numel(varargin{1})>1
            varargin{1} = gpuArray(varargin{1});
        end
        % Gather all extra arguments.
        if nargin > 2
            [varargin{2:end}] = gather(varargin{2:end});
        end
    else
        % Gather all extra arguments.
        [varargin{:}] = gather(varargin{:});
    end
else
    if isa(x,"gpuArray")
        onGPU = true;
    end
end

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

% Dispatch in-memory periodogram if input signal is not gpuArray or input
% window vector is not gpuArray.
if ~onGPU
    varargout = cell(1,nargout);
    [varargout{:}] = periodogram(x,varargin{:});
    return;
end

% look for psd, power, and ms window compensation flags
[esttype, args]= signal.internal.psdesttype({'psd','power','ms'},'psd',varargin);
if strcmpi(esttype,'ms')
    error(message("signal:periodogram:InvalidMsLegacyOption"));
end

if isvector(x)
    N = length(x); % Record the length of the data
else
    N = size(x,1);
end

% extract window argument
if ~isempty(args) && ~ischar(args{1})
    win = args{1};
    args1 = args(2:end);
else
    win = [];
    args1 = args;
end

% scan for options
options = periodogram_options(isreal(x),N,args1{:});

if ~options.reassign && nargout>3
    error(message('MATLAB:nargoutchk:tooManyOutputs'));
end

% Generate a default window if needed
%   default window is rectangular of same size as input.
%   if 'reassigned' is specified, then a Kaiser window is used instead
winName = 'User Defined';
winParam = '';
if isempty(win)
    if options.reassign
        win = kaiser(N,38);
    else
        win = rectwin(N);
        winName = 'Rectangular';
        winParam = N;
    end
    % Ensure that the default window is also on the GPU.
    win = gpuArray(win);
end

% In-memory periodogram uses signal.internal.sigcheckfloattype but it
% relies on isa(x, datatype). Performing input validation here.
if ~isfloat(x)
    error(message('signal:sigcheckfloattype:InvalidInput',...
    'X', 'periodogram', 'double/single', classUnderlying(x)));
end
if ~isfloat(win)
    error(message('signal:sigcheckfloattype:InvalidInput',...
    'WINDOW', 'periodogram', 'double/single', classUnderlying(win)));
end

if (numel(x)<2 || numel(size(x))>2)
    error(message('signal:computeperiodogram:NDMatrixUnsupported'));
end

% Cast to enforce precision rules. Both x and window are gpuArray.
if superiorfloat(x, win) == "single"
    x = single(x);
    win = single(win);
end

Fs    = options.Fs;
nfft  = options.nfft;

% Compute the PS using periodogram over the whole Nyquist range.
[Sxx,w,RSxx,wc] = computeperiodogram(x,win,nfft,esttype,Fs,options);

% If frequency vector was specified, return and plot two-sided PSD
if length(nfft) > 1 && strcmpi(options.range,'onesided')
    warning(message('signal:periodogram:InconsistentRangeOption'));
    options.range = 'twosided';
end

% compute reassigned spectrum if needed.
if options.reassign
    RPxx = computepsd(RSxx,w,options.range,nfft,Fs,esttype);
    % Compute the one-sided corrected frequency vector for each component
    % of input signal
    wc = makeOnesidedWc(options.range,wc,nfft);
    % de-alias
    wc = dealiasWc(options,wc);
else
    RPxx = cast([],'like',RSxx);
    wc = zeros([0,0],'like',w);
end

% Compute the 1-sided or 2-sided PSD [Power/freq] or mean-square [Power].
% Also, compute the corresponding freq vector & freq units.
[Pxx,w,units] = computepsd(Sxx,w,options.range,nfft,Fs,esttype);

% compute confidence intervals if needed.
if ~isnan(options.conflevel)
    Pxxc = signal.internal.spectral.confInterval(options.conflevel, Pxx, isreal(x), w, options.Fs, 1);
elseif nargout>2 && ~options.reassign
    Pxxc = signal.internal.spectral.confInterval(0.95, Pxx, isreal(x), w, options.Fs, 1);
else
    Pxxc = cast([],'like',Pxx);
end

if nargout==0 % Plot when no output arguments are specified
    [Pxx,w,Pxxc,RPxx] = gather(Pxx,w,Pxxc,RPxx);
    signal.internal.spectral.plotPeriodogram(Pxx,w,Pxxc,RPxx,options,esttype,units,winName,winParam);
else
    if options.centerdc
        if options.reassign
            RPxx = signal.internal.spectral.psdcenterdc(RPxx, w, [], options);
            wc = centerWc(options,wc);
        end
        [Pxx, w, Pxxc] = signal.internal.spectral.psdcenterdc(Pxx, w, Pxxc, options);
    end
    
    % assign outputs in correct order
    if options.reassign
        % first and third output are reassigned and unnormalized power
        Px = RPxx;
        Px0 = Pxx;
    else
        % first and third output are normalized power and confidence
        % intervals
        Px = Pxx;
        Px0 = Pxxc;
    end
    
    % If the input is a vector and a row frequency vector was specified,
    % return output as a row vector for backwards compatibility.
    if size(options.nfft,2)>1 && isvector(x)
        Px = real(Px.');
        w = w.';
        if options.reassign
            Px0 = Px0.';
            wc = wc.';
        end
    else
        Px = real(Px);
    end
    
    % Cast to enforce precision rules
    % Only case if output is requested, otherwise plot using double
    % precision frequency vector.
    w = cast(w,'like',Px);
    if options.reassign
        wc = cast(wc,'like',Px);
    else
        wc = zeros(0,0,'like',Px);
    end
    
    outputs = {Px,w,Px0,wc};
    varargout = outputs(1:nargout);
end
end

%------------------------------------------------------------------------------
function options = periodogram_options(isreal_x,N,varargin)
%PERIODOGRAM_OPTIONS   Parse the optional inputs to the PERIODOGRAM function.
%   PERIODOGRAM_OPTIONS returns a structure, OPTIONS, with following fields:
%
%   options.nfft         - number of freq. points at which the psd is estimated
%   options.Fs           - sampling freq. if any
%   options.range        - 'onesided' or 'twosided' psd
%   options.centerdc     - true if 'centered' specified

% Generate defaults
sizeNFFT = [1 1];
for i=1:length(varargin)
    if ~ischar(varargin{i})
        sizeNFFT = size(varargin{i});
        break;
    end
end
if sizeNFFT(1) > 1 || sizeNFFT(2) > 1
    options1.nfft = coder.nullcopy(zeros(sizeNFFT));
else
    options1.nfft = max(256, 2^nextpow2(N));
end

%assign invalid default value to infer size as 1*1 for codegen
options1.Fs = nan; % Work in rad/sample
options1.centerdc = false;
options1.range = 'twosided';  %Two Sided Range
options1.conflevel = nan; % Default Invalid value

% extract and remove any 'reassigned' option from the argument list
[reassign,args1] = getReassignmentOption(varargin{:});
options1.reassign = reassign;

% Determine if frequency vector specified
freqVecSpec = false;
len_args = length(args1);
if len_args > 0
    for i=1:len_args
        if ~ischar(args1{i}) && length(args1{i}) >1
            freqVecSpec = true;
        end
    end
end

if isreal_x && ~freqVecSpec
    options1.range = 'onesided'; %One Sided Range
end

% Scan legacy freqrange options and error
if any(strcmp(args1, 'whole'))
    error(message('signal:periodogram:InvalidFreqrangeLegacyOption'));
elseif any(strcmp(args1, 'half'))
    error(message('signal:periodogram:InvalidFreqrangeLegacyOption'));
end

[options,msg,msgobj] = psdoptions(isreal_x,options1,args1{:});

if ~isempty(msg)
  error(msgobj);
end

% ensure frequency vector is linearly spaced when performing reassignment
if reassign && ~isscalar(options.nfft)
    f = reshape(options.nfft,[],1);
    
    % see if we can get a uniform spacing of the freq vector
    [~, ~, ~, maxerr] = signal.internal.spectral.getUniformApprox(f);
    isuniform = maxerr < 3*eps(signalwavelet.internal.typeof(f));
    
    if ~isuniform
        error(message("signal:periodogram:ReassignFreqMustBeUniform"));
    end
end

end

%--------------------------------------------------------------------------
function [reassign, args]  = getReassignmentOption(varargin)
% search for 'reassigned' flag and return true if present.
% error if 
reassign = false;
args = varargin;
matchLoc = find(strncmpi('reassign',args,8));
if ~isempty(matchLoc)
    reassign = true;
    if any(strcmpi('confidencelevel',args))
        %required to be a runtime error for function signatures : func(x,'conflevel',c)
        error(message('signal:psdoptions:ConflictingOptions','reassigned', 'ConfidenceLevel'));
    end
end

args(matchLoc) = [];

end

%--------------------------------------------------------------------------
function w = makeOnesidedWc(range,w,nfft)

if strcmp(range,'onesided') && isscalar(nfft)
   if mod(nfft,2) ~= 0
      select = matlab.internal.ColonDescriptor(1,1,(nfft+1)/2);  % ODD
   else
      select = matlab.internal.ColonDescriptor(1,1,nfft/2+1);    % EVEN
   end
   w = subsref(w, substruct('()', {select,':'}));
end
end

%--------------------------------------------------------------------------
function Wc = centerWc(options,Wc)

nFreq = size(Wc,1);
if options.centerdc
  nfft_even = signalwavelet.internal.iseven(options.nfft);
  if strcmp(options.range,'onesided')
    if nfft_even
      Wc = [-subsref(Wc, substruct('()', {matlab.internal.ColonDescriptor(nFreq-1,-1,2), ':'})) ; ...
          subsref(Wc, substruct('()', {matlab.internal.ColonDescriptor(1,1,nFreq), ':'}))];
    else
      Wc = [-subsref(Wc, substruct('()', {matlab.internal.ColonDescriptor(nFreq,-1,2), ':'})) ; ...
          subsref(Wc, substruct('()', {matlab.internal.ColonDescriptor(1,1,nFreq), ':'}))];
    end
  else % two-sided
    if nfft_even
      Wc = [subsref(Wc, substruct('()', {matlab.internal.ColonDescriptor(nFreq/2+2,1,nFreq), ':'})) ; ...
          subsref(Wc, substruct('()', {matlab.internal.ColonDescriptor(1,1,nFreq/2+1), ':'}))];
    else
      Wc = [subsref(Wc, substruct('()', {matlab.internal.ColonDescriptor((nFreq+1)/2+1,1,nFreq), ':'})) ; ...
          subsref(Wc, substruct('()', {matlab.internal.ColonDescriptor(1,1,(nFreq+1)/2), ':'}))];
    end
  end
end
end

%--------------------------------------------------------------------------
function Wc = dealiasWc(options,Wc)
Fs = options.Fs;
if isnan(Fs)
    % normalize to 2*pi when default specified.
    Fs1 = 2*pi;
else
    Fs1 = Fs;
end

freqs = options.nfft;

hasNegativeFreqs  = any(freqs < 0);

if options.centerdc || hasNegativeFreqs
   % map to [-Fs/2,Fs/2) when using negative frequencies
   Wc = mod(Wc+Fs1/2,Fs1)-Fs1/2;
else
   % map to [0,Fs) when using positive frequencies
   Wc = mod(Wc,Fs1);
end
end
