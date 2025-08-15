classdef (Abstract) coupledallpass < dfilt.singleton
    %COUPLEDALLPASS Coupled-allpass filter virtual class.
    %   COUPLEDALLPASS is a virtual class---it is never intended to be instantiated.

    
    %dfilt.coupledallpass class
    %   dfilt.coupledallpass extends dfilt.singleton.
    %
    %    dfilt.coupledallpass properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %
    %    dfilt.coupledallpass methods:
    %       doFrameProcessing - Returns true if frame processing if supported by realizemdl()
    %       iscoupledallpass - True if the structure is coupled all pass
    %       nadd - Returns the number of adders
    %       parse_filterstates - Store filter states in hTar for realizemdl
    %       realizemdl - Filter realization (Simulink diagram).
    %       thisisrealizable - True if the structure can be realized by simulink
    %       tocalattice -   Convert to the non-pc calattice.
    %       tocalatticepc -   Convert to the pc calattice.
    
    methods
        realizemdl(H,varargin)
    end  % public methods
      
    methods (Hidden)
        [targs,strs] = convertchoices(this)
        msg = dgdfgen(Hd,hTar,doMapCoeffsToPorts,pos)
        flag = doFrameProcessing(~)
        b = iscoupledallpass(~)
        logi = isparallelfilterable(this)
        [f,offset] = multfactor(this)
        n = nadd(this)
        s = objblockparams(this,varname)
        hTar = parse_filterstates(Hd,hTar)
        f = thisisrealizable(Hd)
        Hd = tocalattice(this)
        Hd = tocalatticepc(this)
    end  % possibly private or hidden
    
end  % classdef

