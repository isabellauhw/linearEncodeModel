classdef lpweight < fspecs.abstractlp
%LPWEIGHT   Construct an LPWEIGHT object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.lpweight class
%   fspecs.lpweight extends fspecs.abstractlp.
%
%    fspecs.lpweight properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass - Property is of type 'posdouble user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%
%    fspecs.lpweight methods:
%       getdesignobj -   Get the designobj.
%       measureinfo -   Return a structure of information for the measurements.



    methods  % constructor block
        function this = lpweight(varargin)
        %LPWEIGHT   Construct a LPWEIGHT object.
        
        %   Author(s): J. Schickler
        
        % this = fspecs.lpweight;
        
        respstr = 'Lowpass';
        fstart = 2;
        fstop = 3;
        nargsnoFs = 5;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % lpweight
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(~,str,sigonlyflag)
    minfo = measureinfo(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

