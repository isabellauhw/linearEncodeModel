function [bankFilters, centerFreqOutput] = designOctaveBank(N, FLims, b, Fs)
%designOctaveBank Design octave and fractional octave band filters banks.
%   designOctaveBank designs octave or fractional octave filter-banks and
%   returns the filter, and center frequencies of the filter-banks defined
%   by the ANSI S1.11 standard.
%   The input parameters are:
%   N      - Filter order
%   FLims(1) - Desired lower-edge frequency for the first octave band
%   FLims(2)  - Desired upper-edge frequency for the last octave band
%   b      - Bands per octave
%   Fs     - Sample rate
%
%   The output designedFilter is a [1xL] cell array bankFilters, where L is
%   the number of octave bands between FLims(1) and FLims(2), and a vector
%   centerFreqOutput. bankFilters is comprised of multi-section filters
%   designed with fosNum and fosDen, or with second order sections.
%   centerFreqOutput comprises the center frequencies of octave bands.
%
%   fosNum and fosDen are [Mx5] matrices, where M is the number of
%   fourth-order sections. If M is not a multiple of 4, the first section
%   of fosNum and fosDen is a second-order section. 

%   Copyright 2017 MathWorks, Inc.

%   This function is for internal use only. It may be removed.

[cf,~] = signal.internal.octave.getListOfANSICenterFrequencies(FLims, b);

if isrow(cf)
    cf = cf(:);
end
centerFreqOutput = cf;

[bandFreq, ~] = signal.internal.octave.computeOctaveBands(FLims, b);

% minFreq and maxFreq represent the minimum and maximum frequency limits at
% which an octave band can be designed, such that it is stable.
minFreq = max(3,3*Fs/48E3);

% minFreq must be less than the upper-edge of the last octave band in range
if minFreq > bandFreq(end)
    error(message('signal:poctave:InvalidUpperFrequencyLimit',num2str(minFreq)));
end

guardWidth = 0.05*Fs;
maxFreq = Fs/2 - guardWidth;

% Initialize the filter bank as an empty cell array, and the vector of
% output center frequencies as an empty vector.
bankFilters = {};


for idx = 1:length(cf)
    % Filter can be designed safely within minFreq and maxFreq
    if (bandFreq(idx,1) >= minFreq && bandFreq(idx,2) <= maxFreq)
        [fosNum, fosDen] = ...
            signal.internal.octave.octaveFilterDesigner(N, cf(idx), b, Fs);
        bankFilters{1,idx} = {fosNum; fosDen};
    
    % If upper band edge is less than minFreq, or lower band edge is
    % greater than maxFreq, do not design the filter.
    elseif (bandFreq(idx,2) < minFreq || bandFreq(idx,1) > maxFreq)
        bankFilters{1,idx} = [];
        
    % If the lower edge of the Filter band is less than minFreq, but upper
    % edge is less than maxFreq, design a band-pass filter between minFreq
    % and the upper-band edge.
    elseif (bandFreq(idx,1) < minFreq && bandFreq(idx,2) <= maxFreq)
        [z,p,k] = butter(N/2,[minFreq bandFreq(idx,2)]/(Fs/2));
        bankFilters{1,idx} = cast(zp2sos(z,p,k),'like',N);
        
    % Filter band is wider than the range between minFreq and maxFreq, but
    % upper edge is less than Nyquist frequency, design a band-pass filter
    % between minFreq and maxFreq
    elseif (bandFreq(idx,1) < minFreq && bandFreq(idx,2) > maxFreq && bandFreq(idx,2) < Fs/2)
        [z,p,k] = butter(N/2,[minFreq maxFreq]/(Fs/2));
        bankFilters{1,idx} = cast(zp2sos(z,p,k),'like',N);
        
    % Filter band is wider than the range between minFreq and Nyquist
    % frequency. Design a high-pass filter with a cutoff frequency at
    % minFreq
    elseif (bandFreq(idx,1) < minFreq && bandFreq(idx,2) >= Fs/2)
        [z,p,k] = butter(N,minFreq/(Fs/2),'high');
        bankFilters{1,idx} = cast(zp2sos(z,p,k),'like',N);
    
    % If the upper edge of the filter band is more than maxFreq, but less
    % than the Nyquist frequency, design a band-pass filter with an upper
    % edge frequency at maxFreq
    elseif (bandFreq(idx,2) > maxFreq && bandFreq(idx,2) < Fs/2)
        [z,p,k] = butter(N/2,[bandFreq(idx,1) maxFreq]/(Fs/2));
        bankFilters{1,idx} = cast(zp2sos(z,p,k),'like',N);
       
    % If the upper edge of the filter band is more than the Nyquist
    % frequency, design a high-pass filter with a cut-off frequency at the
    % band's lower edge frequency
    elseif (bandFreq(idx,2) >= Fs/2)
        [z,p,k] = butter(N,bandFreq(idx,1)/(Fs/2),'high');
        bankFilters{1,idx} = cast(zp2sos(z,p,k),'like',N); %#ok<*AGROW>
    end
end

% Delete empty cells 
invalidBandIndex = cellfun('isempty',bankFilters(1,:));
bankFilters(:,invalidBandIndex) = [];
centerFreqOutput(invalidBandIndex) = [];
end

        