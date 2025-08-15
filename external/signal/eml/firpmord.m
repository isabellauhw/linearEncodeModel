function [N, ff, aa, wts] = firpmord(varargin)
%MATLAB Code Generation Library Function

% Copyright 2008-2010 The MathWorks, Inc.
%#codegen    
myfun = 'firpmord';
coder.extrinsic('eml_try_catch');
eml_assert_all_constant(varargin{:});
if nargout == 1 && nargin == 5
   [errid, errmsg, N] = eml_try_catch(myfun,varargin{:});
   errid = coder.internal.const(errid);
   errmsg = coder.internal.const(errmsg);
   N = coder.internal.const(N);
else
   [errid, errmsg, N, ff, aa, wts] = eml_try_catch(myfun,varargin{:});
   errid = coder.internal.const(errid);
   errmsg = coder.internal.const(errmsg);
   N = coder.internal.const(N);
   ff = coder.internal.const(ff);
   aa = coder.internal.const(aa);
   wts = coder.internal.const(wts);
end
eml_lib_assert(isempty(errmsg),errid,errmsg);
