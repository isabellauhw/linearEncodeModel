function s = blockparams(Hd, mapstates, varargin)
%BLOCKPARAMS Returns the parameters for BLOCK

% Copyright 1988-2017 The MathWorks, Inc.

s = super_blockparams(Hd);
s.IIRFiltStruct = 'Direct form II transposed';

% IC
if strcmpi(mapstates, 'on')
    ic    = getinitialconditions(Hd);
    s.IC  = mat2str(ic);
end
