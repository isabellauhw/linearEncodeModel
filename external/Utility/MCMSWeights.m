function MCMSWeights(sheet, mice)
% MCMSWEIGHTS  Makes the mouse weight spreadsheet readable for MCMS.
%   MCMSWEIGHTS(filename, names) returns an .xlsx file formatted for MCMS.
%
%   Example input:
%   MCMSWeights('Mice_on_water_control.xlsx', {'AMR039', 'AMR040', 'AMR041', 'AMR042', 'AMR043', 'AMR044', 'AMR045', 'AMR046', 'AMR047', 'AMR048', 'AMR049'})
% 
%   This would return weights for each of the mice listed.

if ~isstring(sheet) && ~ischar(sheet)
    error('Filename must be a string or a char, not a %s.', class(sheet))
    return %#ok<*UNRCH>
end

if ~iscell(mice)
    error('Names must be a cell array, not a %s.', class(mice))
    return
end

[~, sheet_name] = xlsfinfo(sheet);

mouse_name = [];
date = [];
weight = [];

for k = 1 : numel(mice)
    if ~any(strcmp(sheet_name, mice{k}))
        warning('%s not found\n', mice{k})
    else
        fprintf('%s found, adding to table\n', mice{k})
        index = find(contains(sheet_name, mice{k}));
        data = readtable('Mice_on_water_control.xlsx', 'Sheet', sheet_name{index}); %#ok<FNDSB>

        mouse_name = [mouse_name; table2array(data(:,1))]; %#ok<*AGROW>
        date = [date; table2array(data(:,2))];
        weight = [weight; table2array(data(:,3))];
        
    end
end

T = table(mouse_name, date, weight);
T = rmmissing(T);
filename = sprintf('mouse_weights_%s.xlsx', datestr(now, 'mm-dd-yyyy_HH-MM'));
writetable(T, filename)
fprintf('Mouse weights saved in MCMS format as %s\n', filename)