function [h,delta,result] = cfirpm(varargin)
%MATLAB Code Generation Library Function

% Copyright 2008-2010 The MathWorks, Inc.
%#codegen    
myfun = 'cfirpm';
coder.extrinsic('eml_try_catch');
eml_assert_all_constant(varargin{:});
[errid,errmsg,h,delta,result] = eml_try_catch(myfun,varargin{:});
errid = coder.internal.const(errid);
errmsg = coder.internal.const(errmsg);
h = coder.internal.const(h);
delta = coder.internal.const(delta);
result = coder.internal.const(result);
eml_lib_assert(isempty(errmsg),errid,errmsg);
