function buildcurrent(this)
%BUILDCURRENT Build the current design method

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

hDM          = get(this, 'CurrentDesignMethod');
designmethod = get(this, 'Designmethod');
filtertype   = get(this, 'ResponseType');

try
    
    
    if ~isempty(designmethod) && ~isempty(filtertype)
        
        % If the current design method matches the new one, do not
        % create a new one
        if ~isempty(hDM) && isempty(find(hDM, '-class', designmethod)) || isempty(hDM)
            hDM = feval(designmethod);
        end
        
        if ~isempty(findprop(hDM, 'responseType'))
            set(hDM, 'ResponseType', ...
                tag2string(getcomponent(this, '-class', 'siggui.selector', ...
                    'name', 'Response Type'), this.SubType));
        end
        
        % AbortSet is 'Off' so this will always fire, even if we
        % just change the FilterType
        set(this, 'CurrentDesignMethod', hDM);
    end
catch ME %#ok<NASGU>
    % NO OP this is an undo safety valve.
end


% [EOF]
