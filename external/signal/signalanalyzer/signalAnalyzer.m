function signalAnalyzer(varargin)
%SIGNALANALYZER Visualize and compare multiple signals
%   SIGNALANALYZER opens the Signal Analyzer app.
%
%   SIGNALANALYZER(SIG) opens the Signal Analyzer App and imports and plots
%   the signal SIG. If the app is already open, then it plots SIG in the
%   currently active display. SIG can be a vector or a matrix with
%   independent signals in each column, a timetable object with time values
%   specified as durations, or a timeseries object. When SIG is a timetable
%   or a timeseries, the time values must be increasing and not equal to
%   NaN. When SIG is a timetable, signalAnalyzer will only import table
%   columns containing numeric or logical one or two-dimensional arrays.
%
%   NOTE: Signals are imported in samples and displayed versus sample index
%   by default. If time information is provided (see below) or if the input
%   signals have inherent time information (e.g. timetable or timeseries
%   signals), then the app plots the signals against time.
%
%   SIGNALANALYZER(SIG1,SIG2,...,SIGN) imports N signals and plots them in
%   the currently active display. You cannot import signals with and
%   without inherent time information simultaneously.
%
%   SIGNALANALYZER(...,'SampleRate',Fs) specifies a sample rate, Fs, as a
%   positive scalar expressed in Hz. The app uses the sample rate to plot
%   the signals against time, assuming a start time of zero seconds. You
%   cannot specify a sample rate for signals with inherent time information
%   (e.g. timetable or timeseries signals).
%
%   SIGNALANALYZER(...,'SampleTime',Ts) specifies a sample time, Ts, as a
%   positive scalar expressed in seconds. The app uses the sample time to
%   plot the signals against time, assuming a start time of zero seconds.
%   You cannot specify a sample time for signals with inherent time
%   information.
%
%   SIGNALANALYZER(...,'StartTime',ST) specifies a signal start time, ST,
%   as a numeric scalar expressed in seconds. If you do not specify a
%   sample rate or sample time, then the app assumes a sample rate of 1 Hz.
%   You cannot specify a start time for signals with inherent time
%   information.
%
%   SIGNALANALYZER(...,'TimeValues',Tv) specifies a vector, Tv with time
%   values for each corresponding data point. Tv can be a numeric vector
%   with real time values expressed in seconds or an array of durations.
%   Values in Tv must be increasing and not equal to NaN. All input signals
%   must have the same length as the specified time values vector. You
%   cannot specify a time values vector for signals with inherent time
%   information.
%
%   % EXAMPLE:
%   %   Load a data set containing a helicopter cabin vibration
%   %   signal, vib, sampled at a rate fs. Import
%   %   the signal from the workspace to Signal Analyzer by passing it as
%   %   the first argument to a function call. Import a detrended version
%   %   of the signal as the second argument. Assign the sample rate to
%   %   both signals. Signal Analyzer chooses a variable name (e.g. 'sig1')
%   %   for the second input since it is not associated with a workspace
%   %   variable.
%   load('helidata.mat');
%   signalAnalyzer(vib,detrend(vib),'SampleRate',fs)

%   Copyright 2015-2019 The MathWorks, Inc.

nargoutchk(0,0);

% Find the number of input signals. All inputs up to the first string are
% considered input signals.
N = find(cellfun(@(x) ischar(x) || isstring(x),varargin),1)-1;
if N == 0
    error(message('SDI:sigAnalyzer:InvalidDataTypeInputs'));
elseif isempty(N)
    N = nargin;
end

isInherentTimeInputs = validateSignals(varargin(1:N));
[Fs,Ts,St,Tv,mode] = parsePairs(varargin(N+1:end), isInherentTimeInputs);

if strcmp(mode, 'tv')
    validateSignalSizes(varargin(1:N), length(Tv));
    % Ensure that we have a reasonable non uniformly sampled signal
    validateNonUniformTimeValues(Tv);
end

% Extract signal names. Empty names will be given default names in
% updateRepository. Cast signals to double and store them in sigVals.
% updateRespository will access sigVals using evalin.
sigNames = cell(N,1);
sigVals = cell(N,1);
for i = 1:N
    sigNames{i} = inputname(i);
    if strcmp(mode, 'inherent')
        sigVals{i} = varargin{i};
    else
        sigVals{i} = double(varargin{i});
        if isrow(sigVals{1})
            sigVals{i} = sigVals{i}(:);
        end
    end
end

signal.analyzer.signalAnalyzerImpl(Fs,Ts,St,Tv,mode,sigNames,sigVals);

end

%--------------------------------------------------------------------------
function isInherentTimeInputs = validateSignals(inputCell)
% Validate attributes for input signals

sigsWithInherentTimeCnt = 0;
sigsWithNoInherentTimeCnt = 0;
% Check that we do not have a mix of signals with inherent time information
% and signals with no time information.
for i = 1:length(inputCell)
    sig = inputCell{i};
    if istimetable(sig)
        sigsWithInherentTimeCnt = sigsWithInherentTimeCnt + 1;
    elseif isa(sig,'timeseries')
        sigsWithInherentTimeCnt = sigsWithInherentTimeCnt + 1;
    elseif isa(sig,'labeledSignalSet') && isSupportedInSignalAnalyzer(sig)
        sigsWithInherentTimeCnt = sigsWithInherentTimeCnt + 1;
    else
        sigsWithNoInherentTimeCnt = sigsWithNoInherentTimeCnt + 1;
    end
    if sigsWithInherentTimeCnt > 0 && sigsWithNoInherentTimeCnt > 0
        error(message('SDI:sigAnalyzer:MixSigsWithTimeAndSamples'));
    end
end

% Check signal types and characteristics
for i = 1:length(inputCell)
    sig = inputCell{i};
    if istimetable(sig)
        validateTimetable(sig);
    elseif isa(sig,'timeseries')
        validateTimeseries(sig);
    elseif isa(sig,'labeledSignalSet') && isSupportedInSignalAnalyzer(sig)
            validateLabeledSignalSet(sig);
    elseif isa(sig,'gpuArray')
        error(message('SDI:sigAnalyzer:InvalidDataTypeInputs'));
    elseif isnumeric(sig) || isa(sig,'embedded.fi') || islogical(sig)
        validateattributes(sig,{'numeric','embedded.fi', 'logical'}, ...
            {'2d','finite','nonempty', 'nonsparse'},'','SIG');
        if isscalar(sig)
            error(message('SDI:sigAnalyzer:InvalidDataTypeInputs'));
        end
    else
        error(message('SDI:sigAnalyzer:InvalidDataTypeInputs'));
    end
end
isInherentTimeInputs = (sigsWithInherentTimeCnt > 0);
end

%--------------------------------------------------------------------------
function validateSignalSizes(inputSignals, timeVectLength)
% Validate that input signals have same length as input vector

for idx = 1:length(inputSignals)
    sig = inputSignals{idx};
    if isvector(sig)
        currentSigLength = length(sig);
    else
        currentSigLength = size(sig,1);
    end
    if idx ==1
        sigLength = currentSigLength;
    end
    sizeValid = (sigLength == currentSigLength);
    
    if ~sizeValid
        break;
    end
end

if ~sizeValid || (sigLength ~= timeVectLength)
     error(message('SDI:sigAnalyzer:InvalidSigAndTimeVectorSizes'));
end

end

%--------------------------------------------------------------------------
function [Fs,Ts,St,Tv,mode] = parsePairs(inputCell, isInherentTimeInputs)
% Check that length of the input is even

% Parse name-value pairs
p = inputParser;
p.addParameter('SampleRate',[]);
p.addParameter('SampleTime',[]);
p.addParameter('StartTime',[]);
p.addParameter('TimeValues',[]);
parse(p,inputCell{:});
vals = p.Results;
Fs = vals.SampleRate;
Ts = vals.SampleTime;
St = vals.StartTime;
Tv = vals.TimeValues;

if isInherentTimeInputs
    if sum([~isempty(Fs), ~isempty(Ts), ~isempty(St), ~isempty(Tv)]) > 0
        error(message('SDI:sigAnalyzer:SpecifiedInherentTimeDataAndTimeValues'));
    end    
    mode = 'inherent';    
else    
    if sum([~isempty(Fs), ~isempty(Ts), ~isempty(Tv)]) > 1
        error(message('SDI:sigAnalyzer:MultipleTimeInputs'));
    end
    
    if sum([~isempty(St), ~isempty(Tv)]) > 1
        error(message('SDI:sigAnalyzer:TimeVectorAndStartTime'));
    end
    
    if ~isempty(Fs)
        validateattributes(Fs,{'numeric'},{'real','scalar','positive','finite'},'','''SampleRate''');
        mode = 'fs';        
        if isempty(St)
            St = 0;
        else
            validateattributes(St,{'numeric'},{'real','scalar','finite'},'','''StartTime''');            
        end
    elseif ~isempty(Ts)
        validateattributes(Ts,{'numeric'},{'real','scalar','positive','finite'},'','''SampleTime''');
        mode = 'ts';
        if isempty(St)
            St = 0;
        else
            validateattributes(St,{'numeric'},{'real','scalar','finite'},'','''StartTime''');            
        end
    elseif ~isempty(Tv)        
        if isduration(Tv)
            Tv = seconds(Tv);
        end
        % Add duration to types so that error message shows the two valid
        % types. 
        validateattributes(Tv,{'numeric','duration'},{'vector','real','finite'},'','''TimeValues''');
        if length(Tv) ~= length(unique(Tv))
            error(message('SDI:sigAnalyzer:TimeVectorMustBeUnique'));
        end
        if ~issorted(Tv)
            error(message('SDI:sigAnalyzer:TimeVectorMustBeSorted'));
        end
        mode = 'tv';        
    elseif ~isempty(St)
        validateattributes(St,{'numeric'},{'real','scalar','finite'},'','''StartTime''');
        mode = 'fs';
        Fs = 1;
    else
        mode = 'samples';
    end
    
    % Cast to double
    Fs = double(Fs);
    Ts = double(Ts);
    St = double(St);
    Tv = double(Tv(:));
end
end

%--------------------------------------------------------------------------
function validateTimetable(s)
% Check time table validity

% Time table must not be empty
if isempty(s)
    error(message('SDI:sigAnalyzer:TimetableEmpty'));
end

% Time table must not be empty or contain scalar signals
if length(s.Properties.RowTimes) <= 1
    error(message('SDI:sigAnalyzer:TimetableScalarValues'));
end

% Time must be duration vector
if ~isduration(s.Properties.RowTimes)
    error(message('SDI:sigAnalyzer:TimeInTableMustBeDuration'));
end
% Time values must be finite
if ~all(isfinite(s.Properties.RowTimes))
    error(message('SDI:sigAnalyzer:TimeInTableIsNotFinite'));
end
% Time values must be unique
if length(unique(s.Properties.RowTimes)) ~= length(s.Properties.RowTimes)
    error(message('SDI:sigAnalyzer:TimeInTableIsNotUnique'));
end

% Time values must be sorted
if ~issorted(s)
    error(message('SDI:sigAnalyzer:TimeInTableIsNotSorted'));
end

% Ensure that we have a reasonable non uniformly sampled signal
validateNonUniformTimeValues(seconds(s.Properties.RowTimes));

% There must be at least one table column with a 1 or 2 dimensional
% finite numeric, or logical matrix.
colNames = s.Properties.VariableNames;
validCols = true(1, numel(colNames));
for idx = 1:numel(colNames)
    colData = s.(colNames{idx});
    if ~isnumeric(colData) && ~islogical(colData)
        validCols(idx) = false;
        continue;
    end
    if ~ismatrix(colData)
        validCols(idx) = false;
        continue;
    end
    if ~all(isfinite(colData(:)))
        validCols(idx) = false;
        continue;
    end
end
if ~any(validCols)
    error(message('SDI:sigAnalyzer:ColsInTableNotValid'));
end
end
%--------------------------------------------------------------------------
function validateTimeseries(s)

% Time series must be a scalar
if ~isscalar(s)
    error(message('SDI:sigAnalyzer:TimeseriesMustBeScalar'));
end

% Time series name must be a valid MATLAB variable name
if ~isvarname(s.Name)
    error(message('SDI:sigAnalyzer:TimeseriesInvalidName'));
end

% Time series must not be empty or contain scalar signals
if length(s.Time) <= 1
    error(message('SDI:sigAnalyzer:TimeseriesScalarValues'));
end

% Time values must be unique
if length(unique(s.Time)) ~= length(s.Time)
    % Time values must be unique
    error(message('SDI:sigAnalyzer:TimeInTimeseriesIsNotUnique'));
end

% Ensure that we have a reasonable non uniformly sampled signal
validateNonUniformTimeValues(s.Time);

data = squeeze(s.Data);
if (~isnumeric(data) && ~islogical(data)) || ~all(isfinite(data(:)))
    error(message('SDI:sigAnalyzer:DataInTimeseriesIsNotValid'));
end 

if ~isa(s.DataInfo.Interpolation,'tsdata.interpolation') || ...
        ~strcmp(s.DataInfo.Interpolation.Name, 'linear')
    error(message('SDI:sigAnalyzer:DataInTimeseriesInvalidInterpolation'));
end

if ~strcmp(s.TimeInfo.Units, 'seconds')
    error(message('SDI:sigAnalyzer:TimeInTimeseriesInvalidTimeUnits'));
end
end

%--------------------------------------------------------------------------
function validateNonUniformTimeValues(tv)
    % Check regularity of time vector intervals.
    tmd = signal.sigappsshared.controllers.TimeMetadataDialog.getController();
    [flag, errorObj] = tmd.validateNonUniformTimeValues(tv);
    if ~flag
        error(errorObj);        
    end        
end

%--------------------------------------------------------------------------
function validateLabeledSignalSet(s)
% Check labeledSignalSet validity

% LSS must have members
if s.NumMembers < 1
    error(message('SDI:sigAnalyzer:LabeledSignalSetEmpty'));
end

% Ensure that we have a reasonable non uniformly sampled signal if time
% values are specified either directly or through an inherent timetable
if strcmp(s.TimeInformation,'TimeValues')
    if iscell(s.TimeValues)
       for idx = 1:numel(s.TimeValues)
           validateNonUniformTimeValues(seconds(s.TimeValues{idx}));
       end        
    else
        for idx = 1:size(s.TimeValues,2)
            validateNonUniformTimeValues(seconds(s.TimeValues(:,idx)));
        end
    end
elseif strcmp(s.TimeInformation,'inherent')
    for idx = 1:s.NumMembers
        if iscell(s.Source{idx})
            for midx = 1:length(s.Source{idx})
                validateTimetable(s.Source{idx}{midx});
            end
        else
            validateTimetable(s.Source{idx});
        end
    end
end

end