classdef (Abstract) abstractxpdestinationMCOS < siggui.sigcontainerMCOS & matlab.mixin.SetGet & matlab.mixin.Copyable
  %sigio.abstractxpdestination class
  %   sigio.abstractxpdestination extends siggui.sigcontainer.
  %
  %    sigio.abstractxpdestination properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Data - Property is of type 'mxArray'
  %       Toolbox - Property is of type 'string'
  %
  %    sigio.abstractxpdestination methods:
  %       abstract_thisrender - Render the default options frame.
  %       callbacks - Callbacks for the Export Dialog
  %       getfrheight - Get frame height.
  %       newdata - Update object based on new data to be exported.
  %       thisrender - RENDER Render the default options frame.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %DATA Property is of type 'mxArray'
    Data = [];
    %TOOLBOX Property is of type 'string'
    Toolbox = '';
  end
  
  properties (Access=protected, AbortSet, SetObservable, GetObservable)
    %VARIABLECOUNT Property is of type 'int32'
    VariableCount
    %VECTORCHANGEDLISTENER Property is of type 'handle.listener'
    VectorChangedListener = [];
    %PRIVDATA Property is of type 'sigutils.vector'
    privData = [];
  end
  
  
  events
    NewFrameHeight
  end  % events
  
  methods
    function value = get.Data(obj)
      value = getdata(obj,obj.Data);
    end
    function set.Data(obj,value)
      obj.Data = setdata(obj,value);
    end
    
    function set.VariableCount(obj,value)
      % DataType = 'int32'
      validateattributes(value,{'numeric'}, {'scalar'},'','VariableCount')
      obj.VariableCount = value;
    end
    
    function set.VectorChangedListener(obj,value)
      % DataType = 'handle.listener'
      validateattributes(value,{'event.listener'}, {'scalar'},'','VectorChangedListener')
      obj.VectorChangedListener = value;
    end
    
    function set.privData(obj,value)
      % DataType = 'sigutils.vector'
      validateattributes(value,{'sigutils.vectorMCOS'}, {'scalar'},'','privData')
      obj.privData = setprivdata(obj,value);
    end
    
    function set.Toolbox(obj,value)
      % DataType = 'string'
      validateattributes(value,{'char'}, {'row'},'','Toolbox')
      obj.Toolbox = value;
    end

    function abstract_thisrender(this, varargin)
      %ABSTRACT_THISRENDER Render the default options frame.
      
      %   Author(s): P. Costa
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      pos = parserenderinputs(this, varargin{:});
      
      hFig = get(this, 'FigureHandle');
      
      % Determine positions for the frame
      if isempty(pos)
        pos = getDefaultPosition(this);
      end
      
      hTxtOpts = getcomponent(this, '-class', 'siggui.textOptionsFrameMCOS');
      if isempty(hTxtOpts)
        hTxtOpts = siggui.textOptionsFrameMCOS({'', getString(message('signal:sigtools:sigio:NoOptionalParametersForThisDestination'))});
        addcomponent(this, hTxtOpts);
      end
      
      % Render a default frame
      render(hTxtOpts, hFig, pos);
      
      % % Add contextsensitive help
      % cshelpcontextmenu(this, 'fdatool_ExportWDefaultOpts');
      
    end
    
    
    function cbs = callbacks(h)  %#ok<*MANU>
      %CALLBACKS Callbacks for the Export Dialog
      
      cbs.exportas = @exportas_cb;
      cbs.checkbox = @checkbox_cb;
      
    end
    
    
    function fh = getfrheight(h)
      %GETFRHEIGHT Get frame height.
            
      sz = gui_sizes(h);
      fh = 100*sz.pixf;
      
    end
    
    function newdata(h)
      %NEWDATA Update object based on new data to be exported.
            
      % NO OP
      
    end
    
    
    function thisrender(h, hFig, pos)
      %RENDER Render the default options frame.
      
      if nargin < 3 , pos =[]; end
      if nargin < 2 , hFig = gcf; end
      
      abstract_thisrender(h,hFig,pos);
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    
    function [width, height] = destinationSize(this)
      %DESTINATIONSIZE
      
      sz = gui_sizes(this);
      
      % Default frame height.
      height = 100*sz.pixf;
      width  = 160*sz.pixf;
      
      
    end
    
    function data = getdata(this, data) %#ok<*INUSD>
      %GETDATA
      
      data = this.privData;
      
    end
    
    function data = setdata(this,data)
      %SETDATA
      
      if isa(data, 'sigutils.vectorMCOS') && ~strcmpi(class(elementat(data, 1)),'double')
        this.privData = data;
      else
        datamodel = this.privData;
        if isempty(datamodel)
          datamodel = sigutils.vectorMCOS;
          this.privData = datamodel;
        else
          datamodel.clear;
        end
        if ~iscell(data), data = {data}; end
        for indx = 1:length(data)
          if strcmpi(class(data{indx}),'double')
            data{indx} = sigutils.vectorMCOS(50, data{indx});
          end
          
          datamodel.addelement(data{indx});
        end
      end
      
      this.VariableCount = length(data);
      
    end
    
    function datamodel = setprivdata(this, datamodel)
      %SETPRIVDATA
      
      % Create a listener to the Data property
      l = event.listener(datamodel, 'VectorChanged', @(s,e)prop_listener(this));      
      this.VectorChangedListener = l;
      
      prop_listener(this);
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef


%---------------------------------------------------------------------
function pos = getDefaultPosition(this)

sz = gui_sizes(this);

% Default frame width and height
sz.fw = 150*sz.pixf;
sz.fh = 100*sz.pixf;

pos = [sz.ffs sz.ffs sz.fw sz.fh];

end

% --------------------------------------------------------------------
function exportas_cb(hcbo, eventStruct, h) %#ok<*INUSL>

strs = getappdata(hcbo,'PopupStrings'); % get untranslated strings
idx = get(hcbo,'Value'); % get popup index
h.ExportAs = strs{idx};

end

% --------------------------------------------------------------------
function checkbox_cb(hcbo, eventStruct, h)

set(h, 'Overwrite', get(hcbo, 'Value'));

end

% -------------------------------------------------------
function prop_listener(this, eventData) 

if ~isempty(this.Data)
  % Call an API method to update the concrete classes based on new data.
  newdata(this);
end

end
