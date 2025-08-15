function help_header(this, method, description, type)
%HELP_HEADER   Generic help.

%   Copyright 1999-2015 The MathWorks, Inc.

disp(sprintf('%s\n%s', ...
    sprintf(' DESIGN Design a %s %s filter.', description, type), ...
    sprintf('    HD = DESIGN(D, ''%s'') designs a %s filter specified by the\n    FDESIGN object D, and returns the DFILT/MFILT object HD.', ...
    method, description)));
disp(' ');

do = designopts(this);
supportsSysObj = ~isempty(do) && isfield(do,'SystemObject');
if supportsSysObj
  disp(sprintf('%s\n%s', ...
    sprintf('    HD = DESIGN(D, ..., ''SystemObject'', true) implements the filter, HD,'),...
    sprintf('    using a System object instead of a DFILT/MFILT object.')));
  disp(' ');  
end  

validstructs = getvalidstructs(this);

helpstr = sprintf('    HD = DESIGN(..., ''FilterStructure'', STRUCTURE) returns a filter with the\n');
helpstr = sprintf('%s    structure STRUCTURE.  STRUCTURE is ''%s'' by default and can be any of\n', ...
    helpstr, this.FilterStructure);
helpstr = sprintf('%s    the following:', helpstr);
helpstr = sprintf('%s\n', helpstr);
for indx = 1:length(validstructs)
    helpstr = sprintf('%s\n    ''%s''', helpstr, validstructs{indx});
end

disp(helpstr);

if supportsSysObj
  disp(' ');
  disp(sprintf('%s\n%s\n%s', ...
    sprintf('    Some of the listed structures may not be supported by System object'),...
    sprintf('    filters. Type validstructures(D, ''%s'', ''SystemObject'', true) to',method),...
    sprintf('    get a list of structures supported by System objects.')));    
end  

disp(' ');

% [EOF]
