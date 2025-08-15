function flag = isfromdesignfilt(this)
%ISFROMDESIGNFILT True if dfilt object was designed usign designfilt function

%   Copyright 1999-2015 The MathWorks, Inc.

flag = isprop(this,'FromDesignfilt') && this.FromDesignfilt;

% [EOF]