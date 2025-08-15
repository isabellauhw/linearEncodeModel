classdef bp3db < fspecs.abstract3db2
%BP3DB   Construct an BP3DB object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.bp3db class
%   fspecs.bp3db extends fspecs.abstract3db2.
%
%    fspecs.bp3db properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       FilterOrder - Property is of type 'posint user-defined'  
%       F3dB1 - Property is of type 'posdouble user-defined'  
%       F3dB2 - Property is of type 'posdouble user-defined'  
%
%    fspecs.bp3db methods:
%       analogresp -   Compute analog response object.
%       getdesignobj -   Get the design object.
%       thisgetspecs -   Get the specs.



    methods  % constructor block
        function this = bp3db(varargin)
        %BP3DB   Construct a BP3DB object.
        
        %   Author(s): J. Schickler
        
        % this = fspecs.bp3db;
        
        this.ResponseType = 'Bandpass with 3-dB Frequency Point';
        
        this.setspecs(varargin{:});
        
        
        end  % bp3db
        
    end  % constructor block

    methods  % public methods
    ha = analogresp(h)
    designobj = getdesignobj(~,str,sigonlyflag)
    specs = thisgetspecs(this)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    minfo = measureinfo(this)
end  % possibly private or hidden 

end  % classdef

