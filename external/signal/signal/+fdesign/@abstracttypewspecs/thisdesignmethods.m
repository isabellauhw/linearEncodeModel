function [d, isfull, type] = thisdesignmethods(this, varargin)
%THISDESIGNMETHODS   Return the valid design methods.

%   Copyright 1988-2005 The MathWorks, Inc.

spec = this.CurrentSpecs;  
if nargin > 1 
    if any(strcmpi(varargin{end}, this.SpecificationType)) 
        spec = feval(getconstructor(this, varargin{end})); 
        varargin(end) = []; 
    end 
end 

[d, isfull, type] = designmethods(spec, varargin{:});

% [EOF]
