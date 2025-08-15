classdef filterutils < hgsetget & matlab.mixin.Copyable
  %filtresp.filterutils class
  %    filtresp.filterutils properties:
  %       Filters - Property is of type 'MATLAB array'
  %       ShowReference - Property is of type 'on/off'
  %       PolyphaseView - Property is of type 'on/off'
  %       SOSViewOpts - Property is of type 'dspopts.sosview'
  %
  %    filtresp.filterutils methods:
  %       getlegendstrings -   Get the strings for the legend.
  %       getlineorder -   Return the line -> filter indices.
  %       getlinestyle -   Returns the line style to use for Frequency plots.
  %       propstoadd -   Return the properties to add.
  %       showpoly -   Returns true if we should show the polyphase.
  %       showref -   Returns true if the reference should be shown.
  
  properties (SetObservable, GetObservable)
    %SOSVIEWOPTS Property is of type 'dspopts.sosview'
    SOSViewOpts = [];    
  end
  properties (AbortSet, SetObservable, GetObservable)
    %FILTERS Property is of type 'MATLAB array'
    Filters = [];
    %SHOWREFERENCE Property is of type 'on/off'
    ShowReference = 'off';
    %POLYPHASEVIEW Property is of type 'on/off'
    PolyphaseView = 'off';
  end
  
  
  methods  % constructor block
    function h = filterutils(varargin)
      %FILTERUTILS Construct a FILTERUTILS object
      h.Filters = findfilters(varargin{:});      
    end  % filterutils    
  end  % constructor block
  
  methods
    function set.Filters(obj,value)      
      obj.Filters = setfilters(obj,value);      
    end
    
    function set.ShowReference(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','ShowReference');
      obj.ShowReference = value;
    end
    
    function set.PolyphaseView(obj,value)
      % DataType = 'on/off'
      validatestring(value,{'on','off'},'','PolyphaseView');
      obj.PolyphaseView = value;
    end
    
    function set.SOSViewOpts(obj,value)
      % DataType = 'dspopts.sosview'     
      if ~isempty(value)
        validateattributes(value,{'dspopts.sosview'}, {'scalar'},'','SOSViewOpts')            
      end
      obj.SOSViewOpts = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function strs = getlegendstrings(this, str)
      %GETLEGENDSTRINGS   Get the strings for the legend.

      if nargin > 1
        extra = [' ' str];
      else
        extra = '';
      end
      
      if isempty(extra)
        extrad = extra;
      else
        extrad = [':' extra];
      end
      
      strs = {};
      
      Hd = get(this, 'Filters');
      
      if isempty(Hd)
        return;
      elseif length(Hd) == 1 && ...
          isa(Hd.Filter, 'dfilt.abstractsos') && ...
          ~isempty(this.SOSViewOpts)
        if ~strcmpi(this.SOSViewOpts.View, 'complete')
          
          name = get(Hd, 'Name');
          if isempty(name)
            name = [getString(message('signal:sigtools:filtresp:Filter')) ' #1'];
          end
          
          names = getnames(this.SOSViewOpts, Hd.Filter);
          qstrs = {};
          rstrs = {};
          
          for indx = 1:length(names)
            if isquantized(Hd.Filter) && showref(this)
              qstrs{indx} = sprintf(['%s: %s: ' getString(message('signal:sigtools:filtresp:Quantized')) '%s'], name, names{indx}, extra);
              rstrs{indx} = sprintf(['%s: %s: ' getString(message('signal:sigtools:filtresp:Reference')) '%s'], name, names{indx}, extra);
            else
              rstrs{indx} = sprintf('%s: %s%s', name, names{indx}, extra);
            end
          end
          
          strs = {qstrs{:} rstrs{:}};
          return;
        end
      end
      
      for indx = 1:length(Hd)
        name = get(Hd(indx), 'Name');
        if isempty(name)
          name = sprintf([getString(message('signal:sigtools:filtresp:Filter')) ' #%d'], indx);
        end
        
        cFilt = Hd(indx).Filter;
        
        if isquantized(cFilt) && showref(this) && ispolyphase(cFilt) && showpoly(this)
          for jndx = 1:npolyphase(cFilt)
            strs = {strs{:}, sprintf(['%s: ' getString(message('signal:sigtools:filtresp:Quantized')) ' ' getString(message('signal:sigtools:filtresp:Polyphase')) '(%d)%s'], name, jndx, extra)};
          end
          for jndx = 1:npolyphase(cFilt)
            strs = {strs{:}, sprintf(['%s: ' getString(message('signal:sigtools:filtresp:Reference')) ' ' getString(message('signal:sigtools:filtresp:Polyphase')) '(%d)%s'], name, jndx, extra)};
          end
        elseif isquantized(cFilt) && showref(this)
          % Don't translate the filter names - see g1294314
          strs = {strs{:}, sprintf(['%s: ' getString(message('signal:sigtools:filtresp:Quantized')) '%s'], name,extra)}; 
          strs = {strs{:}, sprintf(['%s: ' getString(message('signal:sigtools:filtresp:Reference')) '%s'], name,extra)}; 
        elseif ispolyphase(cFilt) && showpoly(this)
          for jndx = 1:npolyphase(cFilt)
            strs = {strs{:}, sprintf(['%s: ' getString(message('signal:sigtools:filtresp:Polyphase')) '(%d)%s'], name, jndx, extra)};
          end
        else
          % Don't translate the filter names - see g1294314
           strs = getTranslatedStringcell('signal:sigtools:siggui',strs);
           strs = {strs{:}, sprintf('%s%s', name, extrad)};
        end
        
      end
      
    end
    
    function order = getlineorder(this, basis)
      %GETLINEORDER   Return the line -> filter indices.
      if nargin < 2, basis = 'freq'; end
      
      order = [];
      
      jndx = 1;
      for indx = 1:length(this.Filters)
        cFilt = this.Filters(indx).Filter;
        cindx = jndx;
        jndx = jndx+1;
        
        % Polyphase have max(L,M) plots, which can be determined from the
        % "polyphase" method.
        if ispolyphase(cFilt) && showpoly(this)

          jndx = jndx+npolyphase(cFilt)-1;
          cindx = [cindx:jndx-1];
          %         end
        else
          % Complex filters in the time domain have 2ce as many plots.
          if strcmpi(basis, 'time') && ~isreal(cFilt)
            cindx = [cindx cindx];
          end
        end
        
        % Quantized have twice as many plots.
        if isquantized(cFilt) && showref(this)
          cindx = [cindx cindx];
        end
        
        order = [order cindx];
      end
      
      if length(this.Filters) == 1 && ...
          ~isempty(this.SOSViewOpts)
        if isa(this.Filters(1).Filter, 'dfilt.abstractsos')
          nresps = getnresps(this.SOSViewOpts, this.Filters(1).Filter);
          if length(order) == 1
            order = [1:nresps];
          else
            % We have a complex sos filter.
            order = [1:nresps];
            order = repmat(order, 1, 2);
            %             order = order(:)';
          end
        end
      end
      
      % [EOF]
      
    end
    
    function s = getlinestyle(this, indx)
      %GETLINESTYLE   Returns the line style to use for Frequency plots.
      s = {};
      for idx = 1:length(this.Filters)
        cFilt = this.Filters(idx).Filter;
        cs = {'-'};
        if ispolyphase(cFilt) && showpoly(this)
          cs = repmat(cs, 1, npolyphase(cFilt));
        end
        if isquantized(this.Filters(idx).Filter) && showref(this)
          cs = [cs repmat({'-.'}, 1, length(cs))];
        end
        s = [s cs];
      end
      
      if length(this.Filters) == 1 && ...
          ~isempty(this.SOSViewOpts)
        if isa(this.Filters(1).Filter, 'dfilt.abstractsos')
          s = repmat(s, getnresps(this.SOSViewOpts, this.Filters(1).Filter), 1);
          s = s(:)';
        end
      end
      
      if isempty(s)
        s = {'-'};
      else
        s = s{indx};
      end
    end
    
    function p = propstoadd(this)
      %PROPSTOADD   Return the properties to add.
      p = {'Filters', 'ShowReference', 'PolyphaseView', 'SOSViewOpts'};

    end
    
    function b = showpoly(this)
      %SHOWPOLY   Returns true if we should show the polyphase.
      b = strcmpi(this.PolyphaseView, 'On');      
    end   
    
    function b = showref(this)
      %SHOWREF   Returns true if the reference should be shown.
      
      b = strcmpi(this.ShowReference, 'On');
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function fs = getmaxfs(h)
      %GETMAXFS
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      if isempty(h.Filters)
        fs = [];
      else
        fs = getmaxfs(h.Filters);
      end
     
    end
    
  end  %% possibly private or hidden
  
end  % classdef

function Hd = setfilters(this, Hd)

% If the filter is not already a DFILTwFS make it one.
if ~isa(Hd, 'dfilt.dfiltwfs')
  if ~iscell(Hd), Hd = {Hd}; end
  
  for indx = 1:length(Hd)
    if isa(Hd{indx}, 'dfilt.basefilter')
      Hd{indx} = dfilt.dfiltwfs(Hd{indx});
    elseif isa(Hd{indx}, 'dfilt.dfiltwfs') || isempty(Hd{indx})
      % No Op
    else
      error(message('signal:filtresp:filterutils:schema:NotSupported'));
    end
  end
  
  Hd = [Hd{:}];
end
end  % setfilters


