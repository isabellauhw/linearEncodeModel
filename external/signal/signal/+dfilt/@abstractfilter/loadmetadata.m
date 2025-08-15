function loadmetadata(this, s)
%LOADMETADATA   Load the metadata.

%   Copyright 1988-2014 The MathWorks, Inc.

if isstruct(s)
    if isfield(s,'fdesign')
        hfd = s.fdesign;
    else
        hfd = [];
    end
    designMethodStr = '';
    if s.version.number > 0
        if s.version.number > 2 && isfield(s, 'measurements')
            setmeasurements(this, s.measurements);
            if isfield(s, 'designmethod')
                designMethodStr = s.designmethod;
            elseif isfield(s,'privdesignmethod')
                designMethodStr = s.privdesignmethod;
            end
        end
        hfm = s.fmethod;
    else
        hfm = [];
    end
else
    hfd = getfdesign(s);
    hfm = getfmethod(s);
    designMethodStr = s.privdesignmethod;
end

% Add the SystemObject property if it applies
if ~isempty(hfm) && isa(hfm,'fmethod.abstractdesign')
  addsysobjdesignopt(hfm);
end

setfdesign(this, hfd);
setfmethod(this, hfm);
this.privdesignmethod = designMethodStr;

% [EOF]
