function str = validvaluestring(hPrm)
%VALIDVALUESTRING Returns the valid value in string form

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

vValues = hPrm.ValidValues;

if isa(vValues, 'function_handle')
    
    % Display the function handle as it would appear by itself
    str = ['@' func2str(vValues)];
elseif iscell(vValues)

    % Loop over the valid values and wrap them in single quotes
    str = '';
    for i = 1:length(vValues)
        str = [str '''' vValues{i} ''' '];
    end
else
    
    % Display the range
    mssgObj = message('signal:sigdatatypes:parameter:validvaluestring:AtoB',num2str(vValues(1)),num2str(vValues(end)));
    str = getString(mssgObj);
    
    % If there are 3 elements, the middle must be the step
    if length(vValues) == 3
        mssgObj = message('signal:sigdatatypes:parameter:validvaluestring:InSteps',num2str(vValues(2)));
        str = [str ' ' getString(mssgObj)];
    end
end

% [EOF]
