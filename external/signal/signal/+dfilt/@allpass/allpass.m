classdef (CaseInsensitiveProperties=true,TruncatedProperties = true) allpass < dfilt.abstractallpass
    %ALLPASS Minimum-multiplier allpass filter.
    %   Hd = DFILT.ALLPASS(C) constructs a minimum-multiplier allpass structure
    %   given the allpass coefficients in vector C.
    %
    %   C must have between one and four coefficients.
    %
    %   The allpass transfer function of Hd given the coefficients in C is:
    %                           -1          -n
    %             C(n) + C(n-1)z + .... +  z
    %     H(z) = -------------------------------
    %                      -1             -n
    %             1 + C(1)z + .... + C(n)z
    %
    %   Notice that the leading '1' coefficient in the denominator is not
    %   part of C.
    %
    %   It is possible to construct a cascade of these filters using
    %   DFILT.CASCADEALLPASS. See the help for that filter structure for more
    %   information.
    %
    %   Example: Construct a second-order minimum-multiplier allpass filter
    %   C = [1.5,0.7];
    %   Hd = dfilt.allpass(C);
    %   info(Hd)
    %   realizemdl(Hd) % Requires Simulink; build model for filter
    %
    %   See also DFILT/STRUCTURES
    
    %dfilt.allpass class
    %   dfilt.allpass extends dfilt.abstractallpass.
    %
    %    dfilt.allpass properties:
    %       PersistentMemory - Property is of type 'bool'
    %       NumSamplesProcessed - capture (read only)
    %       FilterStructure - Property is of type 'ustring'  (read only)
    %       States - Property is of type 'mxArray'
    %       AllpassCoefficients - Property is of type 'mxArray'
    %
    %    dfilt.allpass methods:
    %       dgdfgen - generate the dg_dfilt structure from a specified filter structure
    %       secfilter - Filter this section.
    %       ss -  Discrete-time filter to state-space conversion (not supported).
    %       thisisrealizable - True if the structure can be realized by simulink
    %       validate_coeffs -   Validate the coeffs
    
    
    
    methods  % constructor block
        function this = allpass(c)
            
            this.privfq = dfilt.filterquantizer;
            this.privfilterquantizer = dfilt.filterquantizer;
            this.FilterStructure = 'Minimum-Multiplier Allpass';
            this.AllpassCoefficients = [];
            if nargin > 0
                if ~isreal(c)
                    error(message('signal:dfilt:allpass:allpass:complexCoeffs'));
                end
                this.AllpassCoefficients = c;
            end
            
            
        end  % allpass
        
    end  % constructor block
    
    methods  % public methods
        [A,B,C,D] = ss(Hd)
    end  % public methods
    
    
    methods (Hidden)
        DGDF = dgdfgen(Hd,hTar,doMapCoeffsToPorts)
        N = nadd(this)
        [y,zf] = secfilter(Hd,x,zi)
        f = thisisrealizable(Hd)
        n = thisnstates(this)
        varargout = validate_coeffs(this,coeffs)
    end  % possibly private or hidden
    
end  % classdef

