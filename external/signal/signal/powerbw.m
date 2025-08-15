function [bw, flo, fhi, pwr] = powerbw(varargin)
%POWERBW Power Bandwidth.
%   BW = POWERBW(X) computes the 3 dB (half power) bandwidth, BW, 
%   of the input signal vector, X.  BW has units of radians/sample.  
%   If X is a matrix, then POWERBW computes the bandwidth over each column 
%   in X independently.
%
%   To compute the 3 dB bandwidth, POWERBW first computes a power spectrum
%   using PERIODOGRAM and a Kaiser window.  Next, a reference level is
%   computed as the maximum power level of the power spectrum.  The
%   bandwidth is computed from the frequency intercepts where the spectrum
%   drops below the reference level by 3 dB, or encounters the end of the
%   spectrum (whichever is closer).
%    
%   BW = POWERBW(X, Fs) returns the 3 dB bandwidth, BW, in units of
%   hertz. Specify the sample rate of the signal, Fs, as a positive real
%   scalar.
%   
%   BW = POWERBW(Pxx, F) computes the 3 dB bandwidth of the PSD estimate,
%   Pxx. F is a vector of frequencies that corresponds to the vector of Pxx
%   estimates.  If Pxx is a matrix, then POWERBW computes the bandwidth
%   over each column in Pxx independently.
%
%   BW = POWERBW(Sxx, F, RBW) computes the 3 dB bandwidth of the power
%   spectrum estimate, Sxx.  F is a vector of frequencies that corresponds
%   to the vector of Sxx estimates.  If Sxx is a matrix, then POWERBW
%   computes the bandwidth over each column in Sxx independently. RBW, a
%   positive scalar, is the resolution bandwidth used to integrate
%   each power estimate. The resolution bandwidth is the product of two
%   values: the frequency resolution of the discrete Fourier transform and
%   the equivalent noise bandwidth of the window used to compute the PSD.
%
%   BW = POWERBW(...,FREQRANGE) specifies the frequency range over which to
%   compute the reference level as a two-element row vector.  If specified,
%   the reference level will be the average power level seen in the
%   reference band.  If unspecified, the reference level will be the
%   maximum power level of the spectrum.
%
%   BW = POWERBW(...,FREQRANGE,R) specifies the relative amplitude, R, in
%   dB by which the local PSD estimate must drop when computing the borders
%   of the power bandwidth.  The sign of R is ignored when computing the
%   reference level.  The default value for R is approximately 3.01 dB.
%
%   [BW, Flo, Fhi] = POWERBW(...) also returns the left and right
%   frequency borders of the power bandwidth.
%
%   [BW, Flo, Fhi, POWER] = POWERBW(...) also returns the total power
%   within the power bandwidth, POWER.
%
%   POWERBW(...)  with no output arguments by default plots the PSD (or
%   power spectrum) in the current figure window and annotates the
%   bandwidth.
%
%   % Example:
%   %   Compute the 3 dB bandwidth of a chirp signal 
%
%   nSamp = 1024;
%   Fs = 1024e3;
%   t = (0:nSamp-1)'/Fs;
%   x = chirp(t,50e3,nSamp/Fs,100e3);
%
%   powerbw(x,Fs)
%
%   See also OBW, BANDPOWER, PERIODOGRAM, PWELCH, PLOMB.

%   Copyright 2014-2019 The MathWorks, Inc.
%#codegen

narginchk(1,5);

% use a rectangular window for time-domain input
kaiserBeta = 0;

% fetch the PSD from the input
[Pxx, F, Frange, rbw, extraArgs, status] = psdparserange('powerbw', kaiserBeta, varargin{:});

% check if a reference power level rolloff is specified
if isempty(extraArgs)
  R = 10*log10(1/2); % use half power as default reference power rolloff
else
  coder.internal.assert(numel(extraArgs)==1,'signal:powerbw:UnrecognizedAdditionalArguments');
  % extraArgs{1} is the reference power rolloff
  R = extraArgs{1};
  validateattributes(R,{'numeric'},{'real','nonempty','finite','scalar','nonzero'}, ...
                     'powerbw','R');
  % internally use negative sign convention. scalar inference for codegen
  R = -abs(double(R(1)));
end

% compute the power bandwidth and power within the specified range
[bw, flo, fhi, pwr] = signalwavelet.internal.computePowerBW(Pxx, F, Frange, R, status);

% plot if no output arguments specified (only in MATLAB execution)
if nargout==0
  coder.internal.assert(coder.target('MATLAB'),'signal:powerbw:PlottingNotSupported');
  plotPowerBW(Pxx, F, rbw, flo, fhi, R, status);
end

end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function plotPowerBW(Pxx, F, rbw, flo, fhi, R, status)

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
yLim = get(hAxes,'YLim');

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
dB = sprintf('%3.1f',abs(R));
if strcmp(dB(end-1:end),'.0')
  dB(end-1:end)=[];
end

titleStr = getString(message('signal:powerbw:PowerBandwidth',dB));
if numel(flo)==1
  [bw, ~, units] = engunits(fhi-flo,'unicode');
  if status.normF
    titleStr = sprintf('%s: %.3f \\times \\pi %srad/sample',titleStr,bw/pi,units);
  else
    titleStr = sprintf('%s: %.3f %sHz',titleStr,bw,units);
  end
end
title(titleStr);

end