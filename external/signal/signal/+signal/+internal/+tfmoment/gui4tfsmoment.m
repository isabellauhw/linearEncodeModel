function [t4plot, xLabelStr,yLabelStr]=gui4tfsmoment(forder,t,IsCentral)
%GUI4TFSMOMENT generate the string for labels of the plot of tfsmoment

%   Copyright 2017 The MathWorks, Inc.

n = num2str(forder);
if isa(t,'double')||isa(t,'single')
    [t4plot,~,u] = engunits(t,'time');
    xLabelStr = [getString(message('signal:tfmoment:time4tfsmoment')) ' (' u ')'];
elseif isa(t, 'duration')
    [t4plot,~,u] = engunits(seconds(t),'time');
    xLabelStr = [getString(message('signal:tfmoment:time4tfsmoment')) ' (' u ')'];
else
    t4plot = t;
    xLabelStr = getString(message('signal:tfmoment:time4tfsmoment'));
end

if IsCentral
    yLabelStr = strcat('$\mu^', n,'_\omega(t)$');
else  
    yLabelStr = strcat('$<\omega^',n,'>_t$');
end

end


