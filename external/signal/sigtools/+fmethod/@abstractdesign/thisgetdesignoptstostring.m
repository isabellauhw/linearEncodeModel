function [sOut, fnOut] = thisgetdesignoptstostring(this, s, fn) %#ok<INUSL>
%THISGETDESIGNOPTSTOSTRING
    
%   Copyright 1999-2015 The MathWorks, Inc.

% Do nothing. Let the subclass remove more fields by overriding this method.
sOut = s;
fnOut = fn;
