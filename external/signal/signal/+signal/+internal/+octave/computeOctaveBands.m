function [bandFreq, cf] = computeOctaveBands(FLims, b)
%getOctaveBandLimits Determine edge and center frequencies for octave
%bands.
%   The input parameters are:
%   N      - Filter order
%   FLims(1) - Desired lower-edge frequency for the first octave band
%   FLims(2)  - Desired upper-edge frequency for the last octave band
%   b      - Bands per octave
%   Fs     - Sample rate
%
%   The output parameters are:
%   bandFreq - Returns the upper- and lower-edge frequencies of octave
%           bands
%   cf     - Vector of ANSI center frequencies
% 
%   BandFreq is an [Mx2] matrix, where M is the number of octave bands

%   Copyright 2017 MathWorks, Inc.

%   This function is for internal use only. It may be removed.


 [cf,G] = signal.internal.octave.getListOfANSICenterFrequencies(FLims, b);
 
 if isrow(cf)
     cf = cf(:);
 end
 
 bandFreq = zeros(length(cf),2);
 bandFreq(:,1) = cf.*(G^(-1/(2*b)));
 bandFreq(:,2) = cf.*(G^(1/(2*b)));
