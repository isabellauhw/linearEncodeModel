function fullR = getEventDesignMatrix(obj, options)
    % *getEventDesignMatrix*: a function that combines all behavioural together
    % into a non-time shifted design matrix (concatenation). Essential to
    % separate it with video or trial regressors as this needs to be
    % expanded
    
    % INPUT:
    % - *obj*: (can be kept empty) the *object instance* of the class linearEncodeModel
    % that was previously created, in MATLAB this is just a syntax
    % to call the function as it belongs to the method of the class
    % linearEncodeModel()
    % - *options*: the configuration struct that is defined at the
    % beginning of the analysis

    % OUTPUT:
    % - *fullR*: a *table* that contains the non-time shifted
    % behavioural and video PCs regressors.

    varDefs = options.variableDefs;
    nTimepoints = numel(obj.globalTime);
    allData = {};
    allNames = {};

    defNames = fieldnames(varDefs);

    for i = 1:numel(defNames)
        def = varDefs.(defNames{i});

        % Skip types that are not 'event'
        if ~ismember(def.type, {'event'})
            continue;
        end

        % Process each base variable name
        for j = 1:numel(def.vars)
            baseVar = def.vars{j};

            % Get all fields in obj that start with baseVar
            matchingFields = findMatchingFields(obj, baseVar);

            for k = 1:numel(matchingFields)
                fName = matchingFields{k};
                dataCol = obj.(fName);

                % Only include if it's a column vector of length nTimepoints
                if isvector(dataCol) && size(dataCol, 1) == nTimepoints
                    if ~ismember(fName, allNames) % skip duplicates
                        allData{end+1} = double(dataCol(:));  % ensure column vector
                        allNames{end+1} = fName;
                    end
                else
                    continue;
                end
            end
        end
    end

    % Combine into a table
    fullR = table(allData{:}, 'VariableNames', allNames);
end
