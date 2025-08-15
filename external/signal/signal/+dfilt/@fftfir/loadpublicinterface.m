function loadpublicinterface(this, s)
%LOADPUBLICINTERFACE   Load the public interface.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

abstract_loadpublicinterface(this, s);

if isfield(s,'BlockLength') || isprop(s,'BlockLength')
    this.BlockLength = s.BlockLength;
end

if isfield(s,'NonProcessedSamples') || isprop(s,'NonProcessedSamples')
    this.NonProcessedSamples = s.NonProcessedSamples;
end

% [EOF]
