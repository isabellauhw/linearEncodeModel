function [h,a] = fircls1(varargin)
%MATLAB Code Generation Library Function

% Copyright 2008-2010 The MathWorks, Inc.
%#codegen    
myfun = 'fircls1';
coder.extrinsic('eml_try_catch');
eml_assert_all_constant(varargin{:});
[errid,errmsg,h,a] = eml_try_catch(myfun,varargin{:});
errid = coder.internal.const(errid);
errmsg = coder.internal.const(errmsg);
h = coder.internal.const(h);
a = coder.internal.const(a);
eml_lib_assert(isempty(errmsg),errid,errmsg);
