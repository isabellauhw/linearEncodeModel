function commentlines(this, lnStart, lnEnd)
% Comment out the lines of the buffer from line number lnStart to lnEnd
%
% commentlines(B,S,E) comments out the lines of buffer B from line number
% S to line number E. 
%
% commentlines(B,S,'end') comments out lines from line number S up to the
% end of the buffer. 
%
% commentlines(B,'all') comments out all the lines of buffer B.

%   Copyright 2011 The MathWorks, Inc.

c = getcommentchar(this);
bufferLines = this.buffer;

if ischar(lnStart)
  if strcmpi(lnStart,'all')
    lnStart = 1;
    lnEnd = length(bufferLines);
  end
elseif nargin == 3
  if strcmpi(lnEnd, 'end')
    lnEnd = length(bufferLines);
  end
end

clear(this)

for idx = lnStart:lnEnd
    bufferLines{idx} = [c ' ' bufferLines{idx}];    
end

add(this,bufferLines);

% [EOF]
