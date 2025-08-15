function h = gremezfilterorder(mode,isMinOrd,ord)
%FILTERORDER Constructor for the filterOrder object.
%   Inputs:
%      defaultMode - render with specify/minimum selected.
%      isMinOrd    - enable/disable minimum order.
%      ord         - default value for specify order.

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

% Do input error checking
narginchk(0,3);

% Use built-in constructor
h = siggui.gremezfilterorder;

% Set additional inputs/defaults
if nargin > 0, set(h,'Mode',mode); end
if nargin > 1, set(h,'IsMinOrd',isMinOrd); end
if nargin > 2, set(h,'Order',ord); end

% Set version
set(h,'Version',1.0);

% Set tag
settag(h);

% [EOF]
