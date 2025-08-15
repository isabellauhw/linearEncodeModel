classdef (Abstract) abstractclassiciir < fmethod.abstractiirwsos
%ABSTRACTCLASSICIIR   Abstract constructor produces an error.

%   Copyright 1999-2015 The MathWorks, Inc.

%fmethod.abstractclassiciir class
%   fmethod.abstractclassiciir extends fmethod.abstractiirwsos.
%
%    fmethod.abstractclassiciir properties:
%       DesignAlgorithm - Property is of type 'ustring' (read only) 
%       FilterStructure - Property is of type 'ustring'  
%       SOSScaleNorm - Property is of type 'ustring'  
%       SOSScaleOpts - Property is of type 'fdopts.sosscaling'  
%
%    fmethod.abstractclassiciir methods:
%       actualdesign -   Design the filter and return the coefficients.
%       analogspecsword -   Compute an analog specifications object from a
%       bpbsmodifyord - LPHPMODIFYORD   
%       bpcreatecaobj - HPCREATECAOBJ   
%       costheta -  Compute cosine of angles of stable poles.
%       designflfhparameq - DESIGNBWPARAMEQ   
%       doubleord -   Return true if filter order must be doubled.
%       minanalogspecs -   Compute an analog specifications object from a



methods  % public methods
  coeffs = actualdesign(this,hs)
  has = analogspecsword(h,hs)
  N = bpbsmodifyord(this,N)
  Hd = bpcreatecaobj(this,struct,branch1,branch2)
  [cs,theta] = costheta(h,N)
  [s,g] = designflfhparameq(this,N,G0,G,GB,Gb,Flow,Fhigh,varargin)
  bl = doubleord(h)
  has = minanalogspecs(h,hs)
end  % public methods 


methods (Hidden) % possibly private or hidden
  h = allpasshalfband(this,alpha0,alpha1)
  Hd = coupledallpass(this,struct,s)
  Hd = createcaobj(this,struct,branch1,branch2)
  [s,g] = designbwparameq(this,N,G0,G,GB,Gb,w0,Dwb,varargin)
  [s,g] = designminordparameq(this,G0,G,GB,Gb,w0,Dw,Dwb,varargin)
  [s,g] = designparameq(this,N,G0,G,GB,w0,DW,varargin)
  Hd = hpcreatecaobj(this,struct,branch1,branch2)
  Hd = lpcreatecaobj(this,struct,branch1,branch2)
  N = lphpmodifyord(this,N)
  N = modifyord(this,N)
  validstructs = parameqvalidstructs(this)
end  % possibly private or hidden 

end  % classdef

