function plotFRF(FRF,f,fidx,varargin)
%PLOTFRF Plot frequency response functions.
%   This function is for internal use only. It may be removed. 

%   Copyright 2016 The MathWorks, Inc. 

% Plot the FRFs contained in FRF, one per subplot.
% If varargin is provided, plot two FRFs. Otherwise, plot phase.

% Parse Name-value pairs
p = inputParser;
p.addParameter('Coherence',[]);
p.addParameter('OutFRF',[]);
p.addParameter('Opts',[]);

parse(p,varargin{:});
oFRF = p.Results.OutFRF;
coh = p.Results.Coherence;
opts = p.Results.Opts;

numOut = min(size(FRF,2),4);
numIn = min(size(FRF,3),4);

if size(FRF,2) > 4 || size(FRF,3) > 4
  warning(message('signal:modalplot:FRFPlotLimit',4,4));
end

% Convert frequency to engineering units
[f,~,uf] = engunits(f,'unicode');

% Get current figure handle and clear it
newplot;

% Create axes handles for subplots. Make them invisible until plotting.
for jFRF = 1:numOut
  for iFRF = 1:numIn
    P1(iFRF,jFRF) = subplot(2*numOut,numIn,sub2ind([numIn 2*numOut],iFRF,2*jFRF-1),'visible','off'); %#ok<AGROW>
    P2(iFRF,jFRF) = subplot(2*numOut,numIn,sub2ind([numIn 2*numOut],iFRF,2*jFRF),'visible','off');   %#ok<AGROW>
    linkaxes([P1(iFRF,jFRF) P2(iFRF,jFRF)],'x');
  end
end

for jFRF = 1:numOut
  for iFRF = 1:numIn
    
  % Get handle to subplots for this FRF.  
  p1 = P1(iFRF,jFRF);
  p2 = P2(iFRF,jFRF);
  
  % Make the frf plot larger and the phase plot smaller
  p1p = get(p1,'position');
  p1p(2) = p1p(2)+p1p(4)/2;
  p1p(4) = p1p(4)/2;
  set(p1,'position',p1p)
  p1p = get(p1,'position');
  p2p = get(p2,'position');
  p2p(4) = 0.95*(p1p(2)-p2p(2));
  set(p2,'position',p2p)
    
  % Plot phase on the top subplot.
  set(p1,'Visible','on')
  plot(p1,f(fidx),angle(FRF(fidx,jFRF,iFRF)));
  set(p1,'YTick',[-3 3]);
  if ~isempty(oFRF)  % Plot the phase of the reconstructed FRF, if provided.
    hold(p1,'on')
    plot(p1,f(fidx),angle(oFRF(fidx,jFRF,iFRF)),'--');
    hold(p1,'off')
  end
  grid(p1,'on')
  set(p1,'xTickLabels',[])
  
  title(p1,[getString(message('signal:modalplot:FRF')) num2str(jFRF) num2str(iFRF)]);

  % Plot the magnitude of the FRF.
  set(p2,'Visible','on')
  plot(p2,f(fidx),abs(FRF(fidx,jFRF,iFRF)));
  grid(p2,'on')
  if ~isempty(oFRF) % Plot a reconstructed FRF, if provided, and add a legend.
    hold(p2,'on')
    plot(p2,f(fidx),abs(oFRF(fidx,jFRF,iFRF)),'--');
    hold(p2,'off')
    if isequal(jFRF,1) && isequal(iFRF,1)
        legend(p2,getString(message('signal:modalplot:MeasuredResponse')), ...
          getString(message('signal:modalplot:ReconstructedResponse')),'Location','Northeast');
    end
  end
  
  % Plot coherence, if provided.
  if ~isempty(coh)
    yyaxis(p2,'right');
    if ~isempty(opts) && strcmpi(opts.mt,'rovinginput')
      % We have ordinary coherence functions, each corresponding to an
      % input in the FRF matrix.
      plot(p2,f(fidx),coh(fidx,iFRF));
    else
      % Each coherence function corresponds to an output in the FRF matrix.
      plot(p2,f(fidx),coh(fidx,jFRF));
    end
    ylim(p2,[0 1.05])
    yyaxis(p2,'left');
  end
  
  % Only plot xlabels on last subplot.
  if isequal(jFRF,numOut) 
    xlabel(p2,[getString(message('signal:modalplot:Frequency')) ...
    ' (' uf getString(message('signal:modalplot:Hz')) ')'])
  end
  
  % Make the plots tight in x and give a margin in y.
  axis(p1,'tight');
  axis(p2,'tight');
  set(p2,'yscale','log');
  yl1 = get(p1,'ylim');
  yl2 = get(p2,'ylim');
  set(p2,'ylim',[0 .1]*abs(diff(yl2))+yl2);
  set(p1,'ylim',[-.1 .1]*abs(diff(yl1))+yl1);
  end
  
  % Add tags to the plots
  set(p1,'Tag','Phase');
  set(p2,'Tag','Mag');
  
end

% Make a background axis for the y-axis labels and to hide subplots while
% they are being created.
hb = axes(get(P1(1,1),'Parent'),'Visible','off',...
 'Xlim',[0 1],'Ylim',[0 1],'XTick',[],'YTick',[],'XTickLabel',[],'YTickLabel',[],...
 'HitTest','off','Position',[.075 0 .85 1],'Tag','axLabels');

% Plot coherence label if coherence has been plotted.
if ~isempty(coh)
  yyaxis(hb,'left')
  ylabel(hb,getString(message('signal:modalplot:DynFlexMagPhase')),'visible','on');
  yyaxis(hb,'right')
  yticklabels(hb,[]);
  ylabel(hb,getString(message('signal:modalplot:Coherence')),'visible','on');
else
  ylabel(hb,getString(message('signal:modalplot:DynFlexMagPhase')),'visible','on');
end  

% Set NextPlot to replace to clobber next time a plot command is issued.
set(p2.Parent,'NextPlot','replace');

% Make last created subplot the active axis
axes(p2);