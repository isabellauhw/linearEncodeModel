function this = magtext
%MAGTEXT   A magnitude frame with nothing but text in it.
%   MAGTEXT(DEFAULTSTRING)  creates a magtext object and sets the string.

%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.

% first call builtin constructor
this = siggui.magtext;

% Set the tag of the object
settag(this);

% [EOF]
