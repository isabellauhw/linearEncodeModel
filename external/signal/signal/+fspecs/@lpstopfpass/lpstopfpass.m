classdef lpstopfpass < fspecs.abstractlpstopfpass
%LPSTOPFPASS   Construct an LPSTOPFPASS object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.lpstopfpass class
%   fspecs.lpstopfpass extends fspecs.abstractlpstopfpass.
%
%    fspecs.lpstopfpass properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       Fstop - Property is of type 'posdouble user-defined'  
%       Astop - Property is of type 'posdouble user-defined'  
%       Fpass - Property is of type 'double'  
%
%    fspecs.lpstopfpass methods:
%       getdesignobj -   Get the designobj.
%       getdesignpanelstate -   Get the designpanelstate.
%       measureinfo -   Return a structure of information for the measurements.
%       thisgetspecs -   Get the specs.



    methods  % constructor block
        function this = lpstopfpass(varargin)
        %LPSTOPFPASS   Construct a LPSTOPFPASS object.
        
        %   Author(s): J. Schickler
        
        % this = fspecs.lpstopfpass;
        
        respstr = 'Lowpass with passband frequency';
        fstart = 1;
        fstop = 2;
        nargsnoFs = 3;
        fsconstructor(this,respstr,fstart,fstop,nargsnoFs,varargin{:});
        
        
        end  % lpstopfpass
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(this,str)
    s = getdesignpanelstate(this)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef

