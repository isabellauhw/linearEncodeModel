classdef alppassastop < fspecs.alppass
%ALPPASSASTOP   Construct an ALPPASSASTOP object.

%   Copyright 1999-2017 The MathWorks, Inc.

%fspecs.alppassastop class
%   fspecs.alppassastop extends fspecs.alppass.
%
%    fspecs.alppassastop properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       FilterOrder - Property is of type 'posint user-defined'  
%       Wpass - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  


properties (AbortSet, SetObservable, GetObservable)
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
end


    methods  % constructor block
        function h = alppassastop(N,Wp,Apass,Astop)
        %ALPPASSASTOP   Construct an ALPPASSASTOP object.
        %   H = ALPPASSASTOP(N,Wp,Apass,Astop) constructs an analog lowpass filter
        %   design specifications object H with passband-edge specs and stopband-edge
        %   frequency.
        %
        %   N is the filter order, and must be a positive integer.
        %
        %   Wp is the passband-edge frequency, in radians-per-second.
        %
        %   Apass is the maximum passband ripple, in dB.
        %
        %   Astop is the minimum stopband attenuation, in dB.
        
        
        %   Author(s): R. Losada
        
        % h = fspecs.alppassastop;
        
        h.ResponseType = 'Analog lowpass with passband-edge specifications and stopband attenuation';
        if nargin > 0
            h.FilterOrder = N;
        end
        
        if nargin > 1
            h.Wpass = Wp;
        end
        
        if nargin > 2
            h.Apass = Apass;
        end
        
        if nargin > 3
            h.Astop = Astop;
        end
        
        
        end  % alppassastop
        
    end  % constructor block

    methods 
        function set.Astop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Astop');
        value = double(value);
        obj.Astop = value;
        end

    end   % set and get functions 
end  % classdef

