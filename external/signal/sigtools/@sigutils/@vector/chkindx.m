function msg = chkindx(this, indx, nolength)
%CHKINDX Check the index to make sure it is valid.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

% This should be private

narginchk(2,3);

msg = '';

% Make sure that the index is real and positive.
if ~isnumeric(indx) || indx < 1 || ~isreal(indx)
    msg = getString(message('signal:sigtools:sigutils:assignment_VectorIndicesMustEitherBeRealPositiveIntegers'));
   if nargout == 0
     error(message('signal:sigutils:vector:chkindx:IndexNotRealPositiveInt'))
   end            
end

% Make sure that the index is inside the vector.
if indx > length(this) && nargin == 2
    msg = getString(message('signal:sigtools:sigutils:assignment_IndexExceedsVectorLength'));
   if nargout == 0
     error(message('signal:sigutils:vector:chkindx:IndexTooLarge'))
   end    
end

% [EOF]
