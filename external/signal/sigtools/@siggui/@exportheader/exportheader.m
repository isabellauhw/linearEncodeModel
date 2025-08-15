function hEH = exportheader(varargin)
%EXPORTHEADER Construct an exportheader object
%   SIGGUI.EXPORTHEADER(FILTOBJ) Construct an exportheader object with the
%   filter FILTOBJ.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

%Instantiate the exportheader object
hEH = siggui.exportheader;

hEH.exportheader_construct(varargin{:});

% [EOF]
