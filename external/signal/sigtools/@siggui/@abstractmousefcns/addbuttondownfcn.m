function addbuttondownfcn(this, hg, interrupt)
%ADDBUTTONDOWNFCN Add the AxesTool button down function to an HG object
%   ADDBUTTONDOWNFCN(H, HG) Add the AxesTool buttondown function to HG.  The
%   HG Object will now send the ButtonDown event as its button down function.
%   
%   This can only be done for an axes or one of its children.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.

% This should be a private method

narginchk(2,3);

if isempty(hg), return; end

if nargin < 3, interrupt = 'off'; end

hax = ancestor(hg, 'axes');
if isempty(hax)
    error(message('signal:siggui:abstractmousefcns:addbuttondownfcn:GUIErr'));
end

set(hg, 'ButtonDownFcn', @(hcbo, ev) abstract_buttondownfcn(this, hcbo), ...
    'Interruptible', interrupt);

% [EOF]
