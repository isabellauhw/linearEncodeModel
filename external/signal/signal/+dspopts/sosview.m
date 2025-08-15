classdef (CaseInsensitiveProperties=true, TruncatedProperties=true) sosview < hgsetget & matlab.mixin.Copyable
  %dspopts.sosview class
  %    dspopts.sosview properties:
  %       View - Property is of type 'sosviewtypes enumeration: {'Complete','Individual','Cumulative','UserDefined'}'
  %       UserDefinedSections - Property is of type 'mxArray'
  %       SecondaryScaling - Property is of type 'mxArray'
  %
  %    dspopts.sosview methods:
  %       disp -   Display this object.
  %       getfilters -   Get the filters.
  %       getnames -   Get the names.
  %       getnresps - NRESPS   Return the number of responses for the given filter.
  %       trimcustom -   Trim the custom setting for a given filter.

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %VIEW Property is of type 'sosviewtypes enumeration: {'Complete','Individual','Cumulative','UserDefined'}'
    View = 'Complete';
    %USERDEFINEDSECTIONS Property is of type 'mxArray'
    UserDefinedSections = 1;
    %SECONDARYSCALING Property is of type 'mxArray'
    SecondaryScaling = false;
  end
  
  properties (Transient, AbortSet, SetObservable, GetObservable, Hidden)
    %CACHEDFILTERS Property is of type 'mxArray' (hidden)
    cachedFilters = [];
  end
    
  methods  % constructor block
    function this = sosview(varargin)
      %SOSVIEW   Construct a SOSVIEW object.

      if nargin
        set(this, varargin{:});
      end
      
      
    end  % sosview
    
  end  % constructor block
  
  methods
    function set.View(obj,value)
      % Enumerated DataType = 'sosviewtypes enumeration: {'Complete','Individual','Cumulative','UserDefined'}'
      value = validatestring(value,{'Complete','Individual','Cumulative','UserDefined'},'','View');
      obj.View = value;
    end
    
    function value = get.UserDefinedSections(obj)
      value = get_soscustomview(obj,obj.UserDefinedSections);
    end
    function set.UserDefinedSections(obj,value)
      obj.UserDefinedSections = set_soscustomview(obj,value);
    end
    
    function value = get.SecondaryScaling(obj)
      value = get_secondaryscaling(obj,obj.SecondaryScaling);
    end
    function set.SecondaryScaling(obj,value)
      obj.SecondaryScaling = set_secondaryscaling(obj,value);
    end
    
    function set.cachedFilters(obj,value)
      obj.cachedFilters = value;
    end
    
  end   % set and get functions
  
  methods  %% public methods
    function disp(this)
      %DISP   Display this object.

      switch lower(this.View)
        case {'complete', 'individual'}
          props = {'View'};
        case 'cumulative'
          props = {'View', 'SecondaryScaling'};
        case 'userdefined'
          props = {'View', 'UserDefinedSections'};
      end
      
      siguddutils('dispstr', this, props);

    end
    
    
    function filters = getfilters(this, Hd)
      %GETFILTERS   Get the filters.

      c = get(this, 'cachedFilters');
      
      type = lower(get(this, 'View'));
      
      if isempty(c)
        c.complete    = copy(Hd);
        c.individual  = [];
        c.cumulative  = [];
        c.userdefined = [];
      elseif strcmpi(class(c.complete), class(Hd)) && ...
          isequal(get(c.complete, 'sosMatrix'), get(Hd, 'sosMatrix')) && ...
          isequal(get(c.complete, 'scaleValues'), get(Hd, 'scaleValues'))
        
        % If the "complete" filter matches what we are given, we can just
        % return a cached one.  If the appropriate cached filter has already
        % been created, simply return that one.  Otherwise proceed on to the
        % switch statement where the new filters are created.
        if ~isempty(c.(type))
          filters = c.(type);
          return;
        end
      else
        % If the filter doesn't match exactly, empty out the filter cache.
        c.complete    = copy(Hd);
        c.individual  = [];
        c.cumulative  = [];
        c.userdefined = [];
      end
      
      switch type
        case 'complete'
          filters = Hd;
        case 'individual'
          for indx = 1:nsections(Hd)
            filters(indx) = copy(Hd);
            reorder(filters(indx), indx);
            
            % Set the last scale value to 1 for all but the final section.
            if indx ~= nsections(Hd)
              filters(indx).ScaleValues(end) = 1;
            end
          end
        case 'cumulative'
          filters = cumsec(Hd, this.SecondaryScaling);
        case 'userdefined'
          custom = trimcustom(this, Hd);
          for indx = 1:length(custom)
            filters(indx) = copy(Hd);
            reorder(filters(indx), custom{indx});
            
            % Set the last scale value to 1 for all but the final section.
            if max(custom{indx}) ~= nsections(Hd)
              filters(indx).ScaleValues(end) = 1;
            end
          end
      end
      
      % Save the filter.
      c.(type) = filters;
      set(this, 'cachedFilters', c);

    end
    
    
    function names = getnames(this, Hd)
      %GETNAMES   Get the names.
   
      nsecs = nsections(Hd);
      
      alltypes = {'Complete', 'Individual', 'Cumulative', 'UserDefined'};
      
      switch this.View
        case alltypes{1} % 'complete'
          names = {''};
        case alltypes{2} % 'individual'
          for indx = 1:nsecs
            names{indx} = sprintf([getString(message('signal:dspopts:Section')) ' #%d'], indx);
          end
        case alltypes{3} % 'cumulative'
          names = {sprintf([getString(message('signal:dspopts:Section')) ' #%d'],1)};
          for indx = 2:nsecs
            names{indx} = sprintf([getString(message('signal:dspopts:Sections')) ' #1-%d'], indx);
          end
        case alltypes{4} % 'userdefined'
          custom = trimcustom(this, Hd);
          
          for indx = 1:length(custom)
            if length(custom{indx}) == 1
              
              % If there is just one section print it.
              names{indx} = sprintf([getString(message('signal:dspopts:Section')) ' #%d'], custom{indx});
            elseif all(diff(custom{indx}) == 1)
              
              % If we have consecutive sections use a '-'
              names{indx} = sprintf([getString(message('signal:dspopts:Sections')) ' #%d-%d'], min(custom{indx}), max(custom{indx}));
            else
              
              % If the sections aren't consecutive use [].
              names{indx} = [getString(message('signal:dspopts:Sections')) ' #['];
              for jndx = 1:length(custom{indx})
                names{indx} = sprintf('%s%d ', names{indx}, custom{indx}(jndx));
              end
              names{indx} = sprintf('%s]', names{indx}(1:end-1));
            end
          end
      end
      
    end
    
    
    function n = getnresps(this, Hd)
      %NRESPS   Return the number of responses for the given filter.
      
      switch lower(this.View)
        case 'complete'
          n = 1;
        case {'cumulative', 'individual'}
          n = nsections(Hd);
        case 'userdefined'
          % Call trim custom so we throw away any responses that have all of
          % their indexes greater than nsections of Hd.
          n = length(trimcustom(this, Hd));
      end
      
    end
    
    
    function [custom, trimmed, warnstr, warnid] = trimcustom(this, Hd)
      %TRIMCUSTOM   Trim the custom setting for a given filter.
      
      custom = get(this, 'UserDefinedSections');
      if ~iscell(custom)
        custom = {custom};
      end
      
      warnid  = '';
      warnstr = '';
      
      % Loop over the custom cell array.  Make sure none of the specified
      % indices exceeds NSECTIONS
      indx2rm = [];
      trimmed = false;
      for indx = 1:length(custom)
        exceed = custom{indx} > nsections(Hd);
        if any(exceed)
          warnstr = 'User Defined SOS View exceeds the number of sections.  Ignoring higher section numbers.';
          warnid  = 'exceedsnsecs';
          trimmed = true;
          custom{indx}(exceed) = [];
          if isempty(custom{indx})
            indx2rm = [indx2rm indx];
          end
        end
      end
      custom(indx2rm) = [];
            
    end
    
    function varargout = set(obj,varargin)      
     [varargout{1:nargout}] = signal.internal.signalset(obj,varargin{:});            
    end
    
    function values = getAllowedStringValues(~,prop)
      % This function gives the the valid string values for object properties.
      
      switch prop
        case 'View'
          values = {...
            'Complete'
            'Individual'
            'Cumulative'
            'UserDefined'};
          
        otherwise
          values = {};
      end
      
    end
    
  end  %% public methods
  
end  % classdef

function ss = set_secondaryscaling(this, ss)

if ~islogical(ss)
  error(message('signal:dspopts:sosview:schema:SignalErr'));
end

c = get(this, 'cachedFilters');
if ~isempty(c)
  c.cumulative = [];
  set(this, 'cachedFilters', c);
end
end  % set_secondaryscaling


% --------------------------------------------------
function ss = get_secondaryscaling(this, ss)

if ~strcmpi(this.View, 'cumulative')
  ss = 'Not used';
end
end  % get_secondaryscaling


% --------------------------------------------------
function sosview = get_soscustomview(this, sosview)

if ~strcmpi(this.View, 'userdefined')
  sosview = 'Not used';
end
end  % get_soscustomview


% --------------------------------------------------
function sosview = set_soscustomview(this, sosview)

if iscell(sosview)
  for indx = 1:length(sosview)
    
    % Make sure that each element in the cell array is a number
    if ~isnumeric(sosview{indx})
      error(message('signal:dspopts:sosview:schema:MustBeNumeric', 'UserDefinedSections'));
    end
  end
elseif ~isnumeric(sosview)
  error(message('signal:dspopts:sosview:schema:MustBeNumeric', 'UserDefinedSections'));
end

c = get(this, 'cachedFilters');
if ~isempty(c)
  c.userdefined = [];
  set(this, 'cachedFilters', c);
end
end  % set_soscustomview


% [EOF]
