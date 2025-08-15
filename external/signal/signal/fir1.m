function [b,a] = fir1(varargin)

%FIR1   FIR filter design using the window method.
%   B = FIR1(N,Wn) designs an N'th order lowpass FIR digital filter
%   and returns the filter coefficients in length N+1 vector B.
%   The cut-off frequency Wn must be between 0 < Wn < 1.0, with 1.0
%   corresponding to half the sample rate.  The filter B is real and
%   has linear phase.  The normalized gain of the filter at Wn is
%   -6 dB.
%
%   B = FIR1(N,Wn,'high') designs an N'th order highpass filter.
%   You can also use B = FIR1(N,Wn,'low') to design a lowpass filter.
%
%   If Wn is a two-element vector, Wn = [W1 W2], FIR1 returns an
%   order N bandpass filter with passband  W1 < W < W2. You can
%   also specify B = FIR1(N,Wn,'bandpass').  If Wn = [W1 W2],
%   B = FIR1(N,Wn,'stop') will design a bandstop filter.
%
%   If Wn is a multi-element vector,
%          Wn = [W1 W2 W3 W4 W5 ... WN],
%   FIR1 returns an order N multiband filter with bands
%    0 < W < W1, W1 < W < W2, ..., WN < W < 1.
%   B = FIR1(N,Wn,'DC-1') makes the first band a passband.
%   B = FIR1(N,Wn,'DC-0') makes the first band a stopband.
%
%   B = FIR1(N,Wn,WIN) designs an N-th order FIR filter using
%   the N+1 length vector WIN to window the impulse response.
%   If empty or omitted, FIR1 uses a Hamming window of length N+1.
%   For a complete list of available windows, see the help for the
%   WINDOW function. KAISER and CHEBWIN can be specified with an
%   optional trailing argument.  For example, B = FIR1(N,Wn,kaiser(N+1,4))
%   uses a Kaiser window with beta=4. B = FIR1(N,Wn,'high',chebwin(N+1,R))
%   uses a Chebyshev window with R decibels of relative sidelobe
%   attenuation.
%
%   For filters with a gain other than zero at Fs/2, e.g., highpass
%   and bandstop filters, N must be even.  Otherwise, N will be
%   incremented by one.  In this case the window length should be
%   specified as N+2.
%
%   By default, the filter is scaled so the center of the first pass band
%   has magnitude exactly one after windowing. Use a trailing 'noscale'
%   argument to prevent this scaling, e.g. B = FIR1(N,Wn,'noscale'),
%   B = FIR1(N,Wn,'high','noscale'), B = FIR1(N,Wn,wind,'noscale').  You
%   can also specify the scaling explicitly, e.g. FIR1(N,Wn,'scale'), etc.
%
%   % Example 1:
%   %   Design a 48th-order FIR bandpass filter with passband
%   %   0.35 <= w <= 0.65.
%
%   b = fir1(48,[0.35 0.65]);   % Window-based FIR filter design
%   freqz(b,1,512)              % Frequency response of filter
%
%   % Example 2:
%   %   The chirp.mat file contains a signal, y, that has most of its power
%   %   above fs/4, or half the Nyquist frequency. Design a 34th-order FIR
%   %   highpass filter to attenuate the components of the signal below
%   %   fs/4. Use a cutoff frequency of 0.48 and a Chebyshev window with
%   %   30 dB of ripple.
%
%   load chirp;                     % Load data (y and Fs) into workspace
%   y = y + 0.5*rand(size(y));                  % Adding noise
%   b = fir1(34,0.48,'high',chebwin(35,30));    % FIR filter design
%   freqz(b,1,512);                 % Frequency response of filter
%   output = filtfilt(b,1,y);       % Zero-phase digital filtering
%   figure;
%   subplot(211); plot(y,'b'); title('Original Signal')
%   subplot(212); plot(output,'g'); title('Filtered Signal')
%
%   See also KAISERORD, FIRCLS1, FIR2, FIRLS, FIRCLS, CFIRPM,
%            FIRPM, FREQZ, FILTER, WINDOW, DESIGNFILT.

%   FIR1 is an implementation of program 5.2 in the IEEE Programs for
%   Digital Signal Processing tape.

%   Author(s): L. Shure
%              L. Shure, 4-5-90, revised
%              T. Krauss, 3-5-96, revised
%   Copyright 1988-2018 The MathWorks, Inc.

%   Reference(s):
%     [1] "Programs for Digital Signal Processing", IEEE Press
%         John Wiley & Sons, 1979, pg. 5.2-1.
% Copyright 2008-2018 The MathWorks, Inc.

%#codegen

% number of arguments check
narginchk(2,6);

if coder.target('MATLAB')
    [b,a] = eFir1(varargin{:});
else
    % check for constant input arguments
    allConst = true;
    coder.unroll();
    for k = 1:nargin
        allConst = allConst && coder.internal.isConst(varargin{k});
    end
    
    if allConst && coder.internal.isCompiled
        % codegen for constant input arguments
        [b,a] = coder.const(@feval,'fir1',varargin{:});
    else
        % codegen for variable input argument
        [b,a] = eFir1(varargin{:});
    end
end

end

%% FIR1   FIR filter design using the window method.
function [numCoeffs,denCoeffs] = eFir1(N,Wn,varargin)
%#codegen

narginchk(2,6);

% Validate attributes N, Wn
validateattributes(N,{'numeric'},{'scalar','real','finite','positive','nonempty'},'fir1','n',1);
validateattributes(Wn,{'numeric'},{'real','finite','positive','nonempty'},'fir1','Wn',2);

% Cast to enforce precision rules
N = double(N(1));
Wn = double(Wn);

% Parse optional input arguments: ftype, scale, hilbert
[ftype,scaling,hilbert] = parseOptArgs(Wn,varargin{:});

% Compute the frequency vector
[nbands,freq,filterType] = desiredfreq(Wn,ftype);

% Compute the magnitude vector
[magnitude,firstBand] = desiredmag(filterType,nbands);

% Check for appropriate filter order, increase when necessary
if coder.target('MATLAB')
    [N,msg1,msg2,msgobj] = firchk(N,freq(end),magnitude,hilbert);
    if ~isempty(msg1)
        error(msgobj);
    end
    if ~isempty(msg2)
        warning(msgobj);
    end
else
    [N,~,~,~] = firchk(N,freq(end),magnitude,hilbert);
end

% filter length (= order + 1)
L = N + 1;

% find the index of the window argument
windIndex = 0;
for k = 1:length(varargin)
    if isnumeric(varargin{k})
        windIndex = k;
        break;
    end
end

if windIndex > 0
    wind = chkWindow(L,varargin{windIndex});
else
    wind = hamming(L).';
end

% Compute unwindowed impulse response
if hilbert
    hh = firls(L-1,freq,magnitude,'h');
else
    hh = firls(L-1,freq,magnitude);
end

% Window impulse response to get the filter
b = hh .* wind;
denCoeffs = 1;

if scaling
    % Scale so that passband is approx 1
    numCoeffs = scalefilter(b,firstBand,freq,L);
else
    numCoeffs = b;
end


end


%% ---------------------------------------------------------------------------
function b = scalefilter(b,First_Band,ff,L)
%SCALEFILTER   Scale filter to have passband approx. equal to one.

if First_Band
    b = b / sum(b);  % unity gain at DC
else
    if ff(4)==1
        % unity gain at Fs/2
        f0 = 1;
    else
        % unity gain at center of first passband
        f0 = mean(ff(3:4));
    end
    b = b / abs( exp(-1i*2*pi*(0:L-1)*(f0/2))*(b.') );
end

end
%% --------------------------------------------------------------------------
function [ftype,scaling,hilbert] = parseOptArgs(Wn,varargin)
%PARSEOPTARGS   Parse optional input arguments.

% Optional input arguments, in anyorder:
%   1 - Filter type flag, can be 'low','high','bandpass','stop','DC-0','DC-1'
%   2 - Window vector
%   3 - Scale flag, can be 'scale' or 'noscale'.
%   4 - hilbert flag, 'h' 

inputArgs = cell(size(varargin));
[inputArgs{:}] = convertCharsToStrings(varargin{:});

% Initialize ftype & scale
scaling = 1;
scale = "SCALE";
ftype = defaultftype(Wn);
optionStrings = {'LOW','HIGH','BANDPASS','STOP','DC-0','DC-1','NOSCALE','SCALE'};
hilbert = false;

% Flags to check conflicting input types
ftypeFound = false;
scaleFound = false;
windowFound = false;

for argIndex = 1:numel(inputArgs)
    input = inputArgs{argIndex};
    
    if isstring(input) && isscalar(input)
        
        % check for hilbert flag
        if "h" == input || "H" == input
            hilbert = true;
            continue
        end
        
        strOption = convertCharsToStrings(validatestring(input,optionStrings,'fir1'));
        
        switch strOption
            case {"SCALE","NOSCALE"}
                if ~scaleFound
                    scale = strOption;
                    scaleFound = true;
                else
                    coder.internal.errorIf(scaleFound,'signal:fir1:conflictingTypes','Scale',(argIndex + 2));
                end
            case {"LOW","HIGH","BANDPASS","STOP","DC-0","DC-1"}
                if ~ftypeFound
                    ftype = strOption;
                    ftypeFound = true;
                else
                    coder.internal.errorIf(ftypeFound,'signal:fir1:conflictingTypes','Ftype',(argIndex + 2));
                end
        end
        
    elseif isnumeric(input)
        if ~windowFound
            windowFound = true;
            validateattributes(input,{'numeric'},{'vector','real','finite','nonempty'},'fir1','window');
        else
            coder.internal.errorIf(windowFound,'signal:fir1:conflictingTypes','Window',(argIndex + 2));
        end
        
    else
        ok = true;
        coder.internal.errorIf(ok,'signal:fir1:InvalidInputTypes',(argIndex + 2));
    end
end

if scale == "NOSCALE"
    scaling = 0;
end

end

%% ---------------------------------------------------------------------------
function wind = chkWindow(L,inputWindow)
% CHKWINDOW validate the window length.

if length(inputWindow) ~= L
    coder.internal.error('signal:fir1:MismatchedWindowLength');
end

% store the window coefficients as row vector.
wind = double(inputWindow(:))';
end

%% ----------------------------------------------------------------------------
function ftype = defaultftype(Wn)
%DEFAULTFTYPE  Assign default filter type depending on number of bands.

nbandsLength = length(Wn);

if nbandsLength == 1
    ftype = "LOW";
elseif nbandsLength == 2
    ftype = "BANDPASS";
else
    ftype = "DC-0";
end

end

%% --------------------------------------------------------------------------
function [nbands,freq,F] = desiredfreq(Wn,ftype)
%DESIREDFREQ  Compute the vector of frequencies to pass to FIRLS.
%
%   Inputs:
%           Wn    - vector of cutoff frequencies.
%           Ftype - string with desired response ('low','high',...)
%
%   Outputs:
%           nbands - number of frequency bands.
%           ff     - vector of frequencies to pass to FIRLS.
%           Ftype  - converted filter type (if it's necessary to convert)


if  any( Wn<=0 | Wn>=1 )
    coder.internal.error('signal:fir1:FreqsOutOfRange');
end
if  any(diff(Wn)<0)
    coder.internal.error('signal:fir1:FreqsMustBeMonotonic');
end

nbands = length(Wn) + 1;

if (nbands > 2) && (ftype == "BANDPASS")
    F = "DC-0";  % make sure default 3 band filter is bandpass
else
    F = ftype;
end

% create the pair of frequency points based on Wn. freq must be a column
% vector.
ff = repelem(Wn(:),2);
freq = [0;ff(:);1];

end

%% -------------------------------------------------------------------------
function [magnitude,firstBand] = desiredmag(ftype,nbands)
%DESIREDMAG  Compute the magnitude vector (column) to pass to FIRLS.

firstBand = (ftype ~= "DC-0") && (ftype ~= "HIGH");
mags = rem( firstBand + (0:nbands-1), 2);

magnitude = repelem(mags(:),2);

end

% LocalWords:  Wn allownumeric coeffiecients unwindowed passband SCALEFILTER
% LocalWords:  Fs PARSEOPTARGS noscale VALIDATEOPTARGS ie ftype scaleopt N'th
% LocalWords:  DEFAULTFTYPE DESIREDFREQ DESIREDMAG FIRCHK firchk stopband th
% LocalWords:  sidelobe fs DESIGNFILT Shure Krauss CHKWINDOW anyorder

