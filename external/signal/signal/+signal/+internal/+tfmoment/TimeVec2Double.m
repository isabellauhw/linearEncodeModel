function tout = TimeVec2Double(tx)
%

%   Copyright 2017 The MathWorks, Inc.

if isa(tx,'double')
    % xt is time vector   
    tout = tx;  
elseif isduration(tx)   
    tout = seconds(tx(:));  
elseif isdatetime(tx)
    tx = tx-tx(1);
    tout = seconds(tx);   
else
    % No Op
end
end
