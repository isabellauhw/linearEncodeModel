classdef alpcutoff < fspecs.abstractspecwithord
%ALPCUTOFF   Construct an ALPCUTOFF object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.alpcutoff class
%   fspecs.alpcutoff extends fspecs.abstractspecwithord.
%
%    fspecs.alpcutoff properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       FilterOrder - Property is of type 'posint user-defined'  
%       Wcutoff - Property is of type 'posdouble user-defined'  
%
%    fspecs.alpcutoff methods:


properties (AbortSet, SetObservable, GetObservable)
    %WCUTOFF Property is of type 'posdouble user-defined' 
    Wcutoff = 10;
end


    methods  % constructor block
        function h = alpcutoff(varargin)
        %ALPCUTOFF   Construct an ALPCUTOFF object.
        %   H = ALPCUTOFF(N,Wc) Constructs an analog lowpass filter design
        %   specifications object H.
        %
        %   N is the filter order, and must be a positive integer.
        %
        %   Wc is the cutoff frequency, in radians-per-second.
        
        %   Author(s): R. Losada
        
        narginchk(0,2);
        
        % h = fspecs.alpcutoff;
        
        constructor(h,varargin{:});
        
        h.ResponseType = 'Analog lowpass with cutoff';
        
        
        
        end  % alpcutoff
        
    end  % constructor block

    methods 
        function set.Wcutoff(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','Wcutoff');
        value = double(value);
        obj.Wcutoff = value;
        end

    end   % set and get functions 

    methods (Hidden) % possibly private or hidden
    constructor(h,N,Wc)
end  % possibly private or hidden 

end  % classdef

