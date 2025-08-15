classdef kurtogramPlot
%KURTOGRAMPLOT generates plot for kurtogram
    
%   Copyright 2017 The MathWorks, Inc.
    properties
        hKurtogram
    end
    
    methods
        function this = kurtogramPlot(kgram, maxNode, fs, f, w, L, fc, wc, BW, normFreq)
            L = round(L, 1);
            if normFreq
                xlbl = getString(message('signal:kurtogram:FrequencyUnitSample', '\times \pi radians/sample'));
                funit = 'rad/sample';
                f = f/pi;
            else
                [~, scaleFactor, funit] = signal.internal.utilities.getFrequencyEngUnits(fs/2);
                f = f*scaleFactor;
                fc = fc*scaleFactor;
                BW = BW*scaleFactor;
                xlbl = [getString(message('signal:kurtogram:Frequency')) ' (' funit ')'];
            end
            pltTitle = getString(message('signal:kurtogram:kurtogramTitle',...
                'K_{max}', ...
                num2str(maxNode.kurtosis), ...
                num2str(L(w==wc), '%g'), ...
                num2str(wc), ...
                num2str(fc), ...
                funit, ...
                num2str(BW)));
            ylbl = getString(message('signal:kurtogram:windowLength'));
            
            this.hKurtogram = newplot;
            imagesc(this.hKurtogram, f, [], kgram);
            hcolor = colorbar(this.hKurtogram);
            ylabel(hcolor, getString(message('signal:kurtogram:skurtosisLegend')))
            xlabel(this.hKurtogram, xlbl);
            ylabel(this.hKurtogram, ylbl)
            title(this.hKurtogram, pltTitle)
            yticklbl = [num2str(L, '%g') repmat(' ', length(L), 1) num2str(w, '(%d)')];
            set(this.hKurtogram, 'ytick', 1:length(w),...
                'yticklabel', yticklbl);
        end
    end
end
