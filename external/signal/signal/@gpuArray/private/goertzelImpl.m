function Y = goertzelImpl(X,freqIndices)
%GOERTZELIMPL Carries out the Goertzel algorithm for gpuArrays

%   Copyright 2020 The MathWorks, Inc.

szX = size(X);
freqIdx = gpuArray.colon(1,length(freqIndices))';
rowIdx = gpuArray.colon(1,szX(2));
pageIdx = reshape(gpuArray.colon(1,size(X,3)),1,1,[]);
XPrototype = cast(0,"like",X);

Y = arrayfun(@iDoGoertzel,freqIdx,rowIdx,pageIdx);

% Goertzel algorithm using arrayfun with binary expansion
    function Y = iDoGoertzel(myFreqIndex,myCol,myPage)
        twiddleFactor = 2*pi*(freqIndices(myFreqIndex))/(szX(1));
        cos2TwidFactor = 2*cos(twiddleFactor);
        complexConstant = exp(-1i*twiddleFactor);
        phaseCorrection = exp(-1i*twiddleFactor*(szX(1)-1));
        
        s1 = XPrototype;
        s2 = s1;
        
        for index = 1:(szX(1)-1)
            s0 = X(index,myCol,myPage) + cos2TwidFactor*s1 - s2;
            s2 = s1;
            s1 = s0;
        end
        s0 = X(szX(1),myCol,myPage) + cos2TwidFactor*s1 - s2;
        Y = (s0-s1*complexConstant)*phaseCorrection;
    end

end