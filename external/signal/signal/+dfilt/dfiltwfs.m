classdef (CaseInsensitiveProperties=true) dfiltwfs  < hgsetget & matlab.mixin.Copyable & sigio.dyproputil
    %dfilt.dfiltwfs class
    %    dfilt.dfiltwfs properties:
    %       Filter - Property is of type 'MATLAB array'
    %       Fs - Property is of type 'signalNumeric user-defined'
    %       Name - Property is of type 'string'
    %
    %    dfilt.dfiltwfs methods:
    %       freqrespest -   Calculate the frequency response estimate.
    %       freqz - Compute the freqz
    %       freqzparse - Returns the inputs for freqz
    %       getfiltindx - Returns the indices of the dfilts
    %       getfreqinputs - Returns the frequency response inputs
    %       getindex - Returns a vector of indexes
    %       getmaxfs - MAXFS Returns the maximum fs
    %       getminfs - MAXFS Returns the maximum fs
    %       grpdelay - Returns the group delay for the filters
    %       impz - Returns the impulse response
    %       isfssame - Returns true if the fs is the same for all the filters
    %       noisepsd -   Calculate the noise psd.
    %       phasedelay - Phase delay
    %       phasez - Compute the freqz
    %       setfs - Set the FS of the filter/filters
    %       stepz - IMPZ Returns the impulse response
    %       timeresp - Calculates the time response
    %       zerophase - Compute the zero-phase response
    %       zplane - Returns the zeroes and poles of filters
    
    properties (AbortSet, SetObservable, GetObservable)
        %FILTER
        Filter = [];    
        %FS Property is of type 'signalNumeric user-defined'
        Fs = [];
        %NAME Property is of type 'string'
        Name = '';
    end
    
    
    events
        NewFs
    end  % events
    
    methods  % constructor block
        function h = dfiltwfs(filtobj, fs, name)
            %FILTWFS Construct a filtwfs object
            
            narginchk(1,3);
            
            if nargin < 2
                if ispref('SignalProcessingToolbox', 'DefaultFs')
                    fs = getpref('SignalProcessingToolbox', 'DefaultFs');
                else
                    fs = 1;
                end
            end
            
            if nargin < 3
                name = inputname(1);
            end
            
            h.Filter = filtobj;
            set(h, 'Fs', fs);
            set(h, 'Name', name);
            
            
        end  % dfiltwfs
        
    end  % constructor block
    
    methods
        function set.Filter(obj,value)
            obj.Filter = setfilter(obj,value);
        end
        
        function set.Fs(obj,value)
            % User-defined DataType = 'signalNumeric user-defined'
            obj.Fs = value;
        end
        
        function set.Name(obj,value)
            % DataType = 'string'
            validateattributes(value,{'char'}, {'row'},'','Name')
            obj.Name = value;
        end
        
    end   % set and get functions
    
    methods  %% public methods
        function [H, W] = freqrespest(this, L, opts, optsstruct)
            %FREQRESPEST   Calculate the frequency response estimate.
            
            if nargin < 4
                optsstruct.showref = true;
                optsstruct.sosview = [];
                if nargin < 3
                    opts = dspopts.pseudospectrum;
                    opts.NFFT = 512; % NFFT default is 'Nextpow2', but we need a numeric value here.
                    if nargin < 2
                        L = 10;
                    end
                end
            end
            
            % If there is more than 1 filter, we ignore the sosview settings.
            if length(this) > 1 || ~isa(this(1).Filter, 'dfilt.abstractsos')
                optsstruct.sosview = [];
            end
            
            fs = getmaxfs(this);
            if isempty(fs)
                fs = 2*pi;
            end
            
            if strcmpi(opts.SpectrumRange, 'half')
                wmin = 0;
                wmax = fs/2;
            elseif opts.CenterDC
                wmin = -fs/2;
                wmax = fs/2;
            else
                wmin = 0;
                wmax = fs;
            end
            
            % Always get the data from normalized and twosided.  COMPLETEFREQRESP will
            % take care of the rest.
            opts.SpectrumRange       = 'whole';
            opts.NormalizedFrequency = true;
            opts.CenterDC            = false;
            
            nfft = opts.NFFT;
            
            for indx = 1:length(this)
                hindx = this(indx).Filter;
                
                fs = get(this(indx), 'Fs');
                if isempty(fs), fs = getmaxfs(this); end
                if isempty(fs), fs = 2*pi;           end
                
                if ~isempty(optsstruct.sosview)
                    hindx = getfilters(optsstruct.sosview, hindx);
                end
                % When sosview set to cumulative, the hindx could be
                % a vector for multiple filters. However, they are either all
                % quantized or all not. So it is safe to call "all".
                if all(isquantized(hindx)) && optsstruct.showref
                    hindx = [hindx reffilter(hindx)]; %#ok<*AGROW>
                    if isprop(hindx(1),'FromSysObjFlag') && hindx(1).FromSysObjFlag && ...
                            ~isempty(hindx(1).ContainedSysObj)
                        hindx(2).FromSysObjFlag = true;
                        hindx(2).ContainedSysObj = clone(hindx(1).ContainedSysObj);
                        release(hindx(2).ContainedSysObj)
                    end
                end
                
                for jndx = 1:length(hindx)
                    opts.NFFT = force2even(max(4, round(nfft*fs/(wmax-wmin))));
                    H{indx}(:, jndx) = freqrespest(hindx(jndx), L, opts);
                end
                H{indx} = convert2db(H{indx});
                
                % Complete the response for the filter from wmin to wmax based on
                % the sampling frequency of this individual filter.
                [H{indx}, W{indx}] = completefreqresp(H{indx}, fs, wmin, wmax);
            end
            
        end
        
        function [h, w] = freqz(this, varargin)
            %FREQZ Compute the freqz
            %   Inputs:
            %       this    -   The object
            %       NFFT    -   The number of points or a freqvector
            %       UC      -   {'Half', 'Whole', 'FFTShift'}
            
            if nargin > 1 && isstruct(varargin{end})
                opts = varargin{end};
                varargin(end) = [];
            else
                opts.showref  = false;
                opts.showpoly = false;
                opts.sosview  = [];
            end
            
            % If there is more than 1 filter, we ignore the sosview settings.
            if length(this) > 1 || ~isa(this(1).Filter, 'dfilt.abstractsos')
                opts.sosview = [];
            end
            
            [nfft, unitcircle] = freqzparse(this, varargin{:});
            [wmin, wmax]       = getfreqinputs(this, unitcircle);
            
            h = {};
            w = {};
            
            same = isfssame(this);
            
            for indx = 1:length(this)
                cFilt = get(this(indx), 'Filter');
                
                % If it is a polyphase filter, break it down to multiple filters.
                [cFilt,fsScaling] = breakDownPolyphase(cFilt,opts);
                
                if ~isempty(opts.sosview)
                    cFilt = getfilters(opts.sosview, cFilt);
                end
                
                % Get the current sampling frequency.  If the getmaxfs returns [], then
                % all of the filters are normalized.  When this happens we set Fs = 2*pi
                fs = get(this(indx), 'Fs');
                if isempty(fs), fs = getmaxfs(this); end
                if isempty(fs), fs = 2*pi; fsScaling = 1; end
                
                % If unitcircle == 4, then we want to apply the nfft as frequency
                % points (not as the number of points)
                if length(nfft) > 1
                    [h{end+1}, w{end+1}] = freqz(cFilt, nfft, fs*fsScaling);
                    if opts.showref && any(isquantized(cFilt))
                        hr = freqz(reffilter(cFilt), nfft, fs*fsScaling);
                        if size(nfft, 1) == 1
                            h{end} = [h{end}; hr];
                        else
                            h{end} = [h{end} hr];
                        end
                    end
                else
                    
                    inputs = {nfft, same, unitcircle, fs*fsScaling, wmin*fsScaling, wmax*fsScaling};
                    [h{end+1}, w{end+1}] = getresponse1(cFilt, inputs{:});
                    
                    if opts.showref && any(isquantized(cFilt))
                        hr = getresponse1(reffilter(cFilt), inputs{:});
                        h{end} = [h{end} hr];
                    end
                end
            end
            
        end
        
        function [nfft, unitcircle] = freqzparse(hObj, varargin)
            %FREQZPARSE Returns the inputs for freqz
            
            nfft       = 512;
            unitcircle = 1;
            
            if nargin > 2
                unitcircle = strmatch(lower(varargin{2}), {'half', 'whole', 'fftshift'});
            end
            if nargin > 1
                nfft = varargin{1};
            end
            
            if length(nfft) > 1
                unitcircle = 4;
            end
            
        end
        
        function [dindx, qindx] = getfiltindx(h)
            %GETFILTINDX Returns the indices of the dfilts
            
            G = get(h, 'Filter');
            if ~iscell(G), G = {G}; end
            
            qindx     = [];
            dindx     = [];
            otherindx = [];
            
            for n = 1:length(G)
                if isquantized(G{n})
                    qindx = [qindx n];
                else
                    dindx = [dindx n];
                end
            end
            
        end
        
        function [wmin, wmax] = getfreqinputs(hObj, unitcircle)
            %GETFREQINPUTS Returns the frequency response inputs
            
            narginchk(1,2);
            if nargin < 2
                unitcircle = 1;
            end
            
            % If getmaxfs returns [], one or more of the filters is normalized.  We
            % then set the maxfs to 2 (since we normalize to pi, 2 represents 2pi).
            wmax = getmaxfs(hObj);
            if isempty(wmax)
                wmax = 2*pi;
            end
            
            switch unitcircle
                case 1
                    wmin = 0;
                    wmax = wmax/2;
                case 2
                    wmin = 0;
                case 3
                    wmin = -wmax/2;
                    wmax = wmax/2;
                otherwise
                    wmin = [];
                    wmax = [];
            end
            
        end
        
        
        function a = getindex(hObj)
            %GETINDEX Returns a vector of indexes
            
            [dindx, qindx] = getfiltindx(hObj);
            
            a = [qindx; qindx];
            a = reshape(a,1,length(qindx)*2);
            a = [a dindx];
            
        end
        
        
        function [fs, xunits] = getmaxfs(h)
            %MAXFS Returns the maximum fs
            
            %   Author(s): J. Schickler
            %   Copyright 1988-2017 The MathWorks, Inc.
            
            fs = get(h, 'Fs');
            
            if iscell(fs)
                fs = max([fs{:}]);
            end
            
            if nargout > 1
                if isempty(fs)
                    xunits = 'rad/sample';
                else
                    [fs, m, xunits] = engunits(fs);
                    xunits          = [xunits 'Hz'];
                end
            end
            
        end
        
        
        function [fs, xunits] = getminfs(hObj)
            %MAXFS Returns the maximum fs
            
            fs = get(hObj, 'Fs');
            
            if iscell(fs)
                fs = min([fs{:}]);
            end
            
            if nargout > 1
                if isempty(fs)
                    xunits = 'rad/sample';
                else
                    [fs, m, xunits] = engunits(fs);
                    xunits          = [xunits 'Hz'];
                end
            end
            
        end
        
        
        function [g, w] = grpdelay(this, varargin)
            %GRPDELAY Returns the group delay for the filters
            
            if nargin > 1 && isstruct(varargin{end})
                opts = varargin{end};
                varargin(end) = [];
            else
                opts.showref  = false;
                opts.showpoly = false;
                opts.sosview  = [];
            end
            
            % If there is more than 1 filter, we ignore the sosview settings.
            if length(this) > 1 || ~isa(this(1).Filter, 'dfilt.abstractsos')
                opts.sosview = [];
            end
            
            [nfft, unitcircle] = freqzparse(this, varargin{:});
            [wmin, wmax]       = getfreqinputs(this, unitcircle);
            
            g  = {};
            w  = {};
            
            same = isfssame(this);
            
            for indx = 1:length(this)
                
                cFilt = this(indx).Filter;
                
                % If it is a polyphase filter, break it down to multiple filters.
                [cFilt,fsScaling] = breakDownPolyphase(cFilt,opts);

                
                if ~isempty(opts.sosview)
                    cFilt = getfilters(opts.sosview, cFilt);
                end
                
                % Get the current sampling frequency.  If the getmaxfs returns [], then
                % all of the filters are normalized.  When this happens we set Fs = 2*pi
                fs = get(this(indx), 'Fs');
                if isempty(fs), fs = getmaxfs(this); end
                if isempty(fs), fs = 2*pi; fsScaling = 1; end
                
                if unitcircle == 4
                    [g{end+1}, w{end+1}] = grpdelay(cFilt, nfft, fs*fsScaling);
                    if opts.showref && any(isquantized(cFilt))
                        gr = grpdelay(reffilter(cFilt), nfft, fs*fsScaling);
                        g{end} = [g{end} gr];
                    end
                    
                else
                    inputs = {nfft, same, unitcircle, fs*fsScaling, wmin*fsScaling, wmax*fsScaling};
                    [g{end+1}, w{end+1}] = getresponse2(cFilt, inputs{:});
                    if opts.showref && any(isquantized(cFilt))
                        gr = getresponse2(reffilter(cFilt), inputs{:});
                        g{end} = [g{end} gr];
                    end
                end
            end
            
        end
        
        
        function [y, t] = impz(Hd, varargin)
            %IMPZ Returns the impulse response
            
            [y, t] = timeresp(Hd, @lclimpz, varargin{:});
            
        end
        
        function s = isfssame(hObj)
            %ISFSSAME Returns true if the fs is the same for all the filters
            
            %   Author(s): J. Schickler
            %   Copyright 1988-2002 The MathWorks, Inc.
            
            allfs    = get(hObj, 'Fs');
            if ~iscell(allfs)
                s = true;
            else
                allfs = [allfs{:}];
                if isempty(allfs)
                    s = true;
                elseif any(diff(allfs))
                    s = false;
                else
                    s = true;
                end
            end
            
        end
        
        
        function [P, W] = noisepsd(this, L, opts, optsstruct)
            %NOISEPSD   Calculate the noise psd.
            
            if nargin < 4
                optsstruct.showref = true;
                optsstruct.sosview = [];
                if nargin < 3
                    opts = dspopts.spectrum;
                    opts.NFFT = 512; % NFFT default is 'Nextpow2', but here we want a numeric value.
                    if nargin < 2
                        L = 10;
                    end
                end
            end
            
            % If there is more than 1 filter, we ignore the sosview settings.
            if length(this) > 1 || ~isa(this(1).Filter, 'dfilt.abstractsos')
                optsstruct.sosview = [];
            end
            
            fs = getmaxfs(this);
            if isempty(fs)
                fs = 2*pi;
            end
            
            scaleToOneSided = false;
            if ishalfnyqinterval(opts)
                wmin = 0;
                wmax = fs/2;
                scaleToOneSided = true;
            elseif opts.CenterDC
                wmin = -fs/2;
                wmax = fs/2;
            else
                wmin = 0;
                wmax = fs;
            end
            
            % Always get the data from normalized and twosided.  COMPLETEFREQRESP will
            % take care of the rest.
            opts.SpectrumType        = 'twosided';
            opts.NormalizedFrequency = true;
            opts.CenterDC            = false;
            
            nfft = opts.NFFT;
            
            for indx = 1:length(this)
                hindx = this(indx).Filter;
                
                fs = get(this(indx), 'Fs');
                if isempty(fs), fs = getmaxfs(this); end
                if isempty(fs), fs = 2*pi;           end
                
                if ~isempty(optsstruct.sosview)
                    hindx = getfilters(optsstruct.sosview, hindx);
                end
                
                if any(isquantized(hindx)) && optsstruct.showref
                    hindx = [hindx reffilter(hindx)]; %#ok<*AGROW>
                end
                for jndx = 1:length(hindx)
                    opts.NFFT = force2even(max(4, round(nfft*fs/(wmax-wmin))));
                    Hpsd = noisepsd(hindx(jndx), L, opts);
                    P{indx}(:, jndx) = Hpsd.Data;
                end
                P{indx} = convert2db(P{indx})/2;
                
                % Complete the response for the filter from wmin to wmax based on
                % the sampling frequency of this individual filter.
                [P{indx}, W{indx}] = completefreqresp(P{indx}, fs, wmin, wmax);
                
                % Scale by 10*log10(2) if scaleToOneSided is true. The noise psd was
                % obtained using the twosided option. If onesided was specified, we
                % need to scale back.
                if scaleToOneSided
                    % Don't scale DC component
                    P{indx} = [P{indx}(1,:) ; P{indx}(2:end,:)+10*log10(2)];
                end
            end
            
            
        end
        
        
        function [p, w] = phasedelay(this, varargin)
            %PHASEDELAY Phase delay
            
            if nargin > 1 && isstruct(varargin{end})
                opts = varargin{end};
                varargin(end) = [];
            else
                opts.showref  = false;
                opts.showpoly = false;
                opts.sosview  = [];
                opts.normalizedfreq = 'off';
            end
            
            % If there is more than 1 filter, we ignore the sosview settings.
            if length(this) > 1 || ~isa(this(1).Filter, 'dfilt.abstractsos')
                opts.sosview = [];
            end
            
            [nfft, unitcircle] = freqzparse(this, varargin{:});
            [wmin, wmax]       = getfreqinputs(this, unitcircle);
            
            p  = {};
            w  = {};
            
            same = isfssame(this);
            
            for indx = 1:length(this)
                
                cFilt = this(indx).Filter;
                
                % If it is a polyphase filter, break it down to multiple filters.
                [cFilt,fsScaling] = breakDownPolyphase(cFilt,opts);
                
                if ~isempty(opts.sosview)
                    cFilt = getfilters(opts.sosview, cFilt);
                end
                
                % Get the current sampling frequency.  If the getmaxfs returns [], then
                % all of the filters are normalized.  When this happens we set Fs = 2*pi
                fs = get(this(indx), 'Fs');
                if isempty(fs), fs = getmaxfs(this); end
                if isempty(fs), fs = 2*pi; fsScaling = 1; end
                
                if unitcircle == 4
                    [p{end+1}, w{end+1}] = phasedelay(cFilt, nfft, fs*fsScaling);
                    if opts.showref && any(isquantized(cFilt))
                        pr = phasedelay(reffilter(cFilt), nfft, fs*fsScaling);
                        p{end} = [p{end} pr];
                    end
                    
                else
                    inputs = {nfft, same, unitcircle, fs*fsScaling, wmin*fsScaling, wmax*fsScaling};
                    [p{end+1}, w{end+1}] = getresponse3(cFilt, inputs{:});
                    if opts.showref && any(isquantized(cFilt))
                        pr = getresponse3(reffilter(cFilt), inputs{:});
                        p{end} = [p{end} pr];
                    end
                end
            end
            
            % To handle the case of switching x-axis between "normalized frequency" and
            % "frequency" through context menu.  When the filter is designed with a
            % sampling frequency, this sampling frequency is remembered through the
            % code and used when passing into the public phasedelay function to do the
            % calculation.  Therefore, depending on whether the option of normalized
            % frequency is on or off, we need to handle the data ourselves here.
            
            if strcmpi(opts.normalizedfreq, 'on')
                maxfs = getmaxfs(this);
                if ~isempty(maxfs)
                    for indx = 1:length(this)
                        p{indx} = p{indx}/(2*pi)*maxfs;
                    end
                end
            end
            
        end
        
        
        function [p, w] = phasez(this, varargin)
            %PHASEZ Compute the freqz
            %   PHASEZ(H, NFFT, UNITCIRCLE) Compute the freqz for NFFT number of points
            %   and a ...
            
            if nargin > 1 && isstruct(varargin{end})
                opts = varargin{end};
                varargin(end) = [];
            else
                opts.showref  = false;
                opts.showpoly = false;
                opts.sosview  = [];
            end
            
            % If there is more than 1 filter, we ignore the sosview settings.
            if length(this) > 1 || ~isa(this(1).Filter, 'dfilt.abstractsos')
                opts.sosview = [];
            end
            
            [nfft, unitcircle] = freqzparse(this, varargin{:});
            [wmin, wmax]       = getfreqinputs(this, unitcircle);
            
            p = {};
            w = {};
            
            same = isfssame(this);
            
            for indx = 1:length(this)
                
                cFilt = this(indx).Filter;
                
                % If it is a polyphase filter, break it down to multiple filters.
                [cFilt,fsScaling] = breakDownPolyphase(cFilt,opts);
                
                if ~isempty(opts.sosview)
                    cFilt = getfilters(opts.sosview, cFilt);
                end
                
                % Get the current sampling frequency.  If the getmaxfs returns [], then
                % all of the filters are normalized.  When this happens we set Fs = 2*pi
                fs = get(this(indx), 'Fs');
                if isempty(fs), fs = getmaxfs(this); end
                if isempty(fs), fs = 2*pi; fsScaling = 1; end
                
                % If unitcircle == 4, then we want to apply the nfft as frequency
                % points (not as the number of points)
                if length(nfft) > 1
                    [p{end+1}, w{end+1}] = phasez(cFilt, nfft, fs*fsScaling);
                    if opts.showref && any(isquantized(cFilt))
                        pr = phasez(reffilter(cFilt), nfft, fs*fsScaling);
                        p{end} = [p{end} pr];
                    end
                else
                    
                    inputs = {nfft, same, unitcircle, fs*fsScaling, wmin*fsScaling, wmax*fsScaling};
                    [p{end+1}, w{end+1}] = getresponse4(cFilt, inputs{:});
                    if opts.showref && any(isquantized(cFilt))
                        pr = getresponse4(reffilter(cFilt), inputs{:});
                        p{end} = [p{end} pr];
                    end
                end
            end
            
        end
        
        function setfs(Hd, fs)
            %SETFS Set the FS of the filter/filters
            
            if ~iscell(fs)
                set(Hd,'Fs',fs);
            else
                if length(fs) ~= length(Hd)
                    error(message('signal:dfilt:dfiltwfs:setfs:InvalidDimensions'));
                end
                
                for indx = 1:length(Hd)
                    set(Hd(indx), 'Fs', fs{indx});
                end
            end
            
            notify(Hd(1), 'NewFs');
            
        end
        
        function [y, t] = stepz(Hd, varargin)
            %IMPZ Returns the impulse response
            
            [y, t] = timeresp(Hd, @lclstepz, varargin{:});
            
        end
        
        
        function [y, t] = timeresp(this, fcn, varargin)
            %TIMERESP Calculates the time response
            
            w = warning('off', 'FilterDesign:Qfilt:Overflows');
            
            opts.showref  = false;
            opts.showpoly = false;
            opts.sosview  = [];
            N             = [];
            while ~isempty(varargin)
                if isstruct(varargin{1})
                    opts = varargin{1};
                    varargin(1) = [];
                elseif isnumeric(varargin{1})
                    N = varargin{1};
                    varargin(1) = [];
                else
                    error(message('signal:dfilt:dfiltwfs:timeresp:InvalidParam'));
                end
            end
            
            % If there is more than 1 filter, we ignore the sosview settings.
            if length(this) > 1 || ~isa(this(1).Filter, 'dfilt.abstractsos')
                opts.sosview = [];
            end
            
            y  = cell(1, length(this));
            t  = cell(1, length(this));
            
            % Loop over the quantized filters
            for indx = 1:length(this)
                
                fs = get(this(indx), 'Fs');
                if isempty(fs), fs = getmaxfs(this); end
                if isempty(fs), fs = [];             end
                
                if isempty(N)
                    if isempty(fs)
                        lclN = max(getimpzlength(this,opts));
                    else
                        lclN = ceil(getmaxtime(this, opts)*fs);
                    end
                else
                    lclN = N;
                end
                inputs = {lclN, fs};
                
                cFilt = this(indx).Filter;
                
                % If it is a polyphase filter, break it down to multiple filters.
                if opts.showpoly && ispolyphase(cFilt)
                    cFilt = polyphase(cFilt, 'object');
                end
                
                if ~isempty(opts.sosview)
                    cFilt = getfilters(opts.sosview, cFilt);
                end
                
                if opts.showref && any(isquantized(cFilt))
                    [yq, t{indx}] = fcn(cFilt, lclN, fs);
                    yr            = fcn(reffilter(cFilt), lclN, fs);
                    y{indx} = [yq yr];
                else
                    [y{indx}, t{indx}] = fcn(cFilt, lclN, fs);
                end
            end
            
            warning(w);
            
        end
        
        
        function [h, w, p] = zerophase(this, varargin)
            %ZEROPHASE Compute the zero-phase response
            %   ZEROPHASE(H, NFFT, UNITCIRCLE) Compute the zero-phase for NFFT number of points
            %   and a ...
            
            if nargin > 1 && isstruct(varargin{end})
                opts = varargin{end};
                varargin(end) = [];
            else
                opts.showref  = false;
                opts.showpoly = false;
                opts.sosview  = [];
            end
            
            % If there is more than 1 filter, we ignore the sosview settings.
            if length(this) > 1 || ~isa(this(1).Filter, 'dfilt.abstractsos')
                opts.sosview = [];
            end
            
            [nfft, unitcircle] = freqzparse(this, varargin{:});
            [wmin, wmax]       = getfreqinputs(this, unitcircle);
            
            h  = {};
            w  = {};
            p  = {};
            
            % Loop over the # of filters
            for indx = 1:length(this)
                fs = get(this(indx), 'Fs');
                if isempty(fs), fs = getmaxfs(this); end
                if isempty(fs), fs = 2*pi;           end
                
                cFilt = this(indx).Filter;
                
                % If it is a polyphase filter, break it down to multiple filters.
                if opts.showpoly && ispolyphase(cFilt)
                    cFilt = polyphase(cFilt, 'object');
                end
                
                %     if opts.showref && any(isquantized(cFilt))
                %         cFilt = [cFilt reffilter(cFilt)];
                %     end
                
                if ~isempty(opts.sosview)
                    cFilt = getfilters(opts.sosview, cFilt);
                end
                
                % If the length of nfft > 1, we must have a freqvec
                if length(nfft) > 1
                    
                    [h{end+1}, w{end+1}, p{end+1}] = zerophase(cFilt, nfft, fs); %#ok<*AGROW>
                    if opts.showref && any(isquantized(cFilt))
                        [hr, ~, pr] = zerophase(reffilter(cFilt), nfft, fs);
                        
                        
                        if size(nfft, 1) == 1
                            h{end} = [h{end}; hr];
                            p{end} = [p{end}; pr];
                            
                        else
                            h{end} = [h{end} hr];
                            p{end} = [p{end} pr];
                        end
                        
                        
                    end
                    
                    w{end} = nfft;
                else
                    
                    inputs = {nfft, unitcircle, fs, wmin, wmax};
                    [h{end+1}, w{end+1}, p{end+1}] = getresponse5(cFilt, inputs{:});
                    if opts.showref && any(isquantized(cFilt))
                        [hr, ~, pr] = getresponse5(reffilter(cFilt), inputs{:});
                        h{end} = [h{end} hr];
                        p{end} = [p{end} pr];
                    end
                end
            end
            
        end
        
        
        function [zall, pall, kall] = zplane(this, opts)
            %ZPLANE Returns the zeroes and poles of filters
            
            if nargin < 2
                opts.showref  = false;
                opts.showpoly = false;
                opts.sosview  = [];
            end
            
            if length(this) > 1 || ~isa(this(1).Filter, 'dfilt.abstractsos')
                opts.sosview = [];
            end
            
            zall = {};
            pall = {};
            kall = {};
            
            for indx = 1:length(this)
                cFilt = this(indx).Filter;
                if ispolyphase(cFilt) && opts.showpoly
                    cFilt = polyphase(cFilt, 'objects');
                end
                
                if ~isempty(opts.sosview)
                    cFilt = getfilters(opts.sosview, cFilt);
                end
                
                for jndx = 1:length(cFilt)
                    [z, p, k] = zplane(cFilt(jndx));
                    if iscell(z)
                        z = [z{:}];
                        z = z(:);
                        p = [p{:}];
                        p = p(:);
                    end
                    zall = {zall{:}, z};
                    pall = {pall{:}, p};
                    kall = {kall{:}, k};
                    if opts.showref && isquantized(cFilt(jndx))
                        [z, p, k] = zplane(reffilter(cFilt(jndx)));
                        if iscell(z)
                            z = [z{:}];
                            z = z(:);
                            p = [p{:}];
                            p = p(:);
                        end
                        zall{end} = [nanpad(zall{end}, length(z)) z];
                        pall{end} = [nanpad(pall{end}, length(p)) p];
                        kall{end} = [kall{end} k];
                    end
                end
            end
            
        end
        
        
    end  %% public methods
    
end  % classdef

function out = setfilter(h, out)

if ~(isa(out, 'dfilt.basefilter') || isa(out, 'dfilt.basefilterMCOS'))
    %(TODO) remove dfilt.basefilterMCOS after @dfilt package is completely
    %converted from UDD to MCOS
    error(message('signal:dfilt:dfiltwfs:schema:DFILTErr'));
end
end  % setfilter

% --------------------------------------------------------
function nfft = force2even(nfft)

if rem(nfft, 2)
    nfft = nfft+1;
end

end

% -------------------------------------------------------------------------
function [h, w] = getresponse1(Hd, nfft, same, unitcircle, fs, wmin, wmax)

nfft = max(4,round(nfft*fs/(wmax-wmin)));

% Get the response of the entire filter normalized.
h = freqz(Hd, nfft, 'whole');

if same
    
    [h, w] = fastreshape(h, fs, unitcircle, nfft);
else
    % Complete the response for the filter from wmin to wmax based on
    % the sampling frequency of this individual filter.
    [h, w] = completefreqresp(h, fs, wmin, wmax);
end

end


% -------------------------------------------------------------------------
function [g, w] = getresponse2(Hd, nfft, same, unitcircle, fs, wmin, wmax)

nfft = max(4,round(nfft*fs/(wmax-wmin)));

g = grpdelay(Hd, nfft, 'whole');

if same
    [g, w] = fastreshape(g, fs, unitcircle, nfft);
else
    [g, w] = completefreqresp(g, fs, wmin, wmax);
end

end

% -----------------------------------------------------------
function [y, t] = lclimpz(G, N, Fs)

if isempty(Fs), Fs = 1; end
[y, t] = impz(G, N, Fs);

end

% -------------------------------------------------------------------------
function [p, w] = getresponse3(Hd, nfft, same, unitcircle, fs, wmin, wmax)

nfft = max(4,round(nfft*fs/(wmax-wmin)));

p = phasedelay(Hd, nfft, 'whole', fs);

if same
    [p, w] = fastreshape(p, fs, unitcircle, nfft);
else
    [p, w] = completefreqresp(p, fs, wmin, wmax);
end

end


% -------------------------------------------------------------------------
function [p, w] = getresponse4(Hd, nfft, same, unitcircle, fs, wmin, wmax)

if unitcircle == 3
    [p, w] = phasez(Hd, linspace(wmin, wmax, nfft), fs);
else
    
    nfft = max(4,round(nfft*fs/(wmax-wmin)));
    % Get the response of the entire filter normalized.
    p = phasez(Hd, nfft, 'whole');
    
    if same
        [p, w] = fastreshape(p, fs, unitcircle, nfft);
    else
        % Complete the response for the filter from wmin to wmax based on
        % the sampling frequency of this individual filter.
        [p, w] = completefreqresp(p, fs, wmin, wmax);
    end
end

end

% -------------------------------------------
function [y, t] = lclstepz(Hd, N, Fs)

if isempty(Fs), Fs = 1; end
[y, t] = stepz(Hd, N, Fs);

end

% --------------------------------------------------------------
function len = getimpzlength(this, opts)
% For the multiple filter case, return the largest length of the
% impulse response so that we can plot that many points

G = get(this, 'Filter');
if ~iscell(G), G = {G}; end

for j = 1:length(G)
    if opts.showpoly && ispolyphase(G{j})
        G{j} = polyphase(G{j}, 'object');
    end
    len(j) = max(impzlength(G{j}));
end

end

% --------------------------------------------------------------
function time = getmaxtime(this, opts)

len = getimpzlength(this, opts);
fs  = get(this, 'Fs');
if iscell(fs)
    fs  = [fs{:}];
end

time = len./fs;
time = max(time);

end


% -------------------------------------------------------------------------
function [h, w, p] = getresponse5(Hd, nfft, ~, fs, wmin, wmax)

nfft = max(4, round(nfft*fs/(wmax-wmin)));

% Get the response of the entire filter normalized.
[h, ~, p, opts] = zerophase(Hd, nfft, 'whole');

opts.shift       = 0;
[h, w]           = completefreqresp(h, fs, wmin, wmax, opts);
opts.periodicity = 2;
opts.flip        = 0;
if iscell(p)
    tempp        = p{end}(~isnan(p));
else
    tempp        = p(~isnan(p));
end
opts.shift       = -tempp(end);
p                = completefreqresp(p, fs, wmin, wmax, opts);

end



% ------------------------------------------------------------------------
function p = nanpad(p, n)

p = [p(:); NaN(n-length(p), 1)];

end


%--------------------------------------------------------------------------

function [cFilt,fsScaling] = breakDownPolyphase(cFilt,opts)

if opts.showpoly && ispolyphase(cFilt)
    
    rcFactors = cFilt.getratechangefactors;
    cFilt = polyphase(cFilt, 'object');
    if opts.NormalizedFrequency
        fsScaling = 1;
    else        
        fsScaling = 1/rcFactors(1);        
    end
else
    fsScaling = 1;
end

end



% [EOF]
