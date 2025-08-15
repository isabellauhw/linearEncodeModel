function s = thisdesignopts(this, s, N)
%THISDESIGNOPTS   

%   Copyright 1999-2017 The MathWorks, Inc.

if nargin < 3
    % Called by info method
    NBands = this.privNBands;  
else    
   NBands = N;
end

for k = NBands+1:10
  str = [sprintf('B%d',k),'Weights'];
  s = rmfield(s, str);
end

% [EOF]
