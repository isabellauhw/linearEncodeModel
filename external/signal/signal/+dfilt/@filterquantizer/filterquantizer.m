classdef (CaseInsensitiveProperties=true) filterquantizer < matlab.mixin.SetGet & matlab.mixin.Heterogeneous & handle & dynamicprops
%FILTERQUANTIZER Abstract class
    
%dfilt.filterquantizer class
%    dfilt.filterquantizer properties:
%
%    dfilt.filterquantizer methods:
%       allpassdgdfgen -  DGDF = allpassdggen(q, Hd) generate dgdf structure for 1st, 2nd
%       blockparams -   Return the parameters for the block.
%       cascadeallpassdggen - q, Hd) generate dgdf structure for 1st, 2nd
%       conv2sltype - Returns SLTYPE for the given DFILT's quantizer
%       delaydggen - Directed Graph generator for Delay
%       delayfilter -  DELAY Filter for DFILT.DELAY class in double single and fixed point 
%       delayheadconnect - specifies connection and quantization parameters in the
%       demux -  Directed Graph generator for demux
%       df1bodyconnect - specifies the connection and quantization parameters in the
%       df1dggen - Directed Graph generator for Direct Form I (DF-I)
%       df1footconnect - specifies the connection and quantization parameters in the
%       df1headconnect - specifies the blocks, connection and quantization parameters in the
%       df1header_order0 - specifies the blocks, connection and quantization parameters in the
%       df1sosbodyconnect - specifies the connection and quantization parameters in the
%       df1sosdggen - Directed Graph generator for Direct Form I (DF-I) Second
%       df1sosfilter - Filter for DFILT.DF1SOS class in double precision mode
%       df1sosfootconnect - specifies the connection and quantization parameters in the
%       df1sosheadconnect - specifies the blocks, connection and quantization parameters in the
%       df1sosheader_order0 - specifies the blocks, connection and quantization parameters in the
%       df1tbodyconnect - specifies the connection and quantization parameters in the
%       df1tdggen - DF2TDGGEN Directed Graph generator for Direct Form I (DF-I) Transpose
%       df1tfilter - Filter for DFILT.DF1T class in double precision mode
%       df1tfootconnect - specifies the connection and quantization parameters in the
%       df1theadconnect - specifies the blocks, connection and quantization parameters in the
%       df1theader_order0 - specifies the blocks, connection and quantization parameters in the
%       df1tsosbodyconnect - specifies the connection and quantization parameters in the
%       df1tsosdggen - DF2TSOSDGGEN Directed Graph generator for Direct Form I (DF-I) Transpose Second
%       df1tsosfilter - Filter for DFILT.DF1TSOS class in double precision mode
%       df1tsosfootconnect - specifies the connection and quantization parameters in the
%       df1tsosheadconnect - specifies the blocks, connection and quantization parameters in the
%       df1tsosheader_order0 - specifies the blocks, connection and quantization parameters in the
%       df2bodyconnect - specifies the connection and quantization parameters in the
%       df2dggen - Directed Graph generator for Direct Form II (DF-II)
%       df2filter - Filter for DFILT.DF2 class in double precision mode
%       df2footconnect - specifies the connection and quantization parameters in the
%       df2headconnect - specifies the blocks, connection and quantization parameters in the
%       df2header_order0 - specifies the blocks, connection and quantization parameters in the
%       df2sosbodyconnect - specifies the connection and quantization parameters in the
%       df2sosdggen - Directed Graph generator for Direct Form II (DF-II) Second
%       df2sosfilter - Filter for DFILT.DF2SOS class in double precision mode
%       df2sosfootconnect - specifies the connection and quantization parameters in the
%       df2sosheadconnect - specifies connection and quantization parameters in the
%       df2sosheader_order0 - specifies the blocks, connection and quantization parameters in the
%       df2tbodyconnect - specifies the connection and quantization parameters in the
%       df2tdggen - Directed Graph generator for Direct Form II (DF-II) Transpose
%       df2tfilter - Filter for DFILT.DF2T class in double precision mode
%       df2tfootconnect - specifies the connection and quantization parameters in the
%       df2theadconnect - specifies connection and quantization parameters in the
%       df2theader_order0 - specifies the blocks, connection and quantization parameters in the
%       df2tsosbodyconnect - specifies the connection and quantization parameters in the
%       df2tsosdggen - Directed Graph generator for Direct Form II (DF-II) Transpose Second
%       df2tsosfilter - Filter for DFILT.DF2TSOS class in double precision mode
%       df2tsosfootconnect - specifies the connection and quantization parameters in the
%       df2tsosheadconnect - specifies the blocks, connection and quantization parameters in the
%       df2tsosheader_order0 - specifies the blocks, connection and quantization parameters in the
%       dfantisymmetricfirfilter - Filter for DFILT.DFASYMFIR class in double precision mode
%       dfasymfirbodyconnect - specifies the connection and quantization parameters in the
%       dfasymfirdggen - Directed Graph generator for Discrete FIR Asymmetric
%       dfasymfirfootconnect - specifies the connection and quantization parameters in the
%       dfasymfirheadconnect - specifies connection and quantization parameters in the
%       dfasymfirheader_order0 - specifies the blocks, connection and quantization parameters in the
%       dffirbodyconnect - specifies the connection and quantization parameters in the
%       dffirdggen - Directed Graph generator for Discrete FIR
%       dffirfootconnect - specifies the connection and quantization parameters in the
%       dffirheadconnect - specifies connection and quantization parameters in the
%       dffirheader_order0 - specifies the blocks, connection and quantization parameters in the
%       dffirtbodyconnect - specifies the connection and quantization parameters in the
%       dffirtdggen - Directed Graph generator for Discrete FIR Transpose
%       dffirtfootconnect - specifies the connection and quantization parameters in the
%       dffirtheadconnect - specifies the blocks, connection and quantization parameters in the
%       dffirtheader_order0 - specifies the blocks, connection and quantization parameters in the
%       dfsymfirbodyconnect - specifies the connection and quantization parameters in the
%       dfsymfirdggen - Directed Graph generator for Discrete FIR Symmetric
%       dfsymfirfootconnect - specifies the connection and quantization parameters in the
%       dfsymfirheadconnect - specifies connection and quantization parameters in the
%       dfsymfirheader_order0 - specifies the blocks, connection and quantization parameters in the
%       dfsymmetricfirfilter - Filter for DFILT.DFSYMFIR class in double precision mode
%       disp - Object display.
%       dispstr -   Convert the coefficients to the display
%       farrowsrcdggen - Directed Graph generator for farrowsrc multirate filter.
%       farrowsrcfilter - Filter implementation for MFILT.FARROWSRC
%       farrowsrcoutputconnect - <short description>
%       fddggen - Directed Graph generator farrow.fd
%       fftfirfilter - Filter this section.
%       firdecimdggen - FIRDECIM Directed Graph generator for Firdecim multirate filter
%       firinterpdggen - FIRINTERP Directed Graph generator for Firinterp multirate filter
%       firinterpfilter -   Filtering method for fir interpolator.
%       firsrcdggen - Directed Graph generator for firsrc multirate filter.
%       firsrcfilter - FIRINTERPFILTER   Filtering method for fir interpolator.
%       firtdecimdggen - FIRTDECIM Directed Graph generator for Firtdecim multirate filter
%       genmcode -   Generate MATLAB code.
%       getarithmetic - Get the arithmetic.
%       getautoscalefl -   Get the autoscalefl.
%       getbestprecision - Return best precision for Product and Accumulator
%       getdenominator - GetFunction for the Denominator property.
%       internalsettings - Returns the fixed-point settings viewed by the algorithm.  
%       isloggingon -   True if the filter logging is on.
%       latticeallpassbodyconnect - specifies the connection and quantization parameters in the
%       latticeallpassdggen - Directed Graph generator for Discrete all pass
%       latticeallpassfilter - Filter for DFILT.LATTICEALLPASS class in double precision mode
%       latticeallpassfootconnect - specifies the connection and quantization parameters in the
%       latticeallpassheadconnect - specifies the connection and quantization parameters in the
%       latticeallpassheader_order0 - specifies the blocks, connection and quantization parameters in the
%       latticearbodyconnect - specifies the connection and quantization parameters in the
%       latticeardggen - Directed Graph generator for Discrete AR
%       latticearfilter - Filter for DFILT.LATTICEAR class in double precision mode
%       latticearfootconnect - specifies the connection and quantization parameters in the
%       latticearheadconnect - specifies the connection and quantization parameters in the
%       latticearheader_order0 - specifies the blocks, connection and quantization parameters in the
%       latticearmabodyconnect - specifies the connection and quantization parameters in the
%       latticearmadggen - Directed Graph generator for Discrete AR
%       latticearmafilter - Filter for DFILT.LATTICEARMA class in double precision mode
%       latticearmafootconnect - specifies the connection and quantization parameters in the
%       latticearmaheadconnect - specifies connection and quantization parameters in the
%       latticearmaheader_order0 - specifies the blocks, connection and quantization parameters in the
%       latticecafilter - Filter for DFILT.CALATTICE class in double precision mode
%       latticecapcfilter - Filter for DFILT.CALATTICEPC class in double precision mode
%       latticeempty - specifies a filter with empty lattice.  It passes the input
%       latticemamaxbodyconnect - specifies the connection and quantization parameters in the
%       latticemamaxdggen - Directed Graph generator for Discrete MA Maximum Phase
%       latticemamaxfilter - Filter for DFILT.LATTICEMAMAX class in double precision mode
%       latticemamaxfootconnect - specifies the connection and quantization parameters in the
%       latticemamaxheadconnect - specifies connection and quantization parameters in the
%       latticemamaxheader_order0 - specifies the blocks, connection and quantization parameters in the
%       latticemaminbodyconnect - specifies the connection and quantization parameters in the
%       latticemamindggen - Directed Graph generator for Discrete MA Minimum Phase
%       latticemaminfilter - Filter for DFILT.LATTICEMAMIN class in double precision mode
%       latticemaminfootconnect - specifies the connection and quantization parameters in the
%       latticemaminheadconnect - specifies connection and quantization parameters in the
%       latticemaminheader_order0 - specifies the blocks, connection and quantization parameters in the
%       linearfddggen -   Directed Graph generator for FARROW.LINEARFD
%       matrixdemux - Directed Graph generator for matrix demux
%       propstoadd -  Quantize coefficients
%       quantizeacc - Quantize the PolyphaseAccum   
%       quantizecoeffs -  Quantize coefficients
%       scalarblockparams -   Return the parameters for the scalar block.
%       scalardggen - Directed Graph generator for Discrete FIR
%       scalarfilter - Filter for DFILT.SCALAR class in double precision mode
%       scalarheader - specifies the blocks, connection and quantization parameters in the
%       set_ncoeffs -   Set function for the 'ncoeffs' property.
%       set_nphases -   Set function for the 'nphases' property.
%       setdefaultcoeffwl - Set the default coefficient word length
%       setmaxprod -   Set the maxprod.
%       setmaxsum -   Set the maxsum.
%       statespacebodyconnect - specifies the connection and quantization parameters in the
%       statespacedggen - Directed Graph generator for State Space Structure
%       statespacefilter - Filter for DFILT.STATESPACE class in double precision mode
%       statespacefootconnect - specifies the connection and quantization parameters in the
%       statespaceheadconnect - STATESPACETHEADCONNECT specifies connection and quantization parameters in the
%       statespaceheader_order0 - specifies the blocks, connection and quantization parameters in the
%       svnoteq2one - Test if Scale values should be treated as wires
%       wdfallpassdggen - q, Hd) generate dgdf structure for 1st, 2nd


properties (Access=protected, SetObservable, GetObservable)
    %NCOEFFS Property is of type 'mxArray' 
    ncoeffs = 1;
    %NPHASES Property is of type 'mxArray' 
    nphases = 1;
end

properties (SetAccess=protected, SetObservable, GetObservable, Hidden)
    %LOGGINGREPORT Property is of type 'mxArray'  (hidden)
    loggingreport = [];
end


events 
    QuantizeCoeffs
    QuantizeStates
    QuantizeAcc
    QuantizeFracDelay
    UpdateInternals
    adddynprop
end  % events

    methods  % constructor block
        function q = filterquantizer
        
        %   Author(s): R. Losada
        
        end  % filterquantizer
        
    end  % constructor block

    methods 
    end   % set and get functions 

    methods  % public methods
    DGDF = allpassdgdfgen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    b = blockparams(~,~,varargin)
    DGDF = cascadeallpassdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    sltype = conv2sltype(this,varargin)
    DGDF = delaydggen(q,Hd,states)
    [y,zf] = delayfilter(q,b,x,zi)
    [NL,NextIPorts,NextOPorts,mainparams] = delayheadconnect(q,NL,H,mainparams)
    Demux = demux(q,H,nports,gototag)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = df1bodyconnect(q,NL,H,mainparams)
    DGDF = df1dggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [NL,PrevIPorts,PrevOPorts,mainparams] = df1footconnect(q,NL,H,mainparams)
    [NL,NextIPorts,NextOPorts,mainparams] = df1headconnect(q,NL,H,mainparams)
    Head = df1header_order0(q,num,den,H,info)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = df1sosbodyconnect(q,NL,H,mainparams)
    DGDF = df1sosdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [y,zf] = df1sosfilter(q,num,den,sv,issvnoteq2one,x,zi)
    [NL,PrevIPorts,PrevOPorts,mainparams] = df1sosfootconnect(q,NL,H,mainparams)
    [NL,NextIPorts,NextOPorts,mainparams] = df1sosheadconnect(q,NL,H,mainparams)
    Head = df1sosheader_order0(q,sosMatrix,scaleValues,H,info)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = df1tbodyconnect(q,NL,H,mainparams)
    DGDF = df1tdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [y,zfNum,zfDen] = df1tfilter(q,b,a,x,ziNum,ziDen)
    [NL,PrevIPorts,PrevOPorts,mainparams] = df1tfootconnect(q,NL,H,mainparams)
    [NL,NextIPorts,NextOPorts,mainparams] = df1theadconnect(q,NL,H,mainparams)
    Head = df1theader_order0(q,num,den,H,info)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = df1tsosbodyconnect(q,NL,H,mainparams)
    DGDF = df1tsosdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [y,zf] = df1tsosfilter(q,num,den,sv,issvnoteq2one,x,zi)
    [NL,PrevIPorts,PrevOPorts,mainparams] = df1tsosfootconnect(q,NL,H,mainparams)
    [NL,NextIPorts,NextOPorts,mainparams] = df1tsosheadconnect(q,NL,H,mainparams)
    Head = df1tsosheader_order0(q,sosMatrix,scaleValues,H,info)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = df2bodyconnect(q,NL,H,mainparams)
    DGDF = df2dggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [y,zf,tapidxf] = df2filter(q,b,a,x,zi,tapidxi)
    [NL,PrevIPorts,PrevOPorts,mainparams] = df2footconnect(q,NL,H,mainparams)
    [NL,NextIPorts,NextOPorts,mainparams] = df2headconnect(q,NL,H,mainparams)
    Head = df2header_order0(q,num,den,H,info)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = df2sosbodyconnect(q,NL,H,mainparams)
    DGDF = df2sosdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [y,zf] = df2sosfilter(q,num,den,sv,issvnoteq2one,x,zi)
    [NL,PrevIPorts,PrevOPorts,mainparams] = df2sosfootconnect(q,NL,H,mainparams)
    [NL,NextIPorts,NextOPorts,mainparams] = df2sosheadconnect(q,NL,H,mainparams)
    Head = df2sosheader_order0(q,sosMatrix,scaleValues,H,info)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = df2tbodyconnect(q,NL,H,mainparams)
    DGDF = df2tdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [y,zf] = df2tfilter(q,b,a,x,zi)
    [NL,PrevIPorts,PrevOPorts,mainparams] = df2tfootconnect(q,NL,H,mainparams)
    [NL,NextIPorts,NextOPorts,mainparams] = df2theadconnect(q,NL,H,mainparams)
    Head = df2theader_order0(q,num,den,H,info)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = df2tsosbodyconnect(q,NL,H,mainparams)
    DGDF = df2tsosdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [y,zf] = df2tsosfilter(q,num,den,sv,issvnoteq2one,x,zi)
    [NL,PrevIPorts,PrevOPorts,mainparams] = df2tsosfootconnect(q,NL,H,mainparams)
    [NL,NextIPorts,NextOPorts,mainparams] = df2tsosheadconnect(q,NL,H,mainparams)
    Head = df2tsosheader_order0(q,sosMatrix,scaleValues,H,info)
    [y,zf,tapIndex] = dfantisymmetricfirfilter(q,b,x,zi,tapIndex)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = dfasymfirbodyconnect(q,NL,H,mainparams)
    DGDF = dfasymfirdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [NL,PrevIPorts,PrevOPorts,mainparams] = dfasymfirfootconnect(q,NL,H,mainparams,info)
    [NL,NextIPorts,NextOPorts,mainparams] = dfasymfirheadconnect(q,NL,H,mainparams)
    Head = dfasymfirheader_order0(q,num,H,info)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = dffirbodyconnect(q,NL,H,mainparams)
    DGDF = dffirdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [NL,PrevIPorts,PrevOPorts,mainparams] = dffirfootconnect(q,NL,H,mainparams)
    [NL,NextIPorts,NextOPorts,mainparams] = dffirheadconnect(q,NL,H,mainparams)
    Head = dffirheader_order0(q,num,H,info)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = dffirtbodyconnect(q,NL,H,mainparams)
    DGDF = dffirtdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [NL,PrevIPorts,PrevOPorts,mainparams] = dffirtfootconnect(q,NL,H,mainparams)
    [NL,NextIPorts,NextOPorts,mainparams] = dffirtheadconnect(q,NL,H,mainparams)
    Head = dffirtheader_order0(q,num,H,info)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = dfsymfirbodyconnect(q,NL,H,mainparams)
    DGDF = dfsymfirdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [NL,PrevIPorts,PrevOPorts,mainparams] = dfsymfirfootconnect(q,NL,H,mainparams,info)
    [NL,NextIPorts,NextOPorts,mainparams] = dfsymfirheadconnect(q,NL,H,mainparams)
    Head = dfsymfirheader_order0(q,num,H,info)
    [y,zf,tapIndex] = dfsymmetricfirfilter(q,b,x,zi,tapIndex)
    disp(this,spacing)
    varargout = dispstr(this,varargin)
    DGDF = farrowsrcdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [y,z,Tnext] = farrowsrcfilter(this,C,x,L,M,z,Tnext)
    [NL,PrevIPorts,PrevOPorts,mainparams] = farrowsrcoutputconnect(q,NL,H,mainparams,numinputs)
    DGDF = fddggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [y,z] = fftfirfilter(q,Hd,bfft,x,z)
    DGDF = firdecimdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    DGDF = firinterpdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [y,z,tapidx] = firinterpfilter(q,L,p,x,z,tapidx,nx,nchans,ny)
    DGDF = firsrcdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [y,z,tapidx] = firsrcfilter(q,L,M,p,x,z,tapidx,im,inOffset,Mx,Nx,My)
    DGDF = firtdecimdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    h = genmcode(this)
    a = getarithmetic(this)
    fl = getautoscalefl(this,s,signed,wl)
    s = getbestprecision(q)
    den = getdenominator(Hd,den)
    s = internalsettings(h)
    b = isloggingon(this)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = latticeallpassbodyconnect(q,NL,H,mainparams)
    DGDF = latticeallpassdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [y,zf] = latticeallpassfilter(q,k,kconj,x,zi)
    [NL,PrevIPorts,PrevOPorts,mainparams] = latticeallpassfootconnect(q,NL,H,mainparams)
    [NL,NextIPorts,NextOPorts,mainparams] = latticeallpassheadconnect(q,NL,H,mainparams)
    Head = latticeallpassheader_order0(q,num,H,info)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = latticearbodyconnect(q,NL,H,mainparams)
    DGDF = latticeardggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [y,zf] = latticearfilter(q,k,kconj,x,zi)
    [NL,PrevIPorts,PrevOPorts,mainparams] = latticearfootconnect(q,NL,H,mainparams)
    [NL,NextIPorts,NextOPorts,mainparams] = latticearheadconnect(q,NL,H,mainparams)
    Head = latticearheader_order0(q,num,H,info)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = latticearmabodyconnect(q,NL,H,mainparams)
    DGDF = latticearmadggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [y,zf] = latticearmafilter(q,k,kconj,ladder,x,zi)
    [NL,PrevIPorts,PrevOPorts,mainparams] = latticearmafootconnect(q,NL,H,mainparams)
    [NL,NextIPorts,NextOPorts,mainparams] = latticearmaheadconnect(q,NL,H,mainparams)
    Head = latticearmaheader_order0(q,num,den,H,info)
    [y,zf] = latticecafilter(q,Hd,x,zi)
    [y,zf] = latticecapcfilter(q,Hd,x,zi)
    Head = latticeempty(q,num,H,info)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = latticemamaxbodyconnect(q,NL,H,mainparams)
    DGDF = latticemamaxdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [y,zf] = latticemamaxfilter(q,k,kconj,x,zi)
    [NL,PrevIPorts,PrevOPorts,mainparams] = latticemamaxfootconnect(q,NL,H,mainparams)
    [NL,NextIPorts,NextOPorts,mainparams] = latticemamaxheadconnect(q,NL,H,mainparams)
    Head = latticemamaxheader_order0(q,num,H,info)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = latticemaminbodyconnect(q,NL,H,mainparams)
    DGDF = latticemamindggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [y,zf] = latticemaminfilter(q,k,kconj,x,zi)
    [NL,PrevIPorts,PrevOPorts,mainparams] = latticemaminfootconnect(q,NL,H,mainparams)
    [NL,NextIPorts,NextOPorts,mainparams] = latticemaminheadconnect(q,NL,H,mainparams)
    Head = latticemaminheader_order0(q,num,H,info)
    DGDF = linearfddggen(this,Hd,states)
    Demux = matrixdemux(q,H,nstages,norder,roworcol,lbl)
    p = propstoadd(q)
    S = quantizeacc(q,S)
    varargout = quantizecoeffs(q,varargin)
    p = scalarblockparams(this)
    DGDF = scalardggen(q,Hd,coeffnames,doMapCoeffsToPorts)
    [y,zf] = scalarfilter(q,b,x,zi)
    Head = scalarheader(q,num,H,info)
    set_ncoeffs(q,ncoeffs)
    set_nphases(q,nphases)
    setdefaultcoeffwl(this,filtobj)
    setmaxprod(this,Hd)
    setmaxsum(this,Hd)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = statespacebodyconnect(q,NL,H,mainparams)
    DGDF = statespacedggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
    [y,zf] = statespacefilter(q,Hd,x,zi)
    [NL,PrevIPorts,PrevOPorts,mainparams] = statespacefootconnect(q,NL,H,mainparams)
    [NL,NextIPorts,NextOPorts,mainparams] = statespaceheadconnect(q,NL,H,mainparams)
    Head = statespaceheader_order0(q,Dmat,H,info)
    isnoteq2one = svnoteq2one(q,refsvq)
    DGDF = wdfallpassdggen(q,Hd,coeffnames,doMapCoeffsToPorts,states)
end  % public methods 


    methods (Hidden) % possibly private or hidden
    [y,zf] = allpassfilter(this,a,x,zi)
    Hcopy = copy(this)
    [y,zfNum,zfDen,nBPtrf,dBPtrf] = df1filter(q,b,a,x,ziNum,ziDen,nBPtr,dBPtr)
    [y,zf,tapIndex] = dffirfilter(q,b,x,zi,tapIndex)
    [y,zf] = dffirtfilter(q,b,x,zi)
    [y,z] = farrowfdfilter(this,C,x,d,z)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = farrowsrcbodyconnect(q,NL,H,mainparams,interp_order)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = farrowsrcfootconnect(q,NL,H,mainparams,interp_order)
    [NL,NextIPorts,NextOPorts,mainparams] = farrowsrcheadconnect(q,NL,H,mainparams,interp_order,flag)
    Outp = farrowsrcoutputer(q,nphases,H,interp_order,decim_order,info)
    p = fddggenqparam(this)
    Outp = fdfarrowoutputer(q,nphases,H,info)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = firdecimbodyconnect(q,NL,H,mainparams,decim_order)
    [y,zf,acc,phaseidx,tapidx] = firdecimfilter(q,M,p,x,zi,acc,phaseidx,tapidx,nx,nchans,ny)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = firdecimfootconnect(q,NL,H,mainparams,decim_order)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = firdecimheadconnect(q,NL,H,mainparams,decim_order)
    Head = firdecimheader_order0(q,num,decim_order,H,info)
    [NL,NextIPorts,NextOPorts,mainparams] = firdeciminputconnect(q,NL,H,mainparams,decim_order)
    [NL,PrevIPorts,PrevOPorts,mainparams] = firdecimoutputconnect(q,NL,H,mainparams,decim_order)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = firinterpbodyconnect(q,NL,H,mainparams,interp_order)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = firinterpfootconnect(q,NL,H,mainparams,interp_order)
    [NL,NextIPorts,NextOPorts,mainparams] = firinterpheadconnect(q,NL,H,mainparams,interp_order)
    Head = firinterpheader_order0(q,num,interp_order,H,info)
    [NL,PrevIPorts,PrevOPorts,mainparams] = firinterpoutputconnect(q,NL,H,mainparams,interp_order)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = firsrcbodyconnect(q,NL,H,mainparams,interp_order)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = firsrcfootconnect(q,NL,H,mainparams,interp_order)
    [NL,NextIPorts,NextOPorts,mainparams] = firsrcheadconnect(q,NL,H,mainparams,interp_order,flag)
    [NL,PrevIPorts,PrevOPorts,mainparams] = firsrcoutputconnect(q,NL,H,mainparams,interp_order)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = firtdecimbodyconnect(q,NL,H,mainparams,decim_order)
    [y,zf,acc,phaseidx] = firtdecimfilter(q,M,p,x,zi,acc,phaseidx,nx,nchans,ny)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = firtdecimfootconnect(q,NL,H,mainparams,decim_order)
    [NL,PrevIPorts,PrevOPorts,NextIPorts,NextOPorts,mainparams] = firtdecimheadconnect(q,NL,H,mainparams,decim_order)
    Head = firtdecimheader_order0(q,num,decim_order,H,info)
    [NL,NextIPorts,NextOPorts,mainparams] = firtdeciminputconnect(q,NL,H,mainparams,decim_order)
    [NL,PrevIPorts,PrevOPorts,mainparams] = firtdecimoutputconnect(q,NL,H,mainparams,decim_order)
    num = getnumerator(Hd,num)
    sosm = getsosmatrix(q,num,den)
    y = holdinterpfilter(this,L,x,ny,nchans)
    [p,v] = info(this)
    logi = isparallelfilterable(this)
    [y,z] = linearfdfilter(this,x,d,z)
    Pnn = nlminputcomp(this,Hf,M,Pnn)
    [vp,Vp] = nlmrescaleinput(this,vp,Vp)
    S = nulldenstate(q)
    S = nullnumstate(q)
    S = nullstate1(q)
    S = nullstate2(q)
    S = prependzero(q,S)
    delay = quantizefd(this,delay)
    x = quantizeinput(this,x)
    S = quantizestates(q,S)
    scaleopts(this,Hd,opts)
    send_adddynprop(q,dynprops)
    send_quantizecoeffs(q,eventData)
    send_quantizestates(q,eventData)
    specifyall(this,flag)
    this = update(this)
    updateinternalsettings(h)
    S = validateacc(q,S)
    validaterefcoeffs(~,prop,val)
    S = validatestates(q,S)
    S = validatestatesobj(q,S)
    [y,zf] = wdfallpassfilter(this,c,x,zi)
end  % possibly private or hidden 

methods (Static) % static methods
        this = loadobj(s)
    end  % static methods
    

end  % classdef

