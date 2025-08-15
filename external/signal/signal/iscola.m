function [tf,m,maxDeviation] = iscola(win,noverlap,method)
%ISCOLA True for constant overlap-add compliance.
%   tf = ISCOLA(window,noverlap) checks that the specified window and
%   overlap satisfy the Constant Overlap-Add (COLA) constraint to ensure
%   that the inverse short-time Fourier transform (ISTFT) results in
%   perfect reconstruction for non-modified spectra. WINDOW is a vector
%   that specifies the window for the STFT and ISTFT. NOVERLAP specifies an
%   integer number of samples of overlap between adjoining segments. The
%   default method is 'wola' for compatibility with the ISTFT function. The
%   function returns a logical true if the combination of input parameters
%   is COLA-compliant and a logical false if not.
%
%   tf = ISCOLA(...,method) specifies the inversion method to use:
%       'ola'  - Overlap-Add
%       'wola' - Weighted Overlap-Add
%   METHOD defaults to 'wola'.
%
%   [tf,m] = ISCOLA(...) also returns the median of the COLA summation. If
%   the inputs are COLA-compliant, m is equal to the COLA summation
%   constant for all n.
%
%   [tf,m,maxDeviation] = ISCOLA(...) returns the maximum deviation from m.
%   If the inputs are COLA-compliant, then maxDeviation is close to zero.
%
%    % EXAMPLE 1: 
%       % Check the COLA constraint for a rectangular window of length 100
%       % with an overlap of 25 samples (25%) using the 'ola' method of 
%       % reconstruction. The window/overlap combination is not COLA
%       % compliant.
%       window = rectwin(100); 
%       noverlap = 25; 
%       method = 'ola'; 
%       tf = iscola(window,noverlap,method)
% 
%     % EXAMPLE 2: 
%       % Check the COLA constraint for a periodic root-Hann window of 
%       % length 120 with an overlap of 60 (50%) using the 'wola' method of 
%       % reconstruction. The window/overlap combination is COLA compliant.
%       window = sqrt(hann(120,'periodic')); 
%       noverlap = 60; 
%       [tf,m,maxDeviation] = iscola(window,noverlap)
%
%   See also STFT, ISTFT, PSPECTRUM

% [1] Allen, J. B. "Short Term Spectral Analysis, Synthesis, and
%     Modification by Discrete Fourier Transform," IEEE Transactions on
%     Acoustics, Speech, and Signal Processing. Vol. ASSP-25, June 1977,
%     pp. 235-238.
% [2] Griffin, D. W. and J. S. Lim. "Signal Estimation from Modified
%     Short-Time Fourier Transform," IEEE Transactions on Acoustics,
%     Speech, and Signal Processing. Vol. ASSP-32, No. 2, April 1984.

%   Copyright 2018-2020 The MathWorks, Inc.
%#codegen

% Check number of inputs/outputs 
narginchk(2,3);
nargoutchk(0,3);

% Check for method
if nargin<3
    method = 'wola'; 
end

% Validate window
validateattributes(win,{'single','double'},...
    {'nonempty','finite','vector','real'},'iscola','Window');
win = double(win(:)).'; % Convert to double to minimize precision errors 
nwin = numel(win); 

% Validate noverlap
validateattributes(noverlap,{'numeric'},...
    {'scalar','integer','nonnegative','<',nwin},...
    'iscola','OverlapLength');
noverlap = double(noverlap); % Convert to double to minimize precision errors 

% Validate method
validStrings = {'ola','wola'};
method = validatestring(method,validStrings,'iscola','Method');

% Set parameter a 
switch method
    case 'wola'
        a = 1;
    case 'ola'
        a = 0;
end

% Set hop size 
hop = nwin-noverlap;

% Calculate COLA 
nsum = floor(nwin/hop);
colaChk = zeros(1,hop); 
for ii = 1:nsum
   colaChk = colaChk+win(((ii-1)*hop+1):(ii*hop)).^(a+1);
end

% Calculate COLA for remainder 
if rem(nwin,hop)~=0
    colaChk(1:rem(nwin,hop)) = colaChk(1:rem(nwin,hop))+win((end-rem(nwin,hop)+1):end).^(a+1);
end

% COLA constraint must be a constant for perfect reconstruction
nsumTotal = floor(nwin/hop)+double(rem(nwin,hop)~=0);
m = median(colaChk);
maxDeviation = max(abs(colaChk-m));
tf = maxDeviation < nsumTotal*eps; 
