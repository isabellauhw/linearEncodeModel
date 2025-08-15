function h = dspfwiz(filtobj)
%DSPFWIZ Construct a dspfwiz object

%   Copyright 1995-2004 The MathWorks, Inc.

narginchk(1,1)

h = siggui.dspfwiz;

h.Filter = filtobj;

% EOF
