classdef alppassfstop < fspecs.alppass
%ALPPASSFSTOP   Construct an ALPPASSFSTOP object.

%   Copyright 1999-2017 The MathWorks, Inc.

%fspecs.alppassfstop class
%   fspecs.alppassfstop extends fspecs.alppass.
%
%    fspecs.alppassfstop properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       FilterOrder - Property is of type 'posint user-defined'  
%       Wpass - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Wstop - Property is of type 'posdouble user-defined'  


properties (AbortSet, SetObservable, GetObservable)
    %WSTOP Property is of type 'posdouble user-defined' 
    Wstop = 13;
end


    methods  % constructor block
        function h = alppassfstop(N,Wp,Ws,Apass)
        %ALPPASSFSTOP   Construct an ALPPASSFSTOP object.
        %   H = ALPPASSFSTOP(N,Wp,Ws,Apass) constructs an analog lowpass filter
        %   design specifications object H with passband-edge specs and
        %   stopband-edge frequency.
        %
        %   N is the filter order, and must be a positive integer.
        %
        %   Wp is the passband-edge frequency, in radians-per-second.
        %
        %   Ws is the stopband-edge frequency, in radians-per-second. It must be
        %   larger than Wp.
        %
        %   Apass is the maximum passband ripple, in dB.
        
        %   Author(s): R. Losada
        
        % h = fspecs.alppassfstop;
        
        h.ResponseType = 'Analog lowpass with passband-edge specifications and stopband frequency';
        if nargin > 0
            h.FilterOrder = N;
        end
        
        if nargin > 1
            h.Wpass = Wp;
        end
        
        if nargin > 2
            h.Wstop = Ws;
        end
        
        if nargin > 3
            h.Apass = Apass;
        end
        
        
        end  % alppassfstop
        
    end  % constructor block

    methods 
        function set.Wstop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Wstop');
        value = double(value);
        obj.Wstop = value;
        end

    end   % set and get functions 
    
    methods (Hidden) % possibly private or hidden
      p = propstoadd(this,varargin)
    end
end  % classdef

