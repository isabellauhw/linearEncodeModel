function [str, msg] = add_parser(this, varargin)
%ADD_PARSER Parser for the various add methods
%   ADD_PARSER Converts everything to a cellstr.  Finds all '\n' and
%   replaces them with 2 elements in the cell array.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% This should be private.

msg = '';

if nargin==1
    str = '';
elseif nargin==2
    str = varargin{1};
else
    try,
        str = sprintf(varargin{:});
        
        % If the returned string is the same as the first element, this is
        % not meant to be a formatted string.  It is just a cell of
        % strings.
        if strcmp(str, varargin{1})
            str = varargin;
        end
    catch
        str = '';        
        msg = 'Failed to create formatted string';
        if nargout < 2
           error(message('signal:sigcodegen:stringbuffer:add_parser:FailedToCreateString'))
        end
    end
end

if ~iscell(str), str = {str}; end

% If we have a character string, replace it with a cell array.  Look
% for all the new line feeds and convert them to be separations in the
% cell array.
indx = 1;
while indx <= length(str)
    
    if isa(str{indx}, 'sigcodegen.stringbuffer')
        str{indx} = string(str{indx});
    end
    
    if ~ischar(str{indx}) && ~isempty(str{indx})
        msg = 'Can only add strings';
        if nargout < 2
           error(message('signal:sigcodegen:stringbuffer:add_parser:OnlyAddStrings'))
        end        
        break
    end
    
    % Find the first newline feed
    idx = min(strfind(str{indx}, newline));
    if isempty(idx)
        indx = indx + 1;
    else
        
        % If there is a newline feed convert it into two entries of a cell array.
        str = {str{1:indx-1} str{indx}(1:idx-1) [] str{indx}(idx+1:end) str{indx+1:end}};
        indx = indx + 1;
    end
end

% [EOF]
