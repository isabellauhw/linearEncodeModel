classdef bpcutoffwbws < fspecs.abstract3db2
%BPCUTOFFWBWS   Construct an BPCUTOFFWBWS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bpcutoffwbws class
%   fspecs.bpcutoffwbws extends fspecs.abstract3db2.
%
%    fspecs.bpcutoffwbws properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB1 - Property is of type 'posdouble user-defined'  
%       F3dB2 - Property is of type 'posdouble user-defined'  
%       BWstop - Property is of type 'posdouble user-defined'  
%
%    fspecs.bpcutoffwbws methods:
%       cheby2 - Chebyshev Type II digital filter design.
%       getdesignobj -   Get the design object.
%       getdesignpanelstate -   Get the designpanelstate.
%       props2normalize -   Return the property name to normalize.


properties (AbortSet, SetObservable, GetObservable)
    %BWSTOP Property is of type 'posdouble user-defined' 
    BWstop = .25;
end


    methods  % constructor block
        function this = bpcutoffwbws(varargin)
        %BPCUTOFFWBWS   Construct a BPCUTOFFWBWS object.
        
        %   Author(s): V. Pellissier
        
        % this = fspecs.bpcutoffwbws;
        
        respstr = 'Bandpass with cutoff and stopband width';
        fstart = 1;
        fstop = 1;
        nargsnoFs = 3;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % bpcutoffwbws
        
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
    p = props2normalize(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

