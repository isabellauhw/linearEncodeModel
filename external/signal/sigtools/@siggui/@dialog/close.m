function close(hDlg)
%CLOSE Close the dialog figure
%   CLOSE(hDLG) Close the dialog figure.

%   Author(s): J. Schickler
%   Copyright 1988-2017 The MathWorks, Inc.

if isrendered(hDlg)
    
    hFig = get(hDlg, 'FigureHandle');
    
    if ishghandle(hFig)
        
        % Delete the transaction.
        delete(hDlg.Operations);
        
        set(hDlg,'Operations',[]);
        
        delete(hFig);
    end
end

% [EOF]
