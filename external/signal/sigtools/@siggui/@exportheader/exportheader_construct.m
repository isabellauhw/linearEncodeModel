function exportheader_construct(hEH, varargin)
%EXPORTHEADER_CONSTRUCT Constructor for exportheader

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.

filtobj = parse_inputs(varargin{:});

% Instantiate the components of the exportheader object
addcomponent(hEH, siggui.datatypeselector);
addcomponent(hEH, siggui.varsinheader);

% Install Listeners
install_listeners(hEH)

% Filter is set after the listeners are installed so that the
% filter_listener will fire
hEH.Filter = filtobj;


% -------------------------------------------------
function install_listeners(hEH)

listen = handle.listener(hEH, hEH.findprop('Filter'), ...
    'PropertyPostSet', @filter_listener);

set(listen, 'CallbackTarget', hEH);

set(hEH, 'Listeners', listen);


% -------------------------------------------------
function filtobj = parse_inputs(varargin)

narginchk(1,2);

filtobj   = varargin{1};

if ~isa(filtobj, 'dfilt.singleton')
  error(message('signal:siggui:exportheader:exportheader_construct:FilterObjMustBeSpecified'));
end    

% [EOF]
