function bestsize = getbestsize(h, type)
%GETBESTSIZE   Return the best size.
%   GETBESTSIZE(H, TYPE)   Returns either the best height or width
%   depending on the string TYPE that is specified for the UIControl H.

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

origUnits = get(h, 'Units');
set(h, 'Units', 'Pixels');

pos = get(h, 'Position');
str = get(h, 'String');

switch lower(type)
    case 'width'
        
    case 'height'
        width = pos(3);

        spaces = [0 findstr(str, ' ')];

        stringcell = {};

        for indx = 1:length(spaces)-1
            stringcell = {stringcell{:} str(spaces(indx)+1:spaces(indx+1)-1)};
        end
        stringcell = {stringcell{:} str(spaces(end)+1:end)};

        bestsize = 0;

        while ~isempty(stringcell)
            set(h, 'String', stringcell{1})
            ext = get(h, 'Extent');
            k   = 2;
            while ext(3) <= width && k <= length(stringcell)
                ext_str = sprintf('%s ', stringcell{1:k});
                ext_str(end) = [];
                set(h, 'String', ext_str);
                ext = get(h, 'Extent');
                k = k+1;
            end
            
            % If the first string already overruns the width, it must go on
            % a single line.
            if k == 2
                stringcell(1) = [];
            elseif ext(3) < width
                
                % If the extent never outgrew the available width, then we
                % are done.
                stringcell = {};
            elseif length(stringcell) == 1
                
                % If the length of the string cell is one, there is nothing
                % we can do, put the last word on the last line.
                stringcell = {};
            else
                stringcell(1:k-2) = [];
            end
            bestsize = bestsize + ext(4) - 4;
        end
end

set(h, 'String', str, 'Units', origUnits);

% [EOF]
