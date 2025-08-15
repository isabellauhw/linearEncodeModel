function Sout = formatSTFT(S,opts,direc)
% Format centered or twosided STFT to onesided or change back

%#codegen
n = opts.FFTLength;

numFreqSamples = 0;

if signalwavelet.internal.iseven(n)
   numFreqSamples(1) = n/2+1;
else
   numFreqSamples(1) = (n+1)/2;
end

switch direc
    case 'forward'       
        if strcmpi(opts.FrequencyRange,'centered')
            % Format to twosided
            S = twosidedToCentered(S,n);
        end
        
        Sout = S(1:numFreqSamples(1),:);                
    case 'inverse'
        % format onesided to twosided
        Sout = complex(zeros(n(1),size(S,2),opts.DataType));
        Sout(1:numFreqSamples,:) = S;
        if signalwavelet.internal.iseven(n)
            Sout(n:-1:numFreqSamples+1,:) = conj(S(2:numFreqSamples-1,:));
        else
            Sout(n:-1:numFreqSamples+1,:) = conj(S(2:numFreqSamples,:));
        end
        
        if strcmpi(opts.FrequencyRange,'centered')
            Sout = twosidedToCentered(Sout,n);
        end
end
end

function S = twosidedToCentered(S,n)
% Change twosided spectrum to centered

if signalwavelet.internal.iseven(n)
    % even (nyquist is at end of spectrum)
    S = circshift(S,-(n/2-1));
else
    % odd
    S = ifftshift(S,1);
end

end