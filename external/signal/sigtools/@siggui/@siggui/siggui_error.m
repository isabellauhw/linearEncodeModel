function siggui_error(hObj, Title, errstr)
%ERROR Error mechanism
%   ERROR(H) Display an errordlg using 'Error' as the title and lasterr
%   as the string.
%
%   ERROR(H, TITLE) Display an errordlg using TITLE as the title and lasterr
%   as the string.
%
%   ERROR(H, TITLE, ERRSTR) Display an errordlg using TITLE as the title and
%   ERRSTR as the string.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(1,3);

if isrendered(hObj)
    
    % Not sure about this.  Subclasses should probably take care of this.
    hFig = get(hObj,'FigureHandle');
    setptr(hFig, 'arrow');
end

if nargin < 2
    Title = 'Error';
end
if nargin < 3
    ME = MException.last;
    errstr = cleanerrormsg(ME.message);
end

% If there is no error string we cannot produce a worthwhile dialog.  This
% fixes a dspblks problem.
if isempty(errstr), return; end

errordlg(errstr, getTranslatedString('signal:sigtools:siggui',Title), 'modal');

% [EOF]
