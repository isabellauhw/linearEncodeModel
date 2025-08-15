function h = numdenfilterorder(defaultNum,defaultDen)
%ARBMAGFILTERORDER Constructor for the filterOrder object.
%   Inputs:
%      defaultNum - Default value for Numerator order.
%      defaultDen - Default value for Denominator order.

%   Author(s): Z. Mecklai
%   Copyright 1988-2010 The MathWorks, Inc.

% Do input error checking
narginchk(0,2);

% Use built-in constructor
h = siggui.numdenfilterorder;

% Set default properties based on number of inputs

if nargin < 1, defaultNum = '8'; end
if nargin < 2, defaultDen = '8'; end

% Set additional inputs/defaults
% Set the default numerator
set(h,'NumOrder',defaultNum);

% Set the default denominator
set(h,'DenOrder',defaultDen);

% Set version
set(h,'Version',1.0);

settag(h);

% [EOF]
