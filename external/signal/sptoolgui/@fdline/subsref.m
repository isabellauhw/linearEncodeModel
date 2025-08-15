function a = subsref(obj,s)
%SUBSREF Method for fdline object

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.

if strcmp(s(1).type,'()')
    obj = struct(obj);
    obj = obj(s(1).subs{:});    
    obj = fdline(obj);
    s(1) = [];
end

if isempty(s)
    a = obj;
    return
end

switch s(1).type
case {'()','{}'}
    error(message('signal:fdline:subsref:GUIErr'))  
case '.'
    a = get(obj,s(1).subs);
end

if length(s)>1
    % subsref into ans
    a = mysubsref(a,s(2:end));

end


function a = mysubsref(a,s)

for i=1:length(s)
    switch s(i).type
    case '()'
        a = a(s(i).subs{:});
    case '{}'
        a = a{s(i).subs{:}};
    case '.'
        a = getfield(a,s(i).subs);
    end
end
