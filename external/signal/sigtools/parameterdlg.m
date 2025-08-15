function varargout = parameterdlg(varargin)
%PARAMETERDLG Create a parameter dialog box

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(1,3);

hPD = siggui.parameterdlg(varargin{:});
render(hPD);
set(hPD, 'Visible', 'On');

if nargout
    varargout{1} = hPD;
end

% [EOF]
