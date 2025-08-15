function matchingFields = findMatchingFields(obj, baseVar)
% - *matchingFields*: a helper function for getDesignMatrix, returns all field names in obj that start with baseVar
    allFields = fieldnames(obj);
    matchingFields = allFields(startsWith(allFields, baseVar));
end
