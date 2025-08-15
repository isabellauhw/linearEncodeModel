function obj = buildEventRegressors(obj, options)
    % *buildEventRegressors*: a function that help to load the
    % regressors and compile them into a *non-time shifted, non-expanded*
    % design matrix.
    
    % INPUT:
    % - *obj* (can be kept empty): the object instance from the linearEncodeModel class that was
    % created previously, in MATLAB this is just a syntax
    % to call the function as it belongs to the method of the class
    % linearEncodeModel()
    % - *options*: the configuration struct that is defined at the
    % beginning of the analysis
    
    % OUTPUT:
    % - *obj* (can be other names that you have defined previously):
    % the object instance from the linearEncodeModel class that has
    % seperate subfields that contains the defined behavioural regressors
    % of the non-time shifted design matrix

 arguments
        obj struct
        options struct
    end

    % Basic validation
    if ~isfield(options, 'variableDefs')
        error('Missing field: options.variableDefs');
    end

    eventGroups = fieldnames(options.variableDefs);

    for iG = 1:numel(eventGroups)
        groupName = eventGroups{iG};
        groupDef = options.variableDefs.(groupName);

        if ~strcmp(groupDef.type, 'event')
            continue;  % skip non-event groups
        end

        vars = groupDef.vars;
        timeRef = groupDef.timeRef;

        % Handle both string and cell timeRef
        if iscell(timeRef)
            if numel(timeRef) > 2
                warning('timeRef contains more than 2 entries; using only the first one.');
            end
            timeRef = timeRef{1};  % Use first one if multiple
        end

        if ~ismember(timeRef, obj.bhv.Properties.VariableNames)
            warning('Time reference "%s" not found in obj.bhv. Skipping group "%s".', timeRef, groupName);
            continue;
        end

        for iV = 1:numel(vars)
            varName = vars{iV};

            if ~ismember(varName, obj.bhv.Properties.VariableNames)
                warning('Variable "%s" not found in obj.bhv. Skipping.', varName);
                continue;
            end

            fieldName = matlab.lang.makeValidName(varName);
            regVector = zeros(numel(obj.globalTime), 1);

            for iTrial = 1:height(obj.bhv)
                val = obj.bhv.(varName)(iTrial);
                eventTime = obj.bhv.(timeRef)(iTrial);

                if isnan(val) || isnan(eventTime)
                    continue;
                end

                % Mark the closest time index in globalTime
                [~, timeIdx] = min(abs(obj.globalTime - eventTime));
                regVector(timeIdx) = val;
            end

            obj.(fieldName) = regVector;
        end
    end
end
