function win = set_win(h,win)
%SET_WIN Set the window property.

%   Author(s): R. Losada
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(2,2);


if ~isempty(findprop(h,'orderMode')) & isdynpropenab(h,'orderMode')
    ordMode = get(h,'orderMode');
    
    % If trying to set window other than kaiser in minimum mode, error
    if strcmpi(ordMode,'minimum') & ~strcmpi(win,'kaiser')
        error(message('signal:filtdes:fir1:set_win:NotSupported'));
    end
end

