classdef (Abstract) frequencyresp < sigresp.freqaxiswfreqvec & sigio.dyproputil & hgsetget
  %filtresp.frequencyresp class
  %   filtresp.frequencyresp extends sigresp.freqaxiswfreqvec.
  %
  %    filtresp.frequencyresp properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       FastUpdate - Property is of type 'on/off'
  %       Name - Property is of type 'string'
  %       Legend - Property is of type 'on/off'
  %       Grid - Property is of type 'on/off'
  %       Title - Property is of type 'on/off'
  %       FrequencyScale - Property is of type 'string'
  %       NormalizedFrequency - Property is of type 'string'
  %       FrequencyRange - Property is of type 'string'
  %       NumberOfPoints - Property is of type 'double'
  %       FrequencyVector - Property is of type 'double_vector user-defined'
  %       DisplayMask - Property is of type 'on/off'
  %
  %    filtresp.frequencyresp methods:
  %       attachlisteners - Attach listeners to properties for render updates.
  %       enablemask - Returns true if the object supports masks.
  %       frequencyresp_construct - Perform constructions tasks and return all found
  %       getlegendstrings - Returns the strings to use in the legend
  %       getlineorder -   Return the line order.
  %       isreal - Returns true if all the filters are real
  %       updatemasks - Draw the masks onto the bottom axes

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %DISPLAYMASK Property is of type 'on/off'
    DisplayMask
  end
  
  properties (AbortSet, SetObservable, GetObservable, Hidden)
    %HIDDENIMAGCRUMB Property is of type 'bool' (hidden)
    hiddenImagCrumb = false;
    IsOverlayedOn = false;
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %FILTERLISTENER Property is of type 'handle.listener'
    FilterListener = [];
    %FILTERUTILS Property is of type 'filtresp.filterutils'
    FilterUtils = [];        
  end
  
  
  methods
    function value = get.DisplayMask(obj)
      value = getdisplaymask(obj,obj.DisplayMask);
    end
    function set.DisplayMask(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','DisplayMask');
      obj.DisplayMask = value;
    end
    
    function set.FilterListener(obj,value)
      % DataType = 'handle.listener'
      validateattributes(value,{'event.proplistener'}, {'scalar'},'','FilterListener')
      obj.FilterListener = value;
    end
    
    function set.FilterUtils(obj,value)
      % DataType = 'filtresp.filterutils'
      validateattributes(value,{'filtresp.filterutils'}, {'scalar'},'','FilterUtils')
      obj.FilterUtils = value;
    end
    
    function set.hiddenImagCrumb(obj,value)
      % DataType = 'bool'
      validateattributes(value,{'logical'}, {'scalar'},'','hiddenImagCrumb')
      obj.hiddenImagCrumb = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function attachlisteners(this)
      %ATTACHLISTENERS Attach listeners to properties for render updates.
      filterutils = this.FilterUtils;
      l(1) = event.proplistener(this, this.findprop('DisplayMask'),                 'PostSet', @(s,e) lcldisplaymask_listener(this,e));
      l(2) = event.proplistener(filterutils, filterutils.findprop('Filters'),       'PostSet', @(s,e)lclfilter_listener(this,e));
      l(3) = event.proplistener(filterutils, filterutils.findprop('ShowReference'), 'PostSet', @(s,e)lclshow_listener(this,e));
      l(4) = event.proplistener(filterutils, filterutils.findprop('PolyphaseView'), 'PostSet', @(s,e)lclshow_listener(this,e,'none'));
      l(5) = event.proplistener(filterutils, filterutils.findprop('SOSViewOpts'),   'PostSet', @(s,e)sosview_listener(this,e));
      
      this.WhenRenderedListeners = l;
      
      attachfilterlisteners(this);
      
    end
    
    
    function b = enablemask(hObj)
      %ENABLEMASK Returns true if the object supports masks.
      % abstractresp does not support masks.  Only magresp and groupdelay.
      
      b = false;
      
    end
    
    function allPrm = frequencyresp_construct(this, varargin)
      %FREQUENCYRESP_CONSTRUCT Perform constructions tasks and return all found
      %parameters
      %
      %  Search for parameters and setup the freqaxis super class properties
      %  Create the FilterUtils object and pass it the input (to find the
      %  filters).
      %  Add a listener to the Filter to look for complex filters.

      allPrm = freqaxiswfreqvec_construct(this,varargin{:});
      
      this.FilterUtils = filtresp.filterutils(varargin{:});
      findclass(findpackage('dspopts'), 'sosview'); % g 227896
      addprops(this, this.FilterUtils);
      
      l = event.proplistener(this.FilterUtils, this.FilterUtils.findprop('Filters'), 'PostSet', @(s,e)lclfilters_listener(this,e));
      this.FilterListener = l;
      
      lclfilters_listener(this);
      
    end
    
    function strs = getlegendstrings(hObj, varargin)
      %GETLEGENDSTRINGS Returns the strings to use in the legend

      strs = getlegendstrings(hObj.FilterUtils, varargin{:});
      
    end
    
    
    function order = getlineorder(this, varargin)
      %GETLINEORDER   Return the line order.

      order = getlineorder(this.FilterUtils, varargin{:});
      
    end
    
    
    function b = isreal(hObj)
      %ISREAL Returns true if all the filters are real

      Hd = hObj.Filters;
      b = true;
      for indx = 1:length(Hd)
        b = all([b isreal(Hd(indx).Filter)]);
      end
      
    end
    
    function soslistener(this)
      
      Hd = this.Filters;
      if length(Hd) == 1
        if isa(Hd.Filter, 'dfilt.abstractsos')
          
          deletehandle(this, 'Legend');
          
          captureanddraw(this, 'x');
          
          % Make sure that we put up the legend after so that it is on top of the
          % plotting axes.
          updatelegend(this);
          
          
        end
      end
      
    end
    
    
    function updatemasks(hObj)
      %UPDATEMASKS Draw the masks onto the bottom axes

      h = hObj.Handles;
      
      if isfield(h, 'masks')
        h.masks(~ishghandle(h.masks)) = [];
        delete(h.masks);
      end
      
      if strcmpi(hObj.DisplayMask, 'On')
        
        Hd = hObj.Filters;
        
        fs = Hd.Fs;
        mi = Hd.Filter.MaskInfo;
        if isempty(fs) || strcmpi(hObj.NormalizedFrequency, 'on')
          fs = 2;
          mi.frequnit = 'Hz'; % Fool it into using 2 Hz so it looks normalized
        end
        
        % Convert the frequency depending on the new frequency.
        for indx = 1:length(mi.bands)
          mi.bands{indx}.frequency = mi.bands{indx}.frequency*fs/mi.fs;
        end
        mi.fs = fs;
        
        h.masks = info2mask(mi, getbottomaxes(hObj));
        set(h.masks, 'HitTest', 'off');
        hObj.Handles = h;
      end
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function b = frequencyresp_enablemask(hObj)
      %FREQUENCYRESP_ENABLEMASK
      
      if isprop(hObj, 'Filters')
        Hd = hObj.Filters;
        if length(Hd) == 1 & isprop(Hd.Filter, 'MaskInfo')
          b = true;
        else
          b = false;
        end
        
      else
        b = false;
      end
    end
    
    
    function s = getlinestyle(hObj, indx)
      %GETLINESTYLE
      
      s = getlinestyle(hObj.FilterUtils, indx);
      
    end
    
    
    function fs = getmaxfs(h)
      %GETMAXFS

      fs = getmaxfs(h.FilterUtils);
      
    end
    
    function attachfilterlisteners(this)
      
      l = this.WhenRenderedListeners;
      l = l(1:5);
      
      Hd = this.Filters;
      
      if ~isempty(Hd)
        l(end+1) = event.listener(Hd, 'NewFs', @(s,e)fs_listener(this,e));
        l(end+1) = event.proplistener(Hd, Hd(1).findprop('Name'), 'PostSet', @(s,e)name_listener(this,e));
      end
      
      this.WhenRenderedListeners = l;
      
    end
        
            
  end  %% possibly private or hidden
  
end  % classdef

function out = getdisplaymask(hObj, out)

if ~enablemask(hObj)
  out = 'off';
end
end  % getdisplaymask

% ----------------------------------------------------------
function sosview_listener(this, eventData)

Hd = this.Filters;
if length(Hd) == 1
  if isa(Hd.Filter, 'dfilt.abstractsos')
    lclshow_listener(this, eventData, 'x');
  end
end

end

% ----------------------------------------------------------
function lclshow_listener(this, ~, limits)

if ~this.IsOverlayedOn
    
  if nargin < 3
    limits = 'both';
  end
  filtrespShowUpdate(this,limits);
  
end


end


% ----------------------------------------------------------
function lcldisplaymask_listener(this, ~)

updatemasks(this);

end

% ---------------------------------------------------------------------
function lclfilter_listener(this, ~)

% If the Handles property exists means the properties are created
% (dynamically) and exist, only then attach the listeners. In UDD listeners
% can be attached to properties which do not exist for an object, this is
% not allowed in MCOS.
if ~this.IsOverlayedOn    
  filtrespFiltUpdate(this);
end
end

% ---------------------------------------------------------------------
function name_listener(this, ~)

deletehandle(this, 'legend');
updatelegend(this);

end

% ---------------------------------------------------------------------
function fs_listener(this, ~, varargin)

if ~this.IsOverlayedOn    
  filtrespFsUpdate(this);
end

end


% ---------------------------------------------------------------------------
function lclfilters_listener(this, ~)
%LCLFILTERS_LISTENER Looks for complex filters and updates the range.

% If any of the filters are not real, make the range -pi to pi.
if isreal(this)
  if this.hiddenImagCrumb
    opts = getfreqrangeopts(this);
    this.FrequencyRange = opts{1};
    this.hiddenImagCrumb = false;
  end
else
  opts = getfreqrangeopts(this);
  if any(strcmpi(this.FrequencyRange, opts{1}))
    this.hiddenImagCrumb = true;
    this.FrequencyRange = opts{3};
  end
end

end

% [EOF]
