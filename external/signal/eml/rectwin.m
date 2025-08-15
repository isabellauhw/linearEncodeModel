function w = rectwin(n_est)
%MATLAB Code Generation Library Function

% Copyright 2008-2018 The MathWorks, Inc.
%#codegen 

[n,trivialwin] = check_order(n_est);

if trivialwin
    w = zeros(0,1);
    return
end

w = ones(n,1);

end
