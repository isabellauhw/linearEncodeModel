classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) cascade < dfilt.multistage
    %CASCADE Create a cascade of discrete-time filters.
    %   Hd = CASCADE(Hd1, Hd2, etc) returns a discrete-time filter, Hd, of type
    %   cascade, which is a serial interconnection of two or more dfilt
    %   filters, Hd1, Hd2, and so on. The block diagram of this cascade looks
    %   like:
    %
    %      x ---> Hd1 ---> Hd2 ---> etc. ---> y
    %
    %   Note that with the DSP System Toolbox installed, one usually does
    %   not construct CASCADE filters explicitly. Instead, one obtains these
    %   filters as a result from a design using <a href="matlab:help fdesign">FDESIGN</a>.
    %
    %   % EXAMPLE #1: Direct instantiation
    %   Hd = dfilt.dffir([0.05 0.9 0.05]);
    %   Hgain = dfilt.scalar(2);
    %   Hcas = dfilt.cascade(Hgain,Hd)
    %   realizemdl(Hcas)    % Requires Simulink
    %
    %   % EXAMPLE #2: Design an Interpolated FIR lowpass filter
    %   Hcas = design(fdesign.lowpass('Fp,Fst,Ap,Ast',.1, .12, 1, 60), 'ifir')
    %   fvtool(Hcas)        % Analyze filter
    %   x = randn(100,1);   % Input signal
    %   y = filter(Hcas,x); % Apply filter to input signal
    %
    %   See also DFILT/STRUCTURES
    
    %dfilt.cascade class
    %   dfilt.cascade extends dfilt.multistage.
    %
    %    dfilt.cascade properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       Stage - Property is of type 'dfilt.basefilter vector'
    %
    %    dfilt.cascade methods:
    %       block - Generate a DSP System Toolbox block equivalent to the filter object.
    %       computefreqz - Compute the freqz
    %       computegrpdelay - Group delay of a discrete-time filter.
    %       computephasedelay - Phase Delay of a discrete-time filter
    %       computephasez - Phase response of a discrete-time filter.
    %       constraincoeffwlfir - Constrain coefficient wordlength.
    %       convert - Convert structure of DFILT object.
    %       createhdlfilter - CREATHDLFILTER <short description>
    %       defaulttbstimulus - returns a cell array of stimulus types.
    %       filter - Discrete-time filter.
    %       flattencascade - Remove cascades of cascades
    %       ishdlable - True if HDL can be generated for the filter object.
    %       optimizestopbandfir - Optimize stopband.
    %       preprocessCAP - - Preprocess the dfilt coupled allpass for sysobj conversion
    %       sethdl_cascade - Set the properties of hdlfiltercomp (hhdl) from the
    %       ss -  Discrete-time filter to state-space conversion.
    %       thisflatcascade - Add singletons to the flat list of filters Hflat
    %       thisimpzlength - Length of the impulse response for a digital filter.
    %       thisiscascade - ISCASCADE  True for cascaded filter.
    %       thistf -  Convert to transfer function.
    %       tosysobj - Convert to a System object
    %       zpk -  Discrete-time filter zero-pole-gain conversion.
    
    
    
    methods  % constructor block
        function Hd = cascade(varargin)
            
            if nargin == 0
                varargin = {dfilt.dffir(1),dfilt.dffir(1)};
            end
            
            Hd.FilterStructure = 'Cascade';
            
            % Check that all are dfilts before starting to set parameters.
            for k=1:length(varargin)
                if isnumeric(varargin{k})
                    g = squeeze(varargin{k});
                    if isempty(g) || length(g)>1
                        error(message('signal:dfilt:cascade:cascade:Empty'));
                    end
                    varargin{k} = dfilt.scalar(g);
                end
                % Do not attempt varargin{k}(end) for scalar varargin{k}
                % If varargin{k} is a System object, this will fail (function
                % notation)
                L = numel(varargin{k});
                if L > 1
                    v =  varargin{k}(end);
                else
                    v =  varargin{k};
                end
                
                if isfdtbxinstalled
                    if ~(isa(v,'dfilt.singleton') || ...
                            isa(v,'dfilt.multistage') || ...
                            isa(v,'dfilt.abstractfarrowfd'))
                        error(message('signal:dfilt:cascade:cascade:DFILTErr'));
                    end
                else
                    if ~(isa(v,'dfilt.singleton') || isa(v,'dfilt.multistage'))
                        error(message('signal:dfilt:cascade:cascade:DFILTErr'));
                    end
                end
            end
            
            for k=1:length(varargin)
                Hd.Stage = [Hd.Stage; varargin{k}(:)];
            end
        end  % cascade
        
    end  % constructor block
    
    methods
        varargout = block(Hd,varargin)
        Hd2 = convert(Hd,newstruct)
        y = filter(Hd,x,dim)
        [A,B,C,D] = ss(Hd)
        [z,p,k] = zpk(Hd)
        [result,errstr,errorObj] = ishdlable(Hb)
    end  % public methods
    
    methods (Hidden)
        [h,w] = computefreqz(Hd,varargin)
        [Gd,w] = computegrpdelay(Hd,varargin)
        [Phi,W] = computephasedelay(this,varargin)
        [phi,w] = computephasez(Hd,varargin)
        Hd = constraincoeffwlfir(this,Href,WL,varargin)
        hF = createhdlfilter(this)
        stimcell = defaulttbstimulus(Hb)
        msg = dgdfgen(Hd,hTar,doMapCoeffsToPorts,pos)
        c = evalcost(this)
        Hflat = flattencascade(this)
        Hbest = minimizecoeffwlfir(this,Href,varargin)
        Href = optimizecascade(this,Href,fn,varargin)
        Hd = optimizestopbandfir(this,Href,WL,varargin)
        fo = preprocessCAP(f)
        sethdl_cascade(this,hhdl)
        [NMult,NAdd,NStates,MPIS,APIS] = thiscost(this,M)
        len = thisimpzlength(Hd,varargin)
        f = thisiscascade(Hd)
        [num,den] = thistf(Hd)
        Hs = tosysobj(this,returnSysObj)
    end  % possibly private or hidden
    
    methods (Hidden, Sealed)
        Hflat = thisflatcascade(this,Hflat)
    end
    
end  % classdef

