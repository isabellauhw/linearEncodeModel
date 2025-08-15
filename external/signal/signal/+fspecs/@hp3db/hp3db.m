classdef hp3db < fspecs.abstract3db
%HP3DB   Construct an HP3DB object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.hp3db class
%   fspecs.hp3db extends fspecs.abstract3db.
%
%    fspecs.hp3db properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB - Property is of type 'posdouble user-defined'  
%
%    fspecs.hp3db methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the design object.
%       measureinfo -   Return a structure of information for the measurements.
%       thisgetspecs -   Get the specs.



    methods  % constructor block
        function this = hp3db(varargin)
        %HP3DB   Construct a HP3DB object.
        
        %   Author(s): J. Schickler
        
        % this = fspecs.hp3db;
        
        this.ResponseType = 'Highpass with 3-dB Frequency Point';
        
        this.setspecs(varargin{:});
        
        
        end  % hp3db
        
    end  % constructor block

    methods  % public methods
    ha = analogresp(h)
    designobj = getdesignobj(~,str,sigonlyflag)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef

