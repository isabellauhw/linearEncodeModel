function [data, info] = readDatastoreSignalFromCSV(fileName,signalVariableNames,timeInfoType,timeVariableName)
%Default .csv file read function for signalDatastore
% signalVariableNames, timeVariableName must be strings
%For internal use only. It may be removed.

%   Copyright 2019 The MathWorks, Inc.

% set variableNamesFoundInFile to NaN in case detectImportOptions fails - we do not want to
% error out with a message about vars not found in a detectImportOptions
% error case.
variableNamesFoundInFile = NaN;

try
    opts = detectImportOptions(fileName,'PreserveVariableNames',true);
    
    if isempty(signalVariableNames)
        variableNamesFoundInFile = opts.VariableNames;
        if isempty(timeInfoType)
            varNames = string(variableNamesFoundInFile{1});
            opts.SelectedVariableNames = varNames;
        else
            variableNamesFoundInFile(strcmp(variableNamesFoundInFile,timeVariableName)) = [];
            varNames = string(variableNamesFoundInFile{1});
            opts.SelectedVariableNames = [varNames; string(timeVariableName)];
        end
    else
        varNames = string(signalVariableNames);
        if isempty(timeInfoType)
            opts.SelectedVariableNames = varNames;
        else
            opts.SelectedVariableNames = [varNames, string(timeVariableName)];
        end
    end
    
    T = readtable(fileName,opts);
    if numel(varNames) > 1
        data = mat2cell(T{:,varNames},size(T,1),ones(numel(varNames),1)).';
    else
        data = T.(varNames);
    end
    
    if isempty(timeInfoType)
        info = [];
    else
        if timeInfoType == "TimeValues"
            info.(timeInfoType) = T.(timeVariableName);
        else
            info.(timeInfoType) = T.(timeVariableName)(1);
        end
        info.TimeVariableName =  string(timeVariableName);
    end
    info.SignalVariableNames =  string(varNames);
catch ME
    if string(ME.identifier) == "MATLAB:textio:io:UnknownVarName"
        varNamesNotFound = [];
        if ~isempty(signalVariableNames) 
            idx = ~ismember(signalVariableNames,opts.VariableNames);
            if any(idx)
                varNamesNotFound = string(signalVariableNames(idx));
            end
        end
        if ~isempty(timeVariableName) && ~isfield(timeVariableName,opts.VariableNames)
            varNamesNotFound = [varNamesNotFound(:); string(timeVariableName)];
        end
        if numel(varNamesNotFound) == 1
            error(message('signal:signalDatastore:signalDatastore:VariableNotFoundInFile',varNamesNotFound,fileName));
        else
            str = join(varNamesNotFound,"', '");
            error(message('signal:signalDatastore:signalDatastore:VariablesNotFoundInFile',str,fileName));
        end
    elseif isempty(signalVariableNames) && isempty(variableNamesFoundInFile)
        error(message('signal:signalDatastore:signalDatastore:FileHasNoMoreVariablesToRead',fileName));
    end
    throw(ME);
end
