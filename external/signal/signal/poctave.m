function varargout = poctave(x,varargin)
%POCTAVE Generate octave spectrum.
%   P = POCTAVE(X,Fs) computes the octave spectrum, P, of X, as the average
%   power over octave bands defined by the ANSI S1.11 standard. Fs is a
%   positive numeric scalar corresponding to the sample rate of X in units
%   of hertz. Fs must be at least 7 Hz. X can be a vector or matrix
%   containing real double or single precision data. If X is a matrix, then
%   each column of P contains the octave spectrum of the corresponding
%   column of X. The parameter Fs provides time information to the input
%   and only applies when X is a vector or a matrix.
%
%   P = POCTAVE(XT) computes the octave spectrum of the signal contained in
%   the timetable XT. The time values in XT must be strictly increasing,
%   finite, and uniformly spaced. XT must contain real double or single
%   precision data. When the input has multiple channels - i.e., when XT
%   has multiple variables each containing a vector, or a single matrix
%   variable - the function analyzes each channel independently and stores
%   the results in the corresponding columns of P.
% 
%   P = POCTAVE(...,'BandsPerOctave',B) specifies the number of fractional
%   bands per octave as one of 1, 3/2, 2, 3, 6, 12, 24, 48, or 96. In a
%   fractional-octave band, the upper edge frequency is the lower edge
%   frequency times 2^(1/B). If B is not specified, it defaults to 1.
%
%   P = POCTAVE(...,'FilterOrder',N) specifies the order of the bandpass
%   octave filters used to compute band powers. N is a positive numeric
%   even integer. If N is not specified, it defaults to 6.
% 
%   P = POCTAVE(...,'FrequencyLimits',FLIMS) specifies the limits of the
%   desired frequency band over which POCTAVE computes the octave spectrum.
%   FLIMS is an increasing 1-by-2 positive numeric vector expressed in Hz.
%   The specified limits must lie within the Nyquist range. The lower value
%   FLIMS(1) must be at least 3. The upper value FLIMS(2) must be smaller
%   than or equal to the Nyquist frequency. To ensure a stable filter
%   design, the actual minimum achievable frequency limit increases to
%   3*Fs/48e3 if the sample rate exceeds 48 kHz. If 'FrequencyLimits' is
%   not specified, POCTAVE uses the interval [fmin,Fs/2) where fmin is
%   equal to max(3,3*Fs/48e3).
% 
%   P = POCTAVE(...,'Weighting',FWeight) specifies the frequency weighting
%   performed by the function. Fweight can be a numeric matrix, a cell
%   array, a digitalFilter object, or a character array. Fweight can be an
%   SOS matrix of size K-by-6, with each row corresponding to the
%   coefficients of a second-order filter. The number of sections, K, must
%   be greater than or equal to 2. When FWeight is a numeric vector, it
%   represents the coefficients of an FIR filter. When FWeight is a cell
%   array of length 2, it contains the numerator and denominator polynomial
%   coefficients of an IIR filter, in that order. When specified as a
%   character array, Fweight is one of the following:
% 
%       'A' - POCTAVE performs A-weighting on the input. 
% 
%       'C' - POCTAVE performs C-weighting on the input.
% 
%       'none' - POCTAVE does not perform frequency weighting on the input.
% 
%   When not specified, FWeight defaults to 'none'.
% 
%   P = POCTAVE(Pxx,Fs,F,...,'psd') performs octave smoothing. The power
%   spectral density Pxx is converted to a '1/B' octave power spectrum. Pxx
%   can be a vector or matrix containing real, positive, single or double
%   precision data in linear units (i.e. not in dB). If Pxx is a matrix,
%   then each column of P contains the octave spectrum of the corresponding
%   column of Pxx. The frequencies in F correspond to the PSD estimates in
%   Pxx. F must be strictly increasing, finite, and uniformly spaced and
%   specified in the units of Hz. The 'psd' option indicates that the input
%   is a PSD estimate and not a time series. Frequency weighting is not
%   supported for octave smoothing.
% 
%   [P,CF] = POCTAVE(...) returns a vector with the center frequencies of
%   the octave bands over which the octave spectrum is estimated. CF has
%   units of hertz (Hz).
%    
%   POCTAVE(...) with no output arguments plots the octave spectrum in the
%   current figure.
%
%     % EXAMPLE 1:
%         % Construct a unit-variance white noise as an input signal
%         % sampled at 44.1 kHz. To detemine the octave spectrum, choose a
%         % filter order of 8. Visualize the octave spectrum between 120 Hz
%         % and 20 kHz
% 
%         Fs = 44.1E3;
%         xInp = rand(1,2^16);
%         poctave(xInp,Fs,'FrequencyLimits',[120 20E3],'FilterOrder',8);
% 
%     % EXAMPLE 2:
%         % Recompute the octave spectrum of the same signal, but this
%         % time, use a C-Weighting filter. Visualize the spectrum.
% 
%         poctave(xInp,Fs,'FrequencyLimits',[120 20E3],'FilterOrder',8,...
%             'Weighting','C');
%        
%   See also PSPECTRUM

%   Copyright 2017 MathWorks, Inc.
% 

narginchk(1,12);
nargoutchk(0,2);

varargout = cell(nargout,1);
opts = parseAndValidateInputs(x,varargin);

% Call the filtering functions
switch opts.Type
    case 'octaveSpectrum'
        [P,CF] = octaveSpectrum(opts);
    case 'octaveSmoothing'
        [P,CF] = octaveSmoothing(opts);
end

if opts.IsSingle
    P = single(P);
    CF = single(CF);
end

switch nargout 
    case 0
        localplot(P,CF,opts);
    case 1
        varargout{1} = P;
    case 2
        varargout{1} = P;
        varargout{2} = CF;
end

%------------------------------------------------------------------------
function opts = parseAndValidateInputs(x,inputCell)
% Parse and validate input parameters

if ~any(strcmpi(class(x),{'double','single','timetable'}))
    error(message('signal:poctave:InvalidInputDataType'));
end

opts = struct(...
    'Data',[],...
    'DataLength',[],...
    'NumChannels',[],...
    'TimeUnits','',...
    'IsSingle',false,...
    'EffectiveFs',[],...
    'FrequencyLimits',[],...
    'BandsPerOctave',1,...
    'FilterOrder',6,...
    'Weighting','none',...
    'Type','octaveSpectrum',...            
    'FrequencyVector',[]);

matches = find(strcmpi('psd',inputCell));
inputCell(matches) = [];

if any(matches)
    opts.Type = 'octaveSmoothing';
end

if (strcmp(opts.Type,'octaveSpectrum'))
        if istimetable(x)
            if ~all(varfun(@isnumeric,x,'OutputFormat','uniform')) ||...
                    ~all(varfun(@ismatrix,x,'OutputFormat','uniform'))    
                error(message('signal:poctave:InvalidTimeTableType'));
            end
            % Check if all timetable variables are either single or double
            if ~all(varfun(@(x) isa(x,'double'),x,'OutputFormat','uniform'))...
                    && ~all(varfun(@(x) isa(x,'single'),x,'OutputFormat','uniform'))
                error(message('signal:poctave:NonHomogeneousDataType'));
            end
            if size(x,2) > 1 && ~all(varfun(@isvector,x,'OutputFormat','Uniform'))
                error(message('signal:poctave:InvalidTimeTableType'));
            end
            
            rowTimes = x.Properties.RowTimes;
            
            if isduration(rowTimes)
                ttTimeVector = seconds(rowTimes);
                opts.TimeUnits = rowTimes.Format;
            else
                d = rowTimes-rowTimes(1);
                ttTimeVector = seconds(d);
                opts.TimeUnits = rowTimes.Format;
            end
            
            data = x{:,:};
            
            validateattributes(data,{'single','double'},...
                {'nonsparse','finite','nonnan','2d','real'},'poctave','timetable data');
        else
            validateattributes(x,{'single','double'},...
                {'nonsparse','finite','nonnan','2d','real'},'poctave','X');
            
            if isrow(x)
                data = x(:);
            else
                data = x;
            end
        end

elseif (strcmp(opts.Type,'octaveSmoothing'))
        validateattributes(x,{'single','double'},...
            {'nonsparse','finite','nonnan','2d','real','positive'},'poctave','Pxx');
        if isrow(x)
            data = x(:);
        else
            data = x;
        end
       
end

[opts.DataLength, opts.NumChannels] = size(data);
if (opts.DataLength < 2)
    error(message('signal:poctave:InvalidInputLength'));
end

% Find index where inputCell has the first char
strIdx = [];
for testIdx = 1:numel(inputCell)
    testValue = inputCell{testIdx};
    if ischar(testValue) || (isstring(testValue) && isscalar(testValue))
        strIdx = testIdx;
        break;
    end
end
if isempty(strIdx)
    inputCellPvPairs = {};
    inputCellValueOnly = inputCell;
else
    inputCellPvPairs = inputCell(strIdx:end);
    inputCellValueOnly = inputCell(1:strIdx-1);
end
%-------------------------------------------------------------------------
% Get the type string and the name-value pairs
opts = extractTypeAndNameValuePairs(inputCellPvPairs, opts);

%-------------------------------------------------------------------------
% Extract Sample Rate, and Frequency range inputs
opts = extractNamelessInputs(inputCellValueOnly, opts);

%-------------------------------------------------------------------------
% Validate time inputs for time domain analysis or frequency inputs for
% octave smoothing
% Specify a minimum Sample Rate of 7 Hz.
minFs = 7;
if (strcmp(opts.Type,'octaveSpectrum'))

    if istimetable(x)
        if (~isempty(opts.EffectiveFs))
            error(message('signal:poctave:SampleRateAndTimetableInput'));
        end
        opts.EffectiveFs = validateTimeValues(opts.DataLength,ttTimeVector);
    else
        if (~isempty(opts.FrequencyVector))
            error(message('signal:poctave:TooManyValueOnlyInputs'));
        end
        
        if (~isempty(opts.EffectiveFs))
            validateattributes(opts.EffectiveFs, {'numeric'},{'scalar',...
                'real','finite','positive'},'poctave','Sample rate');
            if (opts.EffectiveFs < minFs)
                error(message('signal:poctave:InvalidSampleRate'))
            end
            opts.EffectiveFs = cast(opts.EffectiveFs,'double');
        else
            error(message('signal:poctave:SampleRateRequired'));
        end
    end
      
elseif (strcmp(opts.Type,'octaveSmoothing'))
        % Extract Sample Rate
        validateattributes(opts.EffectiveFs, {'numeric'},...
            {'scalar','real','finite','positive'},'poctave','Sample rate');
        if (opts.EffectiveFs < minFs)
            error(message('signal:poctave:InvalidSampleRate'))
        end
        opts.EffectiveFs = cast(opts.EffectiveFs,'double');
        
        % Extract Frequency vector
        validateattributes(opts.FrequencyVector,{'numeric'},...
            {'real','finite','nonsparse','vector','increasing',...
                'numel',opts.DataLength},'poctave', 'F');
        opts.FrequencyVector = cast(opts.FrequencyVector,'double');
        
        % Check for uniformity of frequency vector
        [~, isIrregular] =...
            signal.internal.utilities.getEffectiveFs(opts.FrequencyVector);
        if isIrregular
            error(message('signal:poctave:FrequencyValuesIrregular'));
        end
        
        % Check for Weighting inputs and error out if true
        if ~strcmpi(opts.Weighting,'none')
            error(message('signal:poctave:WeightingAndOctaveSmoothing'));
        end
end

opts.Data = data;
opts.IsSingle = isa(data,'single');

%---------------------------------
% FrequencyLimits 
AllowedFreqRange = [3, opts.EffectiveFs/2];

if ~isempty(opts.FrequencyLimits)
    validateattributes(opts.FrequencyLimits,{'numeric'},...
        {'row','numel',2,'increasing','finite','real'},'poctave','FrequencyLimits');
    opts.FrequencyLimits = cast(opts.FrequencyLimits,'double');
    
    % Input frequency range must be within allowable range
    if (opts.FrequencyLimits(2) > AllowedFreqRange(2)) || ...
            (opts.FrequencyLimits(1) < AllowedFreqRange(1))
        error(message('signal:poctave:InvalidFrequencyBand',...
            num2str(AllowedFreqRange(1)),num2str(AllowedFreqRange(2))));
    end
else
    opts.FrequencyLimits = AllowedFreqRange;
end

%----------------------------------
% BandsPerOctave
validBArray = [1 3/2 2 3 6 12 24 48 96];
validateattributes(opts.BandsPerOctave,{'numeric'},...
    {'nonempty','scalar'},'poctave','BandsPerOctave');
opts.BandsPerOctave = cast(opts.BandsPerOctave,'double');
if ~any(opts.BandsPerOctave == validBArray)
    error(message('signal:poctave:InvalidBandsPerOctave'));
end

%----------------------------------
% FilterOrder
validateattributes(opts.FilterOrder,{'numeric'},...
    {'nonempty','scalar','integer','positive','even'},'poctave','FilterOrder');
opts.FilterOrder = cast(opts.FilterOrder,'like',opts.Data);

%----------------------------------
% Weighting
validateattributes(opts.Weighting,{'numeric','cell',...
    'string','digitalFilter','char'},{'nonempty'},'poctave','Weighting');

% Check character inputs
if (ischar(opts.Weighting) || isstring(opts.Weighting))
    if size(opts.Weighting,1)>1
        error(message('signal:poctave:InvalidWeightingChar'));
    end
    if any(strcmpi(opts.Weighting,["A";"C"]))
        % Scaling is embedded into sos matrix when one output argument is
        % used in zp2sos.
        opts.Weighting = signal.internal.octave.getWeightingFilter...
            (opts.Weighting,opts.EffectiveFs);
    elseif strcmpi(opts.Weighting,'none')
        opts.Weighting = [];
    else
        error(message('signal:poctave:InvalidWeightingChar'));
    end
    
% Cell inputs
elseif (iscell(opts.Weighting))
    if(numel(opts.Weighting)==2)
        % Validate attributes for numerator of IIR Filter
        validateattributes(opts.Weighting{1},{'single','double'},...
            {'nonsparse','finite','nonnan','vector','real'},'poctave','FWeight{1}');
        opts.Weighting{1} = cast(opts.Weighting{1},'like',opts.Data);
        
        % Validate attributes for denominator of IIR Filter
        validateattributes(opts.Weighting{2},{'single','double'},...
            {'nonsparse','finite','nonnan','vector','real'},'poctave','FWeight{2}');
        opts.Weighting{2} = cast(opts.Weighting{2},'like',opts.Data);
    else
        error(message('signal:poctave:InvalidIIRWeight'));
    end
    
% Matrix inputs
elseif (isnumeric(opts.Weighting))
    if isvector(opts.Weighting)
        % Validate attributes for FIR Filter
        validateattributes(opts.Weighting,{'single','double'},...
            {'nonsparse','finite','nonnan','vector','real'},'poctave','FWeight');
        opts.Weighting = cast(opts.Weighting,'like',opts.Data);
        opts.Weighting = num2cell(opts.Weighting,[1 2]);
        opts.Weighting{2} = 1;
    else
        % Validate attributes for an SOS matrix
        validateattributes(opts.Weighting,{'single','double'},...
            {'nonsparse','finite','nonnan','real','2d','ncols',6},'poctave','FWeight');
        opts.Weighting = cast(opts.Weighting,'like',opts.Data);
    end
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function opts = extractTypeAndNameValuePairs(inputCell, opts)
% Extract string parameters and name-value pairs from inputs
validStrings = ["BandsPerOctave","FilterOrder","FrequencyLimits","Weighting"];

doneFlag = isempty(inputCell);
idx = 1;
while ~doneFlag
    if ischar(inputCell{idx}) || (isstring(inputCell{idx}) && isscalar(inputCell{idx}))
        try
            str = validatestring(inputCell{idx},validStrings);
        catch e
            if strcmp(e.identifier,'MATLAB:unrecognizedStringChoice')
                error(message('signal:poctave:InvalidInputString'))
            else
                error(message(e.identifier))
            end
        end

        if numel(inputCell) > idx
            if isempty(inputCell{idx+1})
                error(message('signal:poctave:EmptyValueInput'));
            end
            opts.(str) = inputCell{idx+1};
            inputCell([idx,idx+1]) = [];
            idx = idx - 1;
        else
            error(message('signal:poctave:PairNameValueInputs'));
        end

        idx = idx + 1;
        doneFlag = (idx > numel(inputCell));
    else
        idx = idx + 1;
        doneFlag = (idx > numel(inputCell));
    end
end
if ~isempty(inputCell)
    error(message('signal:poctave:PairNameValueInputs'));
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function opts = extractNamelessInputs(inputCell,opts)
% Extract nameless parameter inputs

if ~any(cellfun(@isempty, inputCell)) 
   switch numel(inputCell)
       case 0
           return;
       case 1
           if strcmp(opts.Type,'octaveSmoothing')
               error(message('signal:poctave:SampleRateFreqVector'));
           end
           opts.EffectiveFs = inputCell{1};
       case 2
           opts.EffectiveFs = inputCell{1};
           opts.FrequencyVector = inputCell{2};
       otherwise
           error(message('signal:poctave:TooManyValueOnlyInputs'));
   end
else
    error(message('signal:poctave:EmptyValueInput'));
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function effectiveFs = validateTimeValues(dataLength,tv)
% Check regularity of time vector intervals.
validateattributes(tv,{'single','double'},{'real','finite',...
    'nonsparse','vector','increasing','numel',dataLength},'poctave','XT');

tv = double(tv);

[effectiveFs, isIrregular] = signal.internal.utilities.getEffectiveFs(tv);

if isIrregular
    error(message('signal:poctave:TimeValuesIrregular'));
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [P,CF] = octaveSmoothing(opts)
% Perform octave smoothing.

FLims = opts.FrequencyLimits;
b = opts.BandsPerOctave;
Fs = opts.EffectiveFs;

[bandFreq, CF] = signal.internal.octave.computeOctaveBands(FLims, b);

% Truncate last band if upper band-edge is more than Nyqist frequency
bandFreq(end) = min(bandFreq(end),Fs/2);    
P = zeros(length(CF),opts.NumChannels);

for bandIdx = 1:length(CF)
    P(bandIdx,:) = bandpower(opts.Data, opts.FrequencyVector,...
        [bandFreq(bandIdx,1) bandFreq(bandIdx,2)],'psd');
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [P,CF] = octaveSpectrum(opts)
% Perform octave spectrum.

% Perform Weighting
if ~isempty(opts.Weighting)
    % FIR and IIR filters
    if isa(opts.Weighting,'cell')
        opts.Data = filter(opts.Weighting{1},opts.Weighting{2},opts.Data);
    % A/C weighting converted to sos sections, or user defined sos matrix
    elseif ismatrix(opts.Weighting) && size(opts.Weighting,2)==6
        opts.Data = sosfilt(opts.Weighting,opts.Data);
    % digitalFilter object
    else
        if numel(opts.Weighting) == 1
            opts.Data = filter(opts.Weighting,opts.Data);
        else
            error(message('signal:poctave:InvalidDigitalFilterSize'));
        end
    end
end

N = opts.FilterOrder;
FLims = opts.FrequencyLimits;
b = opts.BandsPerOctave;
Fs = opts.EffectiveFs;

[bankFilters, CF] = signal.internal.octave.designOctaveBank(N, FLims, b, Fs);
if ~isempty(bankFilters)
    P = signal.internal.octave.analyzeOctaveBank(opts.Data, bankFilters);
else
    error(message('signal:poctave:InsufficientBandwidth'))
end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function localplot(P,CF,opts)
newplot;
PdB = 10*log10(P);

% Determine engineering units
[~, scaleFactor, unitsStr] = signal.internal.utilities.getFrequencyEngUnits(CF(end));

% Plotting
switch opts.NumChannels
    case 1
        centerFreqLabels = categorical(scaleFactor.*CF);
        pObject = bar(centerFreqLabels, PdB);
        % Set the base value of the bar plot to 3 dB below the minimum
        % octave band-power value. Set ylim such that it covers a height
        % that is 10% more than the tallest bar.
        pObject(1).BaseValue = min(PdB) - 3;
        minHeight = pObject(1).BaseValue;
    otherwise
        % To center the xticks, generate a stair plot of octave spectrum
        % against the lower edge frequencies of octave bands.
        CFLabels = scaleFactor.*CF;
        b = opts.BandsPerOctave;
        lowerEdgeFreqVector = [CF.*2^(-1/(2*b)); CF(end)*2^(1/(2*b))];
        plotPdB = [PdB; PdB(end,:)];
        stairs(scaleFactor.*lowerEdgeFreqVector, plotPdB);
        multiChannelAxes = gca;
        multiChannelAxes.XScale = 'log';
        multiChannelAxes.XTick = CFLabels;
        multiChannelAxes.XAxis.MinorTick = 'off';
        axis tight
        grid minor
        minHeight = min(PdB(:)) - 0.1*(max(PdB(:)) - min(PdB(:)));
end

% Resolve the number of x-ticks to maxNumTicks.
maxNumTicks = 10;
if numel(CF)>maxNumTicks
    spc = ceil(numel(CF)/maxNumTicks);
    % If GUI is a bar plot, then xTicks should be a categorical array.
    if opts.NumChannels == 1 
        xticks(centerFreqLabels(1:spc:end))
    else
        xticks(CFLabels(1:spc:end))
    end
end

maxHeight = max(PdB(:)) + 0.1*(max(PdB(:)) - minHeight);
ylim([minHeight maxHeight])

xlabel([getString(message('signal:poctave:Frequency')) '(' unitsStr ')'])
ylabel(getString(message('signal:poctave:yAxisLabel')))

switch opts.BandsPerOctave
    case 1
        if strcmp(opts.Type,'octaveSpectrum')
            title(getString(message('signal:poctave:titleOctaveSpectrum')))
        else
            title(getString(message('signal:poctave:titleOctaveSmoothing')))
        end
    case 3/2
        if strcmp(opts.Type,'octaveSpectrum')
            title(getString(message('signal:poctave:titleTwoThirdOctaveSpectrum')))
        else
            title(getString(message('signal:poctave:titleTwoThirdOctaveSmoothing')))
        end
    otherwise
        if strcmp(opts.Type,'octaveSpectrum')
            title(getString(message(...
                'signal:poctave:titleFractionalOctaveSpectrum',num2str(opts.BandsPerOctave))))
        else
            title(getString(message(...
                'signal:poctave:titleFractionalOctaveSmoothing',num2str(opts.BandsPerOctave))))
        end
end