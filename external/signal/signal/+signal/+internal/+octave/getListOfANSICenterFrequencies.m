function [cf,G] = getListOfANSICenterFrequencies(FLims, b)
% getListOfANSICenterFrequencies determine center frequencies
%   getListOfANSICenterFrequencies gets a list of valid center frequencies
%   as per ANSI S1.11-2004 standard, based on the frequency limits Flims
%   and bands per octave b.
% 
%   The input parameters are:
%   FLims(1) - Desired lower-edge frequency for the first octave band
%   FLims(2)  - Desired upper-edge frequency for the last octave band
%   b      - Bands per octave
%
%   The output parameters are:
%   cf - Vector of ANSI center frequencies
%   G -  Octave ratio

%   Copyright 2017 MathWorks, Inc.

%   This function is for internal use only. It may be removed.


% Choose octave ratio G for base-ten systems. For base-two systems, G=2
G = 10^(3/10);
G = cast(G,'like',FLims);
% Get the starting octave band index and starting center frequency
[cf, x] = getNearestANSIBand(FLims(1), b);

maxCf = FLims(2)/(G^(-1/(2*b))); % FLims(2) is the maximum lower band-edge frequency
% Iterate over band index 'x' until you reach max center frequency
while 1
    x = x+1;
    new_cf = getCenterFrequencyFromBandIndex(x, b);
    if new_cf>maxCf
        break;
    else
        cf = [cf, new_cf]; %#ok
    end
end

function [cf, x] = getNearestANSIBand(f, b)
% Center frequency and index of the nearest band that is ANSI-compliant.
% "Nearest" is in geometric distance, not linear distance. In other words,
% make sure that the input center frequency 'f' always lies within the
% passband of the octave filter around 'cf'.

G = 10^(3/10);
if rem(b,2)
    % b is odd
    x = round(10/3*b*log10(f/1000)+30);
    cf = G^((x-30)/b)*1000;
else
    x = round(10/3*b*log10(f/1000)+59/2);
    cf = G^((2*x-59)/(2*b))*1000;
end
end

function cf = getCenterFrequencyFromBandIndex(x, b)
% Formula used to compute center frequency as per ANSI S1.11-2004 standard
G = 10^(3/10);
if rem(b,2)
    % b is odd
    cf = G^((x-30)/b)*1000;
else
    cf = G^((2*x-59)/(2*b))*1000;
end
end
end

