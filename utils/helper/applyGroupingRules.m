function vars = applyGroupingRules(vars, groupingRules)
% *applyGroupingRules*: a helper function that deals with special rule in defining regressors. 
% Mainly use when there is a certain combination of regressors needed to be
% lumped together (e.g., stimContrast0, combining the presentation of left and right stim apart)
    fields = fieldnames(groupingRules);
    for i = 1:numel(fields)
        key = fields{i};
        rule = groupingRules.(key);
        if ischar(rule) || isstring(rule)
            % If rule is a string like '0', and matches the value
            if isfield(vars, key) && strcmp(vars.(key), rule)
                % leave it unchanged; other fields may handle the grouping
                continue;
            end
        elseif isstruct(rule)
            % If rule is a struct mapping values to a shared group
            val = vars.(key);
            if isfield(rule, val)
                vars.(key) = rule.(val);
            end
        end
    end
end
