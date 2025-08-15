function [p, v] = basefilter_info(this)
%BASEFILTER_THISINFO   Get the information for this filter.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.

% Get the stability
if isstable(this)
    stablestr = getString(message('signal:sigtools:siggui:Yes'));
else
    stablestr = getString(message('signal:sigtools:siggui:No'));
end

islinphaseflag = islinphase(this);
if islinphaseflag,
    linphase = getString(message('signal:sigtools:siggui:Yes'));
    if isfir(this) && isreal(this),
        t = firtype(this);
        if iscell(t),
            t = [t{:}];
        end
        linphase = [linphase, ' (Type ',int2str(t), ')'];
    end
else
    linphase = getString(message('signal:sigtools:siggui:No'));
end

[coeffp, coeffv] = coefficient_info(this);

p = {getString(message('signal:dfilt:info:FilterStructure')), ...
    coeffp{:}, ...
    getString(message('signal:dfilt:info:Stable')), ...
    getString(message('signal:dfilt:info:LinearPhase'))};

v = {getFilterStructureString(this),...
    coeffv{:},...
    stablestr,...
    linphase
    };


function str = getFilterStructureString(this)

c = class(this);
switch c
    case 'dfilt.dffir'
        str = getString(message('signal:sigtools:siggui:DirectFormFIR'));
    case 'dfilt.dffirt'
        str = getString(message('signal:sigtools:siggui:DirectFormFIRTransposed'));
    case 'dfilt.dfsymfir'
        str = getString(message('signal:sigtools:siggui:DirectFormSymmetricFIR'));
    case 'dfilt.dfasymfir'
        str = getString(message('signal:sigtools:siggui:DirectFormAntisymmetricFIR'));
    case 'dfilt.fftfir'
        str = getString(message('signal:sigtools:siggui:OverlapAddFIR'));
    case 'dfilt.latticeallpass'
        str = getString(message('signal:sigtools:siggui:LatticeAllpass'));
    case 'dfilt.latticearma'
        str = getString(message('signal:sigtools:siggui:LatticeAutoregressiveMovingAverageARMA'));
    case 'dfilt.latticemamax'
        str = getString(message('signal:sigtools:siggui:LatticeMovingAverageMAForMaximumPhase'));
    case 'dfilt.latticemamin'
        str = getString(message('signal:sigtools:siggui:LatticeMovingAverageMAForMinimumPhase'));  
    case 'dfilt.cascade'
        str = getString(message('signal:sigtools:siggui:Cascade'));
    case 'dfilt.calattice'
        str = getString(message('signal:sigtools:siggui:CoupledAllpassCALattice'));
    case 'dfilt.calatticepc'
        str = getString(message('signal:sigtools:siggui:CoupledAllpassCALatticewithPowerComplementaryPCOutput'));
    case 'dfilt.df1'
        str = getString(message('signal:sigtools:siggui:DirectFormI'));
    case 'dfilt.df1sos'
        str = getString(message('signal:sigtools:siggui:DirectFormISecondOrderSections'));
    case 'dfilt.df1t'
        str = getString(message('signal:sigtools:siggui:DirectFormITransposed'));
    case 'dfilt.df1tsos'
        str = getString(message('signal:sigtools:siggui:DirectFormITransposedSecondOrderSections'));
    case 'dfilt.df2'
        str = getString(message('signal:sigtools:siggui:DirectFormII'));
    case 'dfilt.df2sos'
        str = getString(message('signal:sigtools:siggui:DirectFormIISecondOrderSections'));
    case 'dfilt.df2t'
        str = getString(message('signal:sigtools:siggui:DirectFormIITransposed'));
    case 'dfilt.df2tsos'
        str = getString(message('signal:sigtools:siggui:DirectFormIITransposedSecondOrderSections'));
    otherwise
        str = get(this,'FilterStructure');
end
        
        
        
        
        
        % [EOF]
