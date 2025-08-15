function [f4plot, xLabelStr, yLabelStr] = gui4tftmoment(f, torder, IsCentral)
%GUI4TFTMOMENT generate the string for labels of the plot of tftmoment.

%   Copyright 2017 The MathWorks, Inc.

[~, scaleFactor, unit] = signal.internal.utilities.getFrequencyEngUnits(f(end));
f4plot = f*scaleFactor;

n = num2str(torder);
xLabelStr = [getString(message('signal:tfmoment:freq4tfsmoment')) ' (' unit ')'];

if IsCentral
    yLabelStr = strcat('$\mu^',n,'_t(\omega)$'); 
else   
    yLabelStr = strcat('$<t^',n,'>_\omega$'); 
end

end
