classdef tworesps < sigresp.twoanalyses & sigio.dyproputil & hgsetget
  %filtresp.tworesps class
  %   filtresp.tworesps extends sigresp.twoanalyses.
  %
  %    filtresp.tworesps properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       FastUpdate - Property is of type 'on/off'
  %       Name - Property is of type 'string'
  %       Legend - Property is of type 'on/off'
  %       Grid - Property is of type 'on/off'
  %       Title - Property is of type 'on/off'
  %       Analyses - Property is of type 'sigresp.analysisaxis vector'
  %
  %    filtresp.tworesps methods:
  %       attachlisteners -   Attach the WhenRenderedListeners to this object.
  %       enablemask - Returns true if the object supports masks.
  %       objspecificdraw -   Perform the tworesps specific drawing.

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %FILTERUTILS Property is of type 'filtresp.filterutils'
    FilterUtils = [];
  end
  
  
  methods  % constructor block
    function h = tworesps(firstresp, secondresp)
      %TWORESPS Abstract class

      narginchk(1,2);
      
      switch length(firstresp)
        case 1
          narginchk(2,2);
          resps = [firstresp, secondresp];
        case 2
          resps = firstresp;
        otherwise
          error(message('signal:filtresp:tworesps:tworesps:InvalidDimensions'));
      end
      
      % h = filtresp.tworesps;
      h.FilterUtils = filtresp.filterutils;
      findclass(findpackage('dspopts'), 'sosview'); % g 227896
      addprops(h, h.FilterUtils);
      
      h.Filters = [resps(1).Filters];
      for indx = 1:length(resps)
        unrender(resps(indx));
      end
      h.Analyses = resps;
                      
      l(1) = event.proplistener(h,h.findprop('Title'),'PostSet',@(s,e)lclprop_listener(h,e));
      l(2) = event.proplistener(h,h.findprop('Filters'),'PostSet',@(s,e)lclprop_listener(h,e));     
      l(3) = event.proplistener(h,h.findprop('ShowReference'),'PostSet',@(s,e)lclprop_listener(h,e));
      l(4) = event.proplistener(h,h.findprop('PolyphaseView'),'PostSet',@(s,e)lclprop_listener(h,e));
      l(5) = event.proplistener(h,h.findprop('SOSViewOpts'),'PostSet',@(s,e)lclprop_listener(h,e));
       
      set(h, 'Listeners', l);          
    end  % tworesps
    
    
    % ----------------------------------------------------------------------
    
  end  % constructor block
  
  methods
    function set.FilterUtils(obj,value)
      % DataType = 'filtresp.filterutils'
      validateattributes(value,{'filtresp.filterutils'}, {'scalar'},'','FilterUtils');
      obj.FilterUtils = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function attachlisteners(this)
      %ATTACHLISTENERS   Attach the WhenRenderedListeners to this object.
      
      twoanalyses_attachlisteners(this);
      
      l = this.WhenRenderedListeners;
  
      l(end+1) = event.proplistener(this, this.findprop('Filters'), 'PostSet', @(s,e)lclfilters_listener(this,e));
      l(end+1) = event.proplistener(this, this.findprop('SOSViewOpts'), 'PostSet', @(s,e)prop_listener(this,e));
      l(end+1) = event.proplistener(this, this.findprop('PolyphaseView'), 'PostSet', @(s,e)prop_listener(this,e));
      l(end+1) = event.proplistener(this, this.findprop('ShowReference'), 'PostSet', @(s,e)prop_listener(this,e));
      l(end+1) = event.listener(this.Filters, 'NewFs', @(s,e)fs_listener(this,e));
      
      this.WhenRenderedListeners = l;
      
    end
    
    function b = enablemask(~)
      %ENABLEMASK Returns true if the object supports masks.

      % tworesps does not support masks.  Only magresp and groupdelay.
      b = false;
      
    end
    
    function objspecificdraw(this)
      %OBJSPECIFICDRAW   Perform the tworesps specific drawing.

      h = this.Handles;
      
      if length(this.Filters) == 1 && ...
          ~(showpoly(this.FilterUtils) && ispolyphase(this.Filters(1).Filter))
        if isa(this.Filters(1).Filter, 'dfilt.abstractsos')&& ~isempty(this.SOSViewOpts)
          if ~strcmpi(this.SOSViewOpts.View, 'complete')
            return;
          end
        end
        le = length(h.cline);
        if le ~= 1
          c = getcolorfromindex(h.axes(1), 2);
          set(getline(this.Analyses(2)), 'Color', c, ...
            'MarkerFaceColor', c);
        end
      end
      
    end    
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function out = setresps(this, out)
      %SETRESPS

      for i = 1:length(out)
        out(i).Filters = this.Filters;
        out(i).PolyphaseView = this.PolyphaseView;
        out(i).ShowReference = this.ShowReference;
        out(i).SOSViewOpts = this.SOSViewOpts;
      end
      
      out = twoanalyses_setresps(this, out);
      
    end
    
    function tworesps_update(this)
      h = this.Handles;
      delete(get(h.axes(1), 'Title'));
      delete(get(h.axes(2), 'Title'));
      updatetitle(this);
      
      draw(this);     
    end
    
  end  %% possibly private or hidden
  
end  % classdef

% -------------------------------------------------------------------------
function lclprop_listener(hObj, eventData)

prop = eventData.Source.Name;

for i =1:length(hObj.Analyses)
  hObj.Analyses(i).(prop) = hObj.(prop);
end

end 

% -------------------------------------------------------------------------
function fs_listener(this, ~)

% Call single analysis updates first, then call updates for the two
% response object
filtrespFsUpdate(this.Analyses(1))
filtrespFsUpdate(this.Analyses(2))

h = this.Handles;
title(h.axes(1), '');
title(h.axes(2), '');
updatetitle(this);
draw(this);

end

% -------------------------------------------------------------------------
function prop_listener(this, evt)

% Limits only matter for magnitude and freq response analyses. Other
% analyses ignore limit input. 
evtName = evt.Source.Name;
switch evtName
  case 'ShowReference'
    lim = 'both';
  case 'PolyphaseView'
    lim = 'none';
  case 'SOSViewOpts'
    lim = 'x';
end    
% Make sure analyses are in sync with the two response object
this.Analyses(1).(evtName) = this.(evtName);
this.Analyses(2).(evtName) = this.(evtName);

% Call single analysis updates first, then call updates for the two
% response object
filtrespShowUpdate(this.Analyses(1),lim);
filtrespShowUpdate(this.Analyses(2),lim);

h = this.Handles;
delete(get(h.axes(1), 'Title'));
delete(get(h.axes(2), 'Title'));
updatetitle(this);

draw(this);

end

% -------------------------------------------------------------------------
function lclfilters_listener(this, evt)

evtName = evt.Source.Name;
% Make sure analyses are in sync with the two response object
this.Analyses(1).(evtName) = this.(evtName);
this.Analyses(2).(evtName) = this.(evtName);

% Call single analysis updates first, then call updates for the two
% response object
filtrespFiltUpdate(this.Analyses(1));
filtrespFiltUpdate(this.Analyses(2));


l = this.WhenRenderedListeners;

l(end) = event.listener(this.Filters, 'NewFs', @(s,e)fs_listener(this,e));

this.WhenRenderedListeners = l;

deletehandle(this, 'legend');
draw(this);
updatelegend(this);


end
