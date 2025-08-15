function [estType1,arglist] = psdesttype(validtypes,defaulttype,arglist)
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

%   Copyright 2019 The MathWorks, Inc.

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

% LocalWords:  validtypes defaulttype arglist esttype
