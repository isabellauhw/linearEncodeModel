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

%   Author(s): R. Losada
%   Copyright 1988-2017 The MathWorks, Inc.

% Call super's method
props = mis_syncspecs(h,d);

magUnits = get(d,'magUnits');
magUnitsOpts = set(d,'magUnits');

switch magUnits
case magUnitsOpts{1} % 'dB'
	props{end+1} = 'Apass';
case magUnitsOpts{2} % 'Squared'
	props{end+1} = 'Epass';
end	




