function y = goertzelImpl(input,freqIndices,isInputComplex,outExample)
%#codegen
%Generalized Goertzel Algorithm
%Reference : Goertzel algorithm generalized to non-integer multiples of fundamental frequency
% by Peter Sysel and Pavel Rajmic 

%Copyright 2018 The MathWorks, Inc.

sz = size(input);
numFreq = length(freqIndices); %number of frequencies to compute

% Initialize Y with the correct dimension
y = coder.nullcopy(zeros(numFreq,sz(2),'like',outExample));

type = class(outExample);

if isInputComplex
    x = complex(zeros(1,1,type));
else
    x = zeros(1,1,type);
end

for i=1:sz(2)
    
    len = sz(1);
    
    data = input(:,i);

    %memory allocation for the output coefficients
    y1 = coder.nullcopy(zeros(numFreq,1,'like',outExample));

    for freqIndex = 1:numFreq
        
        twiddleFactor = 2*pi*(freqIndices(freqIndex))/(len);
        cos2TwidFactor = 2*cos(twiddleFactor);
        complexConstant = exp(-1i*twiddleFactor);
        phaseCorrection = exp(-1i*twiddleFactor * (len -1));

        s1 = zeros('like',x);
        s2 = zeros('like',x);

        for ind = 1:(len-1)

            s0 = data(ind) + cos2TwidFactor*s1 - s2;  %s[n] = x[n] + 2cos(w0)s[n-1] - s[n-2]
            s2 = s1; 
            s1 = s0;
        end


        s0 = data(len) + cos2TwidFactor*s1 - s2; % evaluate n+1 times with x[n+1]=0;

        %y[n] = s[n] - exp(-j*w0) s[n-1]
        y1(freqIndex) = (s0-s1*complexConstant) *phaseCorrection;

    end
    
     y(:,i) = y1(:);
end

end

% LocalWords:  Sysel Rajmic
