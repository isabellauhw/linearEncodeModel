function enable_listener(this, ~)
%ENABLE_LISTENER Listener to 'enable'

%   Copyright 2008-2011 The MathWorks, Inc.

enabState = this.Enable;

h = this.Handles;

set(h.errorstatus, 'Enable', enabState);

if ~isempty(this.ErrorStatus)
  enabState = 'off';
end

setenableprop([h.gain_lbl h.gain h.actionbtn h.coordinatemode_lbl h.coordinatemode ...
  h.real_lbl h.real h.imaginary_lbl h.imaginary h.currentsection_lbl ...
  h.currentsection h.conjugatemode h.announcenewspecs], enabState);

if strcmpi(enabState,'on')
  if isempty(this.CurrentPoint)
    setenableprop([h.real h.imaginary], 'off');
  end
  
  allroots = get(this, 'AllRoots');
  if length(allroots) <= 1
    setenableprop(h.currentsection, 'off');
  end
end


% [EOF]
