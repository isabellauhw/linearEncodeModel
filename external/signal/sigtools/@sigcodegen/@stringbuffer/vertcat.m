function H = vertcat(varargin)
%VERTCAT Vertical concatenation method for StringBuffer.
%   Vertical concatenation directly appends the buffers.
%   Note that horizontal and vertical concatenation perform
%   identical operatinos.
%
%   Multiple StringBuffer objects may be retained in
%   a cell-array.
%
%   See also STRINGBUFFER/HORZCAT.

%   Author(s): D. Orofino, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

H = horzcat(varargin{:});

% [EOF]
