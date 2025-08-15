classdef stepz < filtresp.timeresp
  %filtresp.stepz class
  %   filtresp.stepz extends filtresp.timeresp.
  %
  %    filtresp.stepz properties:
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
  %    filtresp.stepz methods:
  %       getplotdata - Returns the data to plot

%   Copyright 2015-2017 The MathWorks, Inc.
  
  
  
  methods  % constructor block
    function h = stepz(varargin)
      %STEPZ Construct an stepz object
      
      %   Author(s): J. Schickler
      
      % h = filtresp.stepz;
      
      h.Name = getString(message('signal:sigtools:filtresp:StepResponse'));
      
      h.timeresp_construct(varargin{:});
      
      
    end  % stepz
    
  end  % constructor block
  
  methods  %% public methods
    function [Yall, t] = getplotdata(this)
      %GETPLOTDATA Returns the data to plot
      
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
        
        [Yall, t] = stepz(this.Filters, opts{:}, optsstruct);
      end
    end
    
  end  %% public methods
  
  
  methods (Hidden) %% possibly private or hidden
    function s = legendstring(hObj)
      %LEGENDSTRING
      
      s = 'Step Response';
    end
    
  end  %% possibly private or hidden
  
end  % classdef

