function Hbest = searchmincoeffwl(this,args,varargin)
%SEARCHMINCOEFFWL Search for min. coeff wordlength.
%   This should be a private method.
%
%   If args doesn't have wl field: search for global minimum.
%
%   If args has wl field: search for a filter with coeff wordlength of at
%                         most wl.

%   Copyright 1999-2015 The MathWorks, Inc.

minordspec  = 'Fst,Fp,Ast,Ap';

designargs = {'fircls',...                
                'Zerophase',this.Zerophase,...
                'PassbandOffset',this.PassbandOffset};
           
Hbest = searchmincoeffwlword(this,args,minordspec,designargs,varargin{:});

% [EOF]
