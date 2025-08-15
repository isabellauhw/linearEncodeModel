function x = ensureTallColumnMatrixOrTimetable(x)
% Ensure that X is a tall column vector, a tall matrix, a tall timetable
% with only one variable that is a column vector or a matrix, or a tall
% timetable with multiple variables that are a column vector each. Throw a
% comprehensive error from the tall message catalog.

%   Copyright 2019 The MathWorks, Inc.

narginchk(1, 1);
nargoutchk(1, 1);

adaptorX = matlab.bigdata.internal.adaptors.getAdaptor(x);
if adaptorX.Class == "timetable"
    numVars = width(x);
    if numVars > 1
        % Timetable with multiple variables: column vector each.
        for ii = 1:numVars
            x = tall.validateTrue(x, size(subsref(x, substruct('{}', {':', ii})), 2) == 1, 'signal:tall:TallInputMustBeColumnMatrixOrTimetable');
        end
    else
        % Timetable with only one variable: column vector or matrix.
        x = tall.validateTrue(x, ismatrix(subsref(x, substruct('{}', {':', 1}))), 'signal:tall:TallInputMustBeColumnMatrixOrTimetable');
    end
else
    x = tall.validateMatrix(x, 'signal:tall:TallInputMustBeColumnMatrixOrTimetable');
    x = tall.validateNotRow(x, 'signal:tall:TallInputMustBeColumnMatrixOrTimetable');
end