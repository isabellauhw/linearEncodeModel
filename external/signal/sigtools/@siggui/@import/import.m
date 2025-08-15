function hIT = import
%IMPORT The constructor for the Import Tool
%   IMPORT(hFig, hTARGET)

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

% Instantiate the object
hIT = siggui.import;

% Set up the Structure % Coefficient object
addcomponent(hIT, siggui.coeffspecifier);

% Create the Sampling Frequency object
addcomponent(hIT, siggui.fsspecifier);

% Set up the flags
set(hIT,'IsImported',0);
set(hIT,'Version',1);

% [EOF]
