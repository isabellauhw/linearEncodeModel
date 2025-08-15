function [b,a,b1,b2,sos,g] = maxflat(varargin)
%MATLAB Code Generation Library Function

% Copyright 2008-2010 The MathWorks, Inc.
%#codegen    
myfun = 'maxflat';
coder.extrinsic('eml_try_catch');
eml_assert_all_constant(varargin{:});
[errid,errmsg,b,a,b1,b2,sos,g] = eml_try_catch(myfun,varargin{:});
errid = coder.internal.const(errid);
errmsg = coder.internal.const(errmsg);
b = coder.internal.const(b);
a = coder.internal.const(a);
b1 = coder.internal.const(b1);
b2 = coder.internal.const(b2);
sos = coder.internal.const(sos);
g = coder.internal.const(g);
eml_lib_assert(isempty(errmsg),errid,errmsg);
