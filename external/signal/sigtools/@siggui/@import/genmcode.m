function b = genmcode(h)
%GENMCODE Generate MATLAB code

%   Copyright 1988-2017 The MathWorks, Inc.

hcs = find(h, '-class', 'siggui.coeffspecifier');

% Get the constructor from the Filter Structure popup
object = getshortstruct(hcs,'object');

if strcmpi(hcs.SOS, 'on')
    object = [object 'sos'];
end

coeffs = getselectedcoeffs(hcs);

% Loop over the coefficients and convert them to a string of numbers.
isobj = false;
for indx = 1:length(coeffs)
    [coeffs{indx}, msg] = evaluatevars(coeffs{indx});
    if ~isempty(find(findstr(msg, 'is not numeric.'), 1))
        errStr = '';
    end
    if isa(coeffs{indx}, 'dfilt.basefilter')
        isobj = true;
    end
    
    if ~isobj
        if strcmpi(hcs.SOS, 'on') && (indx == 1)
          coeffs{indx} = mat2str(coeffs{indx});
          % remove brackets, they will be added later
          coeffs{indx} = coeffs{indx}(2:end-1); 
          % Add spaces between commas and ; so that code wrapping works
          % correctly
          coeffs{indx} = strrep(coeffs{indx},',',', ');
          coeffs{indx} = strrep(coeffs{indx},';','; ');
        else
          coeffs{indx} = num2str(coeffs{indx}(:).');
        end
    else
        try
            b = genmcode(coeffs{1});
        catch %#ok<CTCH>
            b = '';
        end
        return
    end
end

% Get the labels from the coefficient specifier
labels = getcurrentlabels(hcs);
for indx = 1:length(labels)
    labels{indx}(end) = [];
    sindx = strfind(labels{indx}, ' ');
    labels{indx}(sindx) = '_';
end

for indx = 1:length(coeffs)
    coeffs{indx} = sprintf('[%s]', coeffs{indx});
    
    % Remove all the extra spaces.
    [s, f] = regexp(coeffs{indx}, ' + ');
    idx = [];
    for jndx = 1:length(s)
        idx = [idx s(jndx)+1:f(jndx)];
    end
    
    coeffs{indx}(idx) = [];
    descs{indx} = sprintf('%s coefficient vector', labels{indx});
end

% Format the labels and coeffs.
inputs = sprintf('%s, ', labels{:});
inputs(end-1:end) = [];

b = sigcodegen.mcodebuffer;
b.addcr(b.formatparams(labels, coeffs, descs));
b.cr;
b.addcr('Hd = %s(%s);', object, inputs);

% [EOF]
