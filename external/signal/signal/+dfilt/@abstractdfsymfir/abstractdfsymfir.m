classdef (Abstract) abstractdfsymfir < dfilt.dffir
    %ABSTRACTDFSYMFIR Abstract class
    
    %dfilt.abstractdfsymfir class
    %   dfilt.abstractdfsymfir extends dfilt.dffir.
    %
    %    dfilt.abstractdfsymfir properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       Numerator - Property is of type 'mxArray'
    %       Arithmetic - Property is of type 'filterdesign_arith enumeration: {'double','single','fixed'}'
    %
    %    dfilt.abstractdfsymfir methods:
    %       parse_coeffstoexport - Store coefficient names and values into hTar for
    
    
    
    methods(Hidden)  
        [hTar,domapcoeffstoports] = parse_coeffstoexport(Hd,hTar)
    end  
    
end  % classdef

