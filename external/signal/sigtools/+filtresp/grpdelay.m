classdef grpdelay < filtresp.frequencyresp
  %filtresp.grpdelay class
  %   filtresp.grpdelay extends filtresp.frequencyresp.
  %
  %    filtresp.grpdelay properties:
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
  %       GroupDelayUnits - Property is of type 'string'
  %
  %    filtresp.grpdelay methods:
  %       enablemask - Returns true if the mask points to grpdelay
  %       getyparams -   Return the param tags that set off a y unzoom.
  %       objspecificdraw - Draw the groupdelay

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %GROUPDELAYUNITS Property is of type 'string'
    GroupDelayUnits = '';
  end
  
  
  methods  % constructor block
    function h = grpdelay(varargin)
      %GROUPDELAY Construct a groudelay object

      h.Name = getString(message('signal:sigtools:filtresp:GroupDelay'));
      
      allPrm = h.frequencyresp_construct(varargin{:});
      
      createparameter(h, allPrm, 'Group Delay Units', 'grpdelay', {'Samples', 'Time'});
      
      
    end  % grpdelay
    
  end  % constructor block
  
  methods
    function value = get.GroupDelayUnits(obj)
      value = getgrpdelay(obj,obj.GroupDelayUnits);
    end
    function set.GroupDelayUnits(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','GroupDelayUnits')
      obj.GroupDelayUnits = setgrpdelay(obj,value);
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function b = enablemask(hObj)
      %ENABLEMASK Returns true if the mask points to grpdelay

      if ~frequencyresp_enablemask(hObj) || ...
          ~strcmpi(hObj.Filters.Filter.MaskInfo.response, 'groupdelay')
        
        b = false;
      else
        b = true;
      end
      
    end
    
    
    function yparams = getyparams(this)
      %GETYPARAMS   Return the param tags that set off a y unzoom.

      yparams = {'grpdelay'};
      
    end
    
    function [m, xunits] = objspecificdraw(this)
      %OBJSPECIFICDRAW Draw the groupdelay
      %   Passes back the frequency vector multiplier and the xunits

      Hd   = this.Filters;
      
      h      = this.Handles;
      h.axes = h.axes(end);
      
      if isempty(Hd)
        m = 1;
        xunits = '';
        ylbl = getString(message('signal:sigtools:filtresp:GroupDelayinSamples'));
        h.line = [];
      else
        opts = getoptions(this);
        
        optsstruct.showref  = showref(this.FilterUtils);
        optsstruct.showpoly = showpoly(this.FilterUtils);
        optsstruct.sosview  = this.SOSViewOpts;
        
        if strcmp(this.NormalizedFrequency,'on')
            optsstruct.NormalizedFrequency = true;
        else
            optsstruct.NormalizedFrequency = false;
        end
        
        [Gall, W] = grpdelay(Hd, opts{:}, optsstruct);
        
        % Apply the samples/time parameter
        if strcmpi(this.GroupDelayUnits, 'time') && ~isempty(getmaxfs(Hd))
          for indx = 1:length(Hd)
            
            fs = get(Hd(indx), 'Fs');
            if isempty(fs), fs = getmaxfs(Hd); end
            
            Gall{indx} = Gall{indx}/fs;
          end
          [Gall, m, units] = cellengunits(Gall);
          ylbl = getString(message('signal:sigtools:filtresp:GroupDelayInTimes', units));
        else
          ylbl = getString(message('signal:sigtools:filtresp:GroupDelayinSamples'));
        end
        
        [W, m, xunits] = normalize_w(this, W);
        
        if ishandlefield(this,'line') && length(h.line) == size(Gall{1}, 2)
          for indx = 1:size(Gall{1}, 2)
            set(h.line(indx), 'XData',W{1}, 'YData',Gall{1}(:,indx));
          end
        else
          h.line = freqplotter(h.axes, W, Gall);
        end
      end
      
      hylbl = ylabel(h.axes, ylbl);
      
      if ~ishandlefield(this, 'grpdelaycsmenu')
        if ~isempty(Hd)
          if ~isempty(getmaxfs(Hd))
            h.grpdelaycsmenu = contextmenu(getparameter(this, 'grpdelay'), hylbl);
          end
        end
      elseif isempty(getmaxfs(this.Filters))
        delete(h.grpdelaycsmenu);
        h = rmfield(h, 'grpdelaycsmenu');
      end
      
      this.Handles = h;

    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function s = legendstring(hObj)
      %LEGENDSTRING

      s = getString(message('signal:sigtools:filtresp:GroupDelay'));
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

function out = setgrpdelay(hObj, out)

hPrm = getparameter(hObj, 'grpdelay');
if ~isempty(hPrm), setvalue(hPrm, out); end
end  % setgrpdelay


% ---------------------------------------------------------------------
function out = getgrpdelay(hObj, out)

hPrm = getparameter(hObj, 'grpdelay');
out  = get(hPrm, 'Value');
end  % getgrpdelay

