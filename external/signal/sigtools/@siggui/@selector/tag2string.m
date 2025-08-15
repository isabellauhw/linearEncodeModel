function string = tag2string(hObj, tag)
%TAG2STRING Map a tag to a string

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

tags = get(hObj, 'Identifiers');
strs = get(hObj, 'String');

string = '';

for i = 1:length(tags)
    if ischar(tags{i})
        if strcmpi(tag, tags{i})
            string = strs{i};
            return;
        end
    else
        indx = find(strcmpi(tag, tags{i}));
        switch length(indx)
            case 0
                % NO OP
            case 1
                string = strs{i}{indx-difference(hObj,i)};
            case 2
                if indx(1) == 1
                    string = strs{i}{indx(2-difference(hObj, i))};
                else
                    error(message('signal:siggui:selector:tag2string:GUIErr'));
                end                    
            otherwise
                error(message('signal:siggui:selector:tag2string:GUIErr'));
        end
    end
end

% [EOF]
