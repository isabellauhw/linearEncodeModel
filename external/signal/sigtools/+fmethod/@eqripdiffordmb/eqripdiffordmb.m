classdef eqripdiffordmb < fmethod.abstracteqripdiffordmbw
%EQRIPDIFFORDMB   Construct an EQRIPDIFFORDMB object.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.eqripdiffordmb class
%   fmethod.eqripdiffordmb extends fmethod.abstracteqripdiffordmbw.
%
%    fmethod.eqripdiffordmb properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       DensityFactor - Property is of type 'double'  
%       MinPhase - Property is of type 'bool'  
%       Wpass - Property is of type 'posdouble user-defined'  
%       Wstop - Property is of type 'posdouble user-defined'  



methods  % constructor block
  function this = eqripdiffordmb(varargin)

  % this = fmethod.eqripdiffordmb;

  this.DesignAlgorithm = 'Equiripple';


  end  % eqripdiffordmb

end  % constructor block
end  % classdef

