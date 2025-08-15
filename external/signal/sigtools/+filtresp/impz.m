classdef impz < filtresp.timeresp & hgsetget
  %filtresp.impz class
  %   filtresp.impz extends filtresp.timeresp.
  %
  %    filtresp.impz properties:
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
  %    filtresp.impz methods:
  %       getplotdata - GENPLOTDATA Get the data to plot

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  
  methods  % constructor block
    function h = impz(varargin)
      %IMPZ Construct an impresp object

      h.Name = getString(message('signal:sigtools:filtresp:ImpulseResponse'));
      
      h.timeresp_construct(varargin{:});
      
      
    end  % impz
    
  end  % constructor block
  
  methods  %% public methods
    function [Yall, t] = getplotdata(this)
      %GENPLOTDATA Get the data to plot

      if isempty(this.Filters)
        Yall = {};
        t    = {};
      else
        
        if strcmpi(this.SpecifyLength, 'off')
          opts = {};
        else
          opts = {this.Length};
        end
        
        optsstruct.showref  = showref(this.FilterUtils);
        optsstruct.showpoly = showpoly(this.FilterUtils);
        optsstruct.sosview  = this.SOSViewOpts;
        
        [Yall, t] = impz(this.Filters, opts{:}, optsstruct);
      end
      
    end    
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function s = legendstring(hObj)
      %LEGENDSTRING

      s = getString(message('signal:sigtools:filtresp:ImpulseResponse'));
      
    end
    
  end  %% possibly private or hidden
  
end  % classdef

