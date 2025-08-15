function [bw, flo, fhi, pwr] = obw(varargin)
%OBW    Occupied bandwidth.
%   BW = OBW(X) computes the 99% occupied bandwidth, BW, of the input
%   signal vector, X.  BW has units of radians/sample. If X is a matrix,
%   then OBW computes the bandwidth over each column in X independently.
%
%   To compute the occupied bandwidth, OBW first internally computes a
%   power spectral density estimate, Pxx, using PERIODOGRAM and a
%   rectangular window.  Next, the PSD is integrated with a rectangular
%   approximation. The bandwidth is computed from the frequency intercepts
%   where the integrated power crosses 0.5% and 99.5% of the total power in
%   the spectrum.  
%
%   BW = OBW(X, Fs) returns the occupied bandwidth, BW, in units of
%   hertz. Specify the sample rate of the signal, Fs, as a positive real
%   scalar.
%   
%   BW = OBW(Pxx, F) computes the occupied bandwidth of the PSD estimate,
%   Pxx. F is a vector of frequencies that corresponds to the vector of 
%   Pxx estimates.  If Pxx is a matrix, then OBW computes the bandwidth 
%   over each column in Pxx independently.
%
%   BW = OBW(Sxx, F, RBW) computes occupied bandwidth of the power spectrum
%   estimate, Sxx.  F is a vector of frequencies that corresponds to the
%   vector of Sxx estimates.  If Sxx is a matrix, then OBW computes the
%   bandwidth over each column in Sxx independently. RBW, a positive
%   scalar, is the resolution bandwidth used to integrate each power
%   estimate. The resolution bandwidth is the product of two values: the
%   frequency resolution of the discrete Fourier transform and the
%   equivalent noise bandwidth of the window used to compute the PSD.
%
%   BW = OBW(...,FREQRANGE) specifies the frequency range over which to
%   restrict the bandwidth computation as a two-element row vector, 
%   [F1 F2], where F1 < F2.  If FREQRANGE is an empty vector, [], 
%   the entire bandwidth is used.  
%
%   BW = OBW(...,FREQRANGE,P) specifies the percentage, P, of the total
%   signal power present in the occupied band.  Specify P as a positive
%   scalar value less than 100.  The bandwidth is computed from the
%   frequency intercepts where the integrated power crosses the (100-P)/2
%   and (100+P)/2 percentages of the total power in the spectrum.
%
%   [BW, Flo, Fhi] = OBW(...) also returns the left and right
%   frequency borders of the occupied bandwidth.
%
%   [BW, Flo, Fhi, POWER] = OBW(...) also returns the power within the
%   occupied bandwidth, POWER.
%
%   OBW(...) with no output arguments by default plots the PSD (or power
%   spectrum) in the current figure window and annotates the bandwidth.
%
%   % Example:
%   %   Compute the occupied bandwidth of a chirp signal 
%
%   nSamp = 1024;
%   Fs = 1024e3;
%   t = (0:nSamp-1)'/Fs;
%   x = chirp(t,50e3,nSamp/Fs,100e3);
%
%   obw(x,Fs)
%
%   See also MEDFREQ POWERBW BANDPOWER FINDPEAKS PERIODOGRAM PWELCH PLOMB.

%   Copyright 2014-2019 The MathWorks, Inc.
%#codegen

narginchk(1,5);

% use a rectangular window for time-domain input
kaiserBeta = 0;

% fetch the PSD from the input
[Pxx, F, Frange, rbw, extraArgs, status] = psdparserange('obw', kaiserBeta, varargin{:});

% use full range if unspecified
if isempty(Frange)
    FrangeVal = [F(1) F(end)];
else
    FrangeVal = Frange;
end

% check if a percentage is specified
if isempty(extraArgs)
    P = 99;
else
    coder.internal.assert(numel(extraArgs)==1,'signal:obw:UnrecognizedAdditionalArguments');
    % extraArgs{1} is the power percentage
    P = extraArgs{1};
    validateattributes(P,{'numeric'},{'real','nonempty','positive','scalar','<',100}, ...
        'obw','P');
    % scalar inference for codegen
    P = double(P(1));
end

% compute the occupied bandwidth and power within the specified range
[bw, flo, fhi, pwr] = signalwavelet.internal.computeOBW(Pxx, F, FrangeVal, P);

% plot if no output arguments specified (only in MATLAB execution)
if nargout==0
    coder.internal.assert(coder.target('MATLAB'),'signal:obw:PlottingNotSupported');
    plotOBW(Pxx, F, FrangeVal, rbw, flo, fhi, P, status);
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function plotOBW(Pxx, F, Frange, rbw, flo, fhi, P, status)

% plot spectrum
if strcmp(status.inputType,'power')
  % power spectrum when specified
  [hLine, xscale] = psdplot(Pxx, F, rbw, 'power', status);
else
  % otherwise, default to PSD
  [hLine, xscale] = psdplot(Pxx, F, rbw, 'psd', status);
end

% show the active frequency range of the measurement
hAxes = ancestor(hLine(1),'axes');
xLim = [F(1) F(end)];
yLim = get(hAxes,'YLim');
psdmaskactiverange(hAxes, xscale, xLim, yLim, Frange);

% plot translucent patch for each estimate
for i=1:numel(flo)
  xData = xscale*[flo(i) fhi(i) fhi(i) flo(i)];
  yData = yLim([1 1 2 2]);
  color = get(hLine(i),'Color');
  patch(xData, yData, color, ...
       'Parent',hAxes, ...
       'EdgeColor','none', ...
       'FaceAlpha',0.125);
end

% once patches are done, plot the frequency borders on top
for i=1:numel(flo)
  line(xscale*[flo(i) flo(i)], yLim, ...
       'Parent',hAxes, ...
       'Color',get(hLine(i),'Color'));
end
for i=1:numel(fhi)
  line(xscale*[fhi(i) fhi(i)], yLim, ...
       'Parent',hAxes, ...
       'Color',get(hLine(i),'Color'));
end

% title the plot
titleStr = getString(message('signal:obw:PercentOccupiedBandwidth',sprintf('%g',P)));
if numel(flo)==1
  [bw, ~, units] = engunits(fhi-flo, 'unicode');
  if status.normF
    titleStr = sprintf('%s: %.3f \\times \\pi %srad/sample',titleStr,bw/pi,units);
  else
    titleStr = sprintf('%s: %.3f %sHz',titleStr,bw,units);
  end
end
title(titleStr);

end