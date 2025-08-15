function varargout = actualdesign(this, hs)
%ACTUALDESIGN Perform the actual design.

%   Copyright 1999-2017 The MathWorks, Inc.

args = designargs(this, hs);

extraargs = {{this.DensityFactor}};

designfcn = getdesignfunction(this);

if isequal(designfcn,@firgr) || isequal(designfcn,@fircband) 
    
    %Warn the user that his UniformGrid = true setting will be ignored
    %in order to achieve the requested non default MinPhase, MaxPhase,
    %MinOrder, or StopbandShape design
    if isprop(this,'privUGridFlag') && isequal(this.privUGridFlag,1)
        warning(message('signal:fmethod:abstracteqrip:actualdesign:UniformGridTrueIgnored'));
    end
    
    if this.MinPhase
        if isprop(this,'MaxPhase') && this.MaxPhase
            error(message('signal:fmethod:abstracteqrip:actualdesign:MinMaxTrue'));
        end            
        extraargs = {extraargs{:}, 'minphase'}; %#ok<*CCAT>
    elseif isprop(this,'MaxPhase') && this.MaxPhase
        extraargs = {extraargs{:}, 'maxphase'};
    end
    
    if iscell(args{1})
        if isminordereven(this)
            args{1}{1} = 'mineven';
            
            % Make sure that the initial order is even.
            if rem(args{1}{2}, 2) == 1
                args{1}{2} = args{1}{2}-1;
            end
        elseif isminorderodd(this)
            args{1}{1} = 'minodd';
            
            % Make sure that the initial order is odd.
            if rem(args{1}{2}, 2) == 0
                args{1}{2} = args{1}{2}-1;
            end
        end
    end    
end
[varargout{1:nargout}] = designfcn(args{:}, extraargs{:});
    
% The DESIGN method is expecting a cell array of coefficients, not a vector
varargout{1} = varargout(1);

% [EOF]
