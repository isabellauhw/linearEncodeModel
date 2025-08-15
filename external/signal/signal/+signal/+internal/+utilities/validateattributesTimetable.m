function [] = validateattributesTimetable(xt, attributes, fname, varname) %#codegen
%UTILVALIDATEATTRIBUTESTIMETABLE  Utility function to validate attributes of timetable XT.
% This function is only for internal use.

%   Copyright 2017 The MathWorks, Inc.

Nattr = length(attributes);
for i = 1:Nattr
    localCheckAttribute(xt, attributes{i}, fname, varname);
end

end

function [] = localCheckAttribute(xt, attr_name, fname, varname)
% Check timetable attribute given the attribute name
switch attr_name
    case 'sorted'
        if(~issorted(xt))
            error(message('signal:utilities:utilities:unsortedTimetable',fname, varname));
        end
    case 'multichannel'
        % validate if the timetable satisfies the definition of
        % multi-channel timetalbe. It should be one of the following types:
        % (1) multiple variables with single column; (2) single variable with
        % multiple columns
        var_name = xt.Properties.VariableNames;
        Nvar = length(var_name);
        if(Nvar>1)
            for i = 1:length(var_name)
                if(~isvector(xt.(var_name{i})))
                    error(message('signal:utilities:utilities:notMultichannelTimetable',fname,varname));
                end
            end
        end
    case 'singlechannel'
        % validate if the timetable is single-channel, i.e. single variable
        % with single column
        var_name = xt.Properties.VariableNames;
        Nvar = length(var_name);
        if Nvar==1
            if(~isvector(xt.(var_name{1})))
                error(message('signal:utilities:utilities:notSinglechannelTimetable',fname,varname));
            end
        else
            error(message('signal:utilities:utilities:notSinglechannelTimetable',fname,varname));
        end
    case 'regular'
        if(~isregular(xt))
            error(message('signal:utilities:utilities:irregularTimetable',fname,varname));
        end
    otherwise
        error(message('signal:utilities:utilities:undefinedTimetableAttributes', attr_name));
end
end