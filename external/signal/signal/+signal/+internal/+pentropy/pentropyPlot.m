classdef pentropyPlot
%SKURTOSISPLOT generate plot for spectral entropy

%   Copyright 2017 The MathWorks, Inc.
    properties
        hPentropy
    end
    
    methods
        function this = pentropyPlot(T, SE)
            ylbl = getString(message('signal:pentropy:spectralEntropy')); 
            this.hPentropy = newplot;
            if isa(T, 'datetime')
                Tplot = T;
                xlbl = getString(message('signal:pentropy:Time'));
            else
                if isa(T, 'duration')
                    Tvec = seconds(T);
                else
                    Tvec = T;
                end
                [Tplot, ~, TUnit] = engunits(Tvec, 'time');
                xlbl = [getString(message('signal:pentropy:Time')) ' (' TUnit ')'];
            end
            if isscalar(SE)
                plot(this.hPentropy, Tplot, SE, 'o');
            else
                plot(this.hPentropy, Tplot, SE);
            end
            xlabel(this.hPentropy, xlbl);
            ylabel(this.hPentropy, ylbl);
            title(this.hPentropy, ylbl);
            grid(this.hPentropy, 'on');
        end
    end
end
