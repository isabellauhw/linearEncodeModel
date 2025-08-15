function [N, Wn, bta, filtype] = kaiserord(varargin)
%   KAISERORD FIR order estimator (lowpass, highpass, bandpass, multiband).
%   [N,Wn,BTA,FILTYPE] = KAISERORD(F,A,DEV,Fs) is the approximate order N,
%   normalized frequency band edges Wn, Kaiser window beta parameter BTA
%   and filter type FILTYPE to be used by the FIR1 function:
%      B = FIR1(N, Wn, FILTYPE, kaiser( N+1,BTA ), 'noscale' )
%
%   The resulting filter will approximately meet the specifications given
%   by the input parameters F, A, and DEV.
%
%   F is a vector of band edge frequencies in Hz, in ascending order
%   between 0 and half the sampling frequency Fs.  A is a vector of 0s and
%   1s specifying the desired function's amplitude on the bands defined by
%   F. The length of F is twice the length of A, minus 2 (it must therefore
%   be even).  The first frequency band is assumed to start at zero, and
%   the last one always ends at Fs/2.
%
%   DEV is a vector of maximum deviations or ripples (in linear units)
%   allowable for each band. The smallest deviation specified (MIN(DEV)) is
%   used for both the passband and the stopband.
%
%   Fs is the sampling frequency (which defaults to 2 if you leave it off).
%
%   C = KAISERORD(F,A,DEV,Fs,'cell') is a cell-array whose elements are the
%   parameters to FIR1.
%
% % EXAMPLE
% %     Design a lowpass filter with a passband edge of 1500Hz, a
% %     stopband edge of 2000Hz, passband ripple of 0.01, stopband ripple
% %     of 0.1, and a sampling frequency of 8000Hz:
%
%      [n,Wn,bta,filtype] = kaiserord( [1500 2000], [1 0], [0.01 0.1], 8000 );
%      b = fir1(n, Wn, filtype, kaiser(n+1,bta), 'noscale');
%
% %     This is equivalent to
%      c = kaiserord( [1500 2000], [1 0], [0.01 0.1], 8000, 'cell' );
%      b = fir1(c{:});
%
% %  CAUTION 1: The order N is just an estimate. If the filter does not
% %  meet the original specifications, a higher order such as N+1, N+2, etc.
% %  will; if the filter exceeds the specs, a slightly lower order one may work.
% %  CAUTION 2: Results are inaccurate if cutoff frequencies are near zero
% %  frequency or the Nyquist frequency; or if the devs are large (10%).
%
%   See also FIR1, KAISER, FIRPMORD.

%   Author(s): J. H. McClellan, 10-28-91
%   Copyright 1988-2018 The MathWorks, Inc.

%   References:
%  [1] J.F. Kaiser, ``Nonrecursive Digital Filter Design Using
%       the I_o-sinh Window Function,'' Proc. 1974 IEEE
%       Symp. Circuits and Syst., April 1974, pp. 20--23.
%  [2] IEEE, Digital Signal Processing II, IEEE Press, New York:
%      John Wiley & Sons, 1975, pp. 123--126.

% Copyright 1998-2018 The MathWorks, Inc.
%#codegen

% Number of input argument check
narginchk(3,5);

isStringFlag = false;
for k = 1:nargin
    isStringFlag = isStringFlag || isstring(varargin{k}) || ischar(varargin{k});
    if isStringFlag 
        validatestring(varargin{k},{'cell'},'kaiserord','cell',5);
        break;
    end
end

% Invalid number of outputs when cell flag is specified
coder.internal.errorIf((isStringFlag && nargout > 1),'signal:kaiserord:InvalidNumberOutputs');

if coder.target('MATLAB')        
    if (isStringFlag && (nargin == 4 && (nargout == 0 || nargout == 1))) || ...
            (isStringFlag && (nargin == 5 && (nargout == 0 || nargout == 1)))            
        N = eKaiserord(varargin{:});
    else        
        [N, Wn, bta, filtype] = eKaiserord(varargin{:});
    end   
else
    allConst = true;
    coder.unroll();
    for k = 1:nargin
        allConst = allConst && coder.internal.isConst(varargin{k});
    end
    
    if allConst && coder.internal.isCompiled
        % codegeneration for constant input arguments
        if (isStringFlag && (nargin == 4 && (nargout == 0 || nargout == 1))) || ...
            (isStringFlag && (nargin == 5 && (nargout == 0 || nargout == 1)))
            N = coder.const(feval('kaiserord',varargin{:}));
        else
           [N, Wn, bta, filtype] = coder.const(@feval,'kaiserord',varargin{:}); 
        end
    else
        % code generation for variable input argument
        if (isStringFlag && (nargin == 4 && (nargout == 0 || nargout == 1))) || ...
            (isStringFlag && (nargin == 5 && (nargout == 0 || nargout == 1)))
            N = eKaiserord(varargin{:});
        else
            [N, Wn, bta, filtype] = eKaiserord(varargin{:});
        end 
        
    end
    
    
end

end

function varargout = eKaiserord(varargin) %#codegen

% check number of arguments
narginchk(3,5);

inputArgs = cell(size(varargin));
[inputArgs{:}] = convertCharsToStrings(varargin{:});

isStringFlag = false;
for k = 1:nargin
    isStringFlag = isStringFlag || isstring(inputArgs{k});          
end

% extract each input arguments fcuts,mags,devs,fsamp
[fcuts,mags,devs,fsamp] = parseInputArgs(inputArgs{:});

% Validate attributes for fcuts, mags, devs
validateattributes(fcuts,{'numeric'},{'vector','real','finite'},'kaiserord','F',1);
validateattributes(mags,{'numeric'},{'vector','real','finite'},'kaiserord','A',2);
validateattributes(devs,{'numeric'},{'vector','real','finite'},'kaiserord','DEV',3);
validateattributes(fsamp,{'numeric'},{'scalar','real','finite'},'kaiserord','Fs',4);

% Cast to enforce precision rules
fcuts = signal.internal.sigcasttofloat(fcuts,'double','kaiserord','F','allownumeric');
mags = signal.internal.sigcasttofloat(mags,'double','kaiserord','A','allownumeric');
devs = signal.internal.sigcasttofloat(devs,'double','kaiserord','DEV','allownumeric');
fsamp = signal.internal.sigcasttofloat(fsamp,'double','kaiserord','Fs','allownumeric');

max_fcuts = max(fcuts,[],2);
coder.internal.errorIf(max_fcuts(1,1) >= (fsamp(1,1)/2),'signal:kaiserord:InvalidRange');

% change to column vector
fcuts_col = fcuts(:);
mags_col = mags(:);
devs_col = devs(:);

% NORMALIZE to sampling frequency
fcuts_col = fcuts_col/fsamp;

% find the length of fcuts and mags
mf = length(fcuts_col);
nbands = length(mags_col);
ndevs = length(devs_col);

dmags = abs(diff(mags_col));
dmags = dmags - dmags(1);

% Validation of mags, fcuts and ndevs

coder.internal.errorIf(nbands ~= ndevs,'signal:kaiserord:InvalidDimensionsADEV','A', 'DEV');
coder.internal.errorIf(min(abs(mags_col)) ~= 0,'signal:kaiserord:SignalErrStopbands');
coder.internal.errorIf(sum(dmags(:)) ~= 0,'signal:kaiserord:SignalErrPassbands');

diffFcuts = diff(fcuts);
if coder.target('MATLAB')
    coder.internal.errorIf(any(diffFcuts<0),'signal:kaiserord:InvalidFreqVec');
else
    check = ~coder.internal.scalarizedAll(@(diffFcuts)~(diffFcuts < 0), diffFcuts);
    coder.internal.errorIf(check,'signal:kaiserord:InvalidFreqVec');
end

coder.internal.errorIf(mf ~= 2*(nbands - 1),'signal:kaiserord:InvalidDimensionsLengthF', 'F', '2*length(A)-2');

% find stop bands
stop = (mags_col == 0);

% divide delta by mag to get relative deviation
devs_col = devs_col ./ (stop + mags_col);

% Determine the smallest width transition zone
% Separate the passband and stopband edges
f1 = fcuts_col(1:2:(mf-1));
f2 = fcuts_col(2:2:mf);
[~,n] = min(f2-f1);
L = 0;  bta = 0;

if(nbands == 2)
    % LOWPASS case: Use formula (ref: Herrmann, Rabiner, Chan)
    [L,bta] = kaislpord( f1(n), f2(n), devs_col(1), devs_col(2));
    
else
    %=== BANDPASS case:
    %    - try different lowpasses and take the WORST one that
    %        goes through the BP specs; try both transition widths
    %    - will also do the bandreject case
    %    - does the multi-band case, one bandpass at a time.
    for i=2:nbands-1
        [L1,bta1] = kaislpord( f1(i-1), f2(i-1), devs_col(i),   devs_col(i-1) );
        [L2,bta2] = kaislpord( f1(i),   f2(i),   devs_col(i),   devs_col(i+1) );
        
        if( L1>L )
            bta = bta1;
            L = L1;
        end
        if( L2>L )
            bta = bta2;
            L = L2;
        end
        
    end
end

N = ceil( L ) - 1;   % need order, not length, for Filter design

%-- use mid-frequency; multiply by 2 for MATLAB
Wn = 2 * (f1 + f2)/2;

filtype = 'low';
if( nbands==2 && mags_col(1)==0 )
    filtype='high';
elseif( nbands==3 && mags_col(2)==0 )
    filtype='stop';
elseif( nbands>=3 && mags_col(1)==0 )
    filtype='DC-0';
elseif( nbands>=3 && mags_col(1)==1 )
    filtype='DC-1';
end

% If order is odd, and gain is not zero at nyquist, increase the order by one.
if isodd(N) && mags_col(end)~=0
    N = N + 1;
end

if (isStringFlag && (nargin == 4 && (nargout == 0 || nargout == 1))) || ...
            (isStringFlag && (nargin == 5 && (nargout == 0 || nargout == 1)))
    varargout{1} = {N, Wn, filtype, kaiser(N+1,bta), 'noscale'};
else
    varargout{1} = N;
    varargout{2} = Wn;
    varargout{3} = bta;
    varargout{4} = filtype;
end

end

function [L,bta] = kaislpord(freq1, freq2, delta1, delta2 )
%KAISLPORD FIR lowpass filter Length estimator
%
%   [L,bta] = kaislpord(freq1, freq2, dev1, dev2)
%
%   input:
%     freq1: passband cutoff freq (NORMALIZED)
%     freq2: stopband cutoff freq (NORMALIZED)
%      dev1: passband ripple (DESIRED)
%      dev2: stopband attenuation (not in dB)
%
%   outputs:
%      L = filter Length (# of samples)   **NOT the order N, which is N = L-1
%   bta =  parameter for the Kaiser window
%
%   NOTE: Will also work for highpass filters (i.e., f1 > f2)
% 	      Will not work well if transition zone is near f = 0, or
%         near f = fs/2

%
% 	Author(s): J. H. McClellan, 8-28-95

%   References:
%     [1] Rabiner & Gold, Theory and Applications of DSP, pp. 156-7.

delta = min( [delta1,delta2] );
atten = -20*log10( delta );
D = (atten - 7.95)/(2*pi*2.285);   %--- 7.95 was in Kaiser's original paper
%
df = abs(freq2 - freq1);
%
L = D/df + 1;
%
bta = signal.internal.kaiserBeta(atten);

end

function [fcuts,mags,devs,fsamp] = parseInputArgs(varargin)
%PARSEINPUTARGS Parse input arguments
% 4 input arguments
% 1. f  - vector of band edges
% 2. a  - desired amplitude on the bands
% 3. dev - max allowable error or deviation between frequency response and
%          desired amplitude
% 4. fs - Sampling frequency fs in Hz. Default to 2 Hz.

isOutputCell = false;
countArgs = 1;

fsamp = 2;
fcuts = 0;
mags = 0;

for k = 1 : nargin
    if ~isOutputCell && isstring(varargin{k})
        validateattributes(varargin{k},{'string'},{'scalartext'},'kaiserord','cell',5);        
        isOutputCell = true;
        continue;
    end
        
    switch countArgs
        case 1
            fcuts = varargin{k};  
        case 2
            mags = varargin{k};
        case 3
            devs = varargin{k};
        case 4
            fsamp = varargin{k};
    end
    
    countArgs = countArgs + 1;            

end

end

% LocalWords:  dev Fs Wn BTA FILTYPE noscale passband stopband bta filtype Vec
% LocalWords:  devs Nonrecursive Proc Symp Syst fcuts cellflag isstring fsamp
% LocalWords:  allownumeric ndevs ADEV Stopbands Herrmann Rabiner lowpasses BP
% LocalWords:  bandreject KAISLPORD kaislpord fs Passbands scalartext Numberof
% LocalWords:  PARSEINPUTARGS
