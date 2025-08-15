function flags = getflags(hFDA,varargin)
%GETFLAGS Get FDATool flags.
%   GETFLAGS(HFDA) returns all the flags in FDATool.
%
%   GETFLAGS(HFDA,FIELD) returns only the flag specified by FIELD.
%
%   GETFLAGS(HFDA,FIELD,SUBFIELD) returns the flag specified by
%   SUBFIELD within the field FIELD.
%
%   See also SETFDAFLAGS. 

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(1,3);

hFig = get(hFDA,'figureHandle');

% Get the UserData of FDATool.
ud = get(hFig, 'UserData');
    
if nargin == 1
    % Return the entire flags structure.
    flags = ud.flags;
elseif nargin > 1
    % Return the requested flag.
    flags = getfield(ud.flags,varargin{:});
end    
    
% [EOF]
