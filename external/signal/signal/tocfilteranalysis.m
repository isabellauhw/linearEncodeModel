function tocfilteranalysis
%----------------------------------------------------------------------------------------------
% Digital Filter Analysis
% Magnitude, phase, impulse, and step responses, phase and group delays, pole-zero analysis
%----------------------------------------------------------------------------------------------
%   <a href="matlab:help abs">abs</a>            - Magnitude
%   <a href="matlab:help angle">angle</a>          - Phase angle
%   <a href="matlab:help freqz">freqz</a>          - Z-transform frequency response
%   <a href="matlab:help grpdelay">grpdelay</a>       - Group delay 
%   <a href="matlab:help phasedelay">phasedelay</a>     - Phase delay 
%   <a href="matlab:help phasez">phasez</a>         - Phase response 
%   <a href="matlab:help unwrap">unwrap</a>         - Unwrap phase angle
%   <a href="matlab:help zerophase">zerophase</a>      - Zero-phase response of real filter
%   <a href="matlab:help zplane">zplane</a>         - Discrete pole-zero plot
%
%   <a href="matlab:help impz">impz</a>           - Impulse response of digital filter
%   <a href="matlab:help impzlength">impzlength</a>     - Impulse response length
%   <a href="matlab:help stepz">stepz</a>          - Step response of digital filter
%
%   <a href="matlab:help filtord">filtord</a>        - Filter order
%   <a href="matlab:help filternorm">filternorm</a>     - 2-norm or inf-norm of a digital filter
%   <a href="matlab:help firtype">firtype</a>        - Type of linear phase FIR filter
%   <a href="matlab:help isallpass">isallpass</a>      - True for all-pass filters
%   <a href="matlab:help digitalFilter.isfir">isfir</a>          - Determine if digital filter has finite impulse response
%   <a href="matlab:help islinphase">islinphase</a>     - True for linear phase filters
%   <a href="matlab:help ismaxphase">ismaxphase</a>     - True for maximum phase filters
%   <a href="matlab:help isminphase">isminphase</a>     - True for minimum phase filters
%   <a href="matlab:help isstable">isstable</a>         - True for stable filters
%
%   <a href="matlab:help filterDesigner">filterDesigner</a> - Open Filter Designer
%   <a href="matlab:help fvtool">fvtool</a>         - Open Filter Visualization Tool
%
% <a href="matlab:help tocfilters">Digital and Analog Filters</a>
% <a href="matlab:help signal">Signal Processing Toolbox TOC</a>

%   Copyright 2015 The MathWorks, Inc.

