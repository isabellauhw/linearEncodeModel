classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) parallel < dfilt.multistage
    %PARALLEL Create a parallel system of discrete-time filter objects.
    %   Hd = PARALLEL(Hd1, Hd2, etc) constructs a parallel system of the filter
    %   objects Hd1, Hd2, etc.  The block diagram looks like:
    %
    %           |->  Hd1 ->|
    %           |          |
    %      x ---|->  Hd2 ->|--> y
    %           |          |
    %           |-> etc. ->|
    %
    %   The filters Hd1, Hd2, ... must be operating either in double-precision
    %   floating-point or single-precision floating-point.
    %
    %   Hd1, Hd2, ... must be either single-rate filters or multirate filters
    %   in which case the rate change of each stage in the parallel structure
    %   must be the same. Note that multirate filters require the DSP System
    %   Toolbox.
    %
    %   Hd1, Hd2, ... can also be parallel or cascade filters themselves.
    %
    %   % EXAMPLE:
    %   k1 = [-0.0154    0.9846   -0.3048    0.5601];
    %   Hd1 = dfilt.latticeallpass(k1);
    %   k2 = [-0.1294    0.8341   -0.4165];
    %   Hd2 = dfilt.latticeallpass(k2);
    %   Hpar = parallel(Hd1 ,Hd2);
    %   x = randn(100,1); % Create a random input signal
    %   y = filter(Hpar,x);
    %   realizemdl(Hpar)    % Requires Simulink
    %
    %   See also DFILT/STRUCTURES
    
    %dfilt.parallel class
    %   dfilt.parallel extends dfilt.multistage.
    %
    %    dfilt.parallel properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       Stage - Property is of type 'dfilt.basefilter vector'
    %
    %    dfilt.parallel methods:
    %       block - Generate a DSP System Toolbox block equivalent to the filter object.
    %       checkvalidparallel -   Check if parallel is valid and error if not.
    %       computefreqz -  Discrete-time filter frequency response.
    %       computephasedelay - Phase Delay of a discrete-time filter
    %       convert - Convert structure of DFILT object.
    %       filter - Discrete-time filter.
    %       getratechangefactors -   Get the ratechangefactors.
    %       isvalidparallel -   True if the object is validparallel.
    %       nadd - Returns the number of adders
    %       thisisparallel -  True for filter with parallel stages.
    %       thistf -  Convert to transfer function.
    %       zpk -  Discrete-time filter zero-pole-gain conversion.
    
    
    
    methods (Hidden)  % constructor block
        function Hd = parallel(varargin)
            
            if nargin == 0
                varargin = {dfilt.dffir(1),dfilt.dffir(1)};
            end
            
            
            Hd.FilterStructure = 'Parallel';
            
            % Check that all are dfilts before starting to set parameters.
            for k=1:length(varargin)
                if isnumeric(varargin{k})
                    varargin{k} = dfilt.scalar(varargin{k});
                end
                if ~(isa(varargin{k}(end),'dfilt.abstractfilter') || isa(varargin{k}(end),'dfilt.multistage'))
                    error(message('signal:dfilt:parallel:parallel:DFILTErr'));
                end
            end
            
            for k=1:length(varargin)
                Hd.Stage = [Hd.Stage; varargin{k}(:)];
            end
            
            checkvalidparallel(Hd);
            
        end  % parallel
    end  % constructor block
    
    methods  % public methods
        varargout = block(Hd,varargin)
        Hd2 = convert(Hd,newstruct)
        y = filter(Hd,x,dim)
        [A,B,C,D] = ss(Hd)
        [z,p,k] = zpk(Hd)
    end  % public methods
    
    
    methods (Hidden) % possibly private or hidden
        checkvalidparallel(this)
        [h,w] = computefreqz(Hd,varargin)
        [G,w] = computegrpdelay(Hd,varargin)
        [Phi,W] = computephasedelay(this,varargin)
        msg = dgdfgen(Hd,hTar,doMapCoeffsToPorts,pos)
        c = evalcost(this)
        rcf = getratechangefactors(this)
        b = isvalidparallel(this)
        n = nadd(this)
        f = thisisparallel(Hd)
        [num,den] = thistf(Hd)
    end  % possibly private or hidden
    
end  % classdef

