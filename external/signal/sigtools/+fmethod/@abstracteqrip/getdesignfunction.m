function desfcn = getdesignfunction(this)
%GETDESIGNFUNCTION   Return the design function to be used in the
%coefficients design

%   Copyright 1999-2015 The MathWorks, Inc.


if this.MinPhase || (isprop(this,'MaxPhase') && this.MaxPhase) ||...
        (isprop(this,'MinOrder') && ~isequal(this.MinOrder,'any')) ||...
        (isprop(this,'StopbandShape') && ~isequal(this.StopbandShape,'flat')) ||...
        (isprop(this,'UniformGrid') && ~this.UniformGrid) || ...
        (~isprop(this,'UniformGrid') && isfdtbxinstalled)
        
   desfcn = @firgr;

else
    desfcn = @firpm;
end
           
% [EOF]
