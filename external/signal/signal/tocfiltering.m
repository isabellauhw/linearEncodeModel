function tocfiltering
%----------------------------------------------------------------------------------------------------
% Digital Filtering
% Zero-phase filtering, median filtering, overlap-add filtering, transfer function representation
%----------------------------------------------------------------------------------------------------
%   <a href="matlab:help bandpass">bandpass</a>   - Filter signals with a bandpass filter
%   <a href="matlab:help bandstop">bandstop</a>   - Filter signals with a bandstop filter
%   <a href="matlab:help highpass">highpass</a>   - Filter signals with a highpass filter
%   <a href="matlab:help lowpass">lowpass</a>    - Filter signals with a lowpass filter
%
%   <a href="matlab:help fftfilt">fftfilt</a>    - Overlap-add filter implementation
%   <a href="matlab:help filter">filter</a>     - Filter implementation
%   <a href="matlab:help filter2">filter2</a>    - Two-dimensional digital filtering
%   <a href="matlab:help filtfilt">filtfilt</a>   - Zero-phase version of filter
%   <a href="matlab:help filtic">filtic</a>     - Determine filter initial conditions
%   <a href="matlab:help hampel">hampel</a>     - Outlier removal via Hampel identifier
%   <a href="matlab:help latcfilt">latcfilt</a>   - Lattice filter implementation
%   <a href="matlab:help medfilt1">medfilt1</a>   - 1-Dimensional median filtering
%   <a href="matlab:help residuez">residuez</a>   - Z-transform partial-fraction expansion
%   <a href="matlab:help sgolayfilt">sgolayfilt</a> - Savitzky-Golay filter implementation
%   <a href="matlab:help sosfilt">sosfilt</a>    - Second-order sections (biquad) filter implementation
%
%   <a href="matlab:help conv">conv</a>       - Convolution
%   <a href="matlab:help conv2">conv2</a>      - 2-D convolution
%   <a href="matlab:help convmtx">convmtx</a>    - Convolution matrix
%   <a href="matlab:help deconv">deconv</a>     - Deconvolution
%
%   <a href="matlab:help cell2sos">cell2sos</a>   - Convert second-order sections cell array to matrix
%   <a href="matlab:help eqtflength">eqtflength</a> - Equalize lengths of transfer function's numerator and denominator
%   <a href="matlab:help latc2tf">latc2tf</a>    - Convert lattice filter parameters to transfer function form
%   <a href="matlab:help sos2cell">sos2cell</a>   - Convert second-order sections matrix to cell array
%   <a href="matlab:help sos2ss">sos2ss</a>     - Convert digital filter second-order section parameters to state-space form
%   <a href="matlab:help sos2tf">sos2tf</a>     - Convert digital filter second-order section data to transfer function form
%   <a href="matlab:help sos2zp">sos2zp</a>     - Convert digital filter second-order section parameters to zero-pole-gain form
%   <a href="matlab:help ss">ss</a>         - Convert digital filter to state-space representation
%   <a href="matlab:help ss2sos">ss2sos</a>     - Convert digital filter state-space parameters to second-order sections form
%   <a href="matlab:help ss2tf">ss2tf</a>      - Convert state-space representation to transfer function
%   <a href="matlab:help ss2zp">ss2zp</a>      - Convert state-space filter parameters to zero-pole-gain form
%   <a href="matlab:help tf">tf</a>         - Convert digital filter to transfer function
%   <a href="matlab:help tf2latc">tf2latc</a>    - Convert transfer function filter parameters to lattice filter form
%   <a href="matlab:help tf2sos">tf2sos</a>     - Convert digital filter transfer function data to second-order sections form
%   <a href="matlab:help tf2ss">tf2ss</a>      - Convert transfer function filter parameters to state-space form
%   <a href="matlab:help tf2zp">tf2zp</a>      - Convert transfer function filter parameters to zero-pole-gain form
%   <a href="matlab:help tf2zpk">tf2zpk</a>     - Convert transfer function filter parameters to zero-pole-gain form
%   <a href="matlab:help zp2sos">zp2sos</a>     - Convert zero-pole-gain filter parameters to second-order sections form
%   <a href="matlab:help zp2ss">zp2ss</a>      - Convert zero-pole-gain filter parameters to state-space form
%   <a href="matlab:help zp2tf">zp2tf</a>      - Convert zero-pole-gain filter parameters to transfer function form
%   <a href="matlab:help zpk">zpk</a>        - Convert digital filter to zero-pole-gain representation
%
%   <a href="matlab:help filt2block">filt2block</a> - Generate Simulink filter block
%   <a href="matlab:help dspfwiz">dspfwiz</a>    - Open Filter Designer Realize Model panel to create Simulink filter block
%
% <a href="matlab:help tocfilters">Digital and Analog Filters</a>
% <a href="matlab:help signal">Signal Processing Toolbox TOC</a>

%   Copyright 2015-2017 The MathWorks, Inc.

