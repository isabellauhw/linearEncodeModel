function designMethodwFs_construct(d,varargin)
%DESIGNMETHODWFS_CONSTRUCT Real constructor for the design method with Fs object.

%   Copyright 1988-2002 The MathWorks, Inc.

% Create a dynamic property to hold the sampling frequency
p = schema.prop(d,'Fs','udouble');
set(d,'Fs',48000);

% Call the super constructor
designMethod_construct(d,varargin{:});
    
% Install a listener to the frequency units
l = handle.listener(d,findprop(d,'freqUnits'),'PropertyPreSet',@freqUnits_listener);
    
% Store listener
set(l, 'callbacktarget', d); % Allow for methods as callbacks
set(d,'freqUnitsListener',l);

% Fire the listener manually the first time
freqUnits_listener(d);








