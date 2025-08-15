function [z,p,k] = besselap(varargin)
%MATLAB Code Generation Library Function

% Copyright 2009-2010 The MathWorks, Inc.
%#codegen    
myfun = 'besselap';
coder.extrinsic('eml_try_catch');
eml_assert_all_constant(varargin{:});
[errid,errmsg,z,p,k] = eml_try_catch(myfun,varargin{:});
errid = coder.internal.const(errid);
errmsg = coder.internal.const(errmsg);
z = coder.internal.const(z);
p = coder.internal.const(p);
k = coder.internal.const(k);
eml_lib_assert(isempty(errmsg),errid,errmsg);
