classdef timeresp < sigresp.timeaxis & sigio.dyproputil & hgsetget
  %filtresp.timeresp class
  %   filtresp.timeresp extends sigresp.timeaxis.
  %
  %    filtresp.timeresp properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       FastUpdate - Property is of type 'on/off'
  %       Name - Property is of type 'string'
  %       Legend - Property is of type 'on/off'
  %       Grid - Property is of type 'on/off'
  %       Title - Property is of type 'on/off'
  %       NormalizedFrequency - Property is of type 'string'
  %       LineStyle - Property is of type 'string'
  %       SpecifyLength - Property is of type 'on/off'
  %       Length - Property is of type 'int32'
  %
  %    filtresp.timeresp methods:
  %       attachlisteners -   Attach the listeners to help with redrawing.
  %       deletelineswithtag - Deletes the lines based on their tag
  %       enablemask - Returns true if the object supports masks.
  %       getlegendstrings - Returns the legend strings
  %       getmarker -   Return the marker to use for the given line index.
  %       getmaxfs - Returns the maximum sampling frequency.
  %       timeresp_construct - Check the inputs

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %SPECIFYLENGTH Property is of type 'on/off'
    SpecifyLength = 'off';
    %LENGTH Property is of type 'int32'
    Length
    IsOverlayedOn = false;
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %FILTERUTILS Property is of type 'filtresp.filterutils'
    FilterUtils = [];        
  end
  
  
  methods
    function value = get.SpecifyLength(obj)
      value = getspecify(obj,obj.SpecifyLength);
    end
    function set.SpecifyLength(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','SpecifyLength');
      obj.SpecifyLength = setspecify(obj,value);
    end
    
    function value = get.Length(obj)
      value = getlength(obj,obj.Length);
    end
    function set.Length(obj,value)
      % DataType = 'int32'
      validateattributes(value,{'int32'}, {'scalar'},'','Length')
      obj.Length = setlength(obj,value);
    end
    
    function set.FilterUtils(obj,value)
      % DataType = 'filtresp.filterutils'
      validateattributes(value,{'filtresp.filterutils'}, {'scalar'},'','FilterUtils')
      obj.FilterUtils = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function attachlisteners(this)
      %ATTACHLISTENERS   Attach the listeners to help with redrawing.
      filtutils = this.FilterUtils;
      l(1) = event.proplistener(filtutils, filtutils.findprop('Filters'),       'PostSet', @(s,e)lclfilter_listener(this,e));
      l(2) = event.proplistener(filtutils, filtutils.findprop('ShowReference'), 'PostSet', @(s,e)lclsrr_listener(this,e));
      l(3) = event.proplistener(filtutils, filtutils.findprop('PolyphaseView'), 'PostSet', @(s,e)lclsrr_listener(this,e));
      l(4) = event.proplistener(filtutils, filtutils.findprop('SOSViewOpts'),   'PostSet', @(s,e)sosview_listener(this,e));
      
      this.WhenRenderedListeners = l;
      
      attachfilterlisteners(this);
      
    end
    
    function deletelineswithtag(hObj)
      %DELETELINESWITHTAG Deletes the lines based on their tag

      % when we can call super methods replace this with
      % super::deletelineswithtag(hObj)
      h = hObj.Handles;
      if isfield(h, 'line')
        delete(h.line(ishghandle(h.line)));
      end
      % delete(findobj(h.axes, 'type', 'line', 'tag', getlinetag(hObj)));
      % delete(findobj(h.axes, 'type', 'line', 'tag', 'timeresp_stemline'));
      
    end
    
    function b = enablemask(hObj)
      %ENABLEMASK Returns true if the object supports masks.

      % abstractresp does not support masks.  Only magresp and groupdelay.
      
      b = false;
      
    end
    
    function strs = getlegendstrings(this, varargin)
      %GETLEGENDSTRINGS Returns the legend strings

      strs = getlegendstrings(this.FilterUtils, varargin{:});
      
      % We need special code to take care of the imaginary part
      imagStrs = repmat({''}, 1, length(strs));
      eindx    = [];
      
      Hd = this.Filters;
      [dindx, qindx] = getfiltindx(Hd);
      if ~showref(this.FilterUtils)
        dindx = sort([dindx qindx]);
        qindx = [];
      end
      nq = length(qindx);
      
      for indx = 1:nq
        
        if isreal(Hd(qindx(indx)).Filter)
          
          % If the filter is real add the index to a list to remove from imagStrs
          eindx = [eindx, 4*indx-2, 4*indx];
        else
          
          % If the filter isn't real add 'imaginary and real
          imagStrs{2*indx-1} = [strs{2*indx-1} ': Imaginary'];
          strs{2*indx-1}     = [strs{2*indx-1} ': Real'];
          imagStrs{2*indx}   = [strs{2*indx} ': Imaginary'];
          strs{2*indx}       = [strs{2*indx} ': Real'];
        end
      end
      
      for indx = 1:length(dindx)
        if ~isreal(Hd(dindx(indx)).Filter)
          imagStrs{2*nq+indx} = [strs{2*nq+indx} ': Imaginary'];
          strs{2*nq+indx}     = [strs{2*nq+indx} ': Real'];
        end
      end
      
      strs = {strs{:}; imagStrs{:}};
      strs = {strs{:}};
      indx = 1;
      while indx <= length(strs)
        if isempty(strs{indx})
          strs(indx) = [];
        else
          indx = indx+1;
        end
      end
      
    end
    
    function [m, f] = getmarker(this, lndx)
      %GETMARKER   Return the marker to use for the given line index.

      m = {};
      f = {};
      
      for indx = 1:length(this.Filters)
        cFilt = this.Filters(indx).Filter;
        if showpoly(this.FilterUtils)
          npoly = npolyphase(cFilt);
        else
          npoly = 1;
        end
        if isquantized(cFilt) && showref(this.FilterUtils)
          m = [m repmat({{'s', 'x'}}, 1, npoly)       repmat({{'o', '*'}}, 1, npoly)];
          f = [f repmat({{'none', 'auto'}}, 1, npoly) repmat({{'auto', 'auto'}}, 1, npoly)];
        else
          m = [m repmat({{'o', '*'}}, 1, npoly)];
          f = [f repmat({{'auto', 'auto'}}, 1, npoly)];
        end
      end
      
      if ~isempty(this.SOSViewOpts) && length(this.Filters) == 1
        if isa(this.Filters(1).Filter, 'dfilt.abstractsos')
          nresps = getnresps(this.SOSViewOpts, this.Filters(1).Filter);
          m = repmat(m, 1, nresps);
          f = repmat(f, 1, nresps);
        end
      end
      
      if nargin > 1
        m = m{lndx};
        f = f{lndx};
      end
      
      
    end    
    
    function fs = getmaxfs(h)
      %GETMAXFS Returns the maximum sampling frequency.

      fs = getmaxfs(h.FilterUtils);
      
    end
    
    function allPrm = timeresp_construct(this, varargin)
      %TIMERESP_CONSTRUCT Check the inputs

      this.FilterUtils = filtresp.filterutils(varargin{:});
      findclass(findpackage('dspopts'), 'sosview'); % g 227896
      addprops(this, this.FilterUtils);
      
      allPrm = this.timeaxis_construct(varargin{:});
      
      createparameter(this, allPrm, 'Specify Length', 'uselength', {'Default', 'Specified'});
      createparameter(this, allPrm, 'Length', 'impzlength', [1 1 inf], 50);
      
      hPrm    = getparameter(this, 'uselength');
      l = [ this.Listeners;
        handle.listener(hPrm, 'NewValue', @uselength_listener); ...
        handle.listener(hPrm, 'UserModified', @uselength_listener); ...
        ];
      set(l, 'CallbackTarget', this);
      set(this, 'Listeners', l);
      
      uselength_listener(this, []);
      
    end              
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function ord = getlineorder(hObj)
      %GETLINEORDER

      ord = getlineorder(hObj.FilterUtils, 'time');
      
    end
    
    function hPrm = getxaxisparams(hObj)
      %GETXAXISPARAMS

      hPrm = hObj.Parameters;
      
      hPrm = find(hPrm, 'tag', 'uselength','-or', ...
        'tag', 'impzlength', '-or', ...
        'tag', 'timemode', '-or', ...
        'tag', 'freqmode', '-or', ...
        'tag', 'plottype'); %#ok<GTARG>
    end
    
    %----------------------------------------------------------------------
    function filtrespShowUpdate(this,~)
      
      deletehandle(this, 'Legend');
      
      captureanddraw(this);
      
      % Make sure that we put up the legend after so that it is on top of the
      % plotting axes.
      updatelegend(this);
      
    end
    %----------------------------------------------------------------------
    function filtrespFiltUpdate(this, ~, ~)      
      attachfilterlisteners(this);
      lclsrr_listener(this);     
    end    
    
    % ----------------------------------------------------------
    function attachfilterlisteners(this)
      
      l = this.WhenRenderedListeners;
      l = l(1:4);
      
      Hd = this.Filters;
      if ~isempty(Hd)
        l(end+1) = event.listener(Hd, 'NewFs', @(s,e)fs_listener(this,e));
        l(end+1) = event.proplistener(Hd, Hd(1).findprop('Name'), 'PostSet', @(s,e)name_listener(this,e));
      end
      
      this.WhenRenderedListeners = l;
      
    end
        
  end  %% possibly private or hidden
  
end  % classdef

function out = setlength(hObj, out)

hPrm = getparameter(hObj, 'impzlength');
if ~isempty(hPrm), setvalue(hPrm, out); end
end  % setlength


% ---------------------------------------------------------------------
function out = getlength(hObj, out)

hPrm = getparameter(hObj, 'impzlength');
out = get(hPrm, 'Value');
end  % getlength


% ---------------------------------------------------------------------
function out = setspecify(hObj, out)

hPrm = getparameter(hObj, 'uselength');
if ~isempty(hPrm)
  if strcmpi(out, 'on')
    value = 'Specified';
  else
    value = 'Default';
  end
  setvalue(hPrm, value);
end
end  % setspecify


% ---------------------------------------------------------------------
function out = getspecify(hObj, out)

hPrm = getparameter(hObj, 'uselength');
out = get(hPrm, 'Value');

if strcmpi(out, 'Specified')
  out = 'On';
else
  out = 'Off';
end
end  % getspecify

% ----------------------------------------------------------
function sosview_listener(this, eventData)

Hd = this.Filters;
if length(Hd) == 1
  if isa(Hd.Filter, 'dfilt.abstractsos')
    lclsrr_listener(this, eventData);
  end
end

end

% ----------------------------------------------------------
function lclsrr_listener(this, ~)

if ~this.IsOverlayedOn
    
  filtrespShowUpdate(this);
  
end

end

% ---------------------------------------------------------------------
function lclfilter_listener(this, ~, varargin)

if ~this.IsOverlayedOn
  filtrespFiltUpdate(this);
end

end

% ---------------------------------------------------------------------
function name_listener(this, ~)

if ishandlefield(this, 'legend')
  h = this.Handles;
  delete(h.legend);
end

updatelegend(this);

end

% ---------------------------------------------------------------------
function fs_listener(this, ~, varargin)

if ~this.IsOverlayedOn    
  filtrespFsUpdate(this);
end

end

% ----------------------------------------------------------
function uselength_listener(this, eventData)

usel = getsettings(getparameter(this, 'uselength'), eventData);

if strcmpi(usel, 'default')
  disableparameter(this, 'impzlength');
else
  enableparameter(this, 'impzlength');
end

end

% [EOF]
