function varargout = tfestimate(x,y,varargin)
%TFESTIMATE   Transfer Function Estimate.
%   Txy = TFESTIMATE(X,Y) estimates the transfer function of the system
%   with input X and output Y using Welch's averaged, modified periodogram
%   method. Txy is the quotient of the Cross Power Spectral Density (CPSD)
%   of X and Y, Pxy, and the Power Spectral Density (PSD) of X, Pxx.
%
%   By default, X and Y are divided into eight sections with 50% overlap,
%   each section is windowed with a Hamming window, and eight modified
%   periodograms are computed and averaged.  See "help pwelch" and "help
%   cpsd" for complete details.
%
%   X and Y may be either vectors or two-dimensional matrices.  If both are
%   matrices and have the same size, TFESTIMATE operates column-wise:
%   Txy(:,n) = TFESTIMATE(X(:,n),Y(:,n)).  If one is a matrix and the other
%   is a vector, the vector is converted to a column vector and expanded
%   internally so both inputs have the same number of columns.
%
%   Txy = TFESTIMATE(X,Y,WINDOW), when WINDOW is a vector, divides each
%   column of X and Y into overlapping sections of length equal to the
%   length of WINDOW, and then windows each section with the vector
%   specified in WINDOW.  If WINDOW is an integer, then each column of X
%   and Y are divided into sections of length WINDOW, and each section is
%   windowed with a Hamming of that length.  If WINDOW is omitted or
%   specified as empty, a Hamming window is used to obtain eight sections
%   of X and Y.
%
%   Txy = TFESTIMATE(X,Y,WINDOW,NOVERLAP) uses NOVERLAP samples of overlap
%   from section to section.  NOVERLAP must be an integer smaller than the
%   WINDOW if WINDOW is an integer, or smaller than the length of WINDOW if
%   WINDOW is a vector.  If NOVERLAP is omitted or specified as empty, it
%   is set to obtain a 50% overlap.
%
%   [Txy,W] = TFESTIMATE(X,Y,WINDOW,NOVERLAP,NFFT) specifies the number of
%   FFT points used to calculate the PSD and CPSD estimates.  For real X
%   and Y, Txy has length (NFFT/2+1) if NFFT is even, and (NFFT+1)/2 if
%   NFFT is odd.  For complex X or Y, Txy always has length NFFT.  If NFFT
%   is specified as empty, it is set to either 256 or the next power of two
%   greater than the length of each section of X (or Y), whichever is
%   greater.
%
%   If NFFT is greater than the length of each section, the data is
%   zero-padded. If NFFT is less than the section length, the segment is
%   "wrapped" (using DATAWRAP) to make the length equal to NFFT. This
%   produces the correct FFT when NFFT is smaller than the section length.
%
%   W is the vector of normalized frequencies at which Txy is estimated.
%   W has units of radians/sample.  For real signals, W spans the interval
%   [0,pi] when NFFT is even and [0,pi) when NFFT is odd.  For complex
%   signals, W always spans the interval [0,2*pi).
%
%   [Txy,W] = TFESTIMATE(X,Y,WINDOW,NOVERLAP,W) computes the two-sided
%   transfer function estimate at the normalized angular frequencies
%   contained in the vector W.  W must have at least two elements.
%
%   [Txy,F] = TFESTIMATE(X,Y,WINDOW,NOVERLAP,NFFT,Fs) returns the transfer
%   function estimate as a function of physical frequency.  Fs is the
%   sampling frequency specified in hertz.  If Fs is empty, it defaults to
%   1 Hz.
%
%   F is the vector of frequencies (in hertz) at which Txy is estimated.
%   For real signals, F spans the interval [0,Fs/2] when NFFT is even and
%   [0,Fs/2) when NFFT is odd.  For complex signals, F always spans the
%   interval [0,Fs).
%
%   [Txy,F] = TFESTIMATE(X,Y,WINDOW,NOVERLAP,F,Fs) computes the transfer
%   function estimate at the physical frequencies contained in the vector
%   F.  F must be expressed in hertz and have at least two elements.
%
%   [...] = TFESTIMATE(...,'mimo') estimates multiple-input/multiple-output
%   transfer functions. Txy is a 3-D array containing one column for each
%   output signal and one page for each input signal. If X is a vector,
%   this option is ignored. If X and Y have a different number of columns
%   and both have more than one column, this option is used by default.
%
%   [...] = TFESTIMATE(...,'Estimator',EST) estimates transfer functions
%   using the estimator EST. EST can be 'H1' or 'H2'. Use 'H1' when the
%   noise is uncorrelated with the input signals, and 'H2' when the noise
%   is uncorrelated with the output signals. If EST is 'H2', then the
%   number of input and output signals must be equal. If EST is not
%   specified, it defaults to 'H1'.
%
%   [...] = TFESTIMATE(...,FREQRANGE) returns the transfer function
%   estimate computed over the specified range of frequencies based upon
%   the value of FREQRANGE:
%
%      'onesided' - returns the one-sided transfer function estimate of
%         real input signals X and Y. If NFFT is even, Txy has length
%         NFFT/2+1 and is computed over the interval [0,pi]. If NFFT is
%         odd, Txy has length (NFFT+1)/2 and is computed over the interval
%         [0,pi). When Fs is optionally specified, the intervals become
%         [0,Fs/2] and [0,Fs/2) for even and odd NFFT, respectively.
%
%      'twosided' - returns the two-sided transfer function estimate for
%         either real or complex input X and Y. Txy has length NFFT and is
%         computed over the interval [0,2*pi). When Fs is specified, the
%         interval becomes [0,Fs).
%
%      'centered' - returns the centered two-sided transfer function
%         estimate for either real or complex X and Y.  Txy has length NFFT
%         and is computed over the interval (-pi, pi] for even NFFT and
%         (-pi, pi) for odd NFFT. When Fs is specified, the intervals
%         become (-Fs/2, Fs/2] and (-Fs/2, Fs/2) for even and odd NFFT,
%         respectively.
%
%      FREQRANGE may be placed in any position in the input argument list
%      after NOVERLAP.  The default value of FREQRANGE is 'onesided' when X
%      and Y are both real and 'twosided' when either X or Y is complex.
%
%   TFESTIMATE(...) with no output arguments plots the transfer function
%   estimate (in decibels per unit frequency) in the current figure window.
%
%   % EXAMPLE 1:
%   h = fir1(30,0.2,rectwin(31));
%   x = randn(16384,1);
%   y = filter(h,1,x);
%   tfestimate(x,y,[],512,1024); % Plot estimate using a default window.
%
%   % Estimate the transfer function and calculate the
%   % filter coefficients using INVFREQZ.
%   [txy,w] = tfestimate(x,y,[],512,1024);
%   [b,a] = invfreqz(txy,w,30,0);
%   htool = fvtool(h,1,b,a); legend(htool,'Original','Estimated');
%
%   % EXAMPLE 2:
%   %   Compute transfer functions for multiple inputs.
%   h1 = fir1(30,0.3,rectwin(31));
%   h2 = fir1(30,0.5,rectwin(31));
%   x = randn(16384,2);
%   y = filter(h1,1,x(:,1)) + filter(h2,1,x(:,2));
%   tfestimate(x,y,[],512,1024,'mimo');
%
%   See also CPSD, PWELCH, MSCOHERE, PERIODOGRAM.

%   Copyright 1988-2020 The MathWorks, Inc.
%#codegen
narginchk(2,10)
inpArgs = cell(1,length(varargin));
if nargin > 2
    [inpArgs{:}] = convertStringsToChars(varargin{:});
else
    inpArgs = varargin;
end

[funcName,args] = parseEstimator(inpArgs{:});

% Possible outputs are:
%       Plot
%       Txy
%       Txy, freq
[varargout{1:nargout}] = welch({x,y},funcName,args{:});

if nargout == 0
    coder.internal.assert(coder.target('MATLAB'),'signal:tfestimate:PlottingNotSupported');
    title(getString(message('signal:dspdata:dspdata:WelchTransferFunctionEstimate')));
end
end

%--------------------------------------------------------------------------
function [funcName,args] = parseEstimator(varargin)
% Parse the estimator n-v pair and return the flag for welch in esttype.
% Remove the pair and return the remaining arguments for welch in args.
if coder.target('MATLAB')
    args = varargin;
    % Remove non-string arguments.
    charArgs = args(cellfun(@ischar,varargin));

    % Remove MIMO and freqrange flags.
    iRem = false(length(charArgs),1);
    for i = 1:length(charArgs)
        validatestring(charArgs{i},{'mimo','onesided','twosided','centered','Estimator','h1','h2'});
        if (strncmpi(charArgs{i},'mimo',length(charArgs{i})) || ...
            strncmpi(charArgs{i},'onesided',length(charArgs{i})) || ...
            strncmpi(charArgs{i},'twosided',length(charArgs{i})) || ...
            strncmpi(charArgs{i},'centered',length(charArgs{i})))
            iRem(i) = true;
        end
    end
    charArgs(iRem) = [];

    % Parse the estimator.
    p = inputParser;
    p.addParameter('Estimator',[]);
    parse(p,charArgs{:});
    est = p.Results.Estimator;

    if ~isempty(est)
        % Remove the name-value pair from the args list.
        iEstValue = find(strcmp(args,est),1);
        args(iEstValue-1:iEstValue) = [];

        % Validate the value.
        est = validatestring(est,{'H1','H2'},'tfestimate','EST');
    else
        est = 'H1';
    end
else
    idx = 0;
    coder.unroll();
    for i = 1:length(varargin)
        if ischar(varargin{i})
            coder.internal.assert(coder.internal.isConst(varargin{i}),'signal:tfestimate:CharParamNotConstant');
            if strncmpi(varargin{i},'estimator',length(varargin{i}))
                coder.internal.errorIf(idx > 0,'signal:tfestimate:MultipleEstimatorOptions');
                coder.internal.errorIf(isempty({varargin{i+1:end}}),'signal:tfestimate:MissingEstimatorOption');
                est = validatestring(varargin{i+1},{'H1','H2'},'tfestimate','EST');
                idx = i;
            end
        end
    end

    if idx == 0
        est = 'H1';
        args = varargin;
    else
        args = {varargin{1:idx-1},varargin{idx+2:end}};
    end
end
% Return the function name for welch.
if strcmp(est,'H2')
    funcName = 'tfeh2';
else
    funcName = 'tfe';
end
end

% LocalWords:  Txy Welch's Pxy Pxx periodograms NOVERLAP NFFT Fs mimo
% LocalWords:  FREQRANGE txy htool esttype freqrange Estimatorvalue tfeh
