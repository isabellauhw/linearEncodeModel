function opts = parseAndValidateInputs(x,response,inputCell)
%parseAndValidateInputs Validate inputs for filtering functions
%   parseAndValidateInputs goes through the input data, x, and verifies
%   correct input types. When input is a timetable it verifies that times
%   are regular, and extracts the effective sample rate from them.
%
%   parseAndValidateInputs goes through the inputCell and parses value only
%   and name-value pair inputs. It outputs a structure containing all the
%   parsed values. It sets defaults when needed, normalizes frequency
%   values, and linearizes ripple and attenuation values.

%   Copyright 2017 MathWorks, Inc.

%   This function is for internal use only. It may be removed.

opts = struct(...
    'SignalLength',[],...
    'IsSinglePrecision',false,...
    'IsRowInput',[],...
    'Response',response,...
    'FunctionName', response,...
    'IsTimetable', false,...
    'Wpass',[],...
    'Fs',[],...
    'IsNormalizedFreq',true,...
    'Steepness',[],...
    'TwPercentage',[],...
    'StopbandAttenuation',60,...    
    'StopbandAttenuationLinear',[],...
    'PassbandRipple',0.1,...
    'PassbandRippleLinear',[],... % PassbandRipple is an internal parameter
    'ImpulseResponse','auto'); 

% Default steepness changes depending on response
if any(strcmp(opts.Response,{'lowpass','highpass'}))
    opts.Steepness = 0.85;
else
    opts.Steepness = [0.85 0.85];
end

% Input type must be floating or timetable
if ~any(strcmpi(class(x),{'double','single','timetable'}))
    error(message('signal:internal:filteringfcns:InvalidInputDataType'));
end

if istimetable(x)
    if ~all(varfun(@validateDataAttributes,x,'OutputFormat','uniform'))
        error(message('signal:internal:filteringfcns:InvalidTimeTableType'));
    end
    
    % Timetable must contain homogeneous data type - i.e all values are
    % double or all are single precision    
    if ~all(varfun(@(x) isa(x,'double'),x,'OutputFormat','uniform')) && ~all(varfun(@(x) isa(x,'single'),x,'OutputFormat','uniform'))
        error(message('signal:internal:filteringfcns:InvalidNonHomogeneousDataType'));
    end
    opts.IsSinglePrecision = all(varfun(@(x) isa(x,'single'),x,'OutputFormat','uniform'));
    
    effectiveFs = validateTimeAttributes(x.Properties.RowTimes);    
    opts.IsTimetable = true;    
else
    if ~validateDataAttributes(x)
        error(message('signal:internal:filteringfcns:InvalidVectorOrMatrixType'));
    end    
    opts.IsSinglePrecision = isa(x,'single');
end
opts.IsRowInput = isrow(x);

if opts.IsRowInput
    opts.SignalLength = length(x);
else
    opts.SignalLength = size(x,1);
end

% Get value only inputs, and name-value pair inputs
[inputCellValueOnly, inputCellPvPairs] = groupInputs(inputCell);

% Extract nameless inputs
opts = extractNamelessInputs(inputCellValueOnly, opts);

% Get the name-value pairs
opts = extractNameValuePairs(inputCellPvPairs, opts);

if opts.IsTimetable
    if isempty(opts.Fs)
        opts.Fs = effectiveFs;
        opts.IsNormalizedFreq = false;
    else
        error(message('signal:internal:filteringfcns:SmapleRateAndTimetableInput'));
    end
else
    if isempty(opts.Fs)
        opts.Fs = 2;
    else
        opts.IsNormalizedFreq = false;
    end
end

opts = validateParameters(opts);

opts = computeTransitionWidthPercentage(opts);

%--------------------------------------------------------------------------
% Get value only inputs, and name-value pair inputs
function [inputCellValueOnly, inputCellPvPairs] = groupInputs(inputCell)

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

%--------------------------------------------------------------------------
function flag = validateDataAttributes(x)

flag = false;
if isfloat(x) && ismatrix(x) && all(isfinite(x(:))) && ~issparse(x)
    flag = true;
end

%--------------------------------------------------------------------------
function effectiveFs = validateTimeAttributes(tv)

if ~isduration(tv) || ~strcmp(tv.Format,'s')
    error(message('signal:internal:filteringfcns:InvalidRowTimes'));
end
if length(tv) ~= length(unique(tv))
    error(message('signal:internal:filteringfcns:InvalidRowTimes'));
end
if ~issorted(tv)
    error(message('signal:internal:filteringfcns:InvalidRowTimes'));
end
tv = seconds(tv);
err = max(abs(tv(:).'-linspace(tv(1),tv(end),numel(tv)))./max(abs(tv)));
isUniformlySampled = ~(err > 3*eps(class(tv)));

if ~isUniformlySampled
    error(message('signal:internal:filteringfcns:InvalidRowTimes'));
end

effectiveFs = 1/mean(diff(tv));

%--------------------------------------------------------------------------
function opts = extractNameValuePairs(inputCell, opts)
% Extract name-value pairs from inputs

validStrings = ["Steepness","StopbandAttenuation","ImpulseResponse"];

doneFlag = isempty(inputCell);
idx = 1;
while ~doneFlag
    if ischar(inputCell{idx}) || (isstring(inputCell{idx}) && isscalar(inputCell{idx}))
        try
            str = validatestring(inputCell{idx},validStrings);
        catch e
            error(message('signal:internal:filteringfcns:InvalidInputString'));
        end
        if numel(inputCell) > idx
            opts.(str) = inputCell{idx+1};
            inputCell([idx,idx+1]) = [];
            idx = idx - 1;
        else
            error(message('signal:internal:filteringfcns:PairNameValueInputs'));
        end
    end
    idx = idx + 1;
    doneFlag = (idx > numel(inputCell));
end
if ~isempty(inputCell)
    error(message('signal:internal:filteringfcns:PairNameValueInputs'));
end

%--------------------------------------------------------------------------
function opts = extractNamelessInputs(inputCell,opts)
% Extract nameless parameter inputs

numInputs = numel(inputCell);
if numInputs == 0
    error(message('signal:internal:filteringfcns:MustSpecifyWpass'));
end
if numInputs > 2
    error(message('signal:internal:filteringfcns:TooManyValueOnlyInputs'));
end

opts.Wpass = inputCell{1};
if numel(inputCell) > 1
    opts.Fs = inputCell{2};
end

%--------------------------------------------------------------------------
function opts = validateParameters(opts)

% Validate sample rate
if ~opts.IsNormalizedFreq
    validateattributes(opts.Fs,{'numeric'},...
        {'nonempty','real','finite','scalar','positive'},opts.FunctionName,'Fs');
    opts.Fs = double(opts.Fs);
end

% Validate passband frequency and normalize value
if opts.IsNormalizedFreq
    str = 'Wpass';
else
    str = 'Fpass';
end

if any(strcmp(opts.Response,{'lowpass','highpass'}))
    validateattributes(opts.Wpass,{'numeric'},...
        {'nonempty','real','finite','scalar','positive'},opts.FunctionName,str);
else
    validateattributes(opts.Wpass,{'numeric'},...
        {'nonempty','real','finite','vector','positive','increasing','numel',2},opts.FunctionName,str);
end
opts.Wpass = double(opts.Wpass);

if opts.IsNormalizedFreq && any(opts.Wpass >=1)
    % Do not allow values outside of Nyquist range if working with
    % normalized frequencies.
    error(message('signal:internal:filteringfcns:InvalidNormalizedWpassValue'));
end

% Compute normalized passband frequency
opts.WpassNormalized = opts.Wpass/(opts.Fs/2);

% Validate stopband attenuation
validateattributes(opts.StopbandAttenuation,{'numeric'},...
    {'nonempty','real','finite','scalar','>=',10},opts.FunctionName,'StopbandAttenuation');
opts.StopbandAttenuation = double(opts.StopbandAttenuation);

% Convert ripple and attenuation to linear scale
opts.StopbandAttenuationLinear = convertmagunits(opts.StopbandAttenuation, 'db', 'linear', 'stop');
opts.PassbandRippleLinear = convertmagunits(opts.PassbandRipple, 'db', 'linear', 'pass');

% Validate Steepness value
if any(strcmp(opts.Response,{'lowpass','highpass'}))
    validateattributes(opts.Steepness,{'numeric'},...
        {'nonempty','real','finite','scalar','>=',0.5,'<',1}, opts.FunctionName,'Steepness');
else
    validateattributes(opts.Steepness,{'numeric'},...
        {'nonempty','real','finite'}, opts.FunctionName,'Steepness');
    
    if ~isvector(opts.Steepness) || numel(opts.Steepness) > 2 || any(opts.Steepness < 0.5) || any(opts.Steepness > 1) 
        error(message('signal:internal:filteringfcns:InvalidSteepness'));
    end    
end
opts.Steepness = double(opts.Steepness);

% Validate impulse response value
opts.ImpulseResponse = validatestring(opts.ImpulseResponse ,["auto","fir","iir"]);

%--------------------------------------------------------------------------
function opts = computeTransitionWidthPercentage(opts)

% Convert steepness to TwPercentage (line going from 0.5 at x = 0.5 to 0.01
% at x = 1)
% 1% when steepness = 1
opts.TwPercentage = -0.98*opts.Steepness + 0.99;

% 0.5% when steepness = 1
% opts.TwPercentage = -0.99*opts.Steepness + 0.995;




