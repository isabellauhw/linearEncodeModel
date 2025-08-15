function [vals, errStr, mssgObj] = evaluatevars(strs, name, checkIsNumericFlag)
%EVALUATEVARS   Evaluate variables in the MATLAB workspace.
%
%   EVALUATEVARS will take a char (or cell array of chars) and evaluate it
%   in the base MATLAB workspace. If the variables exist and are numeric,
%   the workspace variables values are returned in VALS, if they do not
%   exist, and error message and the error message object ere returned in
%   ERRSTR and MSSOBJ respectively. If you only request one output to the
%   function, then  an error will be thrown when an error is found. You can
%   set the optional input checkIsNumericFlag to false if you do not want
%   to check for the variables being numeric.
%
%   Input:
%     strs               - char or cell array of chars from edit boxes
%     names              - char or cell array of char names for the edit 
%                          boxes.  This allows EVALUATEVARS to give 
%                          customized error messages if the editboxes are 
%                          empty. If this input is not given a generic
%                          message 'Editboxes cannot be empty.' will be 
%                          given. If this input is empty it will be ignored.
%     checkIsNumericFlag - set to flase if you do not want the function to
%                          check if the evaluated variable is numeric.
%
%   Outputs:
%     vals    - Values returned after evaluating the input strs in the
%               MATLAB workspace.
%     errStr  - Error string returned if evaluation failed.
%     mssgObj - Message object

%   Copyright 1988-2019 The MathWorks, Inc.

errStr = '';
mssgObj = [];
vals = {};
if nargin < 3
    checkIsNumericFlag = true;
end

if  iscell(strs)
    for n = 1:length(strs) % Loop through strings
        if ~isempty(strs{n})
            try
                vals{n} = evalin('base',['[',strs{n},']']); %#ok<AGROW>
                % Check that vals is a numeric array and not a string.
                if checkIsNumericFlag && ~isnumeric(vals{n})
                  mssgObj = message('signal:evaluatevars:NotNumeric',strs{n});       
                  errStr= getString(mssgObj);
                end     
            catch
                mssgObj = message('signal:evaluatevars:NotDefined',strs{n});
                errStr= getString(mssgObj);
                break;
            end
        else
            if nargin > 1 && ~isempty(name{n})
              mssgObj = message('signal:evaluatevars:EmptyEditBox',name{n});
              errStr = getString(mssgObj);
            else
              mssgObj = message('signal:evaluatevars:EmptyEditBoxes');
              errStr = getString(mssgObj);
            end
            break;
        end 
    end
else
    if ~isempty(strs)
        try
            vals = evalin('base',['[',strs,']']);
            if checkIsNumericFlag && ~isnumeric(vals)             
              mssgObj = message('signal:evaluatevars:NotNumeric',strs);       
              errStr= getString(mssgObj);              
            end
        catch
            mssgObj = message('signal:evaluatevars:NotDefined',strs);
            errStr= getString(mssgObj);            
        end
    else
        if nargin > 1 && ~isempty(name)
            mssgObj = message('signal:evaluatevars:EmptyEditBox',name);
            errStr = getString(mssgObj);          
        else
            mssgObj = message('signal:evaluatevars:EmptyEditBoxes');
            errStr = getString(mssgObj);
        end
    end
end

if nargout < 2
    if ~isempty(errStr)
        error(mssgObj);
    end 
end
end
