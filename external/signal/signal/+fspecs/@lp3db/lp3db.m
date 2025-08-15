classdef lp3db < fspecs.abstract3db
%LP3DB   Construct an LP3DB object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.lp3db class
%   fspecs.lp3db extends fspecs.abstract3db.
%
%    fspecs.lp3db properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB - Property is of type 'posdouble user-defined'  
%
%    fspecs.lp3db methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the design object.
%       measureinfo -   Return a structure of information for the measurements.
%       thisgetspecs -   Get the specs.



    methods  % constructor block
        function this = lp3db(varargin)
        %LP3DB   Construct a LP3DB object.
        
        %   Author(s): J. Schickler
        
        % this = fspecs.lp3db;
        
        this.ResponseType = 'Lowpass with 3-dB Frequency Point';
        
        this.setspecs(varargin{:});
        
        
        end  % lp3db
        
    end  % constructor block

    methods  % public methods
    ha = analogresp(h)
    designobj = getdesignobj(~,str,sigonlyflag)
    minfo = measureinfo(this)
    specs = thisgetspecs(this)
end  % public methods 

end  % classdef

