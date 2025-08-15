function tocfilterdesign
%----------------------------------------------------------------------------------------------------
% Digital Filter Design
% FIR, IIR, windowing, equiripple, least squares, Butterworth, Chebyshev, elliptic, pulse shaping
%----------------------------------------------------------------------------------------------------
%   <a href="matlab:help designfilt">designfilt</a>      - Design a digital filter based on a set of specifications
%   <a href="matlab:help digitalFilter">digitalFilter</a>   - Digital filter
%   <a href="matlab:help digitalFilter.info">info</a>            - Information about digital filter
%   <a href="matlab:help digitalFilter.double">double</a>          - Cast coefficients of digital filter to double precision
%   <a href="matlab:help digitalFilter.isdouble">isdouble</a>        - Determine if digital filter coefficients are double precision
%   <a href="matlab:help digitalFilter.issingle">issingle</a>        - Determine if digital filter coefficients are single precision
%   <a href="matlab:help digitalFilter.single">single</a>          - Cast coefficients of digital filter to single precision
%
%   <a href="matlab:help butter">butter</a>          - Butterworth filter design
%   <a href="matlab:help buttord">buttord</a>         - Butterworth filter order estimation
%   <a href="matlab:help cheby1">cheby1</a>          - Chebyshev Type I filter design (passband ripple)
%   <a href="matlab:help cheb1ord">cheb1ord</a>        - Chebyshev Type I filter order estimation
%   <a href="matlab:help cheby2">cheby2</a>          - Chebyshev Type II filter design (stopband ripple)
%   <a href="matlab:help cheb2ord">cheb2ord</a>        - Chebyshev Type II filter order estimation
%   <a href="matlab:help ellip">ellip</a>           - Elliptic filter design
%   <a href="matlab:help ellipord">ellipord</a>        - Elliptic filter order estimation
%   <a href="matlab:help polyscale">polyscale</a>       - Scale roots of polynomial
%   <a href="matlab:help polystab">polystab</a>        - Stabilize polynomial
%   <a href="matlab:help yulewalk">yulewalk</a>        - Yule-Walker filter design
%
%   <a href="matlab:help cfirpm">cfirpm</a>          - Complex and nonlinear phase equiripple FIR filter design
%   <a href="matlab:help fir1">fir1</a>            - Window based FIR filter design - low, high, band, stop, multi
%   <a href="matlab:help fir2">fir2</a>            - FIR arbitrary shape filter design using the frequency sampling method
%   <a href="matlab:help fircls">fircls</a>          - Constrained Least Squares filter design - arbitrary response
%   <a href="matlab:help fircls1">fircls1</a>         - Constrained Least Squares FIR filter design - low and highpass
%   <a href="matlab:help firls">firls</a>           - Optimal least-squares FIR filter design
%   <a href="matlab:help firpm">firpm</a>           - Parks-McClellan optimal equiripple FIR filter design
%   <a href="matlab:help firpmord">firpmord</a>        - Parks-McClellan optimal equiripple FIR order estimator
%   <a href="matlab:help gaussdesign">gaussdesign</a>     - Gaussian FIR pulse-shaping filter design
%   <a href="matlab:help intfilt">intfilt</a>         - Interpolation FIR filter design
%   <a href="matlab:help kaiserord">kaiserord</a>       - Kaiser window design based filter order estimation
%   <a href="matlab:help maxflat">maxflat</a>         - Generalized Butterworth lowpass filter design
%   <a href="matlab:help rcosdesign">rcosdesign</a>      - Raised cosine FIR pulse-shaping filter design
%   <a href="matlab:help sgolay">sgolay</a>          - Savitzky-Golay FIR smoothing filter design
%
%   <a href="matlab:help filt2block">filt2block</a>      - Generate Simulink filter block
%   <a href="matlab:help dspfwiz">dspfwiz</a>         - Open Filter Designer Realize Model panel to create Simulink filter block
%
%   <a href="matlab:help bilinear">bilinear</a>        - Bilinear transformation with optional prewarping
%   <a href="matlab:help impinvar">impinvar</a>        - Impulse invariance analog to digital conversion
%
%   <a href="matlab:help filterDesigner">filterDesigner</a>  - Open Filter Designer
%
% <a href="matlab:help tocfilters">Digital and Analog Filters</a>
% <a href="matlab:help signal">Signal Processing Toolbox TOC</a>

%   Copyright 2015 The MathWorks, Inc.

