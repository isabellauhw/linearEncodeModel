sessionInfo = readtable('./data/instrumentalSessionInfo.csv','FileType','text','Delimiter',',','ReadVariableNames',true,'TreatAsEmpty','');
vidData = struct();

data_table = table();

for session = 9
% for session = 1:height(sessionInfo)
    
    disp(['Processing video ' num2str(session) ' of ' num2str(height(sessionInfo))]);
    
    if sessionInfo.video(session) == 1
        
        expRef = sessionInfo.expRef{session};
        mouse = sessionInfo.animal_name{session};

        sessionField = sprintf('session_%s', expRef);
        sessionField = matlab.lang.makeValidName(sessionField); % Clean field name

        if ~isfield(vidData, (mouse))
            vidData.(mouse) = struct();
        end

        if ~isfield(vidData.(mouse), (sessionField))
            vidData.(mouse).(sessionField) = struct();
        end

        % load h5 file
        filename = ['/Volumes/Data/', mouse, '/', ...
            expRef(1:10),'/',expRef(12),'/',expRef,'_face_FacemapPose.h5'];
        
        % read mouth keypoints from h5 file
        mouth_x = h5read(filename,'/Facemap/mouth/x');
        mouth_y = h5read(filename,'/Facemap/mouth/y');
        
        lowerlip_x = h5read(filename,'/Facemap/lowerlip/x');
        lowerlip_y = h5read(filename,'/Facemap/lowerlip/y');
        
        % load motion PCs
        load(['/Volumes/Data/', sessionInfo.animal_name{session}, '/', ...
            expRef(1:10),'/',expRef(12),'/',expRef,'_face_proc.mat']);
        
        % retain the first 10 PCs
        MovementPC = movSVD_0(:,1:10);
        MotionPC = motSVD_0(:,1:10);
        
        % get event times
        frameCounts = [size(MotionPC, 1), size(MovementPC, 1), ...
                       size(mouth_x, 1), size(mouth_y, 1), ...
                       size(lowerlip_x, 1), size(lowerlip_y, 1)];
        nFrames = max(frameCounts); % Define here so it's always available
        
        % --- Get event times ---
        try
            event_times = getEventTimes(expRef, 'face_camera_strobe');
        catch MEinner
            warning('Could not retrieve event times for %s: %s', expRef, MEinner.message);
            event_times = NaN(nFrames, 1);
        end
        
        % --- Adjust event_times length ---
        nEvents = numel(event_times);
        tolerance = 5;
        
        % Warnings for mismatch
        if abs(nEvents - size(MotionPC,1)) > tolerance
            warning('Session %s: %d events does not match %d motion PC frames.', expRef, nEvents, size(MotionPC,1));
        end
        if abs(nEvents - size(MovementPC,1)) > tolerance
            warning('Session %s: %d events does not match %d movement PC frames.', expRef, nEvents, size(MovementPC,1));
        end
        
        % --- Align event_times with motion/movement PCs ---
        maxFrames = max(size(MotionPC, 1), size(MovementPC, 1));
        if nEvents > maxFrames
            event_times = event_times(1:maxFrames);
        elseif nEvents < maxFrames
            event_times(end+1:maxFrames) = NaN;
        end
        
        % --- Align event_times with mouth/lowerlip data ---
        arrays = {mouth_x, mouth_y, lowerlip_x, lowerlip_y};
        mouthFrames = max(cellfun(@(x) size(x,1), arrays));
        
        if length(event_times) > mouthFrames
            event_times = event_times(1:mouthFrames);
        elseif length(event_times) < mouthFrames
            newLen = length(event_times);
            mouth_x     = mouth_x(1:newLen, :);
            mouth_y     = mouth_y(1:newLen, :);
            lowerlip_x  = lowerlip_x(1:newLen, :);
            lowerlip_y  = lowerlip_y(1:newLen, :);
        end
        
        % --- Build session table ---
        animal = repmat(categorical({mouse}), length(mouth_x), 1); % intentionally has a different variable name
        exp_ref    = repmat(categorical({expRef}), length(mouth_x), 1); % intentionally has a different variable name
        
        session_table = table(...
            animal,...
            exp_ref,...
            event_times,...  % Fixed variable name
            mouth_x, mouth_y,...
            lowerlip_x, lowerlip_y,...
            MovementPC, ...
            MotionPC);
        
        % Rename them for consistency
        session_table.Properties.VariableNames{'animal'} = 'mouse';
        session_table.Properties.VariableNames{'exp_ref'} = 'expRef';
        session_table.Properties.VariableNames{'event_times'} = 'eventTimes';
        
        % Append to main table
        vidData.(mouse).(sessionField) = session_table;
        disp(['Data assigned for ', mouse, ' - ', expRef]);
    end
    
end

% writetable(data_table,'pavlov_probability_facemap_data.csv')
   
