function this = stringbuffer(varargin)
%STRINGBUFFER Construct a stringbuffer object.
%   H = STRINGBUFFER Construct a stringbuffer object.
%
%   H = STRINGBUFFER(STR) Construct a stringbuffer object and call H.ADD(STR)
%   automatically.

%   Author(s): D. Orofino, J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

this = sigcodegen.stringbuffer;

if nargin > 0
    this.add(varargin);
end

% [EOF]
