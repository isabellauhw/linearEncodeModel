function [labelValue,labelLocs] = peakLabeler(x,t,~,parentLabelLocs,varargin)
%PEAKLABELER callback method for peakLabeler
nameValePair = varargin; 
functionHandle= @islocalmax;
if strcmp(nameValePair(2),'minima')
    functionHandle= @islocalmin;
end

if ~isempty(parentLabelLocs)
    % For ROI and Point parentLabel extract the signal within parentLabelLocs
    tStart = parentLabelLocs(1);
    tEnd = parentLabelLocs(end);
    indexVector = t>=tStart & t<=tEnd;
    x = x(indexVector);
    t = t(indexVector);
end
% Check if other nameValePair was specified
if numel(nameValePair)>2
    peakIdx = functionHandle(x,'SamplePoints',t,nameValePair{3:end});
else
    peakIdx = functionHandle(x,'SamplePoints',t);
end

labelValue= x(peakIdx);
labelLocs = t(peakIdx);
labelValue =labelValue(:);
labelLocs =labelLocs(:);
end

