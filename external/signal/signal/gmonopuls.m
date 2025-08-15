function y = gmonopuls(t,fc)
%GMONOPULS Gaussian monopulse generator.
%   Y = GMONOPULS(T,FC) returns samples of the unity-amplitude
%   Gaussian monopulse with center frequency FC (Hertz) at the
%   times indicated in array T.  By default, FC=1000 Hz.
%
%   TC = GMONOPULS('cutoff',FC) returns the time duration between
%   the maximum and minimum amplitudes of the pulse.
%
%   Default values are substituted for empty or omitted trailing input
%   arguments.
%
%   EXAMPLES:
%
%   % Example 1: Plot a 2 GHz Gaussian monopulse sampled at a rate
%                % of 100 GHz.
%                fc = 2E9;  fs = 100E9;
%                tc = gmonopuls('cutoff', fc);
%                t  = -2*tc : 1/fs : 2*tc;
%                y  = gmonopuls(t,fc); plot(t,y)
%
%   % Example 2: Construct a train of monopulses from Example 1
%                % at a spacing of 7.5ns.
%                fc = 2E9;  fs = 100E9;         % center freq, sample freq
%                D  = [2.5 10 17.5]' * 1e-9;    % pulse delay times
%                tc = gmonopuls('cutoff', fc);  % width of each pulse
%                t  = 0 : 1/fs : 150*tc;        % signal evaluation time
%                yp = pulstran(t,D,@gmonopuls,fc);
%                plot(t,yp)
%
%   See also GAUSPULS, TRIPULS, PULSTRAN, CHIRP.

%   Copyright 1988-2019 The MathWorks, Inc.
%#codegen

% Check number of input parameters
narginchk(1,2);

if nargin < 2
    % default value for 'fc'
    fc = 1E3;
end
if isempty(fc)
    % default value for 'fc'
    fc_cast = cast(1E3,'like',fc);
else
    fc_cast = fc;
end
% 'fc' must be a nonnegative scalar
validateattributes(fc_cast,{'numeric'},{'finite','real','nonnegative','scalar'},mfilename,'fc',2);

if ischar(t) || isStringScalar(t)
    % 't' must be the string 'cutoff'
    if ~strncmpi(t,'cutoff',numel(t))
        coder.internal.error('signal:gmonopuls:InvalidCutoffInput');
    end
    % Compute time duration between minimum and maximum pulse amplitudes
    y = 1/(pi*fc_cast(1));
else
    % 't' must be numeric
    validateattributes(t,{'numeric'},{},mfilename,'t',1);
    % Return RF pulses
    u = pi.*t.*fc_cast(1);
    y = 2*sqrt(exp(1))*u .* exp(-2.*u.^2);
end

end