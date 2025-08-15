function [str, prefix] = getconstructorfromstructure(struct, reffilt)
%GETCONSTRUCTORFROMSTRUCTURE

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if nargin < 2, reffilt = []; end


str = [];
prefix = [];
if isempty(struct), return; end

indx = findstr(lower(struct), ', sos');
if ~isempty(indx), struct(indx:end) = []; end

switch upper(struct)
    case {'DIRECT-FORM I','DIRECT FORM I'} 
        str = 'df1';prefix = 'dfilt.';
    case {'DIRECT-FORM II','DIRECT FORM II'}
        str = 'df2';prefix = 'dfilt.';
    case {'DIRECT-FORM I TRANSPOSED','DIRECT FORM I TRANSPOSED'}
        str = 'df1t';prefix = 'dfilt.';
    case {'DIRECT-FORM II TRANSPOSED','DIRECT FORM II TRANSPOSED'}
        str = 'df2t';prefix = 'dfilt.';
    case {'DIRECT-FORM I, SECOND-ORDER SECTIONS','DIRECT FORM I, SECOND-ORDER SECTIONS'}
        str = 'df1sos';prefix = 'dfilt.';
    case {'DIRECT-FORM II, SECOND-ORDER SECTIONS','DIRECT FORM II, SECOND-ORDER SECTIONS','DIRECT FORM II, SECOND-ORDER-SECTIONS'}
        str = 'df2sos';prefix = 'dfilt.';
    case {'DIRECT-FORM I TRANSPOSED, SECOND-ORDER SECTIONS','DIRECT FORM I TRANSPOSED, SECOND-ORDER SECTIONS'}
        str = 'df1tsos';prefix = 'dfilt.';
    case {'DIRECT-FORM II TRANSPOSED, SECOND-ORDER SECTIONS','DIRECT FORM II TRANSPOSED, SECOND-ORDER SECTIONS'}
        str = 'df2tsos';prefix = 'dfilt.';
        
    case {'DIRECT-FORM FIR','DIRECT FORM FIR'}
        str = 'dffir';prefix = 'dfilt.';
    case {'DIRECT-FORM FIR TRANSPOSED','DIRECT FORM FIR TRANSPOSED'}
        str = 'dffirt';prefix = 'dfilt.';
    case {'DIRECT-FORM SYMMETRIC FIR','DIRECT FORM SYMMETRIC FIR'}
        str = 'dfsymfir';prefix = 'dfilt.';
    case {'DIRECT-FORM ANTISYMMETRIC FIR','DIRECT FORM ANTISYMMETRIC FIR'}
        str = 'dfasymfir';prefix = 'dfilt.';
    case 'OVERLAP-ADD FIR',               str = 'fftfir';prefix = 'dfilt.';
        
    case 'LATTICE ALLPASS',               str = 'latticeallpass';prefix = 'dfilt.';
    case 'LATTICE MOVING-AVERAGE MINIMUM PHASE', str = 'latticemamin';prefix = 'dfilt.';
    case 'LATTICE MOVING-AVERAGE MAXIMUM PHASE', str = 'latticemamax';prefix = 'dfilt.';
    case 'LATTICE AUTOREGRESSIVE (AR)',   str = 'latticear';prefix = 'dfilt.';
    case 'LATTICE AUTOREGRESSIVE MOVING-AVERAGE (ARMA)', str = 'latticearma';prefix = 'dfilt.';
    case 'LATTICE MOVING-AVERAGE (MA) FOR MINIMUM PHASE', str = 'latticemamin';prefix = 'dfilt.';
    case 'LATTICE MOVING-AVERAGE (MA) FOR MAXIMUM PHASE', str = 'latticemamax';prefix = 'dfilt.';
        
    case 'STATE-SPACE',                   str = 'statespace';prefix = 'dfilt.';
    case 'SCALAR',                        str = 'scalar';prefix = 'dfilt.';
    case 'DELAY',                         str = 'delay';prefix = 'dfilt.';
    case 'CASCADE',                       str = 'cascade';prefix = 'dfilt.';
    case 'PARALLEL',                      str = 'parallel';prefix = 'dfilt.';
    case 'CASCADE MINIMUM-MULTIPLIER ALLPASS', str = 'cascadeallpass';prefix = 'dfilt.';
    case 'CASCADE WAVE DIGITAL FILTER ALLPASS', str = 'cascadewdfallpass';prefix = 'dfilt.';
        
    case 'COUPLED-ALLPASS (CA) LATTICE',  str = 'calattice';prefix = 'dfilt.';
    case 'COUPLED-ALLPASS (CA) LATTICE WITH POWER-COMPLEMENTARY (PC) OUTPUT', str = 'calatticepc';prefix = 'dfilt.';
    case 'COUPLED-ALLPASS LATTICE, POWER COMPLEMENTARY OUTPUT', str = 'calatticepc';prefix = 'dfilt.';
    case 'COUPLED-ALLPASS LATTICE',       str = 'calattice';prefix = 'dfilt.';
        
        
    case 'FARROW FRACTIONAL DELAY',       str = 'farrowfd';prefix = 'dfilt.';
    case 'FARROW LINEAR FRACTIONAL DELAY', str = 'farrowlinearfd';prefix = 'dfilt.';
        
    case 'MINIMUM-MULTIPLIER ALLPASS',    str = 'allpass';prefix = 'dfilt.';
    case 'WAVE DIGITAL FILTER ALLPASS',   str = 'wdfallpass';prefix = 'dfilt.';
    
    %MFILT CLASSES
    case 'CASCADED INTEGRATOR-COMB DECIMATOR', str = 'cicdecim';prefix = 'mfilt.';
    case 'CASCADED INTEGRATOR-COMB INTERPOLATOR', str = 'cicinterp';prefix = 'mfilt.';
    case 'FARROW SAMPLE-RATE CONVERTER', str = 'farrowsrc';prefix = 'mfilt.';
    case 'OVERLAP-ADD FIR POLYPHASE INTERPOLATOR', str = 'fftfirinterp';prefix = 'mfilt.';
    case 'DIRECT-FORM FIR POLYPHASE DECIMATOR', str = 'firdecim';prefix = 'mfilt.';
    case 'DIRECT-FORM FIR POLYPHASE INTERPOLATOR', str = 'firinterp';prefix = 'mfilt.';
    case 'DIRECT-FORM FIR POLYPHASE SAMPLE-RATE CONVERTER', str = 'firsrc';prefix = 'mfilt.';
    case 'DIRECT-FORM TRANSPOSED FIR POLYPHASE DECIMATOR', str = 'firtdecim';prefix = 'mfilt.';
    case 'FIR HOLD INTERPOLATOR', str = 'holdinterp';prefix = 'mfilt.';
    case 'IIR POLYPHASE DECIMATOR', str = 'iirdecim';prefix = 'mfilt.';
    case 'IIR POLYPHASE INTERPOLATOR'   , str = 'iirinterp';prefix = 'mfilt.';
    case 'DIRECT-FORM FIR POLYPHASE LINEAR INTERPOLATOR', str = 'linearinterp';prefix = 'mfilt.';
    case 'IIR WAVE DIGITAL FILTER POLYPHASE DECIMATOR', str = 'iirwdfdecim';prefix = 'mfilt.';
    case 'IIR WAVE DIGITAL FILTER POLYPHASE INTERPOLATOR' , str = 'iirwdfinterp';prefix = 'mfilt.';
    case 'DIRECT-FORM FIR POLYPHASE FRACTIONAL DECIMATOR', str = 'firfracdecim'; prefix = 'mfilt.';
    case 'DIRECT-FORM FIR POLYPHASE FRACTIONAL INTERPOLATOR', str = 'firfracinterp'; prefix = 'mfilt.';
    case 'FIR LINEAR INTERPOLATOR', str = 'linearinterp'; prefix = 'mfilt.';
end


% [EOF]
