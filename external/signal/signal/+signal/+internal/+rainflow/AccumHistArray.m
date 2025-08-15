function A = AccumHistArray(subs,sz,isSingle)
%ACCUMHISTARRAY Codegen version of accumarray for 2D histograms
%   This function is for internal use only. It may be removed. 

%   Copyright 2017 The MathWorks, Inc.

%#ok<*EMCLS>
%#ok<*EMCA>
%#codegen

if isSingle
  A = zeros(sz,'like',single(0));
else
  A = zeros(sz); 
end

for i = 1:size(subs,1)
  A(subs(i,1),subs(i,2)) = A(subs(i,1),subs(i,2)) + 1; 
end

end