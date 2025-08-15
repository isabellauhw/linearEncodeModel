classdef bscutoffwbwp < fspecs.abstract3db2
%BSCUTOFFWBWP   Construct an BSCUTOFFWBWP object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bscutoffwbwp class
%   fspecs.bscutoffwbwp extends fspecs.abstract3db2.
%
%    fspecs.bscutoffwbwp properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB1 - Property is of type 'posdouble user-defined'  
%       F3dB2 - Property is of type 'posdouble user-defined'  
%       BWpass - Property is of type 'posdouble user-defined'  
%
%    fspecs.bscutoffwbwp methods:
%       cheby1 - Chebyshev Type I digital filter design.
%       getdesignobj -   Get the design object.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Return the property name to normalize.


properties (AbortSet, SetObservable, GetObservable)
    %BWPASS Property is of type 'posdouble user-defined' 
    BWpass = .25;
end


    methods  % constructor block
        function this = bscutoffwbwp(varargin)
        %BSCUTOFFWBWP   Construct a BSCUTOFFWBWP object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.bscutoffwbwp;
        
        respstr = 'Bandstop with cutoff and passband width';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 3;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % bscutoffwbwp
        
    end  % constructor block

    methods 
        function set.BWpass(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','BWpass');
        value = double(value);
        obj.BWpass = value;
        end

    end   % set and get functions 

    methods  % public methods
    Hd = cheby1(this,varargin)
    designobj = getdesignobj(this,str)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    p = props2normalize(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

