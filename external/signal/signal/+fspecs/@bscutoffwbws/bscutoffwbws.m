classdef bscutoffwbws < fspecs.abstract3db2
%BSCUTOFFWBWS   Construct an BSCUTOFFWBWS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bscutoffwbws class
%   fspecs.bscutoffwbws extends fspecs.abstract3db2.
%
%    fspecs.bscutoffwbws properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB1 - Property is of type 'posdouble user-defined'  
%       F3dB2 - Property is of type 'posdouble user-defined'  
%       BWstop - Property is of type 'posdouble user-defined'  
%
%    fspecs.bscutoffwbws methods:
%       cheby2 - Chebyshev Type II digital filter design.
%       getdesignobj -   Get the design object.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       props2normalize -   Return the property name to normalize.
%       thisgetspecs -   Get the specs.


properties (AbortSet, SetObservable, GetObservable)
    %BWSTOP Property is of type 'posdouble user-defined' 
    BWstop = .15;
end


    methods  % constructor block
        function this = bscutoffwbws(varargin)
        %BSCUTOFFWBWS   Construct a BSCUTOFFWBWS object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.bscutoffwbws;
        
        respstr = 'Bandstop with cutoff and stopband width';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 3;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % bscutoffwbws
        
    end  % constructor block

    methods 
        function set.BWstop(obj,value)
        % User-defined DataType = 'posdouble user-defined'
        validateattributes(value,{'numeric'},...
          {'scalar','positive'},'','BWstop');
        value = double(value);
        obj.BWstop = value;
        end

    end   % set and get functions 

    methods  % public methods
    Hd = cheby2(this,varargin)
    designobj = getdesignobj(this,str)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    p = props2normalize(this)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef

