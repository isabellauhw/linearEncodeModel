function varargout = rpmtrack(x, varargin)
%RPMTRACK Extract RPM from a vibration signal
%   RPM = RPMTRACK(X,FS,ORDER,P) returns RPM, an estimate of rotational
%   speed as a function of time, extracted from a vibration signal, X. X is
%   a double or single precision vector sampled at a rate of FS hertz.
%   RPMTRACK performs a two-step (coarse-fine) estimation method.
%   Initially, the function computes a time-frequency map of X and extracts
%   from it a ridge of interest based on P, a specified set of points on
%   the ridge, and ORDER, the ridge order. Specify P as a two-column matrix
%   with one time-frequency coordinate on each row. The extracted ridge
%   provides a coarse estimate of the RPM profile. In the second step,
%   RPMTRACK uses a Vold-Kalman filter to compute the order waveform of the
%   extracted ridge, estimates a new time-frequency map based on the
%   waveform, and extracts the isolated order ridge to provide a finer
%   estimate of the RPM profile.
%
%   RPM = RPMTRACK(XT,ORDER,P) returns an RPM estimate for the signal in
%   the timetable XT. XT must have a single variable containing a double or
%   single precision vector. The time values in XT must be durations,
%   strictly increasing, finite and uniformly spaced. The returned RPM is
%   also a timetable with one variable whose time variable has the same
%   format as the time column in XT.
%
%   If you do not have enough information about the ridges, you can leave
%   P, or both ORDER and P, unspecified. In that case, RPMTRACK launches an
%   interactive plot that displays the time-frequency map and enables you
%   to select ridge points with the mouse.
%
%   RPM = RPMTRACK(...,'Method',EM) specifies the type of time-frequency
%   map used in the estimation process as one of 'stft' or 'fsst'. When EM
%   is set to 'stft', RPMTRACK uses the short-time Fourier transform to
%   compute the time-frequency map and a Vold-Kalman filter to extract the
%   order waveform. When EM is set to 'fsst', RPMTRACK uses the Fourier
%   synchrosqueezed transform to compute the time-frequency map and the
%   inverse synchrosqueezed transform to extract the order waveform. EM
%   defaults to 'stft'.
%
%   RPM = RPMTRACK(...,'FrequencyResolution',FRES) specifies the frequency
%   resolution bandwidth, FRES, as a numeric scalar in Hz. When
%   'FrequencyResolution' is not specified, RPMTRACK chooses a value
%   automatically based on the size of the input data. See documentation to
%   learn more.
%
%   RPM = RPMTRACK(...,'PowerPenalty',PPEN) specifies the maximum allowable
%   difference in power (in dB) between adjacent points on a ridge in the
%   time-frequency map. Use this parameter to ensure that RPMTRACK finds
%   the correct ridge for the corresponding order. 'PowerPenalty' is useful
%   when you want to differentiate order ridges that cross or are closely
%   spaced in frequency but have different power levels. The default value
%   is Inf.
%
%   RPM = RPMTRACK(...,'FrequencyPenalty',FPEN) specifies FPEN, a penalty
%   in the coarse ridge-extraction algorithm, as a nonnegative scalar. Use
%   this parameter to ensure that RPMTRACK avoids big jumps that could make
%   the ridge estimate move to an incorrect time-frequency location.
%   'FrequencyPenalty' is useful when you want to differentiate order
%   ridges that cross or are closely spaced in frequency and have similar
%   power levels. The default value is 0.
%
%   RPM = RPMTRACK(...,'StartTime',TSTART) specifies a start time for
%   RPMTRACK to estimate the RPM profile. Use this parameter to exclude
%   signal values before TSTART. You can specify TSTART as a numeric scalar
%   in seconds or as a duration.
%
%   RPM = RPMTRACK(...,'EndTime',TEND) specifies an end time for RPMTRACK
%   to estimate the RPM profile. Use this parameter to exclude signal
%   values after TEND. TEND defaults to the input signal end time. You can
%   specify TEND as a numeric scalar in seconds or as a duration.
%
%   [RPM, TOUT] = RPMTRACK(...) returns the time vector TOUT at which the
%   RPM is computed.
%
%   RPMTRACK(...) with no output arguments plots the power time-frequency
%   map in an interactive plot. If both ORDER and P are specified, the plot
%   also shows the estimated RPM profile.
%
%   EXAMPLE 1:
%   % Generate a vibration signal with 3 harmonic components
%   fs = 1000;                        % sample rate
%   t = (0:1/fs:6);                   % time vector
%   fi = 20 + t.^6.*exp(-t);          % instantaneous frequency
%   phi = 2*pi*cumtrapz(t,fi);        % instantaneous phase
%   ol = [1 2 3];                     % order list
%   amp = [5 10 5];                   % amplitudes
%   vib = amp*cos(ol'.*phi);          % vibration signal
%   order = 2;                        % ridge order
%   P = [3 112.6];                    % point on the ridge
%   % Extract the RPM profile and visualize it
%   rpmtrack(vib,fs,order,P);
%
%   Example 2:
%   % Generate a two-order runup/coastdown vibration signal
%   fs = 1000;                            % sample rate
%   t = (0:1/fs:20);                      % time samples
%   fi = 20 + t.^6.*exp(-t);              % instantaneous frequency
%   phi = 2*pi*cumtrapz(t,fi);            % instantaneous phase
%   vib = 10*cos(phi) + 20*cos(2*phi);    % vibration signal
%   order = 1;                            % ridge order
%   P = [5 125];                          % point on the ridge
%   % Extract the RPM profile and visualize it
%   rpmtrack(vib,fs,order,P,'FrequencyResolution',5);

%   See also RPMORDERMAP, PSPECTRUM, ORDERWAVEFORM, FSST, TFRIDGE.

% Copyright 2017-2018 The MathWorks, Inc.

narginchk(1,16);
nargoutchk(0,2);

% Parse and validate the input arguments
nArgOut = nargout;
opts = parseAndValidateInputs(x,nArgOut,varargin{:});

% Compute map, time and frequency
[Sx,Fx,Tx,Px] = signal.internal.rpmtrack.computeMap(opts);

% Initialize rpm and tout
rpm = [];
tout = [];

if opts.ComputeRPM
    % [...] = rpmtrack(...,ORDER,P,...) or rpmtrack(...,ORDER,P,...)
    [rpm,tout] = signal.internal.rpmtrack.computeRPM(Sx,Fx,Tx,Px,opts);
    
    % Cast output time vector to single if the input signal is single
    if opts.IsSingle
        tout = single(tout);
    end
    % Cast estimated rpm into time table if input signal is a timetable
    if opts.IsTimeTable
        tout = duration(0,0,tout,'Format',opts.TimeFormat);
        rpm = timetable(tout,rpm);
    end
    % Output
    if (nArgOut == 1)
        % RPM = rpmtrack(...,ORDER,P,...)
        varargout{1} = rpm;
    elseif (nArgOut == 2)
        % [RPM,TOUT] = rpmtrack(...,ORDER,P,...)
        varargout{1} = rpm;
        varargout{2} = tout;
    end
end

if opts.LaunchGUI
    % GUI will be launched if there is no output argument assigned, or
    % order and ridge points are unspecified, or only ridge points are 
	% unspecified.
    
    % Get name of value-only input arguments for generating MATLAB script
    % in GUI
    voInArgNames = cell(opts.NumValueOnlyInputArguments,1);
    for n = 1:opts.NumValueOnlyInputArguments
        voInArgNames{n} = inputname(n);
    end
    opts = signal.internal.rpmtrack.getRHSFunctionCallInfo(voInArgNames,opts);
    % Get caller information
    stk =  dbstack('-completenames');
    % Check if caller is a function or the command line. Sniff the output
    % variable name.
    opts.OutputArgumentNames = ...
        signal.internal.rpmtrack.getRPMTrackOutputVarName(stk);
    if (nArgOut > 0)
        g = signal.internal.rpmtrack.RPMTracker(Sx,Fx,Tx,Px,rpm,tout,opts);
        waitfor(g,'IsExportButtonPushed',true);        
        if isvalid(g)
            if (nArgOut == 1)
                varargout{1} = g.EstimatedRPMToWS;
            elseif (nArgOut == 2)
                varargout{1} = g.EstimatedRPMToWS;
                varargout{2} = g.OutputTimeVectorToWS;
            end
        else
            if (nArgOut == 1)
                varargout{1} = [];
            elseif (nArgOut == 2)
                varargout{1} = [];
                varargout{2} = [];
            end
        end
    else
        if isdeployed()
            % rpmtrack GUI unsupported.
            error(message('signal:rpmtrack:CompiledRpmtrack'));
        end
        signal.internal.rpmtrack.RPMTracker(Sx,Fx,Tx,Px,rpm,tout,opts);
    end
end

end

%==========================================================================
%                       parseAndValidateInputs
%==========================================================================
function opts = parseAndValidateInputs(x,nOutArgs,varargin)
% Parse and validate input parameters

% Validate the input signal
opts = validateInputSignal(x);

% Get value-only input argument and/or name-value pair input arguments
[voInArgs,nvpInArgs] = extractValueOnlyAndNVPInArgs(varargin);

% Parse and validate the value-only input arguments and decide if the GUI
% should be launched
opts = parseAndValidateValueOnlyInArgs(voInArgs,nOutArgs,opts);

% Parse the name-value pair input arguments
opts = parseNVPairInArgs(nvpInArgs,opts);

% Validate the name-value pair input arguments
opts = validateNVPairInArgs(opts);

% Sort, check the lower and upper bound limits of the points, if specified
opts = sortPointsAndCheckLowerUpperBounds(opts);

end

%==========================================================================
function opts = validateInputSignal(x)
% Validate the input signal and create the structure conveys the
% value-only, name-value pair input arguments. The structure also store
% some other useful parameters that facilitates processing.

% Check if the input signal is a vector of doubles, singles or timetable
validateattributes(x,{'double','single','timetable'},...
    {'real'},'rpmtrack','input signal');

% Create a structure (opts) to store the input arguments and some extra
% parameters to avoid re-computation
opts = struct('DataVector',[],...
              'DataLength',[],...
              'IsSingle',false,...
              'IsTimeTable',false,...
              'TimeVector',[],...
              'TimeFormat','',...
              'Fs',[],...
              'Order',[],...
              'Points',[],...
              'SortedPoints',[],...
              'Method', 'stft',...
              'FrequencyResolution',[],...
              'PowerPenalty',Inf,...
              'FrequencyPenalty',0,...
              'StartTime',[],...
              'EndTime',[],...
              'ComputeRPM',false,...
              'LaunchGUI',false,...
              'NumValueOnlyInputArguments',[],...
              'ValueOnlyInputArgumentNames',{cell(0)},...
              'NumOutputArguments',[]);

% Parse the input signal
if istimetable(x)
    % Check if the timetable contains only one single-channel data column
    if (size(x,2) ~= 1) || (size(x{:,:},2) ~= 1)
        error(message('signal:rpmtrack:InvalidTimeTableSize'));
    end
    % Check if all values in the single-channel timetable are numeric
    if ~isnumeric(x{:,:})
        error(message('signal:rpmtrack:InvalidTimeTableDataType'));
    end
    
    % Extract the time values, time format
    rowTimes = x.Properties.RowTimes;
    if isduration(rowTimes)
        tVec = seconds(rowTimes);
    else % datetime
        error(message('signal:rpmtrack:InvalidTimeTableTimeType'));
    end
    tVec = tVec(:);
    
    % Validate time values
    validateattributes(tVec,{'numeric'},...
        {'real','finite','nonnegative','increasing','nonnan','vector'},...
        'rpmtrack','Time values in timetable');
    
    % Validate if the time values in timetable are uniformly spaced, if
    % they are, set the sampling frequency to the inverse of the mean of
    % differences between consecutive time values.
    isTimeUniform = signal.internal.isUniformlySpaced(tVec);
    if isTimeUniform
        opts.TimeVector = tVec;
        opts.TimeFormat = rowTimes.Format;
        opts.Fs = 1/mean(diff(tVec));
    else
        error(message('signal:rpmtrack:NonUniformTimeValues'));
    end
    
    % Extract the data values
    data = x{:,:};
    
    opts.IsTimeTable = true;
else % signal input is a vector
    data = x;
    opts.TimeFormat = 's';
end

% Validate the input signal
validateattributes(data,{'double','single'},...
    {'real','finite','nonnan','nonsparse','nonempty','vector'},...
    'rpmtrack','input signal');
if isa(data,'single')
    opts.IsSingle = true;
end
% Convert to column vector
if isrow(data)
    data = data(:);
end
opts.DataVector = data;
opts.DataLength = size(data,1);

end

%==========================================================================
function [voInArgs,nvpInArgs] = extractValueOnlyAndNVPInArgs(inArgs)
% Extract the index of the first char/string argument and based on that
% extract the value-only input arguments (voInArgs) and/or name-value pair
% input arguments (nvpInArgs) from the input arguments.

% strIdx may contain the index of the first char/string input argument. If
% it is empty, then it means that there is no name-value pair input in the
% input argument cell.
strIdx = [];
for testIdx = 1:numel(inArgs)
    testValue = inArgs{testIdx};
    if (ischar(testValue) || (isstring(testValue) && isscalar(testValue)))
        strIdx = testIdx;
        break;
    end
end
if isempty(strIdx)
    voInArgs = inArgs;
    nvpInArgs = {};
else
    voInArgs = inArgs(1:strIdx-1);
    nvpInArgs = inArgs(strIdx:end);
end

end

%==========================================================================
function opts = parseAndValidateValueOnlyInArgs(inArgs,nOutArgs,opts)
% Parse and validate the value-only input arguments, namely, FS,ORDER, and
% P. Also, decide on either launching GUI or computing RPM based on whether
% both order and points are not specified or only points are not specified.

nInArgs = numel(inArgs);

% Number of value-only input arguments (use this to get name of value-only
% arguments for using it in GUI)
% Note that the input signal (x) is not in inArgs.
opts.NumValueOnlyInputArguments = numel(inArgs)+1; 

% Cache number of output arguments in opts for using it in GUI
opts.NumOutputArguments = nOutArgs;

% First parse the sampling frequency if the input signal is not a timetable
% because in this case the sampling frequency must be assigned.
if ~opts.IsTimeTable
    if (nInArgs == 0)
        error(message('signal:rpmtrack:TooFewValueOnlyInputs'));
    else
        % [...] = rpmtrack(X,FS,...);
        fs = inArgs{1};
        validateattributes(fs,{'numeric'}, ...
            {'real','finite','positive','nonnan','nonsparse','scalar'},...
            'rpmtrack','sampling frequency (FS)');
        % Set the sampling frequency and remove it from inArgs cell
        opts.Fs = double(fs);
        inArgs(1) = [];
        % Set time vector because it has not been set for the case where
        % the input signal is a vector.
        opts.TimeVector = (0:opts.DataLength-1)'/opts.Fs;
        % Make decision about LaunchGUI and ComputeRPM
        if isempty(inArgs)
            opts.LaunchGUI = true;
            opts.ComputeRPM = false;
            return;
        end
    end
else % timetable
    % Make decision about LaunchGUI and ComputeRPM
    if (nInArgs == 0)
        % [...] = rpmtrack(XT);
        opts.LaunchGUI = true;
        opts.ComputeRPM = false;
        return;
    end
end

% Parse and validate order 
% [...] = rpmtrack(...,ORDER,...);
order = inArgs{1};
validateattributes(order,{'numeric'},...
    {'real','finite','positive','nonnan','nonsparse','scalar'},...
    'rpmtrack','ORDER');
% Set the order and remove it from inArgs cell
opts.Order = double(order);
inArgs(1) = [];
% Make decision about LaunchGUI and ComputeRPM
if isempty(inArgs)
    opts.LaunchGUI = true;
    % Without specifying points, rpm can not be computed so ComputeRPM is
    % false
    opts.ComputeRPM = false;
    return;
end

% Parse and validate points 
% [...] = rpmtrack(...,P,...);
points = inArgs{1};
validateattributes(points,{'numeric'},...
    {'real','finite','nonnegative','nonnan','nonsparse','2d','ncols',2},...
    'rpmtrack','points (P)');
% Set the points and remove it from inArgs cell
opts.Points = double(points);
inArgs(1) = [];
% Make decision about LaunchGUI and ComputeRPM
if isempty(inArgs)
    % if there is no output, GUI will be launched
    opts.LaunchGUI = (nOutArgs == 0);
    % Required inputs are specified so ComputeRPM is true
    opts.ComputeRPM = true;
else
    error(message('signal:rpmtrack:TooManyValueOnlyInputs'));
end

end

%==========================================================================
function opts = sortPointsAndCheckLowerUpperBounds(opts)
% Sort, check the lower and upper bound limits of the time instances of the
% points. Time instances of the points must be within StartTime and
% EndTime. Also, align them with respect to time origin 0.
points = opts.Points;
if ~isempty(points)
    % Find unique points that have distinct time values and sort them
    % (unique function sorts the points)
    [uniqueSrtdPT,uniqueSrtdPTIdx] = unique(points(:,1));
    % Check if the points' time values are unique
    if (length(uniqueSrtdPT) ~= size(points,1))
        error(message('signal:rpmtrack:NotUniqueTimeValuesInPoints'));
    end
    % Check if the number of unique points (unique in time) is less than or
    % equal to the signal length
    if (numel(uniqueSrtdPT) > opts.DataLength)
        error(message('signal:rpmtrack:TooManyUniquePoints'));
    end
    % Check lower and upper bounds of time instances of points
    if ((uniqueSrtdPT(1) < opts.StartTime) ||...
            (uniqueSrtdPT(end) > opts.EndTime))
        error(message('signal:rpmtrack:InvalidPointsTime'));
    end
    % Check the frequency of the points to be lower than the Nyquist
    % frequency
    if any(points(uniqueSrtdPTIdx,2) >= opts.Fs/2)
        error(message('signal:rpmtrack:InvalidPointsFrequency'));
    end
    % Cache the sorted points
    opts.SortedPoints = points(uniqueSrtdPTIdx,:);
end

end

%==========================================================================
function opts = parseNVPairInArgs(inArgs,opts)
% Parse name-value pair input arguments

% Name-value pair inputs must come in pairs
if isodd(numel(inArgs))
    error(message('signal:rpmtrack:NameValuePairInputs'));
end

% Use strings for string support;
validStrings = ["Method","FrequencyResolution","PowerPenalty",...
    "FrequencyPenalty","StartTime","EndTime"];

% Parse the name-value pair input arguments
isDone = isempty(inArgs);
idx = 1;
while ~isDone
    if (ischar(inArgs{idx}) || ...
            (isstring(inArgs{idx}) && isscalar(inArgs{idx})))
        str = validatestring(inArgs{idx},validStrings);
        
        if (numel(inArgs) > idx)
            opts.(str) = inArgs{idx+1};
            inArgs([idx,idx+1]) = [];
            idx = idx-1;
        else
            error(message('signal:rpmtrack:NameValuePairInputs'));
        end
        idx = idx+1;
        isDone = (idx > numel(inArgs));
    else
        idx = idx+1;
        isDone = (numel(inArgs));
    end
end

end

%==========================================================================
function opts = validateNVPairInArgs(opts)
% Validate the name-value pair input arguments

% Validate Method parameter
validStrings = ["stft","fsst"];
opts.Method = validatestring(opts.Method,validStrings,...
    'rpmtrack','''Method''');

% Check the length of the input signal is greater than 15 when the Method
% is set to "stft" due to the constraint imposed by "orderwaveform"
% function. In the case where Method is set to "fsst", the signal input
% must have at least 10 samples.
if (strcmpi(opts.Method,'stft') && (opts.DataLength <= 15)) 
    error(message('signal:rpmtrack:InvalidInputLengthSTFT'));
elseif (strcmpi(opts.Method,'fsst') && (opts.DataLength <= 9))
    error(message('signal:rpmtrack:InvalidInputLengthFSST'));
end

% Get and validate FrequencyResolution parameter
opts = signal.internal.rpmtrack.getAndValidateFrequencyResolution(opts);

% Validate PowerPenalty parameter
validateattributes(opts.PowerPenalty,{'numeric'},...
    {'real','positive','nonnan','nonsparse','nonempty','scalar'},...
    'rpmtrack','PowerPenalty');
opts.PowerPenalty = double(opts.PowerPenalty);

% Validate FrequencyPenalty parameter
validateattributes(opts.FrequencyPenalty,{'numeric'},...
    {'real','nonnegative','finite','nonnan','nonsparse','nonempty','scalar'},...
    'rpmtrack','''FrequencyPenalty'' value');
opts.FrequencyPenalty = double(opts.FrequencyPenalty);

% Get StartTime and EndTime parameters
[opts.StartTime,opts.EndTime] = getAndValidateStartTimeAndEndTime(...
    opts.StartTime,opts.EndTime,opts.TimeVector);

end

%==========================================================================


%==========================================================================


%==========================================================================
function [st,et] = getAndValidateStartTimeAndEndTime(st,et,t)
% Get and validate StartTime and EndTime parameters
% Inputs:
%   st: StartTime
%   et: EndTime
%   t: TimeVector in the OPTS structure

% Set 'StartTime' or 'EndTime', if unspecified, to the default values.
if isempty(st)
    st = t(1);
end
if isempty(et)
    et = t(end);
end

% Check the type and being real and scalar first.
validateattributes(st,{'numeric','duration'},{'real','scalar'},...
    'rpmtrack','''StartTime'' value');
validateattributes(et,{'numeric','duration'},{'real','scalar'},...
    'rpmtrack','''EndTime'' value');

% Checking attributes like finite or nonnan is not supported for duration
% type using validateattributes.
if isduration(st)
    st = seconds(st);
end
if isduration(et)
    et = seconds(et);
end
st = double(st);
et = double(et);

validateattributes(st,{'double'},...
    {'real','finite','nonnegative','nonnan','scalar'},...
    'rpmtrack','''StartTime'' value');
validateattributes(et,{'double'},...
    {'real','finite','positive','nonnan','scalar'},...
    'rpmtrack','''EndTime'' value');

% Check the lower and upper bound of StartTime and EndTime. They must be
% within the time interval over which the signal is defined and StartTime
% must be less than EndTime.
if ((st < t(1)) || (st >= et) || (et > t(end)))
    error(message('signal:rpmtrack:InvalidStartEndTimeLimit'));
end

end

