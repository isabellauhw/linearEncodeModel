function flag = sigcheckfloattype(x, dataType, fcnName, varName, datacheckflag)
%SIGCHECKFLOATTYPE Check if input x is floating point or numeric and of the
%expected data type
%
% Inputs:
% x             - input data
% dataType      - data type we want to check ('single','double','int8',...)
%                 if set to empty ('') then we do not check for a specific
%                 data type. We only check if data is floating point or
%                 numeric depending on the datacheckflag input.
% fcnName       - function name
% varName       - variable name
% datacheckflag - can be 'allowfloat' or 'allownumeric'. Default is
%                 'allowfloat'. When set to 'allowfloat' the function
%                 checks if data is floating point and then checks if data
%                 is of the specified dataType type. When set to
%                 'allownumeric' the function checks if data is numeric and
%                 then checks if data is of the specified dataType type.
%
% Outputs:
% flag          - true if data is of type dataType


%   Copyright 2013 The MathWorks, Inc.

%#codegen

if nargin < 3
    fcnName = '';
    varName = '';
    datacheckflag = 'allowfloat';
end
if  nargin < 4
    varName = '';
    datacheckflag = 'allowfloat';
end
if nargin < 5
    datacheckflag = 'allowfloat';
end

if strcmpi(datacheckflag,'allowfloat')
  condcheck = true;
  typeCheck = isfloat(x);
elseif strcmpi(datacheckflag,'allownumeric')
  condcheck = false;
  typeCheck = isnumeric(x);
else
  datacheckstr = validatestring(datacheckflag,{'allowfloat','allownumeric'},fcnName,...
      'Data check flag');
  condcheck = strcmpi(datacheckstr,'allowfloat');
  if condcheck
      typeCheck = isfloat(x);
  else
      typeCheck = isnumeric(x);
  end
end    
expType_float = 'double/single';
expType_numeric = 'numeric';

cond1 = ~typeCheck;
cond2 = ~isempty(fcnName);
cond3 = ~isempty(varName);
if cond1
    cond = cond1 && cond2 && cond3;
    if cond
        if condcheck
            coder.internal.errorIf(cond,...
                'signal:sigcheckfloattype:InvalidInput',...
                varName, fcnName, expType_float, class(x));
        else
            coder.internal.errorIf(cond,...
                'signal:sigcheckfloattype:InvalidInput',...
                varName, fcnName, expType_numeric, class(x));
        end
    end
    cond = cond1 && cond2 && ~cond3;
    if cond
        if condcheck
            coder.internal.errorIf(cond,...
                'signal:sigcheckfloattype:InvalidInput1',...
                fcnName, expType_float, class(x));
        else
            coder.internal.errorIf(cond,...
                'signal:sigcheckfloattype:InvalidInput1',...
                fcnName, expType_numeric, class(x));
        end
    end
    cond = cond1 && ~cond2 && cond3;
    if cond
        if condcheck
            coder.internal.errorIf(cond,...
                'signal:sigcheckfloattype:InvalidInput2',...
                varName, expType_float, class(x));
        else
            coder.internal.errorIf(cond,...
                'signal:sigcheckfloattype:InvalidInput2',...
                varName, expType_numeric, class(x));
        end
    end
    cond = cond1 && ~cond2 && ~cond3;
    if cond
        if condcheck
            coder.internal.errorIf(cond,...
                'signal:sigcheckfloattype:InvalidInput3',...
                expType_float, class(x));
        else
            coder.internal.errorIf(cond,...
                'signal:sigcheckfloattype:InvalidInput3',...
                expType_numeric, class(x));
        end
    end
    
end

flag = isa(x,dataType);
