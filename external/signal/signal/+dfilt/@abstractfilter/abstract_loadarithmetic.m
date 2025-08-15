function abstract_loadarithmetic(this, s)
%ABSTRACT_LOADARITHMETIC   Load the arithmetic information.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

% If s is not a structure we need to copy the privfq.
if ~isstruct(s)
    if isprop(s,'privfq') && ~isempty(s.privfq)
        for indx = 1:length(s.privfq)
            privfq(indx) = copy(s.privfq(indx));
        end
    else
        privfq = [];
    end
    
    arith = s.privArithmetic;
else
    
    if isfield(s, 'privArithmetic')
        arith = s.privArithmetic;
    elseif isfield(s,'Arithmetic')
        arith = s.Arithmetic;
    else
        arith = [];
    end
    
    if isfield(s,'privfq')
        privfq = s.privfq;
    else
        privfq = [];
    end
end

if ~isempty(privfq)
    this.privfq = privfq; 
end

if ~isempty(arith)
    this.privArithmetic = arith;
end

% [EOF]
