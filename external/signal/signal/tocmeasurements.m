function tocmeasurements
% ----------------------------------------------------------------------------------------
% Measurements and Feature Extraction
% Peaks, signal statistics, pulse and transition metrics, power, bandwidth, distortion
% ----------------------------------------------------------------------------------------
% Descriptive Statistics
%   <a href="matlab:help cummax">cummax</a>        - Cumulative maxima of array
%   <a href="matlab:help cummin">cummin</a>        - Cumulative minima of array
%   <a href="matlab:help envelope">envelope</a>      - Envelope detector
%   <a href="matlab:help findchangepts">findchangepts</a> - Finds abrupt changes in a signal
%   <a href="matlab:help findpeaks">findpeaks</a>     - Find local maxima
%   <a href="matlab:help mean">mean</a>          - Average or mean value of array
%   <a href="matlab:help cusum">cusum</a>         - Detect small changes in mean via cumulative sums
%   <a href="matlab:help median">median</a>        - Median value of array
%   <a href="matlab:help min">min</a>           - Smallest elements in array
%   <a href="matlab:help peak2peak">peak2peak</a>     - Difference between largest and smallest component
%   <a href="matlab:help peak2rms">peak2rms</a>      - Ratio of largest absolute to root mean squared value
%   <a href="matlab:help rms">rms</a>           - Root mean squared value
%   <a href="matlab:help rssq">rssq</a>          - Root sum squared value
%   <a href="matlab:help seqperiod">seqperiod</a>     - Find minimum-length repeating sequence in a vector
%   <a href="matlab:help std">std</a>           - Standard deviation
%   <a href="matlab:help var">var</a>           - Variance
%
%   <a href="matlab:help alignsignals">alignsignals</a>  - Align two signals by delaying earliest signal
%   <a href="matlab:help dtw">dtw</a>           - Distance between signals via Dynamic Time Warping
%   <a href="matlab:help edr">edr</a>           - Edit distance on real signals
%   <a href="matlab:help finddelay">finddelay</a>     - Estimate delay(s) between signals
%   <a href="matlab:help findsignal">findsignal</a>    - Find signal via similarity search
%
%   <a href="matlab:help signalLabelDefinition">signalLabelDefinition</a>   - Create signal label definition
%   <a href="matlab:help labeledSignalSet">labeledSignalSet</a>        - Labeled signal set
%
% Pulse and Transition Metrics
%   <a href="matlab:help dutycycle">dutycycle</a>     - Duty cycle of bilevel waveform pulses
%   <a href="matlab:help midcross">midcross</a>      - Mid reference level crossing of bilevel waveform transitions
%   <a href="matlab:help pulseperiod">pulseperiod</a>   - Period of bilevel waveform pulses
%   <a href="matlab:help pulsesep">pulsesep</a>      - Separation between bilevel waveform pulses
%   <a href="matlab:help pulsewidth">pulsewidth</a>    - Width of bilevel waveform pulses
%   <a href="matlab:help statelevels">statelevels</a>   - State level estimation of bilevel waveforms via histogram
%
%   <a href="matlab:help falltime">falltime</a>      - Fall time of negative-going bilevel waveform transitions
%   <a href="matlab:help overshoot">overshoot</a>     - Overshoot metrics of bilevel waveform transitions
%   <a href="matlab:help risetime">risetime</a>      - Rise time of positive-going bilevel waveform transitions
%   <a href="matlab:help settlingtime">settlingtime</a>  - Settling time metrics of bilevel waveform transitions
%   <a href="matlab:help slewrate">slewrate</a>      - Slew rate of bilevel waveform transitions
%   <a href="matlab:help undershoot">undershoot</a>    - Undershoot metrics of bilevel waveform transitions
%
% Spectral Measurements
%   <a href="matlab:help bandpower">bandpower</a>     - Band power
%   <a href="matlab:help enbw">enbw</a>          - Equivalent noise bandwidth
%   <a href="matlab:help meanfreq">meanfreq</a>      - Mean frequency
%   <a href="matlab:help medfreq">medfreq</a>       - Median frequency
%   <a href="matlab:help obw">obw</a>           - Occupied bandwidth
%   <a href="matlab:help powerbw">powerbw</a>       - Power bandwidth
%   <a href="matlab:help tfestimate">tfestimate</a>    - Transfer function estimate
%
%   <a href="matlab:help sfdr">sfdr</a>          - Spurious-Free Dynamic Range
%   <a href="matlab:help sinad">sinad</a>         - Signal to Noise and Distortion ratio
%   <a href="matlab:help snr">snr</a>           - Signal to Noise Ratio
%   <a href="matlab:help thd">thd</a>           - Total Harmonic Distortion
%   <a href="matlab:help toi">toi</a>           - Third Order Intercept point
%
% <a href="matlab:help signal">Signal Processing Toolbox TOC</a>

%   Copyright 2011-2015 The MathWorks, Inc.

% [EOF]
