function conveniencePlot(xIn,xOut,opts)
%conveniencePlot Plot filtered data

%   Copyright 2017 MathWorks, Inc.

%   This function is for internal use only. It may be removed.

%#ok<*AGROW>
newplot;

% Passband frequency and time values
passbandFreq = opts.Wpass;
if opts.IsNormalizedFreq
    passbandFreqStr = 'Wpass';   
    passbandFreqUnits = ' \times\pi radians/sample';    
    t = 1:opts.SignalLength;
else
    passbandFreqStr = 'Fpass';
    [passbandFreq, ~, passbandFreqUnits] = engunits(passbandFreq);
    passbandFreqUnits = [passbandFreqUnits 'Hz'];
    
    if opts.IsTimetable
        t = xIn.Properties.RowTimes;
    else
        t = (0:opts.SignalLength-1)/opts.Fs;
    end
end

% Time plot
subplot(2,1,1);
if opts.IsTimetable
    legendStrs = {};    
    vNames = xIn.Properties.VariableNames;
    hold on
    for idx = 1:numel(vNames)
        vName = vNames{idx};
        plot(t,[xIn.(vName),xOut.(vName)]);
        legendStrs = [legendStrs getLegendStrings(size(xIn.(vName),2),vName)]; 
    end
else   
    if opts.IsNormalizedFreq
        timeXLabel = getString(message('signal:internal:filteringfcns:Samples'));        
    else
        [t,~,tUnitsStr] = engunits(t,'time');
        if strcmp(tUnitsStr,'secs')
            tUnitsStr = 's';
        end            
        timeStr = getString(message('signal:internal:filteringfcns:Time'));
        timeXLabel = [timeStr ' (' tUnitsStr ')'];
    end
    if isrow(xIn)
        xIn = xIn(:);
    end
    if isrow(xOut)
        xOut = xOut(:);
    end    
    plot(t,[xIn,xOut]);
    xlabel(timeXLabel);  
    legendStrs = getLegendStrings(size(xIn,2));
end
legend(legendStrs);

responseStr = getString(message(['signal:internal:filteringfcns:' opts.Response]));
passBandTitString = [' (' passbandFreqStr ' = '  mat2str(passbandFreq,4) ' ' passbandFreqUnits ')'];
title([responseStr ' ' passBandTitString]);
grid on;
axis tight

% Power spectrum plot
if opts.IsTimetable
    P = [];
    for idx = 1:numel(vNames)
        [Ptmp,F] = pspectrum([xIn.(vNames{idx}),xOut.(vNames{idx})],t,'Leakage',0.9);    
        P = [P Ptmp];
    end
else      
    if opts.IsNormalizedFreq
        [P,F] = pspectrum([xIn,xOut],'Leakage',0.9);
    else
        [P,F] = pspectrum([xIn,xOut],opts.Fs,'Leakage',0.9);    
    end    
end

if opts.IsNormalizedFreq
    F = F/pi;
    frqStr = getString(message('signal:internal:filteringfcns:NormalizedFrequency'));
    freqXLabel = [frqStr ' (\times\pi radians/sample)']; 
else
    [F,~,fUnitsStr] = engunits(F);
    frqStr = getString(message('signal:internal:filteringfcns:Frequency'));
    freqXLabel = [frqStr ' (' fUnitsStr 'Hz)'];
end
subplot(2,1,2)
plot(F,10*log10(P));
xlabel(freqXLabel);
ylabel(getString(message('signal:internal:filteringfcns:PowerSpectrumDB')));
legend(legendStrs);
grid on;
axis tight
end

%--------------------------------------------------------------------------
function legendStrs = getLegendStrings(numCols, varName)

legendInputStr = getString(message('signal:internal:filteringfcns:LegendInputStr'));
legendOutputStr = getString(message('signal:internal:filteringfcns:LegendOutputStr'));

if nargin < 2
    varName = '';
    varNameFlag = false;
else
    varName = [' ' varName ];
    varNameFlag = true;
end

if numCols == 1
    if isempty(varNameFlag)
        legendStrs = {legendInputStr,legendOutputStr};
    else
        legendStrs = {[legendInputStr varName],[legendOutputStr varName]};
    end
else
    for idx = 1:numCols
        legStrs1{idx} = [legendInputStr [varName '(:,' num2str(idx) ')']]; 
        legStrs2{idx} = [legendOutputStr [varName '(:,' num2str(idx) ')']];
    end
    legendStrs = [legStrs1 legStrs2];
end

end
