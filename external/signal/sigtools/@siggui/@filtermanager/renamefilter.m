function renamefilter(this, indx)
%RENAMEFILTER   Rename the specified filter.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

if nargin < 2
    indx = get(this, 'SelectedFilters');
end

for i = 1:length(indx)
    s{i} = this.Data.elementat(indx(i));
    prompts{i} = getString(message('signal:siggui:filtermanager:renamefilter:Enternewfiltername'));
    defvals{i} = s{i}.currentName;
end

answer = inputdlg(prompts, ...
                  getString(message('signal:siggui:filtermanager:renamefilter:RenameFilter')), ...
                  1, defvals);

if isempty(answer)
    return;
end

if any(strcmpi(answer, ''))
    return;
end

% Check that none of the new names dont overlap with the existing names.
allnames = getnames(this);

% First replace all the new names into the string vector in case the user
% is trying to swap names, we don't want to error.
for jndx = 1:length(answer)
    allnames{indx(jndx)} = answer{jndx};
end    

if length(unique(allnames)) ~= length(allnames)
    error(message('signal:siggui:filtermanager:renamefilter:GUIErr'));
end

for jndx = 1:length(indx)
   s{jndx}.currentName = answer{jndx};

   this.Data.replaceelementat(s{jndx}, indx(jndx));
end

send(this, 'NewData');

% [EOF]
