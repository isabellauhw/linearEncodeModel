function plotFSST(t,f,sst,fNorm,freqloc)
%PLOTFSST Plot the FSST in the current figure
% This function is for internal use only. It may be removed.

%   Copyright 2020 The MathWorks, Inc.
%#codegen

% For MEX targets
coder.extrinsic('signalwavelet.internal.convenienceplot.plotTFR');

if fNorm
    %Convert to time as expected by plotTFR
    t = t ./ (2*pi);
end

if isempty(freqloc)
    plotOpts.freqlocation = 'xaxis';
else
    plotOpts.freqlocation = freqloc;
end

plotOpts.title = getString(message('signal:fsst:titleFSST'));
plotOpts.cblbl = getString(message('signal:fsst:ColorbarLabel'));
plotOpts.cursorclbl = [getString(message('signal:fsst:CursorColorbarLabel')) ' '];
plotOpts.isFsnormalized = fNorm;
signalwavelet.internal.convenienceplot.plotTFR(t,f,abs(sst),plotOpts);
end