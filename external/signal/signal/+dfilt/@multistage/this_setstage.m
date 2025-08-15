function s = this_setstage(this,s) 
%THIS_SETSTAGE PreSet function for the stage property.

%   Copyright 2009-2017 The MathWorks, Inc.

% Create a listener for the stage
l  = event.listener(s, 'ClearMetaData', @(src,evnt)lcl_clearmetadata(src, evnt, this)); 
this.clearmetadatalistener = l;
 
clearmetadata(this);

function lcl_clearmetadata(src, eventData, this)
clearmetadata(this);


