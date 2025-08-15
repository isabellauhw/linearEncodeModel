classdef alpstop < fspecs.abstractspecwithord
%ALPSTOP   Construct an ALPSTOP object.

%   Copyright 1999-2017 The MathWorks, Inc.

%fspecs.alpstop class
%   fspecs.alpstop extends fspecs.abstractspecwithord.
%
%    fspecs.alpstop properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       FilterOrder - Property is of type 'posint user-defined'  
%       Wstop - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  


properties (AbortSet, SetObservable, GetObservable)
    %WSTOP Property is of type 'posdouble user-defined' 
    Wstop = 13;
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
end


    methods  % constructor block
        function h = alpstop(N,Ws,Astop)
        %ALPSTOP   Construct an ALPSTOP object.
        %   H = ALPSTOP(N,Ws,Astop) constructs an analog lowpass filter design
        %   specifications object H with stopband-edge specs.
        %
        %   N is the filter order, and must be a positive integer.
        %
        %   Ws is the stopband-edge frequency, in radians-per-second.
        %
        %   Astop is the minimum stopband attenuation, in dB.
        
        %   Author(s): R. Losada
        
        % h = fspecs.alpstop;
        
        h.ResponseType = 'Analog lowpass with stopband-edge specifications';
        if nargin > 0
            h.FilterOrder = N;
        end
        
        if nargin > 1
            h.Wstop = Ws;
        end
        
        if nargin > 2
            h.Astop = Astop;
        end
        
        
        end  % alpstop
        
    end  % constructor block

    methods 
        function set.Wstop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Wstop');
        value = double(value);
        obj.Wstop = value;
        end

        function set.Astop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Astop');
        value = double(value);
        obj.Astop = value;
        end

    end   % set and get functions 
end  % classdef

