function p = propstosync(this)
%PROPSTOSYNC   

%   Copyright 2005-2012 The MathWorks, Inc.

mc = metaclass(this);
pstruct = mc.PropertyList;

pNames = {pstruct.Name};
pAccess = {pstruct.SetAccess};
pexclude = {'Fs','NormalizedFrequency','FromFilterDesigner'};

% Return a cell array p of property names for properties that are public
% and that are not excluded
ind_ex = cellfun(@(x)~any(strcmp(pexclude,x)),pNames,'UniformOutput',false);
ind_public = cellfun(@(x)strcmp('public',x),pAccess,'UniformOutput',false);
ind_keep = cell2mat(ind_public)&cell2mat(ind_ex);
p = pNames(ind_keep);

p = thispropstosync(this,p(:));

