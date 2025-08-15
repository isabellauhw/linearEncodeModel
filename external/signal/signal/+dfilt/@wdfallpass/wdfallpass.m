classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) wdfallpass < dfilt.abstractallpass
    %WDFALLPASS  Wave digital allpass filter.
    %   Hd = DFILT.WDFALLPASS(C) constructs a wave digital filter allpass
    %   structure given the allpass coefficients in vector C.%
    %
    %   C must have between one, two, or four coefficients. When C has exactly
    %   four coefficients, the first and third coefficient must be equal to
    %   zero.
    %
    %   The allpass transfer function of Hd given the coefficients in C is:
    %                           -1          -n
    %             C(n) + C(n-1)z + .... +  z
    %     H(z) = -------------------------------
    %                      -1             -n
    %             1 + C(1)z + .... + C(n)z
    %
    %   The allpass coefficients are internally converted to wave digital
    %   filters for filtering purposes. Note that only stable filters are
    %   allowed. Also notice that the leading '1' coefficient in the
    %   denominator is not part of C.
    %
    %   It is possible to construct a cascade of these filters using
    %   DFILT.CASCADEWDFALLPASS. See the help for that filter structure for
    %   more information.
    %
    %   DFILT.WDFALLPASS and DFILT.CASCADEWDFALLPASS have the same number of
    %   multipliers than DFILT.ALLPASS and DFITL.CASCADEALLPASS respectively.
    %   However they contain fewer states. On the other hand, they require more
    %   adders.
    %
    %   Example: Construct a second-order wave digital allpass filter
    %   C = [1.5,0.7];
    %   Hd = dfilt.wdfallpass(C);
    %   info(Hd)
    %   realizemdl(Hd) % Requires Simulink; build model for filter
    %
    %   See also DFILT/STRUCTURES
    
    %dfilt.wdfallpass class
    %   dfilt.wdfallpass extends dfilt.abstractallpass.
    %
    %    dfilt.wdfallpass properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       AllpassCoefficients - Property is of type 'mxArray'
    %
    %    dfilt.wdfallpass methods:
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       nmult - Returns the number of multipliers
    %       secfilter - Filter this section.
    %       validate_coeffs -   Validate the coeffs
    
    
    
    methods  % constructor block
        function this = wdfallpass(c)
            
            this.privfq = dfilt.filterquantizer;
            this.privfilterquantizer = dfilt.filterquantizer;
            this.FilterStructure = 'Wave Digital Filter Allpass';
            this.AllpassCoefficients = [];
            if nargin > 0
                if ~isreal(c)
                    error(message('signal:dfilt:wdfallpass:wdfallpass:complexCoeffs'));
                end
                this.AllpassCoefficients = c;
            end
            
            
        end  % wdfallpass
        
    end  % constructor block
    
    methods (Hidden) % possibly private or hidden
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        [out,coeffnames,variables] = mapcoeffstoports(this,varargin)
        N = nadd(this)
        n = nmult(this,optimones,optimnegones)
        [y,zf] = secfilter(Hd,x,zi)
        n = thisnstates(this)
        varargout = validate_coeffs(this,coeffs)
        c = wdfcoefficients(this,coeffs)
    end  % possibly private or hidden
    
end  % classdef

