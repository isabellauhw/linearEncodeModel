function h = remezoptionsframe(varargin)
%REMEZOPTIONSFRAME  Constructor for the remez options frame
%   REMEZOPTIONSFRAME(DENSITY, NAME)
%   DENSITY   -   The density factor to start with
%   NAME      -   The name to use for the frame, if not needed set as empty
%   The input arguments can be specified in any order

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.

% Call builtin constructor
h = siggui.remezoptionsframe;

settag(h);

% [EOF]
