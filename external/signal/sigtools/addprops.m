function varargout = addprops(hParent, hChild, varargin)
%ADDPROPS Method to dynamically add dependent properties to the parent object.
%   ADDPROPS(H, HC) Method to dynamically add dependent properties from HC
%   to H.  HC is assumed to have the method PROPSTOADD, which should return
%   a cell array of strings.
%
%   ADDPROPS(H, HC, PROP1, PROP2, etc.) Adds PROP1, PROP2, etc. from HC to
%   H.  These should be specified with strings.
%
%   ADDPROPS(H, HC, '-not', PROP1, '-not', PROP2) Adds all properties
%   returned from HC's PROPSTOADD method except PROP1 and PROP2.
%
%   ADDPROPS(H, HC, {}) If an empty cell is passed as the third input, no
%   properties will be added to H.

%   Author(s): J. Schickler
%   Copyright 1988-2019 The MathWorks, Inc.

% If we have an extra non '-not' input, it must be the properties to add.
if nargin < 3
    props = propstoadd(hChild);
else
    if strcmpi(varargin{1}, '-not')
        % Eliminate all properties that are referenced to be a '-not'
        indx = 1;
        props = propstoadd(hChild);
        
        while indx < length(varargin)
            if strcmpi(varargin{indx}, '-not')
                idx = strcmpi(varargin{indx+1}, props);
                varargin([indx indx+1]) = [];
                props(find(idx)) = [];
            else
                indx = indx + 1;
            end
        end
    elseif isempty(varargin{1})
        props = {};
    else
        if iscell(varargin{1})
            props = varargin{1};
        else
            props = varargin;
        end
    end
end

% Make sure that there are no duplicate properties.
[props, i] = unique(props);
[i, newi]  = sort(i);
props = props(newi);

if isempty(props)
    if nargout == 1, varargout = {[]}; end
    return;
end

newp = {};

for indx = 1:length(props)

    hindxc = findprop(hChild, props{indx});
    
    if isobject(hParent) %parent is MCOS
         % Add property to hParent(MCOS) from class hChild(UDD or MCOS)
        if isobject(hChild)
          hidn = hindxc.Hidden;
        else
          hidn = strcmp(hindxc.Visible,'off');
        end
        name = hindxc.Name;
        P = addprop(hParent, name);
        % Assign property attributes
        P.GetObservable = 1; 
        P.SetObservable = 1;
        P.AbortSet = 1;
        P.NonCopyable = 0;
        P.Transient = 1;
        P.Hidden = hidn;

        % Assign get and set method function handles
        P.GetMethod = @(~)get_prop([], [], hChild, name);
        P.SetMethod = @(~,val)set_prop([], val, hChild, name);

    else %parent is UDD
        
        if isobject(hChild)
          % Adding props to hParent(UDD) from class hChild(MCOS)
          newp{end+1} = schema.prop(hParent, hindxc.Name, 'mxArray');
          set(newp{end},'AccessFlags.Serialize', 'Off');
          set(newp{end},'SetFunction', {@set_prop, hChild, hindxc.Name});
          set(newp{end},'GetFunction', {@get_prop, hChild, hindxc.Name});

          if hindxc.Hidden
            isVis = 'off';
          else
            isVis = 'on';
          end   

          set(newp{end},'Visible', isVis);

        else
          % Create a property based on the child object's property.
          newp{end+1} = schema.prop(hParent, hindxc.Name, hindxc.datatype);
           set(newp{end}, 'AccessFlags.Serialize', 'Off', ...
            'SetFunction', {@set_prop, hChild, hindxc.Name}, ...
            'GetFunction', {@get_prop, hChild, hindxc.Name}, ...
            'Visible', hindxc.Visible, ...
            'AccessFlags.PublicSet', hindxc.AccessFlags.PublicSet,...
            'AccessFlags.AbortSet', hindxc.AccessFlags.AbortSet);
        end
    end
end

if nargout, varargout = {[newp{:}]}; end

% -------------------------------------------------------------------------
function value = get_prop(hParent, value, hChild, prop)

% Get the value from the child.
value = get(hChild, prop);

% -------------------------------------------------------------------------
function value = set_prop(hParent, value, hChild, prop)

% Set the value in the child.
set(hChild, prop, value);

% [EOF]
