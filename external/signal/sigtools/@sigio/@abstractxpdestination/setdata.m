function data = setdata(this,data)
%SETDATA

%   Author(s): P. Costa
%   Copyright 1988-2017 The MathWorks, Inc.

if isa(data, 'sigutils.vector') && ~strcmpi(class(elementat(data, 1)),'double')
    set(this,'privData',data);
else
    datamodel = this.privData;
    if isempty(datamodel)
        datamodel = sigutils.vector;
        set(this, 'privData', datamodel);
    else
        datamodel.clear;
    end
    if ~iscell(data), data = {data}; end
    for indx = 1:length(data)
        if strcmpi(class(data{indx}),'double')
            data{indx} = sigutils.vector(50, data{indx});
        end
        
        datamodel.addelement(data{indx});
    end
end

set(this, 'VariableCount', length(data));

% [EOF]
