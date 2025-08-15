function struct2param(hPrm, struct)
%STRUCT2PARAM Set the parameters with the information in a structure

%    Author(s): J. Schickler & P. Costa
%    Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);

if ~isempty(struct)
    
    tags = fieldnames(struct);
    
    for i = 1:length(tags)
        h = find(hPrm, 'Tag', tags{i});
        if ~isempty(h)
            setvalue(h, struct.(tags{i}));
        end
    end
end

% [EOF]
