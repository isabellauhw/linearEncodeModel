function currentsection_listener(hObj, eventData)
%CURRENTSECTION_LISTENER Listener to the CurrentSection property

%   Copyright 1988-2017 The MathWorks, Inc.

if nargin > 1 && isstruct(eventData)
    allroots = eventData;
    roots = allroots(hObj.CurrentSection).roots;
else
    allroots = get(hObj, 'AllRoots');
    roots = get(hObj, 'Roots');
end
if isempty(allroots)
    return
end
allroots = [allroots.roots];

% Make sure that the non-currentsection roots are disabled and the
% currentsection roots are enabled.
set(setdiff(allroots, roots), 'Enable', 'Off', 'Current', 'Off');
set(roots, 'Enable', hObj.Enable);

updatelimits(hObj);

if nargin == 1 || ~isstruct(eventData)
  h = get(hObj, 'Handles');
  set(h.gain, 'string', sprintf('%g',hObj.Gain))
end


% [EOF]
