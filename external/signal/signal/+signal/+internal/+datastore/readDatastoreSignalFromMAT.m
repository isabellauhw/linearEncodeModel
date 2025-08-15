function [data, info] = readDatastoreSignalFromMAT(fileName,signalVariableNames,timeInfoType,timeVariableName)
%Default .mat file read function for signalDatastore 
% signalVariableNames, timeVariableName must be strings
%For internal use only. It may be removed.

%   Copyright 2019 The MathWorks, Inc.

info = [];

try
    if isempty(signalVariableNames)
        % set varNames to NaN in case load fails - we do not want to error
        % out with a message about vars not found in a load error case.
        varNames = NaN;

        s = load(fileName);
        varNames = fields(s);
        if ~isempty(timeInfoType)
            info.(timeInfoType) = s.(timeVariableName);
            info.TimeVariableName = string(timeVariableName);
            varNames(strcmp(varNames,timeVariableName)) = [];
        end
        info.SignalVariableNames = string(varNames{1});
        data = s.(varNames{1});
    else
        if isempty(timeInfoType)            
            if numel(signalVariableNames) > 1
                names = cellstr(signalVariableNames);
                s = load(fileName,names{:});
                data = struct2cell(s);
                if numel(data) < numel(signalVariableNames)
                    idx = ~isfield(s,signalVariableNames);
                    varNamesNotFound = string(signalVariableNames(idx));
                    if numel(varNamesNotFound) == 1
                        error(message('signal:signalDatastore:signalDatastore:VariableNotFoundInFile',varNamesNotFound,fileName));
                    else
                        str = join(varNamesNotFound,"', '");
                        error(message('signal:signalDatastore:signalDatastore:VariablesNotFoundInFile',str,fileName));
                    end
                end
            else
                s = load(fileName,signalVariableNames);
                data = s.(signalVariableNames);
            end
        else
            if numel(signalVariableNames) > 1
                names = cellstr(signalVariableNames);
                s = load(fileName,names{:},timeVariableName);
                info.(timeInfoType) = s.(timeVariableName);
                info.TimeVariableName =  string(timeVariableName);
                if ~any(signalVariableNames == timeVariableName)
                    s = rmfield(s,timeVariableName);
                end
                data = struct2cell(s);
                if numel(data) < numel(signalVariableNames)
                    idx = ~isfield(s,signalVariableNames);
                    varNamesNotFound = string(signalVariableNames(idx));
                    if numel(varNamesNotFound) == 1
                        error(message('signal:signalDatastore:signalDatastore:VariableNotFoundInFile',varNamesNotFound,fileName));
                    else
                        str = join(varNamesNotFound,"', '");
                        error(message('signal:signalDatastore:signalDatastore:VariablesNotFoundInFile',str,fileName));
                    end
                end
            else
                s = load(fileName,signalVariableNames,timeVariableName);
                info.(timeInfoType) = s.(timeVariableName);
                info.TimeVariableName =  string(timeVariableName);
                data = s.(signalVariableNames);
            end
        end
        info.SignalVariableNames = string(signalVariableNames);
    end
catch ME
   if string(ME.identifier) == "MATLAB:nonExistentField"
       varNamesNotFound = [];
       if ~isempty(signalVariableNames)
           idx = ~isfield(s,signalVariableNames);
           if any(idx)
               varNamesNotFound = string(signalVariableNames(idx));
           end
       end
       if ~isempty(timeVariableName) && ~isfield(s,timeVariableName)
           varNamesNotFound = [varNamesNotFound(:); string(timeVariableName)];
       end
       if numel(varNamesNotFound) == 1
           error(message('signal:signalDatastore:signalDatastore:VariableNotFoundInFile',varNamesNotFound,fileName));
       else
           str = join(varNamesNotFound,"', '");
           error(message('signal:signalDatastore:signalDatastore:VariablesNotFoundInFile',str,fileName));
       end
   elseif isempty(signalVariableNames) && isempty(varNames)
       error(message('signal:signalDatastore:signalDatastore:FileHasNoMoreVariablesToRead',fileName));
   end
   throw(ME);
end
end