function [s,g] = designflfhparameq(this,N,G0,G,GB,Gb,Flow,Fhigh,varargin)
%DESIGNBWPARAMEQ   

%   Copyright 1999-2015 The MathWorks, Inc.

[w0,Dwb] = parameqbandedge(Flow*pi,Fhigh*pi,1);
if Fhigh ==1, w0=pi; end

[s,g] = designbwparameq(this,N,G0,G,GB,Gb,w0,Dwb,varargin{:});

% [EOF]
