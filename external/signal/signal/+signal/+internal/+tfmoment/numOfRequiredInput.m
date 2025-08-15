function RequiredInputLen = numOfRequiredInput(varargin)
%NUMOFREQUIREDINPUT return the number of inputs before the first char array or string.

%   This function is for internal use only. It may be removed. 
%   Copyright 2017-2019 The MathWorks, Inc. 

%#codegen

for n = 1:numel(varargin)
    if isa(varargin{n},'char')||isa(varargin{n},'string')
        RequiredInputLen = n-1;
        break
    end
    RequiredInputLen = n;
end

end
