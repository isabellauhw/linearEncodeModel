function tocsiggenandpreprocess
% ----------------------------------------------------------
% Signal Generation and Preprocessing
% Create, resample, smooth, denoise, and detrend signals
% ----------------------------------------------------------
% Smoothing and Denoising
%   <a href="matlab:help detrend">detrend</a>     - Remove a linear trend from a vector
%   <a href="matlab:help hampel">hampel</a>      - Outlier removal via Hampel identifier
%   <a href="matlab:help medfilt1">medfilt1</a>    - One dimensional median filter
%   <a href="matlab:help sgolay">sgolay</a>      - Savitzky-Golay Filter Design
%   <a href="matlab:help sgolayfilt">sgolayfilt</a>  - Savitzky-Golay filtering
%
% Resampling
%   <a href="matlab:help decimate">decimate</a>    - Resample data at a lower sample rate
%   <a href="matlab:help downsample">downsample</a>  - Downsample input signal
%   <a href="matlab:help fillgaps">fillgaps</a>    - Fill gaps via autoregressive modeling
%   <a href="matlab:help interp">interp</a>      - Resample data at a higher sample rate
%   <a href="matlab:help interp1">interp1</a>     - General 1-D interpolation 
%   <a href="matlab:help pchip">pchip</a>       - Piecewise Cubic Hermite Interpolating Polynomial
%   <a href="matlab:help resample">resample</a>    - Resample sequence with new sampling rate
%   <a href="matlab:help spline">spline</a>      - Cubic spline interpolation
%   <a href="matlab:help upfirdn">upfirdn</a>     - Up sample, FIR filter, down sample
%   <a href="matlab:help upsample">upsample</a>    - Upsample input signal
%
% Waveform Generation
%   <a href="matlab:help chirp">chirp</a>       - Swept-frequency cosine generator
%   <a href="matlab:help diric">diric</a>       - Dirichlet (periodic sinc) function
%   <a href="matlab:help gauspuls">gauspuls</a>    - Gaussian RF pulse generator
%   <a href="matlab:help gmonopuls">gmonopuls</a>   - Gaussian monopulse generator
%   <a href="matlab:help pulstran">pulstran</a>    - Pulse train generator
%   <a href="matlab:help randn">randn</a>       - Normally distributed random numbers
%   <a href="matlab:help rectpuls">rectpuls</a>    - Sampled aperiodic rectangle generator
%   <a href="matlab:help sawtooth">sawtooth</a>    - Sawtooth function
%   <a href="matlab:help sin">sin</a>         - Sine of argument in radians
%   <a href="matlab:help sinc">sinc</a>        - Sinc or sin(pi*x)/(pi*x) function
%   <a href="matlab:help square">square</a>      - Square wave function
%   <a href="matlab:help tripuls">tripuls</a>     - Sampled aperiodic triangle generator
%   <a href="matlab:help vco">vco</a>         - Voltage controlled oscillator
%
%   <a href="matlab:help buffer">buffer</a>      - Buffer a signal vector into a matrix of data frames
%   <a href="matlab:help demod">demod</a>       - Demodulation for communications simulation
%   <a href="matlab:help modulate">modulate</a>    - Modulation for communications simulation
%   <a href="matlab:help seqperiod">seqperiod</a>   - Find minimum-length repeating sequence in a vector
%   <a href="matlab:help shiftdata">shiftdata</a>   - Shift data to operate on specified dimension
%   <a href="matlab:help unshiftdata">unshiftdata</a> - Inverse of shiftdata
%   <a href="matlab:help stem">stem</a>        - Plot discrete data sequence
%   <a href="matlab:help strips">strips</a>      - Strip plot
%   <a href="matlab:help udecode">udecode</a>     - Uniform decoding of the input
%   <a href="matlab:help uencode">uencode</a>     - Uniform quantization and encoding of the input into N-bits
%   <a href="matlab:help marcumq">marcumq</a>     - Generalized Marcum Q function.
%
% <a href="matlab:help signal">Signal Processing Toolbox TOC</a>

%   Copyright 2015 The MathWorks, Inc.


