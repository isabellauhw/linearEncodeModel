function plotPeriodogram(Pxx,w,Pxxc,RPxx,options,esttype,units,winName,winParam)
%PLOTPERIODOGRAM Plot periodogram espectral estimation
%   Plot the periodogram Pxx and the confidence levels Pxxc if requested.
%   Or plot the reassigned periodogram RPxx if requested.

%   Copyright 1988-2020 The MathWorks, Inc.
%#codegen

if options.reassign
    Px = RPxx;
else
    Px = Pxx;
end

w = {w};
if strcmpi(units,'Hz')
    w = [w, {'Fs',options.Fs}];
end

if strcmp(esttype,'psd')
    hdspdata = dspdata.psd(Px,w{:},'SpectrumType',options.range);
else
    hdspdata = dspdata.msspectrum(Px,w{:},'SpectrumType',options.range);
end

% plot the confidence levels if conflevel is specified.
if ~isempty(Pxxc)
    hdspdata.ConfLevel = options.conflevel;
    hdspdata.ConfInterval =  Pxxc;
end

% Create a spectrum object to store in the PSD object's metadata.
hspec = spectrum.periodogram({winName,winParam}); %#ok<DPRDGRM>
hdspdata.Metadata.setsourcespectrum(hspec);

if options.centerdc
    centerdc(hdspdata);
end
hLine = plot(hdspdata);

% Change the plot style to show the reassigned power
if options.reassign
     plotReassignedSpectrum(hLine,hdspdata);
end

% title the plot appropriately
if strcmp(esttype,'power')
    if options.reassign
        title(getString(message('signal:periodogram:ReassignedPeriodogramPowerSpectrumEstimate')));
    else
        title(getString(message('signal:periodogram:PeriodogramPowerSpectrumEstimate')));
    end
end
end

%--------------------------------------------------------------------------
function plotReassignedSpectrum(hLine,hdspdata)

% fetch axes from line handle
if ~isempty(hLine)
   hAxes = ancestor(hLine(1),'axes');
else
   hAxes = gca;
end

% previous plot has x and y labels we wish to preserve
set(hAxes, 'NextPlot', 'replacechildren');

% obtain the lower limit from the previous plot
yLim = get(hAxes,'YLim');
lowLimit = yLim(1);

% extract frequency vector from original plot
FreqVector = hLine(1).XData(:);

% extract the data from the plot
logPower = 10*log10(hdspdata.Data);
stem(FreqVector,logPower,'BaseValue',lowLimit,'Marker','.');

% bound plot by y limit; give 10 extra dB.
yTick = get(hAxes,'YTick');
set(hAxes,'YLim',[yLim(1) yTick(end)+10]);

% Ensure axes limits are properly cached for zoom/unzoom
resetplotview(hAxes,'SaveCurrentView');

% turn on box and grid
set(hAxes,'Box','on','XGrid','on','YGrid','on');
title(getString(message('signal:periodogram:ReassignedPeriodogramPSDEstimate')));
end
