function abstract_loadpublicinterface(this, s)
%ABSTRACT_LOADPUBLICINTERFACE   Load the public interface.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

base_loadpublicinterface(this, s);

% Make sure we force a copy of any FIs.

if isstruct(s)
    if isfield(s,'ncoeffs')
        if ~isequal(s.ncoeffs,this.ncoeffs)
            s.ncoeffs = this.ncoeffs;
        end
    end
end

if isobject(s)
    if isprop(s,'ncoeffs')
        if ~isequal(s.ncoeffs,this.ncoeffs)
            s.ncoeffs = this.ncoeffs;
        end
    end
end
    
if isstruct(s)
    if isfield(s,'States')
        this.States = forcecopy(this, s.States);
    end
end

if isobject(s)
    if isprop(s,'States')
        this.States = forcecopy(this, s.States);
    end
end

% Need to negate the numerator states due to a change in the R14 spec and
% list denominator first (as it was in R13post)
if strcmp(s.version.description,'R13Post') && isa(this,'dfilt.df1t')
    this.States = [this.States.Denominator; (-this.States.Numerator)];
end

% [EOF]
