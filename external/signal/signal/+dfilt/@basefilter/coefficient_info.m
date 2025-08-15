function [p, v] = coefficient_info(this)
%COEFFICIENT_INFO   Get the coefficient information for this filter.

%   Copyright 1988-2018 The MathWorks, Inc.

%#ok<*AGROW>
coeffs = coefficients(this);
if length(coeffs) == 1
    p = {getString(message('signal:dfilt:info:FilterLength'))};
    v = {sprintf('%d', length(coeffs{1}))};
else
    coeffnames = coefficientnames(this);
    
    for indx = 1:length(coeffs)
        coeffnamestr = getTranslatedString(coeffnames{indx});
        p{indx} = sprintf('%s %s', coeffnamestr, ...
            getString(message('signal:dfilt:info:Length'))); 
        v{indx} = sprintf('%d', length(coeffs{indx}));
    end
end

function str = getTranslatedString(coeffname)


switch coeffname
    case 'Numerator'
        str = getString(message('signal:dfilt:dfilt:Numerator'));
    case 'Denominator'
        str = getString(message('signal:dfilt:dfilt:Denominator'));
    case 'Lattice'
        str = getString(message('signal:dfilt:info:Lattice'));
    case 'Ladder'
        str = getString(message('signal:dfilt:info:Ladder'));
    case 'Coefficients'
        str = getString(message('signal:dfilt:info:Coefficients'));
    case 'FracDelay'
        str =  getString(message('signal:dfilt:info:Fracdelay'));
    case 'Gain'
        str = getString(message('signal:dfilt:dfilt:Gain'));
    case 'Allpass1'
        str = getString(message('signal:sigtools:sigio:Allpass1'));
    case 'Allpass2'
        str = getString(message('signal:sigtools:sigio:Allpass2'));
    case 'Beta'
        str = getString(message('signal:sigtools:sigio:Beta'));
    case 'Latency'
        str = getString(message('signal:dfilt:info:Latency'));
end
% [EOF]
