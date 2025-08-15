function [trialLabels, trialMat, trialIdx] = createTrialDesignMatrix(obj, options)
    % *createTrialDesignMatrix*: generates a design matrix for trial regressors
    % over the non-overlapping, non-expanded time windows (concatenation).
    
    % INPUT:
    % - *obj*: linearEncodeModel instance (for time parameters)
    % - *fullR*: a table containing all regressors
    % - *options*: a configuration struct that is defined at the beginning of
    % the analysis
    
    % OUTPUT:
    % - *trialLabels*: a list of strings showing the regressor names for the
    % trial regressors (e.g., previous trial choice, previous trial difficulty, averaged trial motion energy)
    % - *trialMat*: matrix [frames x number of trial regressors]
    % - *trialIdx*: [number of trial regressors x 1], each element is the regressor index

trialLabels = {};
trialDataCells = {};

varDefs = options.variableDefs;
varNames = fieldnames(varDefs);

for i = 1:numel(varNames)
    key = varNames{i};
    def = varDefs.(key);
    
    if isfield(def, 'type') && strcmp(def.type, 'trial')
        vars = def.vars;
        for v = 1:numel(vars)
            varName = strcat('trial_', vars{v});
            
            if isfield(obj, varName)
                data = obj.(varName);
               
                % Single column data
                trialLabels{end+1} = varName;
                trialDataCells{end+1} = data(:);

            else
                error('Variable "%s" not found as a field in obj.', varName);
            end
        end
    end
end

trialMat = cat(2, trialDataCells{:});
trialIdx = (1:numel(trialLabels))';