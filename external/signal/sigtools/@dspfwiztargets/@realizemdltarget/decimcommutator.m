function hblk = decimcommutator(hTar, name, N, qparam, dspblklibname,render)
%DECIMCOMMUTATOR Add a Decimator Commutator (1->N) block to the model.
%   HBLK = DECIMCOMMUTATOR(HTAR, NAME, N,qparam) adds a interpolation commutator
%   (1->N) block named NAME, sets its input number to N and returns a
%   handle HBLK to the block.   DSPBLKLIBNAME specifies the signal
%   processing toolbox so that upsample can be realized.  Note this
%   commutator is anti-clockwise, i.e. 1->N->N-1->...->2->1
%

% Copyright 2004-2017 The MathWorks, Inc.

    narginchk(5,6);

    if nargin<6
        render=true;
    end

    hTarDecimCommutator = copy(hTar);
    if ischar(N)
        N = str2double(N);
    end

    N_str = num2str(N);

    if render
        sys = hTar.system;
        idx = findstr(sys, '/');
        set_param(0,'CurrentSystem',sys(1:idx(end)-1));

        hTarDecimCommutator.destination = 'current';
        idx = findstr(sys,'/');
        if length(idx) == 1
            blockpath = hTar.blockname;
        else
            blockpath = sys(idx(end)+1:end);
        end

        hTarDecimCommutator.blockname = [blockpath '/' name];
        pos = createmodel(hTarDecimCommutator);
        hsubsys = add_block('built-in/subsystem',hTarDecimCommutator.system,'Tag','FilterWizardDecimatorCommutator');
        set_param(hsubsys,'Position',pos);
        subsys = hTarDecimCommutator.system;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % realize the commutator
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        p = positions;

        % input
        blkname = 'input';
        hblk = hTarDecimCommutator.inport(blkname,qparam);
        set_param(hblk,'Position',[35 42 65 58]);

        % first phase downsample and output
        blkname = 'downsamp1';
        hblk = hTarDecimCommutator.downsample(blkname,N_str,dspblklibname);
        set_param(hblk,'Position',[115 35 145 65]);
        blkname = 'output1';
        hblk = outport(hTarDecimCommutator,blkname);
        set_param(hblk,'Position',[185 42 215 58]);

        add_line(subsys,'input/1','downsamp1/1','autorouting','on');
        add_line(subsys,'downsamp1/1','output1/1','autorouting','on');

        % delays and downsamplers
        for m = 1:N-1
            delayblkname = ['delay',num2str(m)];
            hblk = hTarDecimCommutator.delay(delayblkname,'1');
            set_param(hblk,'Position',delaypos(m,p,N));
            set_param(hblk,'Orientation','down');
            downblkname = ['downsamp',num2str(m+1)];
            hblk = hTarDecimCommutator.downsample(downblkname,N_str,dspblklibname);
            set_param(hblk,'Position',downsamplepos(m,p,N));
            outblkname = ['output',num2str(m+1)];
            hblk = outport(hTarDecimCommutator,outblkname);
            set_param(hblk,'Position',outputpos(m,p,N));
            add_line(subsys,[delayblkname '/1'],[downblkname '/1'],'autorouting','on');
            add_line(subsys,[downblkname '/1'],[outblkname '/1'],'autorouting','on');
        end

        % connect input to first delay
        if N>1
            add_line(subsys,'input/1','delay1/1','autorouting', 'on');
        end

        % connect all delays
        for m = 1:N-2
            add_line(subsys,['delay' num2str(m) '/1'],['delay' num2str(m+1) '/1'],'autorouting','on');
        end
    else        
        % not regenerate the subsystem, but still need to pass the two parameters down if needed
        InputProcessing = '';
        switch (hTar.InputProcessing)
          case 'columnsaschannels'
            InputProcessing  = 'Columns as channels (frame based)';
            delayInputProcessing  = InputProcessing;
          case 'elementsaschannels'
            InputProcessing  = 'Elements as channels (sample based)';
            delayInputProcessing  = InputProcessing;
          case 'inherited'
            InputProcessing  = 'Inherited (this choice will be removed - see release notes)';
            delayInputProcessing  = 'Inherited';
        end
        RateOptions = '';
        switch(hTar.RateOption)
          case 'enforcesinglerate'
            RateOptions = 'Enforce single-rate processing';
          case 'allowmultirate'
            RateOptions = 'Allow multirate processing';
        end
        
        % delays and downsamplers
        % first phase downsample and output
        sys = hTar.system;
        blkname = [sys '/' name '/' 'downsamp1'];
        if ~strcmp(get_param(blkname, 'InputProcessing'),'InputProcessing')||...
                ~strcmp(get_param(blkname, 'RateOptions'),'RateOptions') 
            % only set underlying blocks if needed            
            set_param(blkname, 'InputProcessing', InputProcessing,...
                               'RateOptions', RateOptions);
            for m = 1:N-1
                blkname = [sys '/' name '/' 'delay', num2str(m)];
                set_param(blkname, 'InputProcessing', delayInputProcessing);
                blkname = [sys '/' name '/' 'downsamp', num2str(m+1)];
                set_param(blkname, 'InputProcessing', InputProcessing,...
                                   'RateOptions', RateOptions);
            end
        end
    end



% ------------------------------
%       Utility functions
% ------------------------------

function p = positions

    p.output = [-15 -8 15 8];
    p.downsample = [-15 -15 15 15];
    p.delay = [-15 -15 15 15];

function pos = outputpos(stage,p,N)
    pos = min(100,32000/N)*[0 stage 0 stage]+[200 50 200 50]+p.output;

function pos = downsamplepos(stage,p,N)
    pos = min(100,32000/N)*[0 stage 0 stage]+[130 50 130 50]+p.downsample;

function pos = delaypos(stage,p,N)
    pos = min(100,32000/N)*[0 stage 0 stage]+[75 0 75 0]+p.delay;

