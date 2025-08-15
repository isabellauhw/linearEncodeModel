classdef skurtosisPlot
%SKURTOSISPLOT generate plot for spectral kurtosis

%   Copyright 2017 The MathWorks, Inc.
    properties
        hSkurtosis
    end
    
    methods
        function this = skurtosisPlot(SK, fs, f, threshold, confidenceLevel, normFreq)
            
            if normFreq
                xlbl = getString(message('signal:pkurtosis:FrequencyUnitSample', '\times \pi radians/sample'));
                f = f/pi;
            else
                [~, scaleFactor, unit] = signal.internal.utilities.getFrequencyEngUnits(fs/2);
                f = f*scaleFactor;
                xlbl = [getString(message('signal:pkurtosis:Frequency')) ' (' unit ')'];
            end
            ylbl = getString(message('signal:pkurtosis:skurtosisLegend'));
            confLegend = getString(message('signal:pkurtosis:confidenceLevelLegend', num2str(confidenceLevel)));
            
            this.hSkurtosis = newplot;
            plot(this.hSkurtosis, f, SK)
            hold(this.hSkurtosis, 'on')
            plot(this.hSkurtosis, [f; NaN; f], ...
                [threshold*ones(length(f), 1); NaN; -threshold*ones(length(f), 1)], ...
                '--', 'color', [.85 .325 .098] )
            hold(this.hSkurtosis, 'off')
            legend(this.hSkurtosis, ylbl, confLegend)
            title(this.hSkurtosis, ylbl)
            xlabel(this.hSkurtosis, xlbl)
            ylabel(this.hSkurtosis, ylbl)
            grid(this.hSkurtosis, 'on')
        end
    end
end
