classdef alppass < fspecs.abstractspecwithord
%ALPPASS   Construct an ALPPASS object.

%   Copyright 1999-2017 The MathWorks, Inc.

%fspecs.alppass class
%   fspecs.alppass extends fspecs.abstractspecwithord.
%
%    fspecs.alppass properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       FilterOrder - Property is of type 'posint user-defined'  
%       Wpass - Property is of type 'posdouble user-defined'  
%       Apass - Property is of type 'posdouble user-defined'  


properties (AbortSet, SetObservable, GetObservable)
    %WPASS Property is of type 'posdouble user-defined' 
    Wpass = 7;
    %APASS Property is of type 'posdouble user-defined' 
    Apass = 1;
end


    methods  % constructor block
        function h = alppass(N,Wp,Apass)
        %ALPPASS   Construct an ALPPASS object.
        %   H = ALPPASS(N,Wp,Apass) constructs an analog lowpass filter design
        %   specifications object H with passband-edge specs.
        %
        %   N is the filter order, and must be a positive integer.
        %
        %   Wp is the passband-edge frequency, in radians-per-second.
        %
        %   Apass is the maximum passband ripple, in dB.
        
        %   Author(s): R. Losada
        
        % h = fspecs.alppass;
        
        h.ResponseType = 'Analog lowpass with passband-edge specifications';
        if nargin > 0
            h.FilterOrder = N;
        end
        
        if nargin > 1
            h.Wpass = Wp;
        end
        
        if nargin > 2
            h.Apass = Apass;
        end
        
        
        end  % alppass
        
    end  % constructor block

    methods 
        function set.Wpass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Wpass');
        value = double(value);
        obj.Wpass = value;
        end

        function set.Apass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Apass');
        value = double(value);
        obj.Apass = value;
        end

    end   % set and get functions 
end  % classdef

