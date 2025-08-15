classdef stftmag2sigParser < handle
%STFTPARSER is a function for parsing value-only inputs, flags, and
%   name-value pairs for the STFTMAG2SIG functions. This function is
%   internal use only. It may be removed in the future.

%   Copyright 2020 The MathWorks, Inc.
%#codegen

    properties (Constant,Hidden)
       DefaultNwin = 128;
       DefaultOverlapPercent = 0.75;
       DefaultWin = hann(128,'periodic');
       DefaultFreqRange = 'centered';
       DefaultTimeDimension = 'acrosscolumns';
       DefaultMethod = 'gla';
       DefaultInitPhaseMethod = 'zeros';
       DefaultMaxIter = 100;
       DefaultTol = 1e-4;
       DefaultDisplay = false;
       DefaultUpdateParam = 0.99;
    end
    
    properties(Hidden)
       InputDataType
       FnName
    end

    properties (Access = public)   
       % Size related
       DataSize
       WindowLength
       FFTLength
       OverlapLength
       NumChannels
       
       DataType
       Window
       FrequencyRange
       MaxIterations
       Method
       InitializeMethod
       InitialPhase
       InconsistencyTolerance
       UpdateParameter
       TruncationOrder
       TimeDimension
       NumFreqSamples
       Display
       
       % Time information
       TimeValue
    end
    
    methods
        %-----------------------------------------------------------------------------
        function this = stftmag2sigParser(inputSize,InputDataType,varargin)
            this.FnName = 'stftmag2sig';
            this.InputDataType = InputDataType;
            this.DataSize = inputSize;
            if length(inputSize) == 3
                this.NumChannels = inputSize(3);
            else
                this.NumChannels = 1;
            end
            this.parseInputs(varargin{:})
        end
        %-----------------------------------------------------------------------------
        function parseInputs(this,varargin)
            
            % Check value-only variables
            idxArgIn = 1:length(varargin);
            parseChk = true(size(varargin));
            % Check for FFT Length
            if isempty(varargin) || any([isa(varargin{1},'char'),isa(varargin{1},'string')])
                coder.internal.error('signal:stftmag2sig:NFFTMustBeProvided');
            else
                this.FFTLength = varargin{1};
                parseChk(1) = false;
            end

            % Check for time input
            if length(varargin)>=2&&~any([isa(varargin{2},'char'),isa(varargin{2},'string')])
                this.TimeValue = varargin{2};
                parseChk(2) = false;
            else
                this.TimeValue = [];
            end
            
            idxParse = idxArgIn(parseChk);
            nNameValuePairs = numel(idxParse);
            if nNameValuePairs>=1
                coder.internal.errorIf(~any([isa(varargin{idxParse(1)},'char'),...
                    isa(varargin{idxParse(1)},'string')]),'signal:stftmag2sig:TooManyValueOnlyInputs');
            end
            
            % Parse n-v pairs
            if length(parseChk)==1 && ~parseChk
                this.parseNVpairs(false);
            else
                this.parseNVpairs(true,varargin{1,idxParse});
            end
            
            % Validate parameters
            this.validateInputParams()
        end
        %-----------------------------------------------------------------------------
        function parseNVpairs(this,hasNV,varargin)
            if ~hasNV
                this.DataType = this.InputDataType;
                this.Window = this.DefaultWin;
                this.WindowLength = this.DefaultNwin;
                this.OverlapLength = floor(this.WindowLength*this.DefaultOverlapPercent);
                this.FrequencyRange = this.DefaultFreqRange;
                this.Method = this.DefaultMethod;
                this.InitializeMethod = this.DefaultInitPhaseMethod;
                this.MaxIterations = this.DefaultMaxIter;
                this.InconsistencyTolerance = this.DefaultTol;
                this.TimeDimension = this.DefaultTimeDimension;
                this.Display = this.DefaultDisplay;
                this.InitialPhase = zeros(this.DataSize,this.DataType);
                this.UpdateParameter = zeros(1,this.DataType);
            else
                % ParitalMatching true
                poptions = struct( ...
                    'CaseSensitivity',false, ...
                    'PartialMatching','first', ...
                    'StructExpand',false, ...
                    'IgnoreNulls',true);
                params = {'Window',...
                    'OverlapLength',...
                    'FrequencyRange'...
                    'Method',...
                    'InitializePhaseMethod',...
                    'InitialPhase',...
                    'MaxIterations',...
                    'InconsistencyTolerance',...
                    'InputTimeDimension',...
                    'UpdateParameter',...
                    'TruncationOrder',...
                    'Display'};           
                pstruct = coder.internal.parseParameterInputs(params,poptions,varargin{:});

                % decide data type
                win = coder.internal.getParameterValue(pstruct.Window,...
                    this.DefaultWin,varargin{:});
                validateattributes(win,{'single','double'},...
                    {'nonempty','finite','nonnan','vector','real'},this.FnName,'Window');   
                this.WindowLength = length(win);
                validateattributes(this.WindowLength,{'numeric'},...
                    {'scalar','integer','nonnegative','real','nonnan','nonempty',...
                    'finite','>',1},this.FnName,'Window');
                initialPhase = coder.internal.getParameterValue(pstruct.InitialPhase,...
                    [],varargin{:});

                if isa(win,'single') || isa(initialPhase,'single') ||...
                    strcmp(this.InputDataType,'single')
                    dataType = 'single';
                else
                    dataType = 'double';
                end
                assert(coder.internal.isConst(dataType));
                this.DataType = dataType;

                % parsing
                this.Window = cast(win(:),dataType);
                
                % OverlapLength
                noverlap = coder.internal.getParameterValue(pstruct.OverlapLength,...
                    floor(this.WindowLength*this.DefaultOverlapPercent),varargin{:});
                validateattributes(noverlap,{'numeric'},...
                    {'scalar','integer','nonnegative','real','nonnan',...
                    'finite','nonempty','>=',0,'<',this.WindowLength},...
                    this.FnName,'OverlapLength')        
                this.OverlapLength = noverlap;
                
                % MaxIterations
                maxIter = coder.internal.getParameterValue(pstruct.MaxIterations,...
                    this.DefaultMaxIter,varargin{:});
                validateattributes(maxIter,{'numeric'},...
                    {'scalar','integer','nonnegative','real','nonnan',...
                    'finite','nonempty'},this.FnName,'MaxIterations') 
                this.MaxIterations = double(maxIter);
                
                % Inconsistency tolerance
                tol = coder.internal.getParameterValue(pstruct.InconsistencyTolerance,...
                    this.DefaultTol,varargin{:});
                validateattributes(tol,{'double','single'},...
                      {'scalar','real','nonnan','finite','nonempty','positive'},...
                      this.FnName,'InconsistencyTolerance');       
                this.InconsistencyTolerance = cast(tol,dataType);
                
                % Display
                this.Display = coder.internal.getParameterValue(pstruct.Display,...
                    this.DefaultDisplay,varargin{:});             
                
                % Frequency Range
                frequencyRange = coder.internal.getParameterValue(pstruct.FrequencyRange,...
                    this.DefaultFreqRange,varargin{:});
                validStrings = {'twosided','onesided','centered'};
                this.FrequencyRange = validatestring(frequencyRange,validStrings,this.FnName,'FrequencyRange');
                
                % Time dimension
                timeDimension = coder.internal.getParameterValue(pstruct.InputTimeDimension,...
                    this.DefaultTimeDimension,varargin{:});
                validStrings = {'acrosscolumns','downrows'};
                this.TimeDimension = validatestring(timeDimension,validStrings,this.FnName,'InputTimeDimension');               

                % Method
                method = coder.internal.getParameterValue(pstruct.Method,...
                    this.DefaultMethod,varargin{:}); 
                validStrings = {'gla','legla','fgla'};
                this.Method = validatestring(method,validStrings,this.FnName,'Method');

                % Update parameter
                updateParameter = coder.internal.getParameterValue(pstruct.UpdateParameter,...
                    [],varargin{:});
                if ~isempty(updateParameter)
                   coder.internal.errorIf(~strcmpi(this.Method,'fgla'),...
                      'signal:stftmag2sig:UpdateParameterWithoutFGLA')
                   validateattributes(updateParameter,{'double','single'},...
                      {'scalar','real','nonnan','finite','nonempty'},...
                      this.FnName,'UpdateParameter');
                   this.UpdateParameter = cast(updateParameter,this.DataType);
                else
                    this.UpdateParameter = cast(this.DefaultUpdateParam,this.DataType);
                end            

                % Truncation order
                truncationOrder = coder.internal.getParameterValue(pstruct.TruncationOrder,...
                    [],varargin{:});
                if ~isempty(truncationOrder)
                   coder.internal.errorIf(~strcmpi(this.Method,'legla'),...
                      'signal:stftmag2sig:TruncationOrderWithoutLEGLA')
                   validateattributes(truncationOrder,{'double','single'},...
                      {'scalar','integer','positive','nonnan','finite','nonempty'},...
                      this.FnName,'UpdateParameter');
                   this.TruncationOrder = cast(truncationOrder,this.DataType);
                end

                % Initialize Phase method
                initialMethod = coder.internal.getParameterValue(pstruct.InitializePhaseMethod,...
                    [],varargin{:});

                if ~isempty(initialMethod)
                    this.InitializeMethod = validatestring(initialMethod,...
                        {'zeros','random'},'stftmag2sig','InitializePhaseMethod');
                else
                    this.InitializeMethod = '';
                end
                
                % Initial Phase
                this.InitialPhase = zeros(this.DataSize,this.DataType);
                if isempty(initialPhase)
                    if isempty(initialMethod) % defaut method 'zeros' to initialize the phase
                        this.InitializeMethod = 'zeros';          
                    end                
                else
                    coder.internal.errorIf(~isempty(initialMethod),'signal:stftmag2sig:InitPhaseError');
                    validateattributes(this.InitialPhase,{'single','double'}, ...
                        {'nonsparse','finite','nonnan','2d'},'stftmag2sig','Initial Phase');
                    this.InitialPhase = cast(initialPhase,this.DataType);
                end
            end
        end
        %-----------------------------------------------------------------------------
        function validateInputParams(this)
            
            % Display
            validateattributes(this.Display,{'numeric','logical'},{'scalar','nonnan','finite'},'stftmag2sig','Display');

                        
            % FFTLength
            validateattributes(this.FFTLength,{'double'},...
                {'scalar','integer','nonnegative','real','nonnan',...
                'finite','nonempty','>=',this.WindowLength},this.FnName,'FFTLength');
                 
           % Check if onesided
           isOnesided = strcmp(this.FrequencyRange,'onesided');
           if isOnesided
               if signalwavelet.internal.iseven(this.FFTLength)
                   this.NumFreqSamples = this.FFTLength/2+1;
               else
                   this.NumFreqSamples = (this.FFTLength+1)/2;
               end
           else
              this.NumFreqSamples =  this.FFTLength;
           end
           
           idx = 1;
           if strcmpi(this.TimeDimension,'downrows')
               idx = 2;
           end

           if this.NumFreqSamples~=this.DataSize(idx)
               if idx == 1
                   coder.internal.error('signal:stftmag2sig:InvalidFFTLengthRow', ...
                       this.NumFreqSamples);
               else
                   coder.internal.error('signal:stftmag2sig:InvalidFFTLengthCol', ...
                       this.NumFreqSamples);
               end
           end
           
           % Initial phase
           if ~isempty(this.InitialPhase)
               coder.internal.errorIf(any(size(this.InitialPhase)~=this.DataSize), ...
                   'signal:stftmag2sig:InvalidInitialPhase');
               coder.internal.errorIf(max(this.InitialPhase(:))>pi | max(this.InitialPhase(:))<-pi,...
                   'signal:stftmag2sig:InvalidInitialPhaseRange');
           end
           
           % Check time information
           this.verifyTime();
        end
        %-----------------------------------------------------------------------------
        function verifyTime(this)
            timeMode = '';
            timeValue = this.TimeValue;
            if ~isempty(this.TimeValue)
                if coder.target('MATLAB') && isduration(timeValue)
                    if isscalar(timeValue)
                        timeValue = seconds(timeValue);
                        timeMode = 'ts';
                    else
                        coder.internal.error('signal:stftmag2sig:InvalidTimeInfo');
                    end
                else
                    if isscalar(timeValue)
                        timeMode = 'fs';
                    else
                        coder.internal.error('signal:stftmag2sig:InvalidTimeInfo');
                    end
                end
            end

            % Validate time inputs
            switch timeMode
                case 'fs' % Sample rate provided
                    validateattributes(timeValue, {'numeric'},{'scalar','real','finite','positive'},this.FnName,'sample rate')
                case 'ts' % Duration provided
                    validateattributes(timeValue, {'numeric'},{'scalar','real','finite','positive'},this.FnName,'sample time')
            end
        end
    end

    methods(Static,Hidden=true)
       function props = matlabCodegenNontunableProperties(~)
          props = {'DataType','InputDataType','FnName'}; 
       end
    end
end