function s = getsysobjsupportedstructs(varargin)
%GETSYSOBJSUPPORTEDSTRUCTS  Get structures supported by filter System objects

%   Copyright 2011-2016 The MathWorks, Inc.

% This is a static method

if nargin && strcmp(varargin{1}, 'multirate')
    s = {...
        'firdecim','firtdecim','cicdecim',...
        'firinterp','linearinterp','cicinterp',...
        'firsrc','iirdecim','iirwdfdecim','iirinterp', 'iirwdfinterp'};
elseif nargin && strcmp(varargin{1}, 'ModelGenerationWithFixedPoint')
    % These structures support Simulink Model Generation with fixed point
    % settings
    s = {... 
        'dffir','dffirt','dfsymfir','dfasymfir','latticemamin', ... dsp.FIRFilter
        'df1sos','df1tsos','df2sos','df2tsos', ... dsp.BiquadFilter
        'firdecim','firtdecim', ... dsp.FIRDecimator
        'firinterp','linearinterp', ... dsp.FIRInterpolator
        'cicdecim', ... dsp.CICDecimator
        'cicinterp', ... dsp.CICInterpolator
        'firsrc', ... dsp.FIRRateConverter
        };
else
    s = {... 
        'dffir','dffirt','dfsymfir','dfasymfir','latticemamin', ... dsp.FIRFilter
        'df1sos','df1tsos','df2sos','df2tsos', ... dsp.BiquadFilter
        'df1','df1t','df2','df2t', ... dsp.IIRFilter
        'firdecim','firtdecim', ... dsp.FIRDecimator
        'firinterp','linearinterp', ... dsp.FIRInterpolator
        'cicdecim', ... dsp.CICDecimator
        'cicinterp', ... dsp.CICInterpolator
        'firsrc', ... dsp.FIRRateConverter
        'iirdecim', 'iirwdfdecim', ... dsp.IIRHalfbandDecimator
        'iirinterp', 'iirwdfinterp', ... dsp.IIRHalfbandInterpolator
        'calattice','calatticepc', ... dsp.CoupledAllpassFilter('Lattice')
        'cascadeallpass', ... dsp.CoupledAllpassFilter('Minimum multiplier')
        'cascadewdfallpass',... dsp.CoupledAllpassFilter('Wave Digital Filter')
        };
end
