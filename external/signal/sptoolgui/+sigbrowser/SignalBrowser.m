classdef SignalBrowser < handle
%SIGNALBROWSER SPTool signal browser.

%   Copyright 2012 The MathWorks, Inc.

properties %(Access = private)
  Application
end

methods
  function this = SignalBrowser(varargin)
      
    nargs = nargin;
    names = cell(1, nargs);
    for indx = 1:nargs
      names{indx} = inputname(indx);
    end
    
    hScopeCfg = sigbrowser.SignalBrowserCfg(varargin, uiservices.cacheFcnArgNames(names));
    hScopeCfg.Position = uiscopes.getDefaultPosition([560 420]);
    this.Application = uiscopes.new(hScopeCfg);
    hScopeCfg.Application = this.Application;
    set(this.Application.Parent, 'Tag', 'SignalBrowser');
    
    updateSelectedDisplayProperty(this.Application.Visual,'AxesColor', [1 1 1]);
    updateSelectedDisplayProperty(this.Application.Visual,'AxesTickColor', [0 0 0]);
    updateSelectedDisplayProperty(this.Application.Visual','YLabelReal',getString(message('Spcuilib:scopes:YLabelTimePlot')));

    hDataSource = this.Application.getExtInst('Sources', 'SPTool');
    connectToDataSource(this.Application, hDataSource);
  end
end
end