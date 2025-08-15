classdef coefficients < sigresp.listboxanalysis & sigio.dyproputil & hgsetget
  %filtresp.coefficients class
  %   filtresp.coefficients extends sigresp.listboxanalysis.
  %
  %    filtresp.coefficients properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       FastUpdate - Property is of type 'on/off'
  %       Name - Property is of type 'string'
  %       Format - Property is of type 'string'
  %
  %    filtresp.coefficients methods:
  %       attachlisteners -   Attach the WhenRenderedListeners.
  %       enablemask - Returns true if the object supports masks.
  %       getanalysisdata - Returns the strings in the text box.

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %FORMAT Property is of type 'string'
    Format = '';
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %FILTERUTILS Property is of type 'filtresp.filterutils'
    FilterUtils = [];
  end
  
  
  methods  % constructor block
    function h = coefficients(varargin)
      %COEFFICIENTS Constructor
      %   COEFFICIENTS(FILTOBJ) Construct a coeffview object using FILTOBJ
            
      allPrm = h.super_construct(varargin{:});
      h.FilterUtils = filtresp.filterutils(varargin{:});
      findclass(findpackage('dspopts'), 'sosview'); % g 227896
      addprops(h, h.FilterUtils);
      
      set(h, 'Name', getString(message('signal:sigtools:filtresp:FilterCoefficients')))
      
      opts = {'Decimal', 'Hexadecimal'};
      if isfixptinstalled
        opts{end+1} = 'Binary';
      end
      
      createparameter(h, allPrm, 'Coefficient Display', 'coefficient', opts);
      
      
    end  % coefficients
    
  end  % constructor block
  
  methods
    function set.FilterUtils(obj,value)
      % DataType = 'filtresp.filterutils'
      validateattributes(value,{'filtresp.filterutils'}, {'scalar'},'','FilterUtils')
      obj.FilterUtils = value;
    end
    
    function value = get.Format(obj)
      value = get_format(obj,obj.Format);
    end
    function set.Format(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','Format')
      obj.Format = set_format(obj,value);
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function attachlisteners(this, fcn)
      %ATTACHLISTENERS   Attach the WhenRenderedListeners.
      
      
      filtutils = get(this, 'FilterUtils');
      
      l(1) = event.proplistener(filtutils, filtutils.findprop('Filters'),      'PostSet', @(s,e)filters_listener(this,e,fcn));
      l(2) = event.proplistener(filtutils, filtutils.findprop('ShowReference'),'PostSet', @(s,e)filters_listener(this,e,fcn));
      l(3) = event.proplistener(filtutils, filtutils.findprop('PolyphaseView'),'PostSet', @(s,e)filters_listener(this,e,fcn));
      
      set(this, 'WhenRenderedListeners', l);
      
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
        strs = cell(size(filtobj));
        
        for indx = 1:length(filtobj)
          fmt = {this.Format};
          if showpoly(this.FilterUtils) && ispolyphase(filtobj{indx})
            Hd = polyphase(filtobj{indx}, 'objects');
            for jndx = 1:length(Hd)
              strs{indx} = strvcat(strs{indx}, ...
                lclformat(coeffviewstr(Hd(jndx), fmt{:}), ...
                sprintf([getString(message('signal:sigtools:filtresp:Polyphase')) ' (%d)'], jndx)), ' ');
            end
            strs{indx}(end, :) = [];
          else
            strs{indx} = coeffviewstr(filtobj{indx}, fmt{:});
            if showref(this.FilterUtils) && isquantized(filtobj{indx}) && ...
                ~isa(filtobj{indx}, 'mfilt.abstractcic')
              strs{indx} = strvcat(lclformat(strs{indx}, getString(message('signal:sigtools:filtresp:Quantized'))), ' ', ...
                lclformat(coeffviewstr(reffilter(filtobj{indx}), fmt{:}), getString(message('signal:sigtools:filtresp:Reference'))));
            end
          end
        end
      end
      
      dummy = [];
      
    end
        
  end  %% public methods
  
end  % classdef

function fmt = get_format(this, fmt)

h = getparameter(this, 'coefficient');
fmt = get(h, 'Value');
end  % get_format


% -------------------------------------------------------------------------
function fmt = set_format(this, fmt)

h = getparameter(this, 'coefficient');
fmt = setvalue(h, fmt);
end  % set_format

% ------------------------------------------------------------------
function filters_listener(this, eventStruct, fcn)

feval(fcn, this)

end

% -------------------------------------------------------------------------
function str = lclformat(str, pre)

str = cellstr(str);
for jndx = 1:length(str)
  if ~isempty(strfind(str{jndx}, ':'))
    str{jndx} = sprintf('%s %s', pre, str{jndx});
  end
end
str = strvcat(str{:});

end

