classdef bs3db < fspecs.abstract3db2
%BS3DB   Construct an BS3DB object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bs3db class
%   fspecs.bs3db extends fspecs.abstract3db2.
%
%    fspecs.bs3db properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB1 - Property is of type 'posdouble user-defined'  
%       F3dB2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.bs3db methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the design object.
%       measureinfo -   Return a structure of information for the measurements.
%       thisgetspecs -   Get the specs.



    methods  % constructor block
        function this = bs3db(varargin)
        %BS3DB   Construct a BS3DB object.
        
        %   Author(s): J. Schickler
        
        % this = fspecs.bs3db;
        
        this.ResponseType = 'Bandstop with 3-dB Frequency Point';
        
        this.setspecs(varargin{:});
        
        
        end  % bs3db
        
    end  % constructor block

    methods  % public methods
    ha = analogresp(h)
    designobj = getdesignobj(~,str,sigonlyflag)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef

