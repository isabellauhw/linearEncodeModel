function varargout = instfreq(x, varargin)
%INSTFREQ estimates instantaneous frequency
%   IFREQ = INSTFREQ(X,Fs) returns the instantaneous frequency of X. X can be
%   a vector or matrix containing double or single precision data. Fs is a
%   positive numeric scalar corresponding to the sample rate of X in units
%   of hertz. IFREQ is computed from the first conditional spectral moment of
%   a power spectrogram using the PSPECTRUM function with its default
%   values. When X is a matrix, each column is treated independently.
%
%   IFREQ = INSTFREQ(X,Ts) specifies Ts as a positive scalar duration
%   corresponding to the sample time of X.
%
%   IFREQ = INSTFREQ(X,Tv) specifies time values, Tv, of X as a numeric vector
%   in seconds, a duration vector, or a datetime vector. Time values may be
%   nonuniformly sampled and must be increasing and finite.
%
%   IFREQ = INSTFREQ(TT) computes the instantaneous frequency of the data in
%   timetable TT and returns a timetable IFREQ. TT must contain numeric double
%   or single precision data. The row times must contain a duration or
%   datetime vector with increasing and finite values. All variables in the
%   timetable and the columns inside each variable are treated
%   independently.
%
%   IFREQ = INSTFREQ(TFD,F,T) specifies a time frequency distribution,
%   TFD, as a matrix containing double or single precision data. F is the
%   corresponding frequency values of the TFD as a numeric vector in hertz
%   with length equal to the number of rows in the TFD. T specifies time
%   values of the TFD as a numeric vector, a duration vector, or a datetime
%   vector with length equal to the number of columns in the TFD.
%
%   IFREQ = INSTFREQ(...,'Method',M) specifies the method to compute the
%   instantaneous frequency, M, as 'tfmoment' or 'hilbert'. If M is set to
%   'tfmoment', INSTFREQ calculates the instantaneous frequency by using
%   the first conditional spectral moment of a time frequency distribution.
%   If M is set to 'hilbert', INSTFREQ calculates the instantaneous
%   frequency by differentiating the phase of an analytic signal computed
%   using the Hilbert transform. The 'hilbert' method does not support
%   nonuniformly spaced time values or time-frequency distribution input.
%   If not specified, 'Method' defaults to 'tfmoment'.
%
%   IFREQ = INSTFREQ(...,'FrequencyLimits',FLIMS) specifies the frequency band
%   limits, FLIMS, as a 1-by-2 numeric vector in hertz over which the
%   instantaneous frequency is computed. The default range is the entire
%   frequency band of the time-frequency distribution. The 'hilbert' method
%   does not support this parameter.
%
%   [IFREQ,T] = INSTFREQ(...) returns a time vector, T, corresponding to the
%   instantaneous frequency.
%
%   INSTFREQ(...) with no output arguments plots the instantaneous
%   frequency.
%
%   % EXAMPLE 1:
%      % Compute instantaneous frequency of a 200 Hz sinusoid in noise.
%      Fs = 1000;
%      t = (0:1/Fs:.296)';
%      x = cos(2*pi*t*200)+0.25*randn(size(t));
%      xTable = timetable(seconds(t), x);
%      instfreq(xTable);
%
%   % EXAMPLE 2:
%      % Re-compute the instantaneous frequency of a 200 Hz sinusoid by
%      % specifying an input Time Frequency Distribution using a coarser
%      % frequency resolution of 25 Hz.
%      Fs = 1000;
%      t = (0:1/Fs:.296).';
%      x = cos(2*pi*t*200)+0.2*randn(size(t));
%      xTable = timetable(seconds(t), x);
%      [P,F,T] = pspectrum(xTable,'spectrogram','FrequencyResolution',25);
%      instfreq(P,F,T);
%
%   % EXAMPLE 3:
%      % Compute instantaneous frequency of quadratic chirp.
%      Fs = 1e3;
%      t=0:(1/Fs):2;
%      y=chirp(t,100,1,200,'q');
%      instfreq(y,Fs);
%
%   % EXAMPLE 4:
%      % Re-compute instantaneous frequency of quadratic chirp using the
%      % Hilbert transform method.
%      Fs = 1e3;
%      t=0:(1/Fs):2;
%      y=chirp(t,100,1,200,'q');
%      instfreq(y,Fs,'Method','hilbert');
%
%   See also PSPECTRUM, HILBERT

% Copyright 2017-2019 The MathWorks, Inc.

%#codegen

narginchk(1,7);
nargoutchk(0,2);

[opts,precision] = parseAndValidateInputs(x,varargin{:});

if strcmp(opts.Method,'tfmoment')    
    [instfreq, Time, opts ] = computeInstantaneousFrequencyTfmoment(opts);
elseif strcmp(opts.Method,'hilbert')    
    [instfreq, Time, opts] = computeInstantaneousFrequencyHilbert(opts);
else
    instfreq = []; 
    Time = cast([], precision);
end

%Adjust TT variable names
if strcmp(opts.InputType,'TimeTable') && coder.target('MATLAB')
    varlabel = strcat(opts.VarNames,'_instfreq');
    IF = x(1:size(instfreq,1),:);
    IF.Properties.RowTimes = Time;
    IF.Properties.DimensionNames{1} = 'Time';
    for idx = 1:length(opts.VarNames)
        IF.(opts.VarNames{idx}) = instfreq(:,opts.VarColIndex == idx);
    end
    IF.Properties.VariableNames = varlabel;
    
else
    IF = instfreq;
end
switch nargout
    case 0
        coder.internal.errorIf(~coder.target('MATLAB'), 'signal:instfreq:PlottingNotSupported');
        if strcmp(opts.Method,'tfmoment') && opts.NumChannels == 1
            displayInstFreqSpectrum(Time,instfreq,opts.Power,opts.Frequency,opts.Time)
        else
            displayInstFreq(Time,instfreq,opts)
        end
    case 1   
        varargout{1} = castToCorrectPrecision(IF, precision);
    case 2
        varargout{1} = castToCorrectPrecision(IF, precision);
        varargout{2} = castToCorrectPrecision(Time, precision);
end

end

function c = castToCorrectPrecision(v, precision)
if isnumeric(v)
    c = cast(v, precision);
else
    if strcmpi(precision, 'single')
        c = single(v);
    else
        c = v;
    end
end

end

function [IF,T,opts] = computeInstantaneousFrequencyTfmoment(opts)
%Compute Instantaneous Frequency using the tfmoment method

if opts.NumChannels == 0
    IF = []; 
    T = opts.Time;
    return;
end

inputTypeIsSpectrum = strcmp(opts.InputType,'Spectrum');
if ~inputTypeIsSpectrum
    inputData = opts.Data(:,1);
    [psPower,psFrequency,psTime] = pspectrum(inputData,opts.TimeInfo,'spectrogram');
    opts.Power = cast(psPower, 'like', real(opts.Data));
    opts.Frequency = cast(psFrequency, 'like', real(opts.Data));
    if coder.target('MATLAB')
        opts.Time = psTime;
    else
        opts.Time = reshape(psTime,numel(psTime),1);
    end
end

tfsmoment = signal.internal.tfmoment.tfsmomentCompute(opts.Power,opts.Frequency(:),1,false,opts.FrequencyLim);
IF = zeros(numel(tfsmoment), opts.NumChannels);
for i = 1:numel(tfsmoment)
    IF(i,1) = tfsmoment(i);
end

for idx = 1:opts.NumChannels    
    if ~inputTypeIsSpectrum
        inputData = opts.Data(:,idx);
        [psPower,psFrequency,psTime] = pspectrum(inputData,opts.TimeInfo,'spectrogram');
        opts.Power = cast(psPower, 'like', real(opts.Data));
        opts.Frequency = cast(psFrequency, 'like', real(opts.Data));
        if coder.target('MATLAB')
            opts.Time = psTime;
        else
            opts.Time = reshape(psTime,numel(psTime),1);
        end
    end
    
    tfsmoment = signal.internal.tfmoment.tfsmomentCompute(opts.Power,opts.Frequency(:),1,false,opts.FrequencyLim);  
    for i = 1:numel(tfsmoment)
        IF(i,idx) = tfsmoment(i);
    end    
end

T = opts.Time;

end

function [IF,T,opts] = computeInstantaneousFrequencyHilbert(opts)
%Compute Instantaneous Frequency using the hilbert method

IF = zeros(size(opts.Data,1)-1,size(opts.Data,2));
for idx = 1:opts.NumChannels
    
    inputData = opts.Data(:,idx);
    z = hilbert(inputData);
    IF(:,idx) = opts.SamplingFrequency(1)/(2*pi)*diff(unwrap(angle(z)));
end

if numel(opts.TimeInfo)>1
    TimeInfov = opts.TimeInfo(:);
    Tinfo = TimeInfov(1:end-1);
    if isrow(Tinfo)
        T = Tinfo';
    else
        T = Tinfo;
    end    
    
else
    if isnumeric(opts.TimeInfo)
        temp = 0:1/opts.SamplingFrequency(1):(length(opts.Data)-1)/opts.SamplingFrequency(1);
        T = temp(1:end-1)';
    else
        temp = 0:opts.TimeInfo:(length(opts.Data)-1)*opts.TimeInfo;
        T = temp(1:end-1)';
    end
end

%adjusting Time array to be at center of each period
if isnumeric(T)
    T = bsxfun(@plus, T, ((1/opts.SamplingFrequency(1))/2));
else
    T = T+ seconds((1/opts.SamplingFrequency)/2);
end

end

function displayInstFreq(T,IF,opts)
%Display the instantaneous frequency as a line

[~,freqScale,uf] = signalwavelet.internal.convenienceplot.getFrequencyEngUnits(max(abs(IF(:))));
IF = IF*freqScale;
freqlbl = [getString(message('signal:instfreq:Frequency')) ' (' uf ')'];

if isnumeric(T)
    [~,timeScale,ut] = signalwavelet.internal.convenienceplot.getTimeEngUnits(max(abs(T)));
    T = T*timeScale;
    timelbl = [getString(message('signal:instfreq:Time')) ' (' ut ')'];
else
    timelbl = getString(message('signal:instfreq:Time'));
end

xlbl = timelbl;
ylbl = freqlbl;
h = newplot;

ifhndl = plot(h,T,IF,'LineWidth',1);

% Disable AxesToolbar
ax = ancestor(ifhndl,'axes');
if iscell(ax)
    cellfun(@(hAx) set(hAx,'Toolbar',[]),ax,'UniformOutput',false);
elseif ~isempty(ax) && ~isempty(ax.Toolbar)
    ax.Toolbar = [];
end

ylabel(ylbl);
xlabel(xlbl);
title(getString(message('signal:instfreq:InstFreqEstimate')));

if opts.NumChannels >1
    if strcmp(opts.InputType,'TimeTable')
        legendNames = [];
        for idx = 1:length(opts.VarNames)
            if sum(opts.VarColIndex==idx) ~= 1
                temp = strcat( opts.VarNames{idx}, '\_instfreq(:,', num2str((1:sum(opts.VarColIndex==idx))'), ')');
            else
                temp = strcat( opts.VarNames{idx}, '\_instfreq');
            end
            legendNames = [legendNames; cellstr(temp)]; %#ok<AGROW>
        end
    else
        legendNames = cellstr(num2str((1:opts.NumChannels)', 'instfreq (:,%d)'));
    end
    legend(h,ifhndl,legendNames,'Location','best')
end

ylim(h,[0 (opts.SamplingFrequency/2)*freqScale])

end

function displayInstFreqSpectrum(TF,IF,P,F,T)
%Display the instantaneous frequency as a line over the spectrogram

plotOpts.title = getString(message('signal:instfreq:InstFreqEstimate'));
plotOpts.legend = getString(message('signal:instfreq:InstFreq'));
plotOpts.isFsNormalized = false;

signalwavelet.internal.convenienceplot.plotTFR(T,F,10*log10(abs(P)+eps),TF,IF,plotOpts);

end

function [opts,precision] = parseAndValidateInputs(sig,varargin)
%PARSEANDVALIDATEINPUTS parse and validate inputs for INSTFREQ
%
%	sig is a time table
%       - instfreq(TT, 'Method','tfmoment/hilbert','FrequencyLimits', [f1, f2])
%
%   sig is a signal vector
%       - instfreq(X, Fs, 'Method','tfmoment/hilbert','FrequencyLimits', [f1, f2])
%       - instfreq(X, Ts, 'Method','tfmoment/hilbert','FrequencyLimits', [f1, f2])
%       - instfreq(X, Tv, 'Method','tfmoment/hilbert','FrequencyLimits', [f1, f2])
%
%   sig is time-frequency distribution
%       - instfreq(TFD, F, T, 'Method','tfmoment','FrequencyLimits', [f1, f2])
%
%   This function is for internal use only. It may be removed.

%   Copyright 2017 The MathWorks, Inc.

isMATLAB = coder.target('MATLAB');

xIsTimeTable = false;
if isMATLAB
    xIsTimeTable = istimetable(sig);    
end

coder.internal.errorIf(~isMATLAB && xIsTimeTable, 'signal:instfreq:TimeTableNotSupported');

if isrow(sig)
    x = sig(:);
else
    x = sig;
end
Data = x;

if isMATLAB
    opts = struct(...
        'Data',[],...
        'SamplingFrequency',[],...
        'Time',[],...
        'TimeInfo',[],...
        'Frequency',[],...
        'Power',[],...
        'DataLength',0,...
        'NumChannels',1,...
        'FrequencyLim',[],...
        'IsTimeTable',xIsTimeTable,...,
        'VarNames',[],...
        'VarColIndex',[],...
        'InputType','Signal',...
        'Method','tfmoment');
else
    opts = struct(...
        'Data',Data,...
        'SamplingFrequency',zeros(1,1,'like',real(Data)),...
        'Time',zeros(0,1,'like',real(Data)),...
        'TimeInfo',cast([],'like',real(Data)),...
        'Frequency',cast([],'like',real(Data)),...
        'Power',cast([],'like',real(Data)),...
        'DataLength',0,...
        'NumChannels',1,...
        'FrequencyLim',zeros(1,2,'like',real(Data)),...
        'IsTimeTable',xIsTimeTable,...,
        'VarNames',[],...
        'VarColIndex',[],...
        'InputType','Signal',...
        'Method','tfmoment');

coder.varsize('opts.Data');
coder.varsize('opts.Time');
coder.varsize('opts.TimeInfo');
coder.varsize('opts.Frequency');
coder.varsize('opts.Power');
coder.varsize('opts.FrequencyLim');
coder.varsize('opts.VarNames');
coder.varsize('opts.VarColIndex');
coder.varsize('opts.InputType');
coder.varsize('opts.Method');

end


if ~isempty(varargin)
    numValueOnlyInput = signal.internal.tfmoment.numOfRequiredInput(varargin{:});
else
    numValueOnlyInput = 0;
end

if isMATLAB && opts.IsTimeTable
    %Input is Timetable
    opts.InputType = 'TimeTable';
    
    if numValueOnlyInput > 0
        error(message('signal:instfreq:SampleRateAndTimetableInput'));
    end
    if (height(x) < 2)
        error(message('signal:instfreq:InvalidInputLength'));
    end
    
    if ~all(varfun(@(x) isa(x,'double'),x,'OutputFormat','uniform')) && ~all(varfun(@(x) isa(x,'single'),x,'OutputFormat','uniform'))
        error(message('signal:instfreq:InvalidNonHomogeneousDataType'));
    end
    
    %Validate Data
    signal.internal.utilities.validateattributesTimetable(x,{'sorted'},'instfreq','TT');
    [Data, ~, TimeInfo] = signal.internal.utilities.parseTimetable(x);
    opts.VarNames = x.Properties.VariableNames;
    [opts.DataLength, opts.NumChannels] = size(Data);
    validateattributes(Data, {'single','double'},{'nonempty','finite','2d','nonnan'},'instfreq','Timetable variables');
    opts.Data = Data;
 
    if isa(Data, 'single')
        precision = 'single';
    else
        precision = 'double';
    end
        
    for idx = 1:length(opts.VarNames)
        opts.VarColIndex = [opts.VarColIndex idx*ones(1,size(x.(opts.VarNames{idx}),2))];
    end
    
    %Validate Time
    opts.TimeInfo = TimeInfo;
    validateattributes(TimeInfo,{'numeric','duration','datetime'},{'vector','real','nonempty'},'instfreq','Timetable row times ');
    nvpair = {varargin{1:end}};
    if isnumeric(TimeInfo)
        TimeInfo = double(TimeInfo);
    end
    
    %Compute Fs
    Fs = signal.internal.utilities.computeFs(TimeInfo, 'instfreq');
    if isreal(Data)
        defaultFrequencyLimits = [0,Fs/2];
    else
        defaultFrequencyLimits = [-Fs/2,Fs/2];
    end
    defaultMethod = 'tfmoment';
    opts.SamplingFrequency = Fs;
else
    coder.internal.errorIf(isempty(varargin), 'signal:instfreq:InvalidInputDataTypeVector');
        
    if numValueOnlyInput < 2
        %Input is Signal
        opts.InputType = 'Signal';
        
        %Validate Data
        validateattributes(x, {'single','double'},{'nonempty','finite','2d','nonnan'},'instfreq','Input signal');
        [opts.DataLength, opts.NumChannels] = size(Data);
        
        coder.internal.errorIf(opts.DataLength < 2, 'signal:instfreq:InvalidInputLength');       
        opts.Data = Data;
       
        if isa(Data, 'single')
            precision = 'single';
        else
            precision = 'double';
        end
        
        %Validate Time
        TimeInfo = varargin{1};
        validateattributes(TimeInfo,{'numeric','duration','datetime'},{'vector','real','nonempty'},'instfreq','Time values');
                
        len = length(x);        
        coder.internal.errorIf(~isscalar(TimeInfo) && (length(TimeInfo) ~= len), 'signal:instfreq:TimeNotMatchVector');
        coder.internal.errorIf(isscalar(TimeInfo) && isdatetime(TimeInfo), 'signal:instfreq:TimeNotMatchVector');
        
        if coder.target('MATLAB')
            opts.TimeInfo = TimeInfo;
        else
            opts.TimeInfo = cast(TimeInfo(:), 'like', real(Data));
        end
        
        if numValueOnlyInput == numel(varargin)
            nvpair = {};
        else
            nvpair = {varargin{numValueOnlyInput+1:end}};
        end
        
        %Compute Fs
        Fs = signal.internal.utilities.computeFs(TimeInfo, 'instfreq');
        if isreal(Data)
            defaultFrequencyLimits = [0,Fs(1)/2];
        else
            defaultFrequencyLimits = [-Fs(1)/2,Fs(1)/2];
        end
        
        defaultMethod = 'tfmoment';
        opts.SamplingFrequency = cast(Fs(1),'like',real(opts.Data));
    else
        coder.internal.errorIf(numValueOnlyInput > 2, 'signal:instfreq:TooManyValueOnlyInputs');        
        opts.InputType = 'Spectrum';
        
        %Validate Data
        validateattributes(x, {'single','double'},{'nonnegative','nonempty','finite','real','2d','nonnan'},'instfreq','TFD');
        opts.Power = x;

        if isa(Data, 'single')
            precision = 'single';
        else
            precision = 'double';
        end
       
        %Validate Frequency
        F = varargin{1};
        validateattributes(F, {'numeric'},{'vector', 'nonempty',...
           'nondecreasing','finite','real','nonnan'},'instfreq','Frequency values');
        
        F = double(F);
        
        len = size(x,1);
        coder.internal.errorIf(length(F) ~= len, 'signal:instfreq:FrequencyNotMatch');
               
        opts.Frequency = cast(F, precision);
        
        %Validate Time        
        validateattributes(varargin{2},{'numeric','duration','datetime'},{'vector','nonempty','real'},'instfreq','Time values');
        
        len = size(x,2);
        coder.internal.errorIf(length(varargin{2}) ~= len, 'signal:instfreq:TimeNotMatchTFD');

        if isnumeric(varargin{2})
            TimeInfo = double(varargin{2});
        else
            TimeInfo = varargin{2};
        end
        
        [t, td]= signal.internal.tfmoment.parseTime(TimeInfo,len,'instfreq');
        validateattributes(t, {'single','double'},{'nonnegative','increasing',...
            'finite','real','vector'},'instfreq','time values');
        if coder.target('MATLAB')
            opts.Time = td(:);
        else
            opts.Time = cast(td(:), precision);
        end
        
        if numValueOnlyInput == numel(varargin)
            nvpair = {};
        else
            nvpair = {varargin{numValueOnlyInput+1:end}};
        end
        defaultFrequencyLimits = [F(1),F(end)];
        defaultMethod = 'tfmoment';
    end
end

opts = parseAndValidateNVPair(opts,defaultMethod,defaultFrequencyLimits, nvpair);
end

function opts = parseAndValidateNVPair(opts, defaultMethod,defaultFrequencyLimits,nvpair)
%PARSEANDVALIDATENVPAIR parse and validate the name-value pair for
%INSTFREQ functions.
%
%   This function is for internal use only. It may be removed.
%
%   Copyright 2017 The MathWorks, Inc.

params = struct(...
    'FrequencyLimits', uint32(0), ...
    'Method', uint32(0));
poptions = struct( ...
    'CaseSensitivity',false, ...
    'PartialMatching','unique', ...
    'StructExpand',false, ...
    'IgnoreNulls',true);
pstruct = coder.internal.parseParameterInputs(params, poptions, nvpair{:});

FrequencyLim = coder.internal.getParameterValue(pstruct.FrequencyLimits, defaultFrequencyLimits, nvpair{:});    
validateattributes(FrequencyLim, {'single','double'},...
    {'nondecreasing','finite',...
    'real','vector','>=',defaultFrequencyLimits(1),'<=',defaultFrequencyLimits(2),'numel',2},...
    'instfreq','FrequencyLim');
opts.FrequencyLim = cast(FrequencyLim, 'like', real(opts.Data));

Method = coder.internal.getParameterValue(pstruct.Method, defaultMethod, nvpair{:});

if any(strcmp(Method,{'tfmoment','hilbert'}))
    opts.Method = Method;
    coder.internal.errorIf(strcmp(Method,'hilbert') && strcmp(opts.InputType,'Spectrum'), ...
        'signal:instfreq:MethodAndTFDInput');
            
    coder.internal.errorIf(strcmp(Method, 'hilbert') && ...
            all(FrequencyLim ~= defaultFrequencyLimits), ...
        'signal:instfreq:MethodAndFreqLim');   
        
    if (strcmp(Method,'hilbert')&& numel(opts.TimeInfo) >1)
        if isdatetime(opts.TimeInfo)
            temp = seconds(opts.TimeInfo - opts.TimeInfo(1));
        elseif isduration(opts.TimeInfo)
            temp = seconds(opts.TimeInfo);
        else
            temp = opts.TimeInfo;
        end
        
        err = max(abs(temp(:).'-linspace(temp(1),temp(end),numel(temp)))./max(abs(temp(:))));
        nonUniformSampling = err > 3*eps(class(err));
        coder.internal.errorIf(nonUniformSampling, 'signal:instfreq:MethodAndNonUniformSampling');
        
    end
else
    coder.internal.error('signal:instfreq:InvalidMethod')
end

end
