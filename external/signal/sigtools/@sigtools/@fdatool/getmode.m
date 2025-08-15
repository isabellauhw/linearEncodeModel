function mode = getmode(hFDA,varargin)
%GETMODE Get FDATool mode.
%   GETMODE(HFDA) returns all the mode information in FDATool.
%
%   GETMODE(HFDA,FIELD) returns only the mode specified by FIELD.
%
%   See also SETFDAMODE. 

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(1,2);

hFig = get(hFDA,'FigureHandle');

% Get the user data of FDATool.
ud = get(hFig, 'UserData');
    
if nargin == 1
    % Return the entire mode structure.
    mode = ud.mode;
elseif nargin == 2
    % Return the requested mode.
    mode = getfield(ud.mode,varargin{1});
end    
    
% [EOF]
