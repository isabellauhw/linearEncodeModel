function clearmetadata(this,eventData)
%CLEARMETADATA   Clear the metadata of the object.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.

setfdesign(this, []);
setfmethod(this, []);
this.privMeasurements =  [];
this.privdesignmethod = [];

% Send the clearmetadata event in case object is contained in a multistage
notify(this,'ClearMetaData');

% [EOF]
