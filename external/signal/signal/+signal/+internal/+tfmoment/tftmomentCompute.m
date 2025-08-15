function varargout = tftmomentCompute(tfd, t, torder,IsCentral,TimeRange)
%TFTMOMENTCOMPUTE computes conditional temporal moment of the time-frequency
%distribution.
%   tfd is a n-by-m matrix of time frequency distribution.
%   t is a m-by-1 time vector .
%   torder is a k-by-1 matrix which denotes the order of time.
%   IsCentral specifies the centrality of the moment.
%   TimeRange specifies the time range to calculate the  moment.
%

%   This function is for internal use only. It may be removed. 

%   Copyright 2017 The MathWorks, Inc. 


% Compute the conditional spectral moment
[tminIdx, tmaxIdx] = signal.internal.utilities.getEffectiveRangeIdx(t,TimeRange);
tInFrame = t(tminIdx:tmaxIdx);
tfd = tfd(:,tminIdx:tmaxIdx);
tfd = tfd/sum(tfd(:));
marginalFrequencyPDF = sum(tfd,2);

temp = zeros(size(tfd,1),1);
if IsCentral
     
    for i = 1:length(tInFrame)
        temp(:,1) = temp(:,1)+tInFrame(i)*tfd(:,i);
    end
    conditionalMean = temp./marginalFrequencyPDF;
else
    conditionalMean = 0;
end

temporalMoment = zeros(length(torder), size(tfd,1));
temp = zeros(size(tfd,1),1);
for j = 1:length(torder)
    
    for i = 1:length(tInFrame)
        temp(:,1) = temp(:,1)+(tInFrame(i)-conditionalMean).^torder(j).*tfd(:,i);
    end
    temporalMoment(j,:) = (temp./marginalFrequencyPDF)';
    temp(:) = 0;
end

varargout{1} = temporalMoment;

end
