addpath("./../../m-lib/brainflowMatlab")
addpath("../../m-lib/brainflowMatlab/lib")
addpath("../../m-lib/brainflowMatlab/inc")

fname = ['scene_aff_visual_', datestr(now, 'yyyy-mm-dd-HHMMSS')];

fnamemat = [fname, '.mat'];
fnameeeg = ['file://', fname, '.csv:w'];
KbName('UnifyKeyNames');
TastenCodes  = KbName({'Y', 'M', 'ESCAPE'}); 
TastenVector = zeros(1,256); TastenVector(TastenCodes) = 1;
KbQueueCreate([],TastenVector);
KbQueueStart;

Screen('Preference', 'SkipSyncTests', 1);
MonitorSelection = 7;
MonitorSpecs = getMonitorSpecs(MonitorSelection);

[fixcross, ~, alpha] = imread("fixcross.png");
fixcross(:,:,4) = alpha; clear alpha


Rect = [0, 0, 200, 200]; 

ntrials = 60;
isi1 = 0.8 + 0.4*rand(ntrials,1);
isi2 = 1.5 + 0.8*rand(ntrials,1);
CircleOrRectangle = Shuffle([repmat(1,ntrials/2, 1); repmat(2,ntrials/2, 1)]);
incFactor = 1 + 2*rand(ntrials,1);

% https://brainflow.readthedocs.io/en/stable/Examples.html#matlab
% section Get Data from Board
eegnames = {'F1','F3','C3','C4','O1','O2','TP9','TP10'}; %TP9/TP10 as mastoids
BoardShim.release_all_sessions(); % will not start if other sessions are active 

%boardId = int32(BoardIds.SYNTHETIC_BOARD);
boardId = int32(BoardIds.CYTON_BOARD);
preset  = int32(BrainFlowPresets.DEFAULT_PRESET);
eegchans = BoardShim.get_eeg_channels(boardId, preset);
accchans = BoardShim.get_accel_channels(boardId, preset);
markchan = BoardShim.get_marker_channel(boardId, preset);
srate    = BoardShim.get_sampling_rate(boardId, preset);

params = BrainFlowInputParams();
params.serial_port = 'COM3';
board_shim = BoardShim (boardId, params);

preset  = int32(BrainFlowPresets.DEFAULT_PRESET); 

board_shim.prepare_session();
board_shim.add_streamer(fnameeeg, preset);
board_shim.start_stream(45000, '');

input('Y für Kreis, M für Dreieck (Taste zum Bestätigen)');
try
    Priority(1);
    HideCursor;
    [win, ~] = Screen('OpenWindow', MonitorSpecs.ScreenNumber, 127); 

    Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [width, height] = Screen('WindowSize', win);
    hz = Screen('NominalFrameRate', win);

    fcross = Screen('MakeTexture', win, fixcross);   
    fixRect = CenterRectOnPoint([0 0 50 50], width/2, height/2);

targetFliptime = GetSecs();
outmat = [];
for trl = 1:ntrials
   
    Screen('DrawTexture', win, fcross, [], fixRect);
    crossFliptime = Screen('Flip', win, targetFliptime + isi2(trl));

    dstRect = CenterRectOnPoint(round(Rect*incFactor(trl)), width/2, height/2);
    if CircleOrRectangle(trl) == 1
    Screen('FillOval', win, [255 255 255], dstRect);
    else
    Screen('FillRect', win, [255 255 255], dstRect);    
    end
    
    targetFliptime = Screen('Flip', win, crossFliptime + isi1(trl));
    board_shim.insert_marker(1, preset);
    tsample = board_shim.get_board_data_count(preset);
    KbQueueFlush(); pressed = 0; % flush queue, i.e. start RT timer
    
    Screen('Flip', win, targetFliptime + 0.1);
    
   while ~pressed           
        [pressed, timevec] = KbQueueCheck;
   end%
   [KEYvec, RTvec] = GetBehavioralPerformance(timevec); % get RT; see subfunction

   outmat(trl, 1) = tsample;
   outmat(trl, 2) = CircleOrRectangle(trl);
   outmat(trl, 3) = KEYvec;
   outmat(trl, 4) = RTvec- targetFliptime;
    
   
end




WaitSecs(3);

catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    
end

Screen('CloseAll');

board_shim.stop_stream();
board_shim.release_session();

save(fnamemat, "outmat");
