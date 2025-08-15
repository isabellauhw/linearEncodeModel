function hObj = getwinobject(name)
%GETWINOBJECT   Returns the window object given the name

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% Generate a list with all windows
[w,lw] = findallwinclasses('nonuserdefined');

w{end+1} = 'functiondefined';
lw{end+1} = 'User Defined';

if any(strcmp(name, w))
    winclassname = name;
else
    % Match the current window and find the class name
    indx = find(strcmpi(name,lw));
    if isempty(indx)
        error(message('signal:getwinobject:UnknownWindow', name));
    end
    winclassname = w{indx};
end

%#function sigwin.barthannwin
%#function sigwin.bartlett
%#function sigwin.blackman
%#function sigwin.blackmanharris
%#function sigwin.bohmanwin
%#function sigwin.chebwin
%#function sigwin.flattopwin
%#function sigwin.functiondefined
%#function sigwin.gausswin
%#function sigwin.hamming
%#function sigwin.hann
%#function sigwin.kaiser
%#function sigwin.nuttallwin
%#function sigwin.parzenwin
%#function sigwin.rectwin
%#function sigwin.taylorwin
%#function sigwin.triang
%#function sigwin.tukeywin
%#function sigwin.userdefined

hObj = feval(['sigwin.' winclassname]);

% [EOF]
