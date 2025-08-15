function a = get(obj,prop)
%GET Method for fdax object

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.

obj = struct(obj);

if ~iscell(prop)
    prop = {prop};
end

prop = prop(:);
obj = obj(:);

a = cell(length(obj),length(prop));
for i = 1:length(obj)
    for j = 1:length(prop)
        a{i,j} = getprop(obj(i),prop{j});
    end
end

if all(size(a)==1)
    a = a{:};
end


function val = getprop(obj,prop)
% get the value of a single property of a single object struct

switch prop
    case {'title','xlabel','ylabel','pointer','xlimbound',...
           'ylimbound','xlimpassband','ylimpassband','aspectmode','overlay',...
           'visible','position','overlayhandle',...
           'userdata','help'}
    objud = get(obj.h,'userdata');
    val = eval(['objud.' prop]); %getfield(objud,prop);
case 'h'
    val = obj.h;
otherwise
    val = get(obj.h,prop);
end
