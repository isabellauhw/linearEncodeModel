function addelementat(this, input, indx)
%ADDELEMENTAT Add the element at the vector index

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

narginchk(3,3);
chkindx(this, indx, 'nolength');

% Add the element in the requested index.  Special case the first and last
% indices.
switch indx
case 1
    this.Data = {input, this.Data{:}};
case length(this)+1
    this.Data = {this.Data{:}, input};    
otherwise
    if indx > length(this) + 1
        
        % Allow elements beyond the length and fill with []'s
        filler    = repmat({[]}, 1, indx-length(this)-1);
        data      = this.Data;
        this.Data = {data{:}, filler{:}, input};
    else
        this.Data = {this.Data{1:indx-1}, input, this.Data{indx:end}};
    end
end

sendchange(this, 'NewElement', indx);

% [EOF]
