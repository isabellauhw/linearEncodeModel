function [t,dt] = parseTime(tx,len,funcName)
%PARSETIME function to convert time information tx to time vector t in
%seconds or dt with the same time type with tx. tx can be sampling frequency(double/single), sampling time
%interval(double/single, duration), and time vector(double/single,
%duration, datetime). 
%
% In tfmoment, it is only used for parsing time information of spectrum
% case and parsing time for signal for validation.

%   Copyright 2017-2019 The MathWorks, Inc.
%#codegen


if isa(tx,'double')||isa(tx,'single')    
    if isscalar(tx) && (len~=1)
        % tx is sampling freq
        validateattributes(tx, {'single','double'}, ...
            {'nonnan','finite','real','positive'}, funcName, 'Fs');
        t = (0:len-1)/tx;
        dt = (0:len-1)/tx;
    else
        % tx is time vector
        validateattributes(tx, {'single','double'}, ...
            {'nonnan', 'finite','real','increasing','numel',len}, funcName, 'Tv');
        t = tx(:);     
        dt = tx(:);
    end    
elseif isduration(tx)
    if isscalar(tx) && (len~=1)
        validateattributes(seconds(tx), {'single','double'}, ...
            {'nonnan','finite','real','positive'}, funcName, 'Ts');
        t = (0:len-1)'*seconds(tx);
        dt = (0:len-1)'*tx;
    else        
        t = seconds(tx(:));
        validateattributes(t, {'single','double'}, ...
            {'nonnan', 'finite','real','increasing','numel',len}, funcName, 'Tv');
        dt = tx(:);
    end    
elseif isdatetime(tx) 
    dt = tx;
    tx = tx-tx(1);
    t = seconds(tx);
    validateattributes(t, {'single','double'}, ...
        {'nonnan', 'finite','real','increasing','numel',len}, funcName, 'Tv');
else
    % No Op
end

end
