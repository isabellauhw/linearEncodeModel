function success = action(hObj)
%ACTION Perform the action of the SOS dialog

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

success = true;

filtobj = get(hObj, 'Filter');

inputs = {get(hObj, 'Direction')};

% Map proper SOS scaling strings 
if isa(filtobj, 'dfilt.df2') || isa(filtobj, 'dfilt.df2sos')
    
    scale = get(hObj, 'Scale');
    switch scale
    case 'L-2'
        inputs = {inputs{:}, 2};
    case 'L-infinity'  
        inputs = {inputs{:}, inf};
    end
end
   
% Convert dfilt objects to second-order section form.
data.filter = sos(filtobj, inputs{:}); 
data.mcode  = genmcode(hObj);

send(hObj, 'NewFilter', ...
    sigdatatypes.sigeventdata(hObj, 'NewFilter', data));

% [EOF]
