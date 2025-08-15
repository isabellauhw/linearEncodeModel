function name = evaluateNameTemplate(template, vars, groupingFunc)
% *evaluateNameTemplate*: a helper function that helps evaluating nameTemplate (from the struct provide)
% per trial over a loop across the table table. Essentially, loop through
% the data table, find the combination of variable pairings, assign it to
% to a regressor (e.g., stimulusL00625 = stimulus presented on the left side at 6.25% contrast)

% Allow the user to override vars before evaluating
if nargin >= 3 && isa(groupingFunc, 'function_handle')
    vars = groupingFunc(vars);
end
name = template;
flds = fieldnames(vars);
for i = 1:length(flds)
    fld = flds{i};
    val = vars.(fld);
    name = strrep(name, ['{' fld '}'], string(val));
end
end

