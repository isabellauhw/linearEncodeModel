function h = exportfilt2hw(varargin)
%EXPORTFILT2HW Constructor for an export2hardware object
%   SIGGUI.EXPORTFILT2HW(FILTOBJ) Construct an exportheader object with the
%   filter FILTOBJ.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

h = siggui.exportfilt2hw;

h.exportheader_construct(varargin{:});

addcomponent(h, siggui.targetselector);

settag(h);

% [EOF]
