classdef xp2coeffileMCOS < sigio.abstractxpdestinationMCOS & sigio.dyproputil & matlab.mixin.SetGet & matlab.mixin.Copyable
  %sigio.xp2coeffile class
  %   sigio.xp2coeffile extends sigio.abstractxpdestination.
  %
  %    sigio.xp2coeffile properties:
  %       Tag - Property is of type 'string'
  %       Version - Property is of type 'double' (read only)
  %       Data - Property is of type 'mxArray'
  %       Toolbox - Property is of type 'string'
  %       Format - Property is of type 'fcfFileFormat enumeration: {'Decimal','Hexadecimal','Binary'}'
  %
  %    sigio.xp2coeffile methods:
  %       action - Perform the action of exporting to a filter coefficient file.
  %       getfrheight -   Get the frheight.
  %       newdata - Update object based on new data to be exported.
  
  
  properties (AbortSet, SetObservable, GetObservable)
    %FORMAT Property is of type 'fcfFileFormat enumeration: {'Decimal','Hexadecimal','Binary'}'
    Format = 'Decimal';
  end
  
  
  methods  % constructor block
    function h = xp2coeffileMCOS(data)
      %XP2TXTFILE Constructor for the export to coefficient file class.
      
      %   Author(s): P. Costa
      
      narginchk(1,1);
      
      h.Version = 1.0;
      h.Data = data;
      
      settag(h);
      
      
    end  % xp2coeffile
    
    function set.Format(obj,value)
      % Enumerated DataType = 'fcfFileFormat enumeration: {'Decimal','Hexadecimal','Binary'}'
      value = validatestring(value,{'Decimal','Hexadecimal','Binary'},'','Format');
      obj.Format = value;
    end
    
    function success = action(hCD)
      %ACTION Perform the action of exporting to a filter coefficient file.
      
      %   Author(s): P. Costa
      %   Copyright 1988-2017 The MathWorks, Inc.
      
      fcfwrite(array(hCD.Data), [], hCD.Format(1:3));
      
      success = true;
      
    end
    
    function frheight = getfrheight(this)
      %GETFRHEIGHT   Get the frheight.
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      frheight = 40*sz.pixf;
      
    end
    
    function newdata(h)
      %NEWDATA Update object based on new data to be exported.
      
      % This should be a private method.
      
      %   Author(s): P. Costa
      %   Copyright 1988-2003 The MathWorks, Inc.
      
      % NO OP
      
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    
    function [w, h] = destinationSize(this)
      %DESTINATIONSIZE
      
      %   Author(s): J. Schickler
      %   Copyright 2007 The MathWorks, Inc.
      
      sz = gui_sizes(this);
      w = 160*sz.pixf;
      h = 40*sz.pixf;
      
      
    end
    
    function thisrender(this, varargin)
      %THISRENDER
      
      %   Author(s): J. Schickler
      %   Copyright 1988-2004 The MathWorks, Inc.
      
      pos = parserenderinputs(this, varargin{:});
      
      hFig = get(this, 'Parent');
      
      sz = gui_sizes(this);
      if isempty(pos)
        pos = [10 10 200 50]*sz.pixf;
      else
        pos(4) = pos(4)+8*sz.pixf;
      end
      
      hPanel = uipanel('Parent', hFig, ...
        'Title', getString(message('signal:sigtools:sigio:Options')), ...
        'Units', 'Pixels', ...
        'Visible', 'Off', ...
        'Position', pos);
      
      set(this, 'Container', hPanel);
      
      rendercontrols(this, hPanel, {'format'});
      
      setPopupStrings(this, 'format', {'Decimal', 'Hexadecimal', 'Binary'}, ...
        {fdatoolmessage('DecimalEntry'), fdatoolmessage('HexadecimalEntry'), fdatoolmessage('BinaryEntry')});
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

