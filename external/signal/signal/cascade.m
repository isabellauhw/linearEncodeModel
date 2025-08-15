function Hd = cascade(varargin)
%CASCADE Cascade filter objects.
%    Hd = cascade(Hd1, Hd2, ...) is equivalent to Hd=dfilt.cascade(Hd1,Hd2,...).
%    The block diagram of this cascade looks like:
%        x ---> Hd1 ---> Hd2 ---> ... ---> y
%
%   See also DFILT.

%   Author: Thomas A. Bryan
%   Copyright 1988-2016 The MathWorks, Inc.

multirate = false;
for indx = 1:nargin
    % Do not attempt varargin{indx}(jndx) for scalar varargin{indx}
    % If varargin{indx} is a System object, this will fail (function
    % notation)
    L = numel(varargin{indx});
    if L > 1
        for jndx = 1:length(varargin{indx})
            if ~isempty(findstr('mfilt', class(varargin{indx}(jndx))))
                multirate = true;
                break;
            end
        end
    else
        multirate = ~isempty(findstr('mfilt', class(varargin{indx})));
    end
    if multirate
        break
    end
end

% Suppress MFILT deprecation warnings
w = warning('off', 'dsp:mfilt:mfilt:Obsolete');
restoreWarn = onCleanup(@() warning(w));
    
if multirate
    Hd = mfilt.cascade(varargin{:});
else
    Hd = dfilt.cascade(varargin{:});
end 