function filtobj = getfilter(hFDA, wfs) %#ok<INUSD>
%GETFILTER Returns the current filter of FDATool.
%   FILT = GETFILTER(hFDA) returns the current filter object of the FDATool
%   session specified by hFDA.  The filter object must be a DFILT.
%
% See also SETFILTER.

%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(1,2);
filtobj = get(hFDA, 'Filter');

if isempty(filtobj)
  [filtobj,opts.mcode] = defaultfilter(hFDA);
  opts.update    = true;
  opts.fs        = 48000;
  opts.default   = false;
  opts.source    = 'Designed';
  opts.name      = getString(message('signal:sigtools:sigtools:LowpassEquiripple'));
  opts.filedirty = false;
  setfilter(hFDA, filtobj, opts);
  filtobj = get(hFDA, 'Filter');
else
  % Copy internal filter to ensure set method is not prevented due to AbortSet
  filtobj.Filter = copy(filtobj.Filter);  
end

if nargin < 2
  filtobj = get(filtobj, 'Filter');
end

% [EOF]

