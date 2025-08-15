function varargout = tfmomentCompute(tfd,t,f,tforder,IsCentral,TimeRange,FrequencyRange)
%TFMOMENTCOMPUTE computes joint time-frequency moment of the time-frequency
%distribution
%
%   tfd is a n-by-m matrix of time frequency distribution.
%   t is a m-by-1 time vector.
%   f is a n-by-1 frequency vector.
%   tforder is a k-by-2 matrix where the first column denotes the order of
%   time and the second column denotes the order of frequency.
%   IsCentral specifies the centrality of the moment.
%   TimeRange specifies the time range to calculate the  moment.
%   FrequencyRange specifies the frequency range to calculate the moment.
%

%   This function is for internal use only. It may be removed. 

%   Copyright 2017 The MathWorks, Inc. 


% Compute the conditional spectral moment
[fminIdx, fmaxIdx] = signal.internal.utilities.getEffectiveRangeIdx(f,FrequencyRange);
fInFrame = f(fminIdx:fmaxIdx);
[tminIdx, tmaxIdx] = signal.internal.utilities.getEffectiveRangeIdx(t,TimeRange);
tInFrame = t(tminIdx:tmaxIdx);
tfd = tfd(fminIdx:fmaxIdx,tminIdx:tmaxIdx);
tfd = tfd/sum(tfd(:));
marginalTimePDF = sum(tfd);
marginalFrequencyPDF = sum(tfd,2);

temp1 = zeros(1,size(tfd,2));
if IsCentral
    for i = 1:length(fInFrame)
        temp1(1,:) = temp1(1,:)+fInFrame(i)*tfd((i),:);
    end
    conditionaSpectralMean = temp1./marginalTimePDF;
else
    conditionaSpectralMean = temp1;
end

temp2 = zeros(size(tfd,1),1);
if IsCentral
    for i = 1:length(tInFrame)
        temp2(:,1) = temp2(:,1)+tInFrame(i)*tfd(:,i);
    end
    conditionaTemporalMean = temp2./marginalFrequencyPDF;
else
    conditionaTemporalMean = temp2;
end

jointMoment = zeros(1,size(tforder,1));

for k = 1:size(tforder,1)
    torder = tforder(k,1);
    forder = tforder(k,2);
    temp = 0;
    for j = 1:length(fInFrame)
        for i = 1:length(tInFrame)
            temp = temp+(tInFrame(i)-conditionaTemporalMean(j))^torder*...
                (fInFrame(j)-conditionaSpectralMean(i))^forder*tfd(j,i);
        end
    end
    jointMoment(k) = temp;
end

varargout{1} = jointMoment;

end

