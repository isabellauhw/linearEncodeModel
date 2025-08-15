function this = firceqripfreqspecs
%FIREQRIPFREQSPECS  The Constructor for the class.

%   Author(s): Z. Mecklai
%   Copyright 1988-2017 The MathWorks, Inc.

% Call the builtin constructor
this = siggui.firceqripfreqspecs;

% Create the specsfsspecifier object and store the handle
construct_ff(this);

% Set the tag and version
settag(this);
set(this, 'Version', 1);

% Create a property to hold the cutoff/passband edge/stopband edge
FST = get(this, 'FreqSpecType');
FSTAll = set(this, 'FreqSpecType');
Indx = find(strcmp(FSTAll, FST));

if nargin < 2 , frequency = '1'; end

switch Indx
case 1
    p = schema.prop(this, 'Fc', 'ustring');
case 2
    p = schema.prop(this, 'Fpass', 'ustring');
case 3
    p = schema.prop(this, 'Fstop', 'ustring');
end
p.Description = 'Frequency';

% Store the handle for later use
set(this, 'Dynamic_Prop_Handles', p);

% Set the freq value
set(this, p.Name, frequency);

% [EOF]
