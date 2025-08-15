function tocsigmodeling
% -------------------------------------------------------------------------------
% Signal Modeling
% Linear prediction, autoregressive (AR) models, Yule-Walker, Levinson-Durbin 
% -------------------------------------------------------------------------------
% Autoregressive and Moving Average Models
%   <a href="matlab:help arburg">arburg</a>    - Autoregressive all-pole model parameters - Burg's method
%   <a href="matlab:help arcov">arcov</a>     - Autoregressive all-pole model parameters - covariance method
%   <a href="matlab:help armcov">armcov</a>    - Autoregressive all-pole model parameters - modified covariance method
%   <a href="matlab:help aryule">aryule</a>    - Autoregressive all-pole model parameters - Yule-Walker method
% 
%   <a href="matlab:help invfreqs">invfreqs</a>  - Identify continuous-time filter parameters from frequency response data
%   <a href="matlab:help invfreqz">invfreqz</a>  - Identify discrete-time filter parameters from frequency response data
%   <a href="matlab:help prony">prony</a>     - Prony method for filter design
%   <a href="matlab:help stmcb">stmcb</a>     - Compute linear model using Steiglitz-McBride iteration
%
%Linear Predictive Coding
%   <a href="matlab:help ac2poly">ac2poly</a>   - Autocorrelation sequence to prediction polynomial conversion
%   <a href="matlab:help ac2rc">ac2rc</a>     - Autocorrelation sequence to reflection coefficients conversion 
%   <a href="matlab:help is2rc">is2rc</a>     - Inverse sine parameters to reflection coefficients conversion
%   <a href="matlab:help lar2rc">lar2rc</a>    - Log area ratios to reflection coefficients conversion
%   <a href="matlab:help levinson">levinson</a>  - Levinson-Durbin recursion
%   <a href="matlab:help lpc">lpc</a>       - Linear Predictive Coefficients using autocorrelation method
%   <a href="matlab:help lsf2poly">lsf2poly</a>  - Line spectral frequencies to prediction polynomial conversion
%   <a href="matlab:help poly2ac">poly2ac</a>   - Prediction polynomial to autocorrelation sequence conversion 
%   <a href="matlab:help poly2lsf">poly2lsf</a>  - Prediction polynomial to line spectral frequencies conversion
%   <a href="matlab:help poly2rc">poly2rc</a>   - Prediction polynomial to reflection coefficients conversion
%   <a href="matlab:help rc2ac">rc2ac</a>     - Reflection coefficients to autocorrelation sequence conversion
%   <a href="matlab:help rc2is">rc2is</a>     - Reflection coefficients to inverse sine parameters conversion
%   <a href="matlab:help rc2lar">rc2lar</a>    - Reflection coefficients to log area ratios conversion
%   <a href="matlab:help rc2poly">rc2poly</a>   - Reflection coefficients to prediction polynomial conversion
%   <a href="matlab:help rlevinson">rlevinson</a> - Reverse Levinson-Durbin recursion
%   <a href="matlab:help schurrc">schurrc</a>   - Schur algorithm
%
%   <a href="matlab:help corrmtx">corrmtx</a>   - Data matrix for autocorrelation matrix estimation
%   <a href="matlab:help xcorr">xcorr</a>     - Cross-correlation
%   <a href="matlab:help xcov">xcov</a>      - Cross-covariance
%
% <a href="matlab:help signal">Signal Processing Toolbox TOC</a>

%   Copyright 2005-2015 The MathWorks, Inc.


