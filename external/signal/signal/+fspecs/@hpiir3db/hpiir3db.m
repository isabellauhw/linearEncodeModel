classdef hpiir3db < fspecs.abstractiir3db
%HPIIR3DB   Construct an HPIIRD3DB object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.hpiir3db class
%   fspecs.hpiir3db extends fspecs.abstractiir3db.
%
%    fspecs.hpiir3db properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       NumOrder - Property is of type 'posint user-defined'  
%       DenOrder - Property is of type 'posint user-defined'  
%       F3dB - Property is of type 'posdouble user-defined'  
%
%    fspecs.hpiir3db methods:
%       getdesignobj - Get the design object.



    methods  % constructor block
        function this = hpiir3db(varargin)
        %LP3DB Construct a HPIIR3DB object.
        
        
        % this = fspecs.hpiir3db;
        
        constructor(this,varargin{:});
        
        this.ResponseType = 'Highpass with 3-dB Frequency Point';
        
        end  % hpiir3db
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(~,str,sigonlyflag)
end  % public methods 

end  % classdef

