function varargout = pspectrum(x,varargin) 
%PSPECTRUM Analyze signals in the frequency and time-frequency domains
%   P = PSPECTRUM(X) returns the power spectrum of X. X can be a vector, a
%   matrix, or a timetable containing double or single precision data. When
%   X is a timetable it must contain increasing and finite time values.
%   When input has multiple channels - i.e when X is a matrix, a timetable
%   with a single variable containing a matrix, or a timetable with
%   multiple variables each containing a vector - each channel will be
%   analyzed independently and the PSPECTRUM function will store the
%   results in the corresponding columns of power spectrum matrix P.
%
%   P = PSPECTRUM(X,Fs) specifies Fs as a positive numeric scalar
%   corresponding to the sample rate of X in units of hertz. This parameter
%   provides time information to the input and only applies when X is a
%   vector or a matrix.
%
%   P = PSPECTRUM(X,Ts) specifies Ts as a positive scalar duration
%   corresponding to the sample time of X. This parameter provides time
%   information to the input and only applies when X is a vector or a
%   matrix.
%
%   P = PSPECTRUM(X,Tv) specifies time values, Tv, of X as a numeric vector
%   in seconds, a duration vector, or a datetime vector. Time values must
%   be increasing, and finite. This parameter provides time information to
%   the input and only applies when X is a vector or a matrix.
%
%   PSPECTRUM supports complex data and non-uniformly sampled data. See
%   documentation to learn how these types of data are handled by the
%   function.
%
%   P = PSPECTRUM(...,TYPE) specifies the type of spectral analysis to be
%   performed by the PSPECTRUM function as one of 'power', 'spectrogram',
%   or 'persistence'. When not specified, TYPE defaults to 'power'.
%
%      'power' - PSPECTRUM computes the power spectrum of the input. Output
%      P is a matrix containing one power spectrum estimate for each input
%      channel. Use this option when you want to analyze frequency
%      content of stationary signals.
%
%      'spectrogram' - PSPECTRUM computes the spectrogram of the input.
%      This option only applies when the input contains a single channel.
%      Output P is a matrix containing a short time power spectrum estimate
%      in each column. Use the 'spectrogram' option when you want to
%      analyze how the frequency content of a signal changes over time.
%
%      'persistence' - PSPECTRUM computes the persistence power spectrum of
%      the input. This option only applies when the input contains a single
%      channel. Output P is a matrix containing a 2D histogram of power
%      level counts (given as percentages) observed over a group of short
%      time power spectrum estimates. Use the 'persistence' option when you
%      want to visualize the percentage of time that a particular frequency
%      component was present in the input signal.
%
%   P = PSPECTRUM(...,'TwoSided',VAL) computes centered, two-sided spectrum
%   estimates over the Nyquist range (-pi, pi] when VAL is true. When VAL
%   is false, the function returns one-sided estimates over the Nyquist
%   range [0, pi]. When time information is provided, the Nyquist ranges
%   are in hertz. If not specified, 'TwoSided' defaults to false for real
%   inputs and to true for complex inputs. VAL cannot be set to false for
%   complex inputs.
%
%   P = PSPECTRUM(...,'FrequencyLimits',FLIMS) specifies the frequency band
%   limits, FLIMS, as a 1x2 numeric vector over which the PSPECTRUM
%   function computes estimates. When input contains time information,
%   FLIMS has units of hertz (Hz), otherwise it has units of
%   radians/sample. If a region of the specified limits falls outside the
%   Nyquist range, PSPECTRUM will truncate computations to within the
%   Nyquist range. FLIMS cannot be completely outside of the Nyquist range.
%   If 'FrequencyLimits' is not specified, PSPECTRUM computes estimates
%   over the entire Nyquist range.
%
%   P = PSPECTRUM(...,'Leakage',LKG) specifies the spectral leakage as a
%   numeric scalar between 0 and 1 which controls the sidelobe attenuation
%   of a Kaiser window. The default value is 0.5. When LKG is 0, the
%   PSPECTRUM function will use a spectral window that reduces leakage to a
%   minimum at the expense of spectral resolution. When LKG is 1, the
%   function will increase leakage to a maximum level while improving
%   spectral resolution. A large leakage value enables you to differentiate
%   two closely spaced tones but could mask contiguous smaller tones. A
%   small leakage value enables you to find small tones placed in the
%   vicinity of larger ones at the expense of losing spectral resolution. A
%   leakage of 1 is equivalent to windowing the data with a rectangular
%   window, and a leakage of 0.85, is equivalent to windowing the data with
%   an approximate Hann window.
%
%   P = PSPECTRUM(...,'MinThreshold',THRESH) when TYPE is 'power' or
%   'spectrogram', sets the elements of P to zero when the corresponding
%   elements of 10*log10(P) are less than THRESH. Specify THRESH as a
%   numeric scalar in decibels. When TYPE is 'persistence', sets the
%   elements of P to zero when the corresponding elements of P are less
%   than THRESH. In the 'persistence' case, specify THRESH as a numeric
%   scalar ranging from 0 to 100%. If 'MinThreshold' is not specified, it
%   defaults to -Inf.
%
%   P = PSPECTRUM(...,'FrequencyResolution',FRES) specifies the frequency
%   resolution bandwidth, FRES, as a numeric scalar. When input contains
%   time information, FRES has units of hertz (Hz), otherwise, it has units
%   of radians/sample. When 'FrequencyResolution' is not specified,
%   PSPECTRUM chooses a value automatically based on the size of the input
%   data. See documentation to learn more.
%
%   P = PSPECTRUM(...,'Reassign',VAL) when VAL is true, PSPECTRUM sharpens
%   spectral estimates by performing time and frequency reassignment. When
%   omitted, 'Reassign' defaults to false. This option works best when
%   dealing with tonal data. See documentation to learn more about
%   reassigned spectrum estimates.
%
%   P = PSPECTRUM(...,'TimeResolution',TRES) specifies the time resolution
%   that controls the duration of the segments used to compute the short
%   time power spectra that form spectrogram or persistence spectrum
%   estimates. When input contains time information, TRES is a numeric
%   scalar with units of seconds, otherwise, TRES is given as an integer
%   number of samples. This parameter only applies when TYPE is
%   'spectrogram' or 'persistence', and cannot be specified simultaneously
%   with a 'FrequencyResolution' input. When 'TimeResolution' is not
%   specified, PSPECTRUM chooses a value automatically based on the size of
%   the input data and the value of the frequency resolution (if it has
%   been specified). See documentation to learn more.
%
%   P = PSPECTRUM(...,'OverlapPercent',OP) specifies overlap percent, OP,
%   of data segments used to compute spectrogram and persistence spectrum
%   estimates. OP must be a value in the [0, 100) interval. This parameter
%   only applies when TYPE is 'spectrogram' or 'persistence'. If omitted,
%   PSPECTRUM chooses a value automatically based on the spectral window.
%   See documentation to learn more.
%
%   P = PSPECTRUM(...,'NumPowerBins',NPB) specifies the number of power
%   bins used to compute persistence spectrum estimates as an integer
%   between 20 and 1024. This parameter only applies when TYPE is
%   'persistence'. When 'NumPowerBins' is not specified it defaults to 256.
%
%   [P,F] = PSPECTRUM(...) returns frequency vector F. When input contains
%   time information, F has units of hertz (Hz), otherwise it has units of
%   radians/sample.
%
%   [P,F,T] = PSPECTRUM(...) when TYPE is 'spectrogram', returns time
%   vector T. When input contains time information, T contains time values,
%   otherwise, it contains sample numbers. Spectrogram matrix P contains
%   short time power spectrum estimates on each column. T contains the time
%   values corresponding to the center of the data segments used to compute
%   each short time power spectrum estimate. P has a number of rows equal
%   to the length of the frequency vector F, and number of columns equal to
%   the length of the time vector T.
%
%   [P,F,PWR] = PSPECTRUM(...) when TYPE is 'persistence', returns power
%   values vector, PWR. Persistence spectrum matrix P contains the
%   probabilities (in percentages) of occurrence of signals with certain
%   frequency locations and power levels. P has a number of rows equal to
%   the length of the power vector PWR, and number of columns equal to the
%   length of the frequency vector F.
%
%   PSPECTRUM(...) with no output arguments plots the spectral estimates.
%
%   % EXAMPLE 1:
%      % Compute power spectrum of a 200 Hz sinusoid in noise.
%      Fs = 1000;
%      t = (0:1/Fs:.296)';
%      x = cos(2*pi*t*200)+0.1*randn(size(t));
%      xTable = timetable(seconds(t), x);
%      pspectrum(xTable);
%
%   % EXAMPLE 2:
%      % Re-compute the power spectrum of a 200 Hz sinusoid with a coarser
%      % frequency resolution of 25 Hz.
%      Fs = 1000;
%      t = (0:1/Fs:.296).';
%      x = cos(2*pi*t*200)+0.1*randn(size(t));
%      xTable = timetable(seconds(t), x);
%      pspectrum(xTable,'FrequencyResolution',25);
%
%   % EXAMPLE 3:
%      % Generate a two-channel signal sampled at 100 Hz for 2 seconds. The
%      % first channel consists of a 20 Hz tone and a 21 Hz tone. Both tones
%      % have unit amplitude and their close frequency proximity make them
%      % hard to resolve. The second channel also has two tones. One tone
%      % has unit amplitude and a frequency of 20 Hz. The other tone has an
%      % amplitude of 1/100 and a frequency of 30 Hz. In this case, the weaker
%      % tone will be hard to visualize unless we choose a window with small
%      % leakage. We can use the leakage control of the PSPECTRUM function to
%      % maximize resolution and resolve the closely spaced tones of the first
%      % channel signal, or to minimize leakage and be able to clearly
%      % distinguish the weak tone of the second channel signal.
%      Fs = 100;
%      t = (0:1/Fs:2-1/Fs)';
%      x = sin(2*pi*[20 20].*t)+[1 1/100].*sin(2*pi*[21 30].*t);
%      x = x+randn(size(x)).*std(x)/db2mag(40);
%      pspectrum(x,Fs,'Leakage',0);
%      figure;
%      pspectrum(x,Fs,'Leakage',1);
%
%   % EXAMPLE 4:
%      % Compute spectrogram of quadratic chirp with and without frequency
%      % reassignment.
%      Fs = 1e3;
%      t=0:(1/Fs):2;
%      y=chirp(t,100,1,200,'q');
%      pspectrum(y,Fs,'spectrogram');
%      figure;
%      pspectrum(y,Fs,'spectrogram','Reassign',true);
%
%   % EXAMPLE 5:
%      % Re-compute spectrogram of quadratic chirp using a 0.1 seconds time
%      % resolution.
%      Fs = 1e3;
%      t=0:(1/Fs):2;
%      y=chirp(t,100,1,200,'q');
%      pspectrum(y,Fs,'spectrogram','TimeResolution',0.1);
%
%   % EXAMPLE 6:
%      % Compute the spectrogram and the persistence spectrum of a set of
%      % intermittent sinusoid signals.
%      silence = zeros(1,1500);
%      Fs = 1e3;
%      t = (0:1000-1)/Fs;
%      yStep = [sin(2*pi*50*t) silence sin(2*pi*100*t) silence sin(2*pi*150*t)].';
%      t = seconds((0:length(yStep)-1)/Fs).';
%      yTable = timetable(t,yStep,'VariableNames',{'intermittentSines'});
%      pspectrum(yTable,'spectrogram');
%      figure;
%      pspectrum(yTable,'persistence');
%
%   % EXAMPLE 7:
%      % Visualize an interference narrow band signal within a broad band
%      % signal. The narrow band signal is only present 16.6% of the entire
%      % broad band signal duration. Notice how the interference can be
%      % seen clearly on the persistence spectrum.
%      Fs = 1000;
%      t = (0:1/Fs:500)';
%      x = chirp(t, 180, t(end), 220)+0.15*randn(size(t));
%      idx = floor(length(x)/6);
%      x(1:idx) = x(1:idx) + 0.05*cos(2*pi*t(1:idx)*210);
%      xTable = timetable(seconds(t), x);
%      pspectrum(xTable,'FrequencyLimits',[100,290]);
%      figure;
%      pspectrum(xTable,'spectrogram','FrequencyLimits',[100,290],'TimeResolution',1);
%      figure;
%      pspectrum(xTable,'persistence','FrequencyLimits',[100,290],'TimeResolution',1);
%
%   See also PERIODOGRAM, PWELCH, SPECTROGRAM

%   Copyright 2017-2019 The MathWorks, Inc.
%#codegen

narginchk(1,18);
nargoutchk(0,3);

opts = parseAndValidateInputs(x,varargin);
TORPWR = [];
P = []; %#ok<NASGU>
F = []; %#ok<NASGU>

generatePlots = false;
if coder.target('MATLAB')
    generatePlots = nargout==0;
end

if strcmp(opts.Type,'power')
    [P,F] = computeSpectrum(opts, generatePlots);    
elseif strcmp(opts.Type,'spectrogram')
    [P,F,TORPWR] = computeSpectrogram(opts, generatePlots);
else
    [P,F,TORPWR] = computePersistence(opts, generatePlots);
end

if ~coder.target('MATLAB')
    singlePrecision = isa(x,'single');
else
    singlePrecision = opts.IsSingle;
end
 

for idx = 1:nargout
    if idx == 1
        if singlePrecision
            varargout{idx} = single(P);
        else
            varargout{idx} = P;
        end        
    end
    if idx == 2
        if opts.IsNormalizedFreq
            F = F*pi;
        end
        
        if singlePrecision
            varargout{idx} = single(F);
        else
            varargout{idx} = F;
        end
    end
    if idx == 3
        if singlePrecision && isnumeric(TORPWR)
            varargout{idx} = single(TORPWR);
        else
            varargout{idx} = TORPWR;
        end
    end
end

end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [P,F] = computeSpectrum(opts, plotFlag)
% Compute power spectrum

if opts.IsNormalizedFreq
    timeFactor = 0.5;
else
    timeFactor = 1;
end
Fs = opts.EffectiveFs;
f1 = opts.FrequencyLimits(1);
f2 = opts.FrequencyLimits(2);
t1 = opts.t1*timeFactor;
t2 = opts.t2*timeFactor;
kbeta = convertLeakageToBeta(opts.Leakage);

if isempty(opts.FrequencyResolution)
    % Auto mode
    Npoints = uint32(4096);
else
    % Set Npoints to achieve desired resolution
    fspan = 4*Fs;
    Npoints = uint32((1+fspan/opts.FrequencyResolution(1)));
end

P = zeros(Npoints,opts.NumChannels);
F = zeros(Npoints,1);

if coder.target('MATLAB') 
    zoomSpectrumObj = signalanalyzer.internal.ZoomSpectrum;
else
    zoomSpectrumObj = signal.internal.codegenable.pspectrum.ZoomSpectrum;
end


zoomSpectrumObj.setup(...
        t1,t2,...        % init and end times of input signal
        f1, f2,...       % frequency band
        kbeta,...         % Kaiser beta
        Npoints,...      % Number of frequency points
        4*Fs, ...        % Maximum sample rate
        false,...        % Use zoom FFT if true
        opts.Reassign);  % Reassign freq if true
    
zoomSpectrumObj.specifyTimeVector(t1,Fs,t1,t2);

for idx = 1:opts.NumChannels
    inputData = opts.Data(:,idx);
    
    if ~coder.target('MATLAB') 
        zoomSpectrumObj.resetEstimator(t1,Fs,t1,t2);
    else
        zoomSpectrumObj.specifyTimeVector(t1,Fs,t1,t2);
    end
    
    zoomSpectrumObj.processSegment(inputData);
    
    convertToDB = false;
    if opts.TwoSided
        if opts.Reassign
            P(:,idx) = zoomSpectrumObj.fetchTwoSidedReassignedSpectrum(convertToDB);
        else
            P(:,idx) = zoomSpectrumObj.fetchTwoSidedSpectrum(convertToDB);
        end
    else
        if opts.Reassign
            P(:,idx) = zoomSpectrumObj.fetchOneSidedReassignedSpectrum(convertToDB);
        else
            P(:,idx) = zoomSpectrumObj.fetchOneSidedSpectrum(convertToDB);
        end
    end
    F = zoomSpectrumObj.fetchFrequencyVector();
end

if opts.MinThreshold > 0
    P(P<opts.MinThreshold) = 0;
end

if plotFlag
    if opts.IsSingle
        P = single(P);
        F = single(F);
    end
    FRES = zoomSpectrumObj.getTargetResolutionBandwidth();
    displaySpectrum(F,P,opts.IsNormalizedFreq,FRES);
end
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [P,F,T,FRES,TRES,zMin,zMax] = computeSpectrogram(opts, plotFlag)
% Compute spectrogram

Fs = opts.EffectiveFs;
f1 = opts.FrequencyLimits(1);
f2 = opts.FrequencyLimits(2);
zMin = [];
zMax = [];
if opts.IsNormalizedFreq
    timeFactor = 0.5;
else
    timeFactor = 1;
end

kbeta = convertLeakageToBeta(opts.Leakage);
ENBW = getENBWEstimate(kbeta);
Npoints = uint32(1024);

timeResolutionAuto = false;
timeResolution = -1;

if isempty(opts.FrequencyResolution) && isempty(opts.TimeResolution)
    timeResolutionAuto = true;
    timeResolution = -1; % don't-care value
elseif ~isempty(opts.FrequencyResolution)
    timeResolutionAuto = false;
    % Need to divide by time factor because when working in normalized
    % frequency we want timeResolution in samples. Dividing by time factor
    % is the same as multiplying by Fs=2. In the non-normalized case
    % timeResolution must be in seconds so in that case we do not need to
    % multiply by Fs.
    timeResolution = (ENBW/opts.FrequencyResolution)/timeFactor;
    fspan = 4*opts.EffectiveFs;
    Npoints = uint32((1+fspan/opts.FrequencyResolution));
elseif ~isempty(opts.TimeResolution)
    timeResolutionAuto = false;
    timeResolution = opts.TimeResolution;
end

computeZLimits = (nargout > 5);

if coder.target('MATLAB')
    spectrogramObj = signalanalyzer.internal.Spectrogram;
else
    spectrogramObj = signal.internal.codegenable.pspectrum.Spectrogram;
end

% When computing spectrogram for persistence spectrum we want computed
% values to be in dB - we want to measure density on a dB spectrum.
convertToDB = strcmp(opts.Type,'persistence');

spectrogramObj.setup(...
    timeResolutionAuto,...  % auto resolution if true
    timeResolution,...      % time res value - irrelevant if auto
    opts.OverlapPercent,... % overlap percentage
    opts.DataLength,...     % entire signal length
    opts.DataLength,...     % segment under analysis length
    timeFactor,...          % 0.5 if normalized freq, 1 otherwise
    Fs,...                  % sample rate
    opts.t1, opts.t2,...    % init and end times of input signal
    opts.t1, opts.t2,...    % init and end times of input signal
    f1, f2,...              % frequency band
    kbeta,...                % Kaiser beta
    Npoints,...             % Number of frequency points
    4*Fs,...                % Maximum sample rate
    computeZLimits,...      % Compute zMin,zMax if true
    false,...               % Use zoom fft if true
    opts.Reassign,...       % Reassign time/freq if true
    convertToDB,...         % Convert powers to dB if true
    opts.TwoSided);          % Two sided spectrum if true

spectrogramObj.computeSpectrogram(opts.Data,opts.TimeVector,true);
P = spectrogramObj.getSpectrogramMatrix();
F = spectrogramObj.fetchFrequencyVector();
T = spectrogramObj.fetchTimeVector()/timeFactor;
FRES = spectrogramObj.getTargetResolutionBandwidth();
TRES = spectrogramObj.getTimeResolution();

if opts.MinThreshold > 0
    P(P<opts.MinThreshold) = 0;
end

if computeZLimits
    zMin =spectrogramObj.getZMin();
    zMax =spectrogramObj.getZMax();
end


if ~isempty(opts.InitialDate)
    % Set times to datetime format if time information is in datetimes
    T = seconds(T) + opts.InitialDate;
end

if plotFlag
    if opts.IsSingle
        P = single(P);
        F = single(F);
        if isnumeric(T)
            T = single(T);
        end
    end
    displaySpectrogram(T,F,P,opts.IsNormalizedFreq,opts.MinThreshold,FRES,TRES);
else
    
    if isnumeric(T) && ~isempty(opts.TimeUnits)
        % Set times to duration format if time information is in durations
        T = duration(0,0,T,'Format',opts.TimeUnits);
    end
    
end


end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

function [P,F,PWR] = computePersistence(opts, plotFlag)
% Compute persistence spectrum

% Cache probability min threshold and set it to zero in opts so that
% spectrogram is computed with no threshold.
minThreshold = opts.MinThreshold;
opts.MinThreshold = 0;

[Pspectrogram,F,~,FRES,TRES,zMin,zMax] = computeSpectrogram(opts, false);
Npoints = length(F);
numSpectralWindows = size(Pspectrogram,2);

f1 = opts.FrequencyLimits(1);
f2 = opts.FrequencyLimits(2);

% Add 5% cushion so that there is some empty space above and below the
% persistence spectrum image.
pwrCushion = 0.05*abs(zMax-zMin);
zMin = zMin-pwrCushion;
zMax = zMax+pwrCushion;

if coder.target('MATLAB')
    persistenceObj = signalanalyzer.internal.PersistenceSpectrum;
else
    persistenceObj = signal.internal.codegenable.pspectrum.PersistenceSpectrum;
end

persistenceObj.setup(f1,f2,Npoints,zMin,zMax,opts.NumPowerBins);
persistenceObj.computeSpectrum(Pspectrogram(:));
P = persistenceObj.fetchPersistenceSpectrum2D();
P = 100*(P/numSpectralWindows); % convert to probability in percentage

F = persistenceObj.fetchFrequencyVector();
PWR = persistenceObj.fetchMagnitudeVector(); % this is in dB

if minThreshold > 0
    P(P<minThreshold) = 0;
end

if plotFlag
    if opts.IsSingle
        P = single(P);
        F = single(F);
        PWR = single(PWR);
    end
    displayPersistence(PWR,F,P,opts.IsNormalizedFreq,opts.MinThreshold,...
        FRES,TRES,numSpectralWindows);
end

% Convert PWR to linear before returning
PWR = 10.^(PWR/10);
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Helper functions
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function kbeta = convertLeakageToBeta(leakage)
kbeta = 40*(1-leakage);
end

%--------------------------------------------------------------------------
function enbwValue = getENBWEstimate(kbeta)
% Calculate enbw using approximation similar to zoomspectrum engine
poly1 = [-7.42100220301407e-05,  0.0010951661775193,  -0.00601630113184729,...
    0.0135330207063678,-0.00553286257981127,   0.00188967508127851,...
    -0.000245892879902476, 1.00000397846243];
poly2 = [ 5.69809789173636e-06, -0.000159680213659123, 0.00182733327457552,...
    -0.0104618197432362,0.0265970133409903,    0.00682196582785356,...
    -0.0609769138391775,   1.04788712768061];
poly3 = [ 7.68603379795731e-12, -1.66807848853759e-09, 1.5594811121591e-07,...
    -8.2806698857875e-06,0.000279922339315112, -0.00665206774673593,...
    0.161004938614092,    0.690887010063724];

if  kbeta <= 2.9
    poly = poly1;
elseif kbeta <= 4.9
    poly = poly2;
else
    poly = poly3;
end
enbwValue = 0;
for idx = 1:8
    enbwValue = enbwValue*kbeta + poly(idx);
end

end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [opts] = parseAndValidateInputs(x,inputCell)
% Parse and validate input parameters

if ~any(strcmpi(class(x),{'double','single','timetable'}))
    coder.internal.error('signal:pspectrum:InvalidInputDataType');
end

if coder.target('MATLAB')
opts = struct(...
    'Data',[],...
    'DataLength',0,...
    'NumChannels',0,...
    'IsComplex',false,...
    'IsSingle',false,...
    'TimeUnits','',...
    'InitialDate',[],...
    'TimeMode','samples',...
    'EffectiveFs',0,...
    'IsNormalizedFreq',false,...
    'NonUniform',false,...
    't1',0,...
    't2',0,...
    'TimeVector',[],...
    'NyqustRange',[0 0],...
    'FrequencyLimits',[Inf Inf],...
    'Type','power',...
    'Leakage', 0.5,...
    'MinThreshold', -Inf,...
    'FrequencyResolution',[],...
    'Reassign',false,...
    'TimeResolution',[],...
    'OverlapPercent',Inf,...
    'NumPowerBins',Inf,...    
    'TwoSided',false);
else
opts = struct(...
    'Data',zeros(0,'like',double(x)),...
    'DataLength',0,...
    'NumChannels',0,...
    'IsComplex',false,...
    'IsSingle',false,...
    'TimeUnits','',...
    'InitialDate',[],...
    'TimeMode','samples',...
    'EffectiveFs',0,...
    'IsNormalizedFreq',false,...
    'NonUniform',false,...
    't1',0,...
    't2',0,...
    'TimeVector',[],...
    'NyqustRange',[0 0],...
    'FrequencyLimits',[Inf Inf],...
    'Type','power',...
    'Leakage', 0.5,...
    'MinThreshold', -Inf,...
    'FrequencyResolution',[],...
    'Reassign',false,...
    'TimeResolution',[],...
    'OverlapPercent',Inf,...
    'NumPowerBins',Inf,...    
    'TwoSided',false);
end

coder.varsize('opts.Data');
coder.varsize('opts.TimeVector');
coder.varsize('opts.TimeMode');
coder.varsize('opts.Type');
coder.varsize('opts.FrequencyResolution');
coder.varsize('opts.TimeResolution');

if coder.target('MATLAB') && istimetable(x)
    if ~all(varfun(@isnumeric,x,'OutputFormat','uniform')) || ~all(varfun(@ismatrix,x,'OutputFormat','uniform'))
        error(message('signal:pspectrum:InvalidTimeTableType'));
    end
    
    if ~all(varfun(@(x) isa(x,'double'),x,'OutputFormat','uniform'))...
            && ~all(varfun(@(x) isa(x,'single'),x,'OutputFormat','uniform'))
        error(message('signal:pspectrum:InvalidTimeTableMixedType'));
    end
    
    % If table has multiple variables, each one can only contain a vector
    if size(x,2) > 1 && ~all(varfun(@(n)size(n,2),x,'OutputFormat','uniform') == 1)
        error(message('signal:pspectrum:InvalidTimeTableType'));
    end
    
    rowTimes = x.Properties.RowTimes;
    
    if isduration(rowTimes)
        ttTimeVector = seconds(rowTimes);
        opts.TimeUnits = rowTimes.Format;
    else
        d = rowTimes-rowTimes(1);
        ttTimeVector = seconds(d);
        opts.TimeUnits = rowTimes.Format;
        opts.InitialDate = rowTimes(1);
    end
    data = x{:,:};
    
    validateattributes(data,{'single','double'},...
        {'nonsparse','finite','nonnan','2d'},'pspectrum','timetable data');
    
    if isrow(data)
        data = data(:);
    end
    opts.TimeMode = 'tt';
else
    validateattributes(x,{'single','double'},...
        {'nonsparse','finite','nonnan','2d'},'pspectrum','X');
    if isrow(x)
        data = x(:);
    else
        data = x;
    end
end

coder.varsize('data');

opts.IsSingle = isa(data,'single');
dataDoublePrecision = double(data);
[opts.DataLength, opts.NumChannels] = size(dataDoublePrecision);
opts.IsComplex = ~isreal(dataDoublePrecision);

%Set the default value for two-sided spectrum wrt to the input signal
%complexity - false for real signals and true for complex signals. The
%parser will override this setting if TwoSided is specified by the user.
opts.TwoSided = opts.IsComplex;
if (opts.DataLength < 2)
    coder.internal.error('signal:pspectrum:InvalidInputLength');
end

%---------------------------------
% Get the type string and the name-value pairs
opts = extractTypeAndNameValuePairs(inputCell, opts);

%---------------------------------
% Validate type and input data size
if ~strcmp(opts.Type,'power') && opts.NumChannels > 1
    coder.internal.error('signal:pspectrum:TooManyInputChannels','TYPE');
end

%---------------------------------
% Extract Fs,Ts,Tv, and Frequency range inputs
[opts, timeValue, opts.InitialDate] = extractNamelessInputs(inputCell, opts, opts.InitialDate);

%---------------------------------
% Validate time inputs
switch opts.TimeMode
    case 'tv'
        if coder.target('MATLAB') && istimetable(x)
            error(message('signal:pspectrum:TimeValuesAndTimetableInput'));
        end

        if ~isempty(timeValue)
            validateattributes(timeValue, {'numeric'},{'vector','nonnan','finite'},'pspectrum','time values')
            timeVector1 = double(timeValue(:));
            [opts.NonUniform, opts.EffectiveFs] = validateTimeValues(opts.DataLength,timeVector1);
            if opts.NonUniform 
                [opts.Data, timeVector] = resample(dataDoublePrecision, timeVector1, opts.EffectiveFs, 'linear');
                opts.DataLength = length(timeVector);
            else
                opts.Data = dataDoublePrecision;
                timeVector = timeVector1;
            end
            opts.t1 = timeVector(1);
            opts.t2 = timeVector(end);
            if ~strcmp(opts.Type,'power')
                opts.TimeVector = timeVector(:);
            end
        end
    case 'fs'
        if coder.target('MATLAB') && istimetable(x)
            error(message('signal:pspectrum:SmapleRateAndTimetableInput'));
        end

        if ~isempty(timeValue)
            validateattributes(timeValue, {'numeric'},{'scalar','real','finite','positive'},'pspectrum','sample rate')
            opts.Data = dataDoublePrecision;            
            opts.EffectiveFs = double(timeValue(1));
            opts.t1 = 0;
            opts.t2 = (opts.DataLength-1)/opts.EffectiveFs;
            if ~strcmp(opts.Type,'power')
                opts.TimeVector = (0:opts.DataLength-1).'/opts.EffectiveFs;
            end
        end
    case 'ts'
        if coder.target('MATLAB') && istimetable(x)
            error(message('signal:pspectrum:SmapleTimeAndTimetableInput'));
        end

        if ~isempty(timeValue)
            validateattributes(timeValue, {'numeric'},{'scalar','real','finite'},'pspectrum','sample time')
            opts.Data = dataDoublePrecision;
            opts.EffectiveFs = double(1/timeValue(1));
            opts.t1 = 0;
            opts.t2 = (opts.DataLength-1)/opts.EffectiveFs;
            if ~strcmp(opts.Type,'power')
                opts.TimeVector = (0:opts.DataLength-1).'/opts.EffectiveFs;
            end
        end
    case 'samples'
        opts.Data = dataDoublePrecision;
        opts.EffectiveFs = 2;
        opts.t1 = 0;
        opts.t2 = opts.DataLength-1;
        if ~strcmp(opts.Type,'power')
            opts.TimeVector = (0:opts.DataLength-1).';
        end
        opts.IsNormalizedFreq = true;
end
if coder.target('MATLAB') && istimetable(x)
    timeVector = ttTimeVector(:);
    validateattributes(timeVector,{'numeric'},{'vector','nonnan','finite'},'pspectrum','time values');
    timeVector = double(timeVector);
    [opts.NonUniform, opts.EffectiveFs] = validateTimeValues(opts.DataLength,timeVector);
    if opts.NonUniform
        [opts.Data, timeVector] = resample(dataDoublePrecision, timeVector, opts.EffectiveFs, 'linear');
        opts.DataLength = length(timeVector);
    else
        opts.Data = dataDoublePrecision;
    end
    opts.t1 = timeVector(1);
    opts.t2 = timeVector(end);
    if ~strcmp(opts.Type,'power')
        opts.TimeVector = timeVector(:);
    end
end

if opts.IsNormalizedFreq
    freqFactor = pi;
else
    freqFactor = 1;
end
%---------------------------------
% TwoSided
validateattributes(opts.TwoSided,{'logical'},...
    {'scalar'},'pspectrum','TwoSided');

if opts.IsComplex && ~opts.TwoSided
    coder.internal.error('signal:pspectrum:OneSidedComplex');
end

%---------------------------------
% FrequencyLimits
if opts.TwoSided
    opts.NyqustRange = [-opts.EffectiveFs/2, opts.EffectiveFs/2]*freqFactor;
else
    opts.NyqustRange = [0, opts.EffectiveFs/2]*freqFactor;
end

if opts.FrequencyLimits(1) ~= Inf && opts.FrequencyLimits(2) ~= Inf
    validateattributes(opts.FrequencyLimits,{'numeric'},...
        {'row','numel',2,'increasing','finite','real'},'pspectrum','FrequencyLimits');
    opts.FrequencyLimits = double(opts.FrequencyLimits);
    
    % Range cannot be completely outside of Nyquist band
    if (opts.FrequencyLimits(2) <= opts.NyqustRange(1)) || ...
            (opts.FrequencyLimits(1) >= opts.NyqustRange(2))
        coder.internal.error('signal:pspectrum:InvalidFrequencyBand',...
            sprintf('%f', opts.NyqustRange(1)),sprintf('%f',opts.NyqustRange(2)));
    end
    % Truncate range to within the nyquist band
    opts.FrequencyLimits(1) = max(opts.FrequencyLimits(1),opts.NyqustRange(1));
    opts.FrequencyLimits(2) = min(opts.FrequencyLimits(2),opts.NyqustRange(2));
else
    opts.FrequencyLimits = opts.NyqustRange;
end

opts.FrequencyLimits = opts.FrequencyLimits/freqFactor;

%---------------------------------
% Leakage
validateattributes(opts.Leakage,{'numeric'},...
    {'nonempty','real','finite','scalar','>=',0,'<=',1},'pspectrum','Leakage');
opts.Leakage = double(opts.Leakage);

%---------------------------------
% MinThreshold
if strcmp(opts.Type,'persistence')
    if opts.MinThreshold == -Inf
        opts.MinThreshold = 0;
    end
    validateattributes(opts.MinThreshold,{'numeric'},...
        {'nonempty','real','scalar','>=',0,'<=',100},...
        'pspectrum','MinThreshold');
    opts.MinThreshold = double(opts.MinThreshold);
else
    validateattributes(opts.MinThreshold,{'numeric'},...
        {'nonempty','real','scalar'},'pspectrum','MinThreshold');
    opts.MinThreshold = double(opts.MinThreshold);
    opts.MinThreshold = 10^(opts.MinThreshold/10);
end

%---------------------------------
% FrequencyResolution
if ~isempty(opts.FrequencyResolution)
    validateattributes(opts.FrequencyResolution, {'numeric'},...
        {'nonempty','real','scalar','finite'},'pspectrum','FrequencyResolution');   
    opts.FrequencyResolution = double(opts.FrequencyResolution);
    validateFrequencyResolution(opts.FrequencyResolution(1), opts.Leakage,...
        opts.EffectiveFs, opts.DataLength, opts.IsNormalizedFreq);
    
    opts.FrequencyResolution = opts.FrequencyResolution/freqFactor;
end

%---------------------------------
% Reassign
validateattributes(opts.Reassign,{'logical'},...
    {'scalar'},'pspectrum','Reassign');

%---------------------------------
% TimeResolution
if ~isempty(opts.TimeResolution) && ~any(strcmp(opts.Type,{'spectrogram','persistence'}))
    coder.internal.error('signal:pspectrum:TimeResNotApplicable','TYPE');
end
if ~isempty(opts.TimeResolution) && ~isempty(opts.FrequencyResolution)
    coder.internal.error('signal:pspectrum:TimeResAndFreqResSimultaneously');
end
if any(strcmp(opts.Type,{'spectrogram','persistence'})) && ~isempty(opts.TimeResolution)
    validateattributes(opts.TimeResolution, {'numeric'},...
        {'nonempty','real','scalar','finite'},'pspectrum','TimeResolution');
    opts.TimeResolution = double(opts.TimeResolution);
    validateTimeResolution(opts.TimeResolution(1), opts.EffectiveFs,...
        opts.DataLength, opts.IsNormalizedFreq);
end

%---------------------------------
% OverlapPercent
if opts.OverlapPercent ~= Inf && ~any(strcmp(opts.Type,{'spectrogram','persistence'}))
    coder.internal.error('signal:pspectrum:OverlapNotApplicable','TYPE');
end
if any(strcmp(opts.Type,{'spectrogram','persistence'}))
    if opts.OverlapPercent == Inf
        kbeta = convertLeakageToBeta(opts.Leakage);
        enbwValue = getENBWEstimate(kbeta);
        opts.OverlapPercent = (1-(1/(2*enbwValue-1)))*100;
    else
        validateattributes(opts.OverlapPercent,{'numeric'},...
            {'nonempty','real','finite','scalar','>=',0,'<',100},'pspectrum','OverlapPercent');
        opts.OverlapPercent = double(opts.OverlapPercent);
    end
end

%---------------------------------
% NumPowerBins
if ~isnumeric(opts.NumPowerBins)
    coder.internal.error('signal:pspectrum:PairNameValueInputs');
end

if opts.NumPowerBins ~= Inf && ~strcmp(opts.Type,'persistence')
    coder.internal.error('signal:pspectrum:NumPwrBinsNotApplicable','TYPE');
end
if strcmp(opts.Type,'persistence')
    if opts.NumPowerBins == Inf
        opts.NumPowerBins = 256;
    else
        validateattributes(opts.NumPowerBins,{'numeric'},...
            {'nonempty','integer','finite','scalar','>=',20,'<=',1024},...
            'pspectrum','NumPowerBins');
        opts.NumPowerBins = double(opts.NumPowerBins);
    end
end

end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [opts] = extractTypeAndNameValuePairs(inputCell, opts)
% Find index where inputCell has the first char
strIdx = 0;
for testIdx = 1:numel(inputCell)
    testValue = inputCell{testIdx};
    if ischar(testValue) || (isstring(testValue) && isscalar(testValue))
        strIdx = testIdx;
        break;
    end
end

% Extract string parameters and name-value pairs from inputs
if isempty(inputCell) || strIdx == 0
    return;
end

% Use strings for string support
validStrings = {'power','spectrogram','persistence','FrequencyLimits',...
    'Leakage','MinThreshold','FrequencyResolution','Reassign',...
    'TimeResolution','OverlapPercent','NumPowerBins','TwoSided'};

ignoreOpts = false(1, numel(inputCell));
ignoreOpts(1:strIdx-1) = true;

for idx = strIdx:numel(inputCell)
    if ischar(inputCell{idx}) || (isstring(inputCell{idx}) && isscalar(inputCell{idx}))
        if coder.target('MATLAB')
            try
                str = validatestring(inputCell{idx},validStrings);
            catch e
                error(message('signal:pspectrum:InvalidInputString'));
            end
        else
            str = validatestring(inputCell{idx},validStrings,'pspectrum');
        end
        
        coder.varsize('str');
        
        if any(strcmp(str,{'power','spectrogram','persistence'}))
            opts.Type = str;
            ignoreOpts(idx) = true;
        else
            if idx >= numel(inputCell) || isempty(inputCell{idx+1})
                coder.internal.error('signal:pspectrum:PairNameValueInputsNonEmpty');
            end
            
            if (idx+1) <= numel(inputCell)
                if strcmp(str,'FrequencyLimits') && isnumeric(inputCell{idx+1})
                    freqLimits = inputCell{idx+1};                    
                    opts.FrequencyLimits = double(freqLimits(1:2));                    
                elseif strcmp(str, 'Leakage') && isnumeric(inputCell{idx+1}) && isscalar(inputCell{idx+1})
                    opts.Leakage = double(inputCell{idx+1});
                elseif strcmp(str, 'MinThreshold') && isnumeric(inputCell{idx+1}) && isscalar(inputCell{idx+1})
                    opts.MinThreshold = double(inputCell{idx+1});
                elseif strcmp(str, 'FrequencyResolution') && isnumeric(inputCell{idx+1})
                    opts.FrequencyResolution = double(inputCell{idx+1});
                elseif strcmp(str, 'Reassign') && islogical(inputCell{idx+1})
                    opts.Reassign = inputCell{idx+1};
                elseif strcmp(str, 'TimeResolution') && isnumeric(inputCell{idx+1})
                    opts.TimeResolution = double(inputCell{idx+1});
                elseif strcmp(str, 'OverlapPercent') && isnumeric(inputCell{idx+1}) && isscalar(inputCell{idx+1})
                    opts.OverlapPercent = double(inputCell{idx+1});
                elseif strcmp(str, 'NumPowerBins') && isnumeric(inputCell{idx+1}) && isscalar(inputCell{idx+1})
                    opts.NumPowerBins = double(inputCell{idx+1});
                elseif strcmp(str, 'TwoSided') && islogical(inputCell{idx+1}) && isscalar(inputCell{idx+1})
                    opts.TwoSided = inputCell{idx+1};
                else
                    if (strcmp(str, 'Leakage') || strcmp(str, 'MinThreshold') ...
                            || strcmp(str, 'OverlapPercent') ...
                            || strcmp(str, 'NumPowerBins') ...
                            || strcmp(str, 'TwoSided'))
                        if ~ischar(inputCell{idx+1}) && coder.target('MATLAB')
                            validateattributes(inputCell{idx+1}, {'numeric', 'logical'}, {'scalar'}, 'pspectrum');
                        end
                    end
                        
                    coder.internal.error('signal:pspectrum:PairNameValueInputs');
                end
            end            
            
            ignoreOpts([idx, idx+1]) = true;
        end
    end
end

ignoredOpts = sum(ignoreOpts);

if  ignoredOpts ~= numel(ignoreOpts)
    coder.internal.error('signal:pspectrum:PairNameValueInputs');
end

end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [opts, timeValue, InitialDate] = extractNamelessInputs(inputCell, opts, InitialDate)
% Find index where inputCell has the first char
strIdx = -1;
for testIdx = 1:numel(inputCell)
    testValue = inputCell{testIdx};
    if ischar(testValue) || (isstring(testValue) && isscalar(testValue))
        strIdx = testIdx;
        break;
    end
end

if strIdx ~= -1
    strIdx = strIdx - 1;
else
    strIdx = numel(inputCell);
end


% Extract nameless parameter inputs
coder.internal.errorIf(strIdx > 1, 'signal:pspectrum:TooManyValueOnlyInputs');

if isempty(inputCell) || strIdx < 1    
    timeValue = [];
    return;
end

value = inputCell{1};
if coder.target('MATLAB')
    timeValue = [];
else
    timeValue = cast([],'like',value);
end

if coder.target('MATLAB') && isdatetime(value)
    timeValue = seconds(value - value(1));
    opts.TimeMode = 'tv';
    opts.TimeUnits = value.Format;    
    InitialDate = value(1);
elseif coder.target('MATLAB') && isduration(value)
    if isscalar(value)
        timeValue = seconds(value);
        opts.TimeMode = 'ts';
    else
        timeValue = seconds(value);
        opts.TimeMode = 'tv';
    end
    opts.TimeUnits = value.Format;
else
    if isscalar(value)
        timeValue = value;
        opts.TimeMode = 'fs';
    elseif isempty(value)
        coder.internal.error('signal:pspectrum:EmptyValueOnlyInput');
    else
        timeValue = value;
        opts.TimeMode = 'tv';
    end
end

end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [needsResampling, effectiveFs] = validateTimeValues(dataLength,tv)
% Check regularity of time vector intervals.

if dataLength ~= length(tv)
    coder.internal.error('signal:pspectrum:TimeValuesLength');
end
if ~isscalar(tv) && length(tv) ~= length(unique(tv))
    coder.internal.error('signal:pspectrum:TimeValuesUnique');
end
if ~issorted(tv)
    coder.internal.error('signal:pspectrum:TimeValuesIncreasing');
end

err = max(abs(tv(:).'-linspace(tv(1),tv(end),numel(tv)))./max(abs(tv)));
needsResampling = err > 3*eps(class(tv));

% The mean has better numerical precision than the median so if the vector
% is uniformly sampled then use mean to get the average sample rate.

if needsResampling
    if ~validateNonUniformTimeValues(tv)
        coder.internal.error('signal:pspectrum:TimeValuesIrregular');
    end
    effectiveFs = 1/median(diff(tv));
else
    effectiveFs = 1/mean(diff(tv));
end

end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function validateFrequencyResolution(freqRes, leakage, Fs, dataLength, isNormalizedFreq)

kbeta = convertLeakageToBeta(leakage);
ENBW = getENBWEstimate(kbeta);
fresMin = Fs*ENBW/dataLength;
fResMax = Fs*ENBW;
if freqRes < fresMin || freqRes > fResMax
    if isNormalizedFreq
        unitsStr = ' (*pi radians/sample)';
        freqFactor = pi;
    else
        unitsStr = ' (Hz)';
        freqFactor = 1;
    end
    
    if coder.target('MATLAB')
        error('signal:pspectrum:FreqResNotAchivable', ...
            [getString(message('signal:pspectrum:FreqResNotAchivable',...
            sprintf('%f', fresMin/freqFactor),sprintf('%f', fResMax/freqFactor))) unitsStr '.']);
    else
        coder.internal.error('signal:pspectrum:FreqResNotAchivable', ...
            'frequency resolution not achievable');
    end
end

end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function validateTimeResolution(timeRes, Fs, dataLength, isNormalizedFreq)

% Time resolution is affected by ENWB but we will limits requested
% resolution to the entire signal length. The algorithm will truncate to
% the signal length if a window of longer duration is needed due to ENBW >
% 1.
if isNormalizedFreq
    Fs = 1;
end

segmentLength = floor(timeRes*Fs);
if segmentLength > dataLength || segmentLength < 1
    if isNormalizedFreq
        coder.internal.error('signal:pspectrum:InvalidTimeResSamples',sprintf('%f', dataLength));
    else
        coder.internal.error('signal:pspectrum:InvalidTimeResSeconds',sprintf('%f', dataLength/Fs),sprintf('%f', 1/Fs));
    end
end

end 
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function displaySpectrum(f,P,isFsnormalized,FRES)
newplot;

if isFsnormalized
    scaleFactor = 1;
    freqUnitsStr = signalwavelet.internal.convenienceplot.getNormalizedFreqUnits();
else
    [~, scaleFactor, freqUnitsStr] = signalwavelet.internal.convenienceplot.getFrequencyEngUnits(max(abs(f)));
    [freqRes, ~,freqResUnitsStr] = signalwavelet.internal.convenienceplot.getFrequencyEngUnits(FRES);
end
f = f*scaleFactor;
l = plot(f,10*log10(P));

% Disable AxesToolbar
ax = ancestor(l,'axes');
if iscell(ax)
    cellfun(@(hAx) set(hAx,'Toolbar',[]),ax,'UniformOutput',false);
elseif ~isempty(ax) && ~isempty(ax.Toolbar)
    ax.Toolbar = [];
end

ylabel(getString(message('signal:pspectrum:PowerSpectrumDB')));
if isFsnormalized
    xlabel([getString(message('signal:pspectrum:NormalizedFreq')) ' (' freqUnitsStr ')']);
    title(['Fres =' num2str(FRES) freqUnitsStr]);
else
    xlabel([getString(message('signal:pspectrum:Frequency')) ' (' freqUnitsStr ')']);
    title(['Fres = ' num2str(freqRes) ' ' freqResUnitsStr]);
end
xlim([f(1), f(end)]);
grid on;

end 
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function displaySpectrogram(t,f,P,isFsnormalized, threshold,FRES,TRES)
% Cell array of the standard frequency units strings

[fres,~,fresUnitsStr] = signalwavelet.internal.convenienceplot.getFrequencyEngUnits(FRES);
fresStr = ['Fres = ' num2str(fres) ' ' fresUnitsStr];
[tres,~,tresUnitsStr] = signalwavelet.internal.convenienceplot.getTimeEngUnits(TRES);
tresStr = ['Tres = ' num2str(tres) ' ' tresUnitsStr];

plotOpts.title = [fresStr, ', ' tresStr];
plotOpts.threshold = 10*log10(threshold+eps);
plotOpts.isFsnormalized = isFsnormalized;
signalwavelet.internal.convenienceplot.plotTFR(t,f,10*log10(abs(P)+eps),plotOpts);

end 
%--------------------------------------------------------------------------
function displayPersistence(pwr,f,P,isFsnormalized, threshold,FRES,TRES,numWindows)
% Cell array of the standard frequency units strings
% This assumes that pwr is in dB

% Setup a floor for zero counts as 50% of min possible density
probFloor = 100*0.5/numWindows;
P(P<probFloor) = probFloor;

if isFsnormalized
    freqUnitsStr = signalwavelet.internal.convenienceplot.getNormalizedFreqUnits();
    freqlbl = [getString(message('signal:pspectrum:NormalizedFreq')) ' (' freqUnitsStr ')'];
    
    fresStr = ['Fres = ' num2str(FRES) freqUnitsStr];
    tresStr = ['Tres = ' num2str(TRES) ' ' getString(message('signal:pspectrum:SamplesLowerCase'))];
else
    [~,freqScale,uf] = signalwavelet.internal.convenienceplot.getFrequencyEngUnits(max(abs(f)));
    f = f*freqScale;
    freqlbl = [getString(message('signal:pspectrum:Frequency')) ' (' uf ')'];
    
    [fres,~,fresUnitsStr] = signalwavelet.internal.convenienceplot.getFrequencyEngUnits(FRES);
    [tres,~,tresUnitsStr] = signalwavelet.internal.convenienceplot.getTimeEngUnits(TRES);
    fresStr = ['Fres = ' num2str(fres) ' ' fresUnitsStr];
    tresStr = ['Tres = ' num2str(tres) ' ' tresUnitsStr];
end

h = newplot;
xlbl = freqlbl;
ylbl = getString(message('signal:pspectrum:PowerSpectrumDB'));

hndl = imagesc(f, pwr, P);
hndl.Parent.YDir = 'normal';

if threshold>0
    Pmax = max(P(:));
    if threshold < Pmax
        set(ancestor(hndl,'axes'),'CLim',[threshold Pmax]);
    else
        set(ancestor(hndl,'axes'),'CLim',[Pmax threshold+eps]);
    end
end
cblabel = getString(message('signal:pspectrum:DensityPercent'));

% Persistence spectrum looks better when plotted in log scale
set(ancestor(hndl,'axes'),'ColorScale','log');

% Keep the Colorbar in linear scale
hcb = colorbar;
hcb.Label.String = cblabel;
hcb.Ruler.Scale = 'Linear';

ylabel(ylbl);
xlabel(xlbl);
title([fresStr, ', ' tresStr]);

%Set up datacursor
hdcm = datacursormode(ancestor(h,'figure'));
hdcm.UpdateFcn = {@cursorUpdatePersistenceFunction,f,pwr,P};
end 
%----------------------------------------------------------------------
function output_txt = cursorUpdatePersistenceFunction(~,event,x,y,c)
pos = event.Position;

xVal = pos(1);
yVal = pos(2);

%Get indices for x and y
[~,xidx] = min(abs(x - pos(1)));
[~,yidx] = min(abs(y - pos(2)));

output_txt{1} = [getString(message('signal:pspectrum:FrequencyCursorLabel')) ' ' num2str(xVal,4)];
output_txt{2} = [getString(message('signal:pspectrum:PowerSpectrumCursorLabel')) ' ' num2str(yVal,4)];

%Set the C label for the datatip
output_txt{3} = [getString(message('signal:pspectrum:DensityCursorLabel')) ' ' num2str(c(yidx,xidx),4)];
end
%----------------------------------------------------------------------
function flag = validateNonUniformTimeValues(tv)
% check irregularity of the time values by measuring how different
% are the mean and median of the time differences.
% mean(diff(time))/median(diff(time)).This is eqivalent to looking
% at the ratio of the lenghth of the data after resampling over the
% length of the data before resampling.

dtv = diff(tv);
medianTimeInterval = median(dtv);
meanTimeInterval = mean(dtv);
flag = medianTimeInterval/meanTimeInterval < 100 && meanTimeInterval/medianTimeInterval < 100;
end
