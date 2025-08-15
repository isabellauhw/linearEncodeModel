classdef ahpcutoff < fspecs.alpcutoff
%AHPCUTOFF   Construct an AHPCUTOFF object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fspecs.ahpcutoff class
%   fspecs.ahpcutoff extends fspecs.alpcutoff.
%
%    fspecs.ahpcutoff properties:
%       ResponseType - Property is of type 'ustring' (read only) 
%       FilterOrder - Property is of type 'posint user-defined'  
%       Wcutoff - Property is of type 'posdouble user-defined'  



    methods  % constructor block
        function h = ahpcutoff(varargin)
        %AHPCUTOFF   Construct an AHPCUTOFF object.
        %   H = AHPCUTOFF(N,Wc) Constructs an analog highpass filter design
        %   specifications object H.
        %
        %   N is the filter order, and must be a positive integer.
        %
        %   Wc is the cutoff frequency, in radians-per-second.
        
        
        %   Author(s): R. Losada
        
        narginchk(0,2);
        
        % h = fspecs.ahpcutoff;
        
        constructor(h,varargin{:});
        
        h.ResponseType = 'Analog highpass with cutoff';
        
        
        end  % ahpcutoff
        
    end  % constructor block
end  % classdef

