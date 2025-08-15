function [E,V] = dpss(varargin)
%MATLAB Code Generation Library Function

% Copyright 2008-2010 The MathWorks, Inc.
%#codegen    
coder.extrinsic('eml_try_catch');
eml_assert_all_constant(varargin{:});

[errid,errmsg,E,V] = eml_try_catch('dpss',varargin{:});
errid = coder.internal.const(errid);
errmsg = coder.internal.const(errmsg);
E = coder.internal.const(E);
V = coder.internal.const(V);
eml_lib_assert(isempty(errmsg),errid,errmsg);
