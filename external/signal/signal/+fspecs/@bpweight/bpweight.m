classdef bpweight < fspecs.abstractbpweight
%BPWEIGHT   Construct an BPWEIGHT object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bpweight class
%   fspecs.bpweight extends fspecs.abstractbpweight.
%
%    fspecs.bpweight properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fstop1 - Property is of type 'posdouble user-defined'  
%       Fpass1 - Property is of type 'posdouble user-defined'  
%       Fpass2 - Property is of type 'posdouble user-defined'  
%       Fstop2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.bpweight methods:
%       getdesignobj - Get the designobj.
%       measureinfo -   Return a structure of information for the measurements.



    methods  % constructor block
        function this = bpweight(varargin)
        %BPWEIGHT   Construct a BPWEIGHT object.
        
        %   Author(s): J. Schickler
        
        % this = fspecs.bpweight;
        
        respstr = 'Bandpass';
        fstart = 2;
        fstop = 5;
        nargsnoFs = 8;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % bpweight
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(~,str,sigonlyflag)
    minfo = measureinfo(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    specs = thisgetspecs(this)
end  % possibly private or hidden 

end  % classdef

