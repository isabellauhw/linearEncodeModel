function s = getstate(hFDA)
%GETSTATE Returns the state of FDATool.
%   S = GETSTATE(hFDA) returns the state structure for the session of
%   FDATOOL associated with hFDA.

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.

narginchk(1,1);

hComps = allchild(hFDA);
hfvt = hFDA.FvtoolHandle;

s = [];

for indx = 1:length(hComps)

    if ismethod(hComps(indx), 'getstate')
        
        lbl = get(hComps(indx).classhandle, 'Name');
        sc = getstate(hComps(indx));
        if ~isempty(sc)
            s.(lbl) = sc;
        end
    end
end

if ~isempty(hfvt) && ismethod(hfvt, 'getstate')
  
  ClassName = regexp(class(hfvt),'\.','split');
  lbl = ClassName{end};
  sc = getstate(hfvt);
  if ~isempty(sc)
    s.(lbl) = sc;
  end
  
end

s.current_filt = getfilter(hFDA);

% For backwards compatibility purposes, we place the
% filtermadeby in the mode field
s.filterMadeBy = get(hFDA,'filterMadeBy');
s.currentFs    = get(getfilter(hFDA, 'wfs'), 'Fs');
s.currentName  = get(getfilter(hFDA, 'wfs'), 'Name');
s.version      = get(hFDA,'version');
s.mcode        = copy(get(hFDA, 'MCode'));

% [EOF]
