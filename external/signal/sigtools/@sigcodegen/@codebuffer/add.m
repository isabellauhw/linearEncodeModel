function add(this, varargin)
%ADD Add the strings to the buffer.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.

str = add_parser(this, varargin{:});

if ~isempty(this.buffer)
    str = {[this.buffer{end} str{1}], str{2:end}};
    this.buffer{end} = '';
end

% Add it to the buffer with the superclass method.
this.sb_add(this.format(str));

% [EOF]
