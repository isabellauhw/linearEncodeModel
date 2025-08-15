function newStrs = removeampersands(Strs)
% REMOVEAMPERSANDS Remove the ampersands (&) from the strings.
% 
% Inputs:
%   Strs - a string or cell array of strings.

%   Author(s): P. Pacheco and R. Losada 
%   Copyright 1988-2017 The MathWorks, Inc.

% Return early if input is empty
if isempty(Strs)
    newStrs = '';
    return
end

if iscell(Strs)
    for k = 1:length(Strs)
        newStr = removeIt(Strs{k});
        newStrs{k} = newStr;
    end
elseif ischar(Strs)
    newStrs = removeIt(Strs);
end
    
function Str = removeIt(Str)
%REMOVEIT   Remove the ampersand from a string.
indx = findstr(Str,'&');
if ~isempty(indx)
	Str = [Str(1:indx-1), Str(indx+1:end)];
end
