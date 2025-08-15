classdef (Abstract) abstractxp2fileMCOS < sigio.abstractxpdestwvarsMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
%sigio.abstractxp2file class
%   sigio.abstractxp2file extends sigio.abstractxpdestwvars.
%
%    sigio.abstractxp2file properties:
%       Tag - Property is of type 'string'  
%       Version - Property is of type 'double' (read only) 
%       Data - Property is of type 'mxArray'  
%       Toolbox - Property is of type 'string'  
%       DefaultLabels - Property is of type 'mxArray'  
%       VariableLabels - Property is of type 'mxArray'  
%       VariableNames - Property is of type 'mxArray'   
%       FileName - Property is of type 'string'  
%       FileExtension - Property is of type 'string'  
%       DialogTitle - Property is of type 'string'  


properties (AbortSet, SetObservable, GetObservable)
    %FILENAME Property is of type 'string' 
    FileName = '';
    %FILEEXTENSION Property is of type 'string' 
    FileExtension = '';
    %DIALOGTITLE Property is of type 'string' 
    DialogTitle = '';
end


methods 
    function set.FileName(obj,value)
        % DataType = 'string'
        validateattributes(value,{'char'}, {'row'},'','FileName')
        obj.FileName = value;
    end

    function set.FileExtension(obj,value)
        % DataType = 'string'
        validateattributes(value,{'char'}, {'row'},'','FileExtension')
        obj.FileExtension = value;
    end

    function set.DialogTitle(obj,value)
        % DataType = 'string'
        validateattributes(value,{'char'}, {'row'},'','DialogTitle')
        obj.DialogTitle = value;
    end

end   % set and get functions 
end  % classdef

