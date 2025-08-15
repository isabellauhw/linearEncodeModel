classdef bsweight < fspecs.abstractbsweight
%BSWEIGHT   Construct an BSWEIGHT object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bsweight class
%   fspecs.bsweight extends fspecs.abstractbsweight.
%
%    fspecs.bsweight properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fpass1 - Property is of type 'posdouble user-defined'  
%       Fstop1 - Property is of type 'posdouble user-defined'  
%       Fstop2 - Property is of type 'posdouble user-defined'  
%       Fpass2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.bsweight methods:
%       getdesignobj -   Get the designobj.
%       measureinfo -   Return a structure of information for the measurements.



    methods  % constructor block
        function this = bsweight(varargin)
        %BSWEIGHT   Construct a BSWEIGHT object.
        
        %   Author(s): J. Schickler
        
        % this = fspecs.bsweight;
        
        respstr = 'Bandstop';
        fstart = 2;
        fstop = 5;
        nargsnoFs = 8;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % bsweight
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(~,str,sigonlyflag)
    minfo = measureinfo(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    p = propstoadd(this,varargin)
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

