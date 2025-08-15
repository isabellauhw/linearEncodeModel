function str = coeffviewstr(this, varargin)
%COEFFVIEWSTR   

%   Copyright 2004-2016 The MathWorks, Inc.

pnum = this.privNum;
pden = this.privDen;

svq = this.privScaleValues;
svqcell = num2cell(svq);
isnoteq2one = this.issvnoteq2one;
sv = cell(length(isnoteq2one),1);
sv(isnoteq2one) = svqcell;
if isprop(this,'Arithmetic') && strcmp(this.Arithmetic,'single')
    sv(~isnoteq2one) = {single(1)};
else
    sv(~isnoteq2one) = {1};
end

str  = '';

sep = '--------------------------';

for indx = 1:nsections(this)
    [num_str, den_str, sv_str] = dispstr(this.filterquantizer, ...
        pnum(indx, :).', pden(indx, :).', sv{indx}, varargin{:});
    
    % Add each section.
    strTemp = char(sep, ...
        sprintf([getString(message('signal:dfilt:dfilt:Section')) ' #%d'], indx), ...
        sep, ...
        [getString(message('signal:dfilt:dfilt:Numerator')) ':'], ...
        num_str, ...
        [getString(message('signal:dfilt:dfilt:Denominator')) ':'], ...
        den_str, ...
        [getString(message('signal:dfilt:dfilt:Gain')) ':'], ...                  
        sv_str);
    
    if isempty(str)
        str = strTemp;
    else
        str = char(str, strTemp);
    end
end

% Add the output gain.
[~, ~, sv_str] = dispstr(this.filterquantizer, 1, 1, sv{end}, varargin{:});
strTemp = char(sep, [getString(message('signal:dfilt:dfilt:OutputGain')) ':'], sv_str);
if isempty(str)
    str = strTemp;
else
    str = char(str, strTemp);
end

% [EOF]
