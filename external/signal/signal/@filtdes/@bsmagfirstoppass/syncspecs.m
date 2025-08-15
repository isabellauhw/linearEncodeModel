function props = syncspecs(h,d)
%SYNCSPECS Properties to sync.
%
%   Inputs:
%       h - handle to this object
%		d - handle to container objects
%
%   Outputs:
%       props - cell array, with list of properties to sync from
%               and list of properties to sync to.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

magUnits = get(d,'magUnits');
magUnitsOpts = set(d,'magUnits');

switch magUnits
case magUnitsOpts{1} % 'dB'
	props = {'Astop', 'Apass2'};
case magUnitsOpts{2} % 'Linear'
	props = {'Dstop', 'Dpass2'};
end	

% [EOF]
