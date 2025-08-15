function [x,M,isreal_x,y,Ly,win,winName,winParam,noverlap,k,L,options] = ...
    welchparse(x1,esttype,varargin)
%WELCHPARSE   Parser for the PWELCH & SPECTROGRAM functions
%
% Outputs:
% X        - First input signal (used when esttype = MS & PSD)
% M        - An integer containing the length of the data to be segmented
% isreal_x - Boolean for input complexity
% Y        - Second input signal (used when esttype = CPSD, TFE, MSCOHERE)
% Ly       - Length of second input signal (used when esttype = CPSD, TFE,
%          MSCOHERE)
% WIN - A scalar or vector containing the length of the window or the
%       window respectively (Note that the length of the window determines
%       the length of the segments)
% WINNAME  - String with the window name.
% WINPARAM - Window parameter.
% NOVERLAP - An integer containing the number of samples to overlap (may
%          be empty)
% K        - Number of segments
% OPTIONS  - A structure with the following fields:
%   OPTIONS.nfft  - number of freq. points at which the psd is estimated
%   OPTIONS.Fs    - sampling freq. if any
%   OPTIONS.range - 'onesided' or 'twosided' psd

%   Copyright 1988-2019 The MathWorks, Inc.

%#codegen

% Parse input arguments
[x,M,isreal_x,y,Ly,win1,winName,winParam,noverlap1,opts,isMimo] = ...
    parse_inputs(x1,esttype,varargin{:});

% Obtain the necessary information to segment x and y
[L,noverlap,win] = segment_info(M,win1,noverlap1);

% Parse optional args nfft, fs, and spectrumType
options = welch_options(isreal_x,L,isMimo,esttype,opts{:});

% Check unsupported string options
if strcmpi(esttype,'ms') || strcmpi(esttype,'power') || strcmpi(esttype,'psd')
    coder.internal.errorIf(options.MIMO,'signal:welchparse:PWELCHStringSupport')
end

if strcmpi(esttype,'cpsd') || strcmpi(esttype,'mscohere')
    if ~isnan(options.conflevel)
        coder.internal.error('signal:welchparse:UnrecognizedStringCpsdMscohere','ConfidenceLevel');
    end
    if options.maxhold
        coder.internal.error('signal:welchparse:UnrecognizedStringCpsdMscohere','maxhold');
    end   
    if options.minhold
        coder.internal.error('signal:welchparse:UnrecognizedStringCpsdMscohere','minhold');
    end   
end

% Compute the number of segments
k = (M-noverlap)./(L-noverlap);

% Uncomment the following line to produce a warning each time the data
% segmentation does not produce an integer number of segments.
%if fix(k) ~= k),
%   warning('signal:welchparse:MustBeInteger','The number of segments is not an integer, truncating data.');
%end

k = fix(k);

% Error out for tfestimate if the number of segments is less
% than the number of columns of x and the MIMO parameter was specified.
if k < size(x,2) && options.MIMO && ...
    any(strcmpi(esttype,{'tfe','tfeh2'})) 
    coder.internal.error('signal:welch:TFESegmentMIMO')
end

% Error out for mscohere if the number of segments is less than one more
% than the number of columns of x. For SISO case, we continue to return 1's
% for the undefined case with one segment. For MIMO, since we already have
% a lower limit on segment size, we set this lower limit to avoid the
% undefined case.
if (k < size(x,2)+1 && options.MIMO) && ...
    strcmpi(esttype,'mscohere')
    coder.internal.error('signal:welch:MSCOHERESegmentMIMO')
end
end

%-----------------------------------------------------------------------------------------------
function [x,Lx,isreal_x,y,Ly,win,winName,winParam,noverlap,opts,isMimo] = ...
    parse_inputs(x1,esttype,varargin)
% Parse the inputs to the welch function.

% Assign defaults in case of early return.
is2sig   = false;

% Determine if one or two signal vectors was specified.
if iscell(x1)
    if numel(x1) > 1 % Cell array.
        y1 = x1{2};
        validateattributes(y1,{'single','double'}, {'finite','nonnan'},'pwelch','x')
        is2sig = true;
    else
        y1=[];
    end
    x2 = x1{1};
else
    if ~any(strcmpi(esttype,{'psd','power','ms'}))
        coder.internal.error('signal:welchparse:NeedCellArray');
    end
    x2=x1;
    y1=[];
end

validateattributes(x2,{'single','double'}, {'finite','nonnan'},'pwelch','x')
if isvector(x2)
  x = reshape(x2,numel(x2),1);
else
   x = x2;
end
Lx = size(x,1);

isreal_x = isreal(x);


% Parse window and overlap, and cache remaining inputs.
lenargin = length(varargin);
if lenargin >= 1
    win = varargin{1};
    if lenargin >= 2
        if isempty(coder.target)
            noverlap = varargin{2};
        else
            noverlap = signal.internal.sigcasttofloat(varargin{2},'double','welchparse','noverlap',....
                'allownumeric');
        end
        % Cache optional args nfft, fs, and spectrumType.
        if lenargin >= 3
            opts = {varargin{3:end}};
        else
            opts = {};
        end
    else
        noverlap = [];
        opts = {};
    end
else
    win = [];
    opts = {};
    noverlap = [];
end

isMimo = false;

% Parse 2nd input signal vector.
if is2sig
    if isvector(y1)
      y = reshape(y1,numel(y1),1);
    else
      y = y1;
    end
    isreal_x = isreal(y) && isreal_x;
    Ly = size(y,1);
    coder.internal.errorIf(size(x,1) ~= size(y,1),'signal:welchparse:MismatchedLength');
    % If the H2 tfestimate is selected and the number of input and output
    % channels is not equal, error out under two conditions:
    % 1. The user specified MIMO
    % 2. The neither x nor y is a vector. If either is a vector, it will be
    % expanded to match the size of the other channel in the SISO case.
    % This is a fundamental limitation of the MIMO estimator, because the
    % cross-spectral matrix between x and y must be square.
    if strcmp(esttype,'tfeh2') && size(x,2) ~= size(y,2) && ...
        (any(strcmpi(opts,'mimo')) ||  size(x,2)~=1 && size(y,2) ~=1)
       coder.internal.error('signal:welchparse:MismatchedChannelH2');
    end
    
    % If the number of channels of X and Y do not match, neither is a
    % vector, and 'mimo' was not specified, use 'mimo'.
    if size(x,2)~=1 && size(y,2) ~=1 && size(x,2) ~= size(y,2) && ~any(strcmpi(opts,'mimo'))
            isMimo = true;
    end
else
    Ly= 0;
    y=y1;
end

coder.internal.errorIf(isscalar(win) && win(1,1) == 1, 'signal:welchparse:WindowMustBeMoreThanOneSampleLong');

if isempty(win) || isscalar(win)
    winName = 'hamming';
    winParam = 'symmetric';
else
    % Defaults
    winName  = 'User Defined';
    winParam = '';
end

end

%-----------------------------------------------------------------------------------------------
function [L,noverlap,win] = segment_info(M,win1,noverlap1)
%SEGMENT_INFO   Determine the information necessary to segment the input data.
%
%   Inputs:
%      M        - An integer containing the length of the data to be segmented
%      WIN      - A scalar or vector containing the length of the window or the window respectively
%                 (Note that the length of the window determines the length of the segments)
%      NOVERLAP - An integer containing the number of samples to overlap (may be empty)
%
%   Outputs:
%      L        - An integer containing the length of the segments
%      NOVERLAP - An integer containing the number of samples to overlap
%      WIN      - A vector containing the window to be applied to each section
%
%
%   The key to this function is the following equation:
%
%      K = (M-NOVERLAP)/(L-NOVERLAP)
%
%   where
%
%      K        - Number of segments
%      M        - Length of the input data X
%      NOVERLAP - Desired overlap
%      L        - Length of the segments
%
%   The segmentation of X is based on the fact that we always know M and two of the set
%   {K,NOVERLAP,L}, hence determining the unknown quantity is trivial from the above
%   formula.

% Check that noverlap is a scalar
coder.internal.errorIf(any(size(noverlap1) > 1),'signal:welchparse:invalidNoverlap');

L = 0;
if ~coder.target('MATLAB') && isa(win1,'single')
    % in codegen, error out if window is variable sized and single precision
    coder.internal.assert(coder.internal.isConst(size(win1)),'signal:welchparse:varSizeWindowMustbeDouble');
end
if isempty(win1)
    % Use the closest to 8 sections, determine their length
    if isempty(noverlap1)
        % Use 50% overlap
        L = fix(M./4.5);
        noverlap = fix(0.5.*L);
        coder.internal.errorIf(L<2,'signal:welchparse:NotEnoughSamplesForDefaultSettings');
    else
        L = fix((M+7.*noverlap1(1))./8);
        noverlap = noverlap1(1);
    end
    % Use a default window
    win = hamming(L);

else
    Lenwin = length(win1);
    coder.internal.errorIf(~any(size(win1) <= 1) || ischar(win1),'signal:welchparse:MustBeScalarOrVector', 'WINDOW');
    
    % Determine the window and its length (equal to the length of the segments)
    if Lenwin > 1
        % WIN is a vector
        L = length(win1);
        win = win1;
    elseif Lenwin == 1
        win = hamming(win1(1,1));
        L = length(win);
    else
        win = [];
    end
    
    if isempty(noverlap1)
        % Use 50% overlap
        noverlap = fix(0.5.*L);
    else
        noverlap = noverlap1(1);
    end
end

if ~isempty(L)
    % Do some argument validation
    coder.internal.errorIf(L > M,'signal:welchparse:invalidSegmentLength');
    coder.internal.errorIf(noverlap >= L,'signal:welchparse:NoverlapTooBig');
end

end

%------------------------------------------------------------------------------
function options1 = welch_options(isreal_x,N,isMimo,esttype,varargin)
%WELCH_OPTIONS   Parse the optional inputs to the PWELCH function.
%   WELCH_OPTIONS returns a structure, OPTIONS, with following fields:
%
%   options.nfft         - number of freq. points at which the psd is estimated
%   options.Fs           - sampling freq. if any
%   options.range        - 'onesided' or 'twosided' psd
%   options.average      - <true> | false
%   options.maxhold      - <true> | false
%   options.minhold      - <true> | false
%   options.MIMO         -  true  |<false>

% Generate defaults
sizeNFFT = [1 1];
for i=1:length(varargin)
    if ~ischar(varargin{i})
        sizeNFFT = size(varargin{i});
        break;
    end
end
if sizeNFFT(1) > 1 || sizeNFFT(2) > 1
    options.nfft = coder.nullcopy(zeros(sizeNFFT));
else
    options.nfft = max(256, 2^nextpow2(N));
end
isInMATLAB = coder.target('MATLAB');
options.Fs = nan; % Work in rad/sample
options.conflevel = nan; %Default Invalid value
options.average = true;
options.maxhold = false;
options.minhold = false;
options.MIMO = false;
options.conflevel = nan; %Default initial value
options.isNFFTSingle = false;

%in psdoptions, check if isfield centerdc and do this to avoid init
options.centerdc = false;

% Parse MIMO flag. It can be a case-insensitive match, and can be
% truncated from the end.
MIMOIdx = false(length(varargin),1);
for i = 1:length(varargin)
    MIMOIdx(i) = strncmpi('mimo',varargin{i},length(varargin{i})); 
end
if any(MIMOIdx) || isMimo
    if (sum(MIMOIdx) + double(isMimo)) > 1
        coder.internal.error('signal:psdoptions:MultipleValues');
    else
        options.MIMO = true;
        if isInMATLAB
            varargin(MIMOIdx) = [];
        end
    end
end

% Determine if frequency vector specified
freqVecSpec = false;
if (~isempty(varargin) && ~ischar(varargin{1}) && length(varargin{1}) > 1)
    freqVecSpec = true;
end

if isreal_x && ~freqVecSpec
    options.range = 'onesided';
else
    options.range = 'twosided';
end

% Parse TRACE input
normalIdx = strcmpi('mean',varargin);
maxholdIdx = strcmpi('maxhold',varargin);
minholdIdx = strcmpi('minhold',varargin);

coder.internal.errorIf(any(normalIdx) && (strcmpi(esttype,'cpsd') || ...
    strcmpi(esttype,'mscohere')), 'signal:welchparse:MeanTrace',esttype)

if any(normalIdx)
    options.average = true;
    if isInMATLAB
        varargin(normalIdx) = [];
    end
elseif any(maxholdIdx)
    options.maxhold = true;
    if isInMATLAB
        varargin(maxholdIdx) = [];
    end
elseif any(minholdIdx)
    options.minhold = true;
    if isInMATLAB
        varargin(minholdIdx) = [];
    end
end
 
if any(strcmp(varargin, 'whole'))
    coder.internal.warning('signal:welchparse:InvalidRange', '''whole''', '''twosided''');
elseif any(strcmp(varargin, 'half'))
    coder.internal.warning('signal:welchparse:InvalidRange', '''half''', '''onesided''');
end

[options1,msg,msgobj] = psdoptions(isreal_x,options,varargin{:});

if isInMATLAB && ~isempty(msg)
    error(msgobj); 
end

end
% [EOF]

% LocalWords:  esttype WINNAME WINPARAM NOVERLAP nfft Fs fs tfeh nonnan nd
% LocalWords:  mimo noverlap maxhold minhold allownumeric Mustbe
