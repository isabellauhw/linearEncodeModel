function varargout = tsa(x,varargin)
%TSA Time-synchronous signal average
%   TA = TSA(X,Fs,TP) computes a time-synchronous signal average, TA, of
%   the signal X based on a vector of tachometer pulse times, TP, in
%   seconds. X is a vector sampled at a rate of Fs hertz. If TP is a
%   vector, it contains nonnegative strictly increasing time instants of
%   constant rotational phase. If TP is a scalar, it contains a constant
%   time interval over which all rotations occur. You can use TACHORPM to
%   extract tachometer pulse time instants from a tachometer signal.
%
%   TA = TSA(X,T,TP) computes a time-synchronous average of X with
%   corresponding time values in T. T can be a vector, a one-dimensional
%   <a href="matlab:help duration">duration</a> array, or a scalar duration. If T is a vector or a duration 
%   array, it contains sample times corresponding to each element of X. If
%   T is a scalar duration, it contains the time interval between samples.
%   Time values must be strictly increasing and finite.
%
%   TA = TSA(XT,TP) computes a time-synchronous average for the signal
%   stored in the timetable XT. XT must contain a single numeric column
%   variable. Time values in XT must be strictly increasing and finite.
%
%   TA = TSA(...,'PulsesPerRotation',PR) specifies a positive scalar
%   representing the number of reference time instants in TP per shaft
%   rotation. PR defaults to 1.
%
%   TA = TSA(...,'Method',AM) specifies the averaging method. AM can be:
%     'linear': linear interpolation
%     'spline': cubic spline interpolation
%      'pchip': piecewise cubic Hermite interpolation
%        'fft': frequency-domain averaging
%   AM defaults to 'linear'.
%
%   TA = TSA(...,'ResampleFactor',RF) specifies a positive integer
%   factor to increase the sample rate of X before averaging. RF
%   defaults to 1. 
%
%   TA = TSA(...,'NumRotations',NR) specifies a positive integer
%   representing the number of shaft rotations contained in TA. NR defaults
%   to 1.
%
%   [TA,T,P] = TSA(...) returns the sample times, T, and the phase in
%   revolutions, P, corresponding to TA.
%
%   [TA,T,P,RPM] = TSA(...) returns the constant rotational speed
%   corresponding to TA in revolutions per minute.
%
%   TSA(...) with no output arguments plots the time-synchronous average
%   signal and corresponding signal segments in the current plot.
%
%   % Example 1: 
%   %   Compute the time-synchronous average of a sinusoid in white 
%   %   Gaussian noise.
%   fs = 500;
%   f0 = 10;
%   t = (0:9999)'/fs;
%   y = sin(2*pi*f0*t)+randn(size(t))/10;
%   tPulse = (0:1/f0:max(t))';
%   tsa(y,fs,tPulse)
%
%   % Example 2: 
%   %   Compute the time-synchronous average of a Gaussian noise signal.
%   fs = 500;
%   t = seconds((0:9999)'/fs);
%   y = randn(size(t))/10;
%   TT = timetable(t,y);
%   tPulse = 1/10;
%   tsa(TT,tPulse)

% Copyright 2017-2018 The MathWorks, Inc.

%#ok<*EMCLS>
%#ok<*EMCA>
%#codegen

narginchk(2,11);
nargoutchk(0,4);

if nargout == 0 && ~coder.target('MATLAB')
    % Plotting is not supported for code generation. If this is running in
    % MATLAB, just call MATLAB's TSA, else error.
    coder.internal.assert(coder.target('MEX') || coder.target('Sfun'), ...
        'signal:codegeneration:PlottingNotSupported');
    feval('tsa',x,varargin{:});
    return
end

[x,t,fs,tp,pr,nr,rf,im,ad,isTimeTable,~,timeType,timeFormat] = parseAndValidateInputs(x,varargin{:});

% Cast to enforce precision rules
isSingle = isa(x,'single');
if isSingle
    t = single(t);
    fs = single(fs);
    tp = single(tp);
    pr = single(pr);
    rf = single(rf);
    nr = single(nr);
else
    t = double(t);
    fs = double(fs);
    tp = double(tp);
    pr = double(pr);
    rf = double(rf);
    nr = double(nr);
end

if rf > 1
    % Interpolate (resample) by zero-padding in the frequency domain.
    xUp = fftInterpolate(x,rf);
    tUp = interp1(1:length(t),t,(1:1/rf:length(t)+1-1/rf)','linear','extrap');
else
    xUp = x;
    tUp = t;
end

% Interpolate tachometer pulse locations based on the number of pulses per
% revolution to determine synchronous signal start and end points. Segment
% start locations are up to the second to last tachometer pulse.
st = interp1(1:length(tp),tp,(1:pr:length(tp))','linear');

if strcmp(ad,'time') % time-domain averaging
    % Determine the number of interpolation points for each synchronous
    % segment. We use the number of points in the minimum segment period
    % and 'round' for consistency with the frequency domain approach.
    N = round(min(diff(st),[],1)*fs);
    
    % Compute the sample rate. The output sample rate is not well defined
    % here, since we are really resampling in the phase domain. Define fsO
    % so that a constant tone input at f0 yields a constant tone at f0 for
    % both integer and non-integer number of samples per cycle (fs/f0). We
    % use the minimum segment period for consistency with the frequency
    % domain approach.
    fO =  1/min(diff(st),[],1);
    fsO = N*fO;
    
    % Interpolate each synchronous segment onto an N-sample time grid. Use
    % up to the second to last pulse time to ensure the entire segment fits
    % in the data.
    tss = bsxfun(@plus,st(1:end-1),bsxfun(@times,(0:N-1),diff(st)/N))';
    tsaM = interp1(tUp,xUp,tss,im);
    
    % Create signal sections
    if ~isequal(nr,1)
        sz2 = size(tsaM,2)-mod(size(tsaM,2),nr);
        tsaM = reshape(tsaM(:,1:sz2),size(tsaM,1)*nr,[]);
    end
    
    % Average sections
    tsa = mean(tsaM,2);
    
else % frequency-domain averaging
    % Reduce segments based on number of rotations to include in the output.
    st = st(1:nr:length(st)-mod(length(st)-1,nr));
    
    % Find start sample index for each segment.
    idxStart = round(interp1(tUp,1:length(tUp),st(1:end-1),'linear'));
    % Use 'extrap' because last pulse time can be outside the range of tUp.
    idxEnd = round(interp1(tUp,1:length(tUp),st(2:end),'linear','extrap'))-1;
    
    % Define the segment spectrum length.
    N = min(idxEnd-idxStart,[],1)+1;
    
    % Compute the sample rate. The output sample rate is not well defined
    % here, since we are really resampling in the phase domain. Define fsO
    % so that a constant tone input at f0 yields a constant tone at f0 for
    % both integer and non-integer number of samples per cycle (fs/f0).
    Neff = mean(bsxfun(@plus,idxEnd-idxStart,1),1);
    fsO = N/Neff*fs;
    fO = (fs*rf)/(Neff/nr);
    
    [minHalfLen,isLenOdd] = getHalfSpectrumLength(N);
    
    tsaF = zeros(minHalfLen,1,'like',1i*x(1));
    for i = 1:length(idxStart)
        % Compute the fft of each segment. Scale the resulting spectrum to
        % correct for the length. Here, the shortest segment corresponds to
        % the lowest sample rate, and has the lowest spectral amplitudes.
        % All other spectra are adjusted to a lower amplitude to account
        % for the increased signal length (in samples).
        S = fft(xUp(idxStart(i):idxEnd(i)));
        tsaF = tsaF + S(1:minHalfLen)*N/length(S);
    end
    
    % Average
    tsaF = tsaF/length(idxStart);
    
    % Convert to time domain
    if isLenOdd
        tsa = real(ifft([tsaF; conj(flipud(tsaF(2:end)))]));
    else
        tsa = real(ifft([tsaF; conj(flipud(tsaF(2:end-1)))]));
    end
    
    % Resample back to the original sample rate.
    if rf > 1
        % Since this signal is interpolated, we can decimate directly.
        tsa = tsa(1:rf:end);
    end
    
    % Generate time-domain segments if we are plotting.
    if nargout == 0
        tsaM = zeros(minHalfLen,length(idxStart),'like',1i*x(1));
        for i = 1:length(idxStart)
            % Compute the fft of each segment. Scale the resulting spectrum
            % to correct for the length. Here, the shortest segment
            % corresponds to the lowest sample rate, and has the lowest
            % spectral amplitudes. All other spectra are adjusted to a
            % lower amplitude to account for the increased signal length
            % (in samples).
            S = fft(xUp(idxStart(i):idxEnd(i)));
            tsaM(:,i) = S(1:minHalfLen)*N/length(S);
        end
        
        % Convert frequency-domain segments back to time domain.
        if isLenOdd
            tsaM = real(ifft([tsaM; conj(flipud(tsaM(2:end,:)))],[],1));
        else
            tsaM = real(ifft([tsaM; conj(flipud(tsaM(2:end-1,:)))],[],1));
        end
        tsaM = tsaM(1:rf:end,:);
    end
    
end

tOut = (0:length(tsa)-1)'/fsO;

if nargout == 0
    plotTSA(tsaM,nr);
end

if nargout > 0
    if isTimeTable
        ttTime = formatTime(tOut,timeType,timeFormat);
        varargout{1} = timetable(ttTime,tsa);
    else
        varargout{1} = tsa;
    end
end

if nargout > 1    
    varargout{2} = formatTime(tOut,timeType,timeFormat);    
end

if nargout > 2
    if isTimeTable
        ttTime = formatTime(tOut,timeType,timeFormat);
        varargout{3} = timetable(ttTime,tOut*fO);
    else
        varargout{3} = tOut*fO;
    end
end

if nargout > 3
    varargout{4} = fO*60;
end

end
%--------------------------------------------------------------------------
function [x,t,fs,tp,pr,nr,rf,im,ad,isTimeTable,td,timeType,timeFormat] = parseAndValidateInputs(X,varargin)

isInMATLAB = coder.target('MATLAB');
isTimeTable = isa(X,'timetable');

% Check that if we don't have a timetable that we have at least three
% inputs.
if ~isTimeTable
    narginchk(3,11);
end

% Find first input string.
bChar = false(nargin - 1,1);
for i = 1:nargin - 1
    bChar(i) = ischar(varargin{i});
end
iChar = find(bChar,1);
if isempty(iChar)
    iChar = nargin;
else
    iChar = iChar(1); %codegen
end

coder.internal.assert(iChar < 4,'signal:tsa:TooManyNumerical');

% Parse x,t,and tp. Store input duration sample rate or period in T avoid
% rounding errors. Store the position of the first n-v pair in ivarargin.
if isTimeTable
    T = [];
    TP = varargin{1};
    if nargin > 2 && ~ischar(varargin{2})
        %Error out if we have a timetable followed by two numerical values.
        [x,t,td,timeType,timeFormat] = signal.internal.nvh.parseTimeCodegen(X,'tsa',varargin{1},false);
    else
        [x,t,td,timeType,timeFormat] = signal.internal.nvh.parseTimeCodegen(X,'tsa',[],false);
    end
    ivarargin = 2;
else
    T = varargin{1};
    TP = varargin{2};
    [x,t,td,timeType,timeFormat] = signal.internal.nvh.parseTimeCodegen(X,'tsa',T,false);
    ivarargin = 3;
end

% Default values for n-v pairs.
defaultPulsesPerRotation = 1;
defaultNumRotations = 1;
defaultInterpMethod = 'linear';
defaultResampleFactor = 1;

if isInMATLAB
    % Parse name-value pairs
    p = inputParser;
    p.addParameter('PulsesPerRotation',defaultPulsesPerRotation);
    p.addParameter('NumRotations',defaultNumRotations);
    p.addParameter('Method',defaultInterpMethod);
    p.addParameter('ResampleFactor',defaultResampleFactor);
    
    parse(p,varargin{ivarargin:end});
    pr = p.Results.PulsesPerRotation;
    nr = p.Results.NumRotations;
    im = p.Results.Method;
    rf = p.Results.ResampleFactor;
    
else
    parms = struct('PulsesPerRotation',uint32(0), ...
        'NumRotations',uint32(0), ...
        'Domain',uint32(0), ...
        'Method',uint32(0), ...
        'ResampleFactor',uint32(0));
    
    pstruct = eml_parse_parameter_inputs(parms,[],varargin{ivarargin:end});
    pr = eml_get_parameter_value(pstruct.PulsesPerRotation,defaultPulsesPerRotation,varargin{ivarargin:end});
    nr = eml_get_parameter_value(pstruct.NumRotations,defaultNumRotations,varargin{ivarargin:end});
    im = eml_get_parameter_value(pstruct.Method,defaultInterpMethod,varargin{ivarargin:end});
    rf = eml_get_parameter_value(pstruct.ResampleFactor,defaultResampleFactor,varargin{ivarargin:end});
end

% Check if t is uniformly spaced.
err = max(abs(t(:)-linspace(t(1),t(end),numel(t))')./max(abs(t(:)),[],1),[],1);
isTUniform = err < 3*eps(class(t));

% Validate x,t, and tp.
validateattributes(x,{'single','double'},...
    {'real','finite','nonsparse','vector'},'tsa','X');
validateattributes(t,{'single','double'},...
    {'real','finite','nonsparse','vector','nonnegative','increasing','numel',length(x)},'tsa','T');

% Make sure x, t are column vectors.
x = x(:);
t = t(:);

% Specify sample rate
if isInMATLAB && isscalar(T) && isduration(T)
    fs = 1/seconds(T);
else
    %Use an effective rate for non-uniformly sampled signals.
    if isTUniform
        fs = 1/mean(diff(t),1); % should give back original fs used to construct time vector
    else
        fs = 1/median(diff(t));
    end
end

%If TP is a scalar, generate a column vector of pulse times.
if isscalar(TP)
    tMax = max(t,[],1);
    tMin = min(t,[],1);
    tp = (double(tMin):TP:double(tMax)+1/double(fs))';
else
    tp = TP;
end

tp = tp(:);

% Remove pulses outside the times in t. Allow a pulse that is one sample
% past the last sample in order to use the last segment, if possible.
tpIdx = tp<=(max(t,[],1)+1/fs) & tp>=min(t,[],1);
tp = tp(tpIdx);
warnTP = ~all(tpIdx);

validateattributes(tp,{'single','double'},...
    {'real','finite','nonsparse','vector','nonnegative','increasing'},'tsa','TP');

% Validate string n-v pair inputs.
im = validatestring(im,{'linear','spline','pchip','fft'},'TSA','Method');

% Select average domain based on im.
if strcmp(im,'fft')
    ad = 'frequency';
else
    ad = 'time';
end

% Validate numeric n-v pair inputs.
validateattributes(pr,{'single','double'},{'real','finite','nonsparse','scalar','positive'},'tsa','PulsesPerRotation');
validateattributes(nr,{'single','double'},{'real','finite','nonsparse','scalar','positive','integer'},'tsa','NumRotations');
validateattributes(rf,{'single','double'},{'real','finite','nonsparse','scalar','positive','integer'},'tsa','ResampleFactor');

% Check that resample factor is a constant if we are in codegen
if ~isInMATLAB
    coder.internal.assert(eml_is_const(rf),'signal:tsa:RFCodegen');
end

% Check that if t is not equally spaced, we are in the time domain.
if strcmp(ad,'frequency')
    coder.internal.assert(isTUniform,'signal:tsa:UniformFrequency','X');
end

% Check that if we are resampling, X is uniformly sampled.
if rf > 1
    coder.internal.assert(isTUniform,'signal:tsa:UniformRF','X');
end

% Verify that x contains at least nr revolutions
coder.internal.assert(pr*nr<numel(tp),'signal:tsa:MustTwoPulseTimes',nr);

% Verify that pr produces at least one sample per revolution
coder.internal.assert(round(min(diff(tp),[],1)*fs*pr)>1,'signal:tsa:MustOneSamplePerRev');

% Warn if we truncated TP.
if warnTP
    coder.internal.warning('signal:tsa:PulsesOut','TP','X');
end

end
%--------------------------------------------------------------------------
function xUp = fftInterpolate(x,P)
% Resample (interpolate) X by a factor of P using fft/ifft. x is a column
% vector.
XUp = zeros(P*length(x),1,'like',1i*x(1));
X = fft(x);
oneSidedLength = getHalfSpectrumLength(length(x));
XUp(1:oneSidedLength) = X(1:oneSidedLength)*P;
XUp(end-(length(x)-oneSidedLength-1):end) = X(oneSidedLength+1:end)*P;
xUp = real(ifft(XUp));
end
%--------------------------------------------------------------------------
function [oneSidedLength,isLenOdd] = getHalfSpectrumLength(N)
% Return length of one-sided spectrum
isLenOdd = isodd(N);
if isLenOdd
    oneSidedLength = (N+1)/2;
else
    oneSidedLength = (N)/2+1;
end
end
%--------------------------------------------------------------------------
function plotTSA(tsaM,nr)
% Convenience plotting function.
h = newplot;

% Plot the upsampled coherent segments and the average.
tAng = (0:size(tsaM,1)-1)'/size(tsaM,1)*nr;
hx = plot(tAng,tsaM, 'b-');
hold on;
plot(tAng,mean(tsaM,2),'LineWidth',3)
[hx(:).Color] = deal([.25 .25 .25 0.05]);
xlabel(getString(message('signal:tsa:Phase')))
ylabel(getString(message('signal:tsa:Amplitude')))
grid on
title(getString(message('signal:tsa:TSATitle')));

% Make the plots tight in x and give a margin in y.
ax = hx(1).Parent;
axis(ax,'tight');
yl = signal.internal.nvh.plotLimits(get(ax,'ylim'));
set(ax,'ylim',yl);

% Set NextPlot to replace to clobber next time a plot command is issued.
set(h,'NextPlot','replace');
end

%--------------------------------------------------------------------------
function tout = formatTime(tin,timeType,timeFormat)
if strcmp(timeType,'duration')
    tout = duration(0,0,tin,'Format',timeFormat);
elseif strcmp(timeType,'datetime')
    % tsa cannot support date outputs because it computes time seasonality
    tout = seconds(tin);
else
    tout = tin;
end
end
