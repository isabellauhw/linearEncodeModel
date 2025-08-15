function visible_listener(this, varargin)
%VISIBLE_LISTENER   Listener to the Visible property.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

visState = get(this, 'Visible');

h  = get(this, 'TabHandles');
if strcmpi(visState, 'off')
    
    set(convert2vector(h), 'Visible', 'Off');
    
    sigcontainer_visible_listener(this, varargin{:});
else
    
    set([h.tabbuttons h.tabpanel h.tablabels], 'Visible', 'On');
    hon = h.tabcovers(this.CurrentTab);
    set(hon, 'Visible', 'On');
    set(setdiff(h.tabcovers, hon), 'Visible', 'Off');
    lbls = gettablabels(this);
    
    ontab = this.CurrentTab;
        
    showtab(this, ontab);
    hidetab(this, setdiff(1:length(lbls), ontab))
end

% [EOF]
