classdef alpmin < fspecs.abstractspec
%ALPMIN   Construct an ALPMIN object.

%   Copyright 1999-2017 The MathWorks, Inc.

%fspecs.alpmin class
%   fspecs.alpmin extends fspecs.abstractspec.
%
%    fspecs.alpmin properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       Wpass - Property is of type 'posdouble user-defined'  
%       Wstop - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  


properties (AbortSet, SetObservable, GetObservable)
    %WPASS Property is of type 'posdouble user-defined' 
    Wpass = 7;
    %WSTOP Property is of type 'posdouble user-defined' 
    Wstop = 13;
    %APASS Property is of type 'posdouble user-defined' 
    Apass = 1;
    %ASTOP Property is of type 'posdouble user-defined' 
    Astop = 60;
end


    methods  % constructor block
        function h = alpmin(wp,ws,rp,rs)
        %ALPMIN   Construct an ALPMIN object.
        %   H = ALPMIN(Wpass,Wstop,Apass,Astop) constructs an analog minimum-order
        %   lowpass filter specifications object.
        %
        %   Wpass is the passband-edge frequency in radians-per-second and must be
        %   a positive scalar.
        %
        %   Wstop is the stopband-edge frequency in radians-per-second and must be
        %   a positive scalar.
        %
        %   Apass is the maximum passband deviation in dB. It must be a positive
        %   scalar.
        %
        %   Astop is the minimum stopband attenuation in dB. It must be a positive
        %   scalar.
        
        %   Author(s): R. Losada
        
        % h = fspecs.alpmin;
        
        h.ResponseType = 'Analog minimum-order lowpass';
        if nargin > 0
            h.Wpass = wp;
        end
        
        if nargin > 1
            h.Wstop = ws;
        end
        
        if nargin > 2
            h.Apass = rp;
        end
        
        if nargin > 3
            h.Astop = rs;
        end
        
        
        
        end  % alpmin
        
    end  % constructor block

    methods 
        function set.Wpass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Wpass');
        value = double(value);
        obj.Wpass = value;
        end

        function set.Wstop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Wstop');
        value = double(value);
        obj.Wstop = value;
        end

        function set.Apass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Apass');
        value = double(value);
        obj.Apass = value;
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

