function [estType1,arglist,estIdx1] = psdesttype(validtypes,defaulttype,arglist)
%#codegen
%PSDESTTYPE - return the PSD estimation type option
%
%   validtypes  - a cell array of valid estimator types
%                 (e.g. {'power','ms','psd'})
%
%   defaulttype - the default type to use if no type is found
%
%   arglist    - the input argument list
%
%   Errors out if different estimation types are specified in arglist.
%
%   Additionally, for code generation, the function returns the index of
%   the PSD estimation type option, estIdx1, as in the input argument list,
%   arglist. Returns 0 if the option is absent.

%   Copyright 2012-2019 The MathWorks, Inc.

if isempty(coder.target) % For MATLAB execution
    esttype = defaulttype;
    found = false;

    for i=1:numel(validtypes)
        matches = find(strcmpi(validtypes{i},arglist));
        if ~isempty(matches)
            if ~found
                found = true;
                esttype = validtypes{i};               
                arglist(matches) = [];               
            else
                error(message('signal:psdoptions:ConflictingEstTypes',esttype,validtypes{i}));
            end
        end
    end
    estType1 = esttype;
    estIdx1 = 0;
else       % For Code generation     
    found = false;
    allConst = true;
    estIdx = 0;
    for i = 1:numel(arglist)
        if ischar(arglist{i})
            allConst = allConst && coder.internal.isConst(arglist{i});
        end
    end
    if ~allConst
        % If character array inputs are not compile-time constants,
        % we predefine the output. This is not required for compile-time
        % constant character arrays. Predefining the output if the inputs
        % are compile-time constants would make the output esttype
        % variable-sized.
        esttype = defaulttype;
    end

    for i = coder.unroll(1:numel(validtypes))
        for j = 1:numel(arglist)
            if ischar(arglist{j}) && strcmpi(arglist{j},validtypes{i})
                if ~found
                    esttype = arglist{j};
                    found = true;
                    estIdx = j;
                    break;
                end
                coder.internal.assert(~found,...
                    'signal:psdoptions:ConflictingEstTypes',esttype,validtypes{i});
            end
        end
    end

    if ~found
        estType1 = defaulttype;
        estIdx1 = 0;
    else
        estType1 = esttype;
        estIdx1 = estIdx;
    end
end

% LocalWords:  validtypes defaulttype arglist esttype
