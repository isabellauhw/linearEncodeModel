classdef lpiir3db < fspecs.abstractiir3db
%LPIIR3DB   Construct an LPIIR3DB object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.lpiir3db class
%   fspecs.lpiir3db extends fspecs.abstractiir3db.
%
%    fspecs.lpiir3db properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       NormalizedFrequency - Property is of type 'bool'  
%       Fs - Property is of type 'mxArray'  
%       NumOrder - Property is of type 'posint user-defined'  
%       DenOrder - Property is of type 'posint user-defined'  
%       F3dB - Property is of type 'posdouble user-defined'  
%
%    fspecs.lpiir3db methods:
%       getdesignobj - Get the design object.



    methods  % constructor block
        function this = lpiir3db(varargin)
        %LP3DB   Construct a LPIIR3DB object.
        
        
        % this = fspecs.lpiir3db;
        
        constructor(this,varargin{:});
        
        this.ResponseType = 'Lowpass with 3-dB Frequency Point';
        
        end  % lpiir3db
        
    end  % constructor block

    methods  % public methods
    designobj = getdesignobj(~,str,sigonlyflag)
end  % public methods 

end  % classdef

