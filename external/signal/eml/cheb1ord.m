function [order,wn] = cheb1ord(varargin)
%MATLAB Code Generation Library Function

% Copyright 2009-2010 The MathWorks, Inc.
%#codegen    
myfun = 'cheb1ord';
coder.extrinsic('eml_try_catch');
eml_assert_all_constant(varargin{:});
[errid,errmsg,order,wn] = eml_try_catch(myfun,varargin{:});
errid = coder.internal.const(errid);
errmsg = coder.internal.const(errmsg);
order = coder.internal.const(order);
wn = coder.internal.const(wn);
eml_lib_assert(isempty(errmsg),errid,errmsg);
