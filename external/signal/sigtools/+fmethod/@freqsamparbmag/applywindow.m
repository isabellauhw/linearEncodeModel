function b = applywindow(this,b,N)
%APPLYWINDOW   

%   Copyright 1999-2019 The MathWorks, Inc.

%#function bartlett
%#function barthannwin
%#function blackman
%#function blackmanharris
%#function bohmanwin
%#function chebwin
%#function flattopwin
%#function gausswin
%#function hamming
%#function hann
%#function kaiser
%#function nuttallwin
%#function parzenwin
%#function rectwin
%#function taylorwin
%#function tukeywin
%#function triang

w = this.Window;
if ~isempty(w)
    if isa(w, 'function_handle') || ischar(w)
        try
            w = feval(w,N+1);
        catch
            error(message('signal:fmethod:freqsamparbmag:applywindow:InvalidWindow'));
        end
    elseif iscell(w) && length(w)==2
        try
            w = feval(w{1},N+1,w{2});
        catch
            error(message('signal:fmethod:freqsamparbmag:applywindow:InvalidWindow'));
        end
    elseif isnumeric(w)
        if length(w)~=N+1
            error(message('signal:fmethod:freqsamparbmag:applywindow:InvalidWindow'));
        end
    else
        error(message('signal:fmethod:freqsamparbmag:applywindow:InvalidWindow'));
    end
    b = b.*w(:).';
end


% [EOF]
