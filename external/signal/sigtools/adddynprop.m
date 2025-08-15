function varargout = adddynprop(h, name, datatype, setfcn, getfcn)
%ADDDYNPROP   Add a dynamic property
%   ADDDYNPROP(H, NAME, TYPE)  Add the dynamic property with NAME and
%   datatype TYPE to the object H.
%
%   ADDDYNPROP(H, NAME, TYPE, SETFCN, GETFCN)  Add the dynamic property and
%   setup PostSet and PreGet listeners with the functions SETFCN and GETFCN.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

narginchk(3,5);

if nargin < 5
    getfcn = [];
    if nargin < 4
        setfcn = [];
    end
end

% Add the dynamic property.
if ishandle(h) %UDD
  hp = schema.prop(h, name, datatype);
  set(hp, 'AccessFlags.Serialize', 'Off', ...
      'SetFunction', setfcn, ...
      'GetFunction', getfcn);
    
elseif isobject(h) %MCOS

  % Add the dynamic property and set property attributes
  hp = addprop(h, name);
  hp.GetObservable = 1; 
  hp.SetObservable = 1;
  hp.AbortSet = 1;
  hp.NonCopyable = 0;
  hp.Hidden = 0;
  % Assign handles for the get and set methods
  hp.GetMethod = getfcn;
  hp.SetMethod = setfcn;  
  
end

if nargout
    varargout = {hp};
end

% [EOF]
