function varargout = tfsmomentCompute(tfd, f, forder, IsCentral,FrequencyRange)
%TFSMOMENTCOMPUTE computes conditional spectral moment of the time-frequency
%distribution.
%   tfd is a n-by-m matrix of time frequency distribution.
%   f is a n-by-1 frequency vector.
%   forder is a k-by-1 matrix which denotes the order of frequency.
%   IsCentral specifies the centrality of the moment.
%   FrequencyRange specifies the frequency range to calculate the moment.
%

%   This function is for internal use only. It may be removed. 

%   Copyright 2017-2019 The MathWorks, Inc. 

%#codegen

% Compute the conditional spectral moment
[fminIdx, fmaxIdx] = signal.internal.utilities.getEffectiveRangeIdx(f,FrequencyRange);
fInFrame = f(fminIdx:fmaxIdx);
tfd = tfd(fminIdx:fmaxIdx,:);
tfd = tfd/sum(tfd(:));
marginalTimePDF = sum(tfd);

temp = zeros(1,size(tfd,2));
if IsCentral 
    for i = 1:length(fInFrame)
        temp(1,:) = temp(1,:)+fInFrame(i)*tfd((i),:);
    end
    conditionalMean = temp./marginalTimePDF;
else
    conditionalMean = 0;
end

spectralMoment = zeros(length(forder), size(tfd,2));
temp = zeros(1,size(tfd,2));
for j = 1:length(forder) 
    for i = 1:length(fInFrame)
        temp(1,:) = temp(1,:)+(fInFrame(i)-conditionalMean).^forder(j).*tfd((i),:);
    end
    spectralMoment(j,:) = temp./marginalTimePDF;
    temp(:) = 0;  
end

varargout{1} = spectralMoment;

end
