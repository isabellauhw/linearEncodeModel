classdef info < sigresp.listboxanalysis & sigio.dyproputil & hgsetget
  %filtresp.info class
  %   filtresp.info extends sigresp.listboxanalysis.
  %
  %    filtresp.info properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       FastUpdate - Property is of type 'on/off'
  %       Name - Property is of type 'string'
  %
  %    filtresp.info methods:
  %       attachlisteners -   Attach the WhenRenderedListeners
  %       enablemask - Returns true if the object supports masks.
  %       getanalysisdata - Returns the strings in the text box.
  
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %FILTERUTILS Property is of type 'filtresp.filterutils'
    FilterUtils = [];
  end
  
  
  methods  % constructor block
    function h = info(varargin)
      %INFO Constructor
      %   INFO(FILTOBJ) Construct an info object using FILTOBJ

      h.super_construct(varargin{:});
      h.FilterUtils = filtresp.filterutils(varargin{:});
      findclass(findpackage('dspopts'), 'sosview'); % g 227896
      addprops(h, h.FilterUtils);
      
      h.Name = getString(message('signal:sigtools:filtresp:FilterInformation'));
      
      
    end  % info
    
  end  % constructor block
  
  methods
    function set.FilterUtils(obj,value)
      % DataType = 'filtresp.filterutils'
      validateattributes(value,{'filtresp.filterutils'}, {'scalar'},'','FilterUtils')
      obj.FilterUtils = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function attachlisteners(this, fcn)
      %ATTACHLISTENERS   Attach the WhenRenderedListeners

      filtutils = this.FilterUtils;
      
      l(1) = event.proplistener(filtutils, filtutils.findprop('Filters'),       'PostSet', @(s,e)filters_listener(this,e,fcn));
      l(2) = event.proplistener(filtutils, filtutils.findprop('ShowReference'), 'PostSet', @(s,e)filters_listener(this,e,fcn));
      l(3) = event.proplistener(filtutils, filtutils.findprop('PolyphaseView'), 'PostSet', @(s,e)filters_listener(this,e,fcn));
      
      this.WhenRenderedListeners = l;
      
    end
    
    function b = enablemask(hObj)
      %ENABLEMASK Returns true if the object supports masks.

      % abstractresp does not support masks.  Only magresp and groupdelay.
      
      b = false;
      
    end
    
    function [strs, dummy] = getanalysisdata(this)
      %GETANALYSISDATA Returns the strings in the text box.

      if isempty(this.Filters)
        strs = {''};
      else
        
        filtobj = get(this.Filters, 'Filter');
        
        if ~iscell(filtobj), filtobj = {filtobj}; end
        
        % Get the info from each of the filters.
        strs = cell(size(filtobj));
        
        for indx = 1:length(filtobj)
          if showpoly(this.FilterUtils) && ispolyphase(filtobj{indx})
            Hd = polyphase(filtobj{indx}, 'objects');
            for jndx = 1:length(Hd)
              strs{indx} = strvcat(strs{indx}, sprintf([getString(message('signal:sigtools:filtresp:Polyphase')) ' (%d)'], jndx), ...
                ' ', info(Hd(jndx), 'long'), ' ');
            end
            strs{indx}(end, :) = [];
          else
            strs{indx} = info(filtobj{indx}, 'long');
          end
        end
      end
      
      dummy = [];
      
    end
    
    function soslistener(this)
      % No OP      
    end      
    
  end  %% public methods
  
end  % classdef

% ------------------------------------------------------------------
function filters_listener(this, eventStruct, fcn)

feval(fcn, this)

end

