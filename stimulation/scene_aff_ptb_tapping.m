Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference','TextEncodingLocale','UTF-8');

addpath("./../../m-lib/brainflowMatlab")
addpath("../../m-lib/brainflowMatlab/lib")
addpath("../../m-lib/brainflowMatlab/inc")

fname = ['scene_aff_tapping_', datestr(now, 'yyyy-mm-dd-HHMMSS')];
ntrials = 16; % must be even


fnamemat = [fname, '.mat'];
fnameeeg = ['file://', fname, '.csv:w'];


MonitorSelection = 7;
MonitorSpecs = getMonitorSpecs(MonitorSelection);

[fixcross, ~, alpha] = imread("fixcross.png");
fixcross(:,:,4) = alpha; clear alpha
[arr, ~, alpha] = imread("arrowright.png");
arr(:,:,4) = alpha; clear alpha

Rect = [0, 0, 200, 200]; 

isi1 = 0.8 + 0.4*rand(ntrials,1);
isi2 = 1.5 + 0.8*rand(ntrials,1);
LeftOrRight = repmat([1 2], 1, ntrials/2);
%incFactor = 1 + 2*rand(ntrials,1);

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

try
    Priority(1);
    HideCursor;
    [win, ~] = Screen('OpenWindow', MonitorSpecs.ScreenNumber, 127); 

    Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [width, height] = Screen('WindowSize', win);
    hz = Screen('NominalFrameRate', win);
    
    Screen('TextFont',win, 'Courier New');
Screen('TextSize',win, 40);
Screen('TextStyle', win, 1+2);


    fcross = Screen('MakeTexture', win, fixcross);
    rarrow = Screen('MakeTexture', win, arr);
    fixRect = CenterRectOnPoint([0 0 50 50], width/2, height/2);
    right = width/2+50:75:width/2+50+4*75;
    left  = width/2-50:-75:width/2-50-4*75;
    lrects = CenterRectOnPoint(fixRect, left(2:5)', repmat(height/2, 4,1));
    rrects = CenterRectOnPoint(fixRect, right(2:5)', repmat(height/2, 4,1));

targetFliptime = GetSecs();
outmat = [];
for trl = 1:ntrials
    if LeftOrRight(trl) == 1
    trect = lrects;
    trect = [trect; trect(3:-1:1,:)];
    angl = -180;
    else
    trect = rrects;
    trect = [trect; trect(3:-1:1,:)];
    angl = 0;
    end

    Screen('DrawTexture', win, fcross, [], fixRect);
    crossFliptime = Screen('Flip', win, targetFliptime + isi2(trl));
    WaitSecs(1+rand*0.5)
    Screen('DrawTexture', win, rarrow, [], fixRect, angl);
    Screen('Flip', win, targetFliptime + isi2(trl));
    board_shim.insert_marker(LeftOrRight(trl), preset);
    tsample = board_shim.get_board_data_count(preset);

    WaitSecs(2+rand());
    
    for j = 1:size(trect, 1)
    %Screen('DrawTexture', win, fcross, [], fixRect);
    Screen('DrawTexture', win, rarrow, [], fixRect, angl);
    Screen('FillOval', win, [255 255 255], trect(j,:)');
    Screen('Flip', win);
%    DrawFormattedText(win, 'test');
    WaitSecs(2);
    end
   outmat(trl, 1) = tsample;
   outmat(trl, 2) = LeftOrRight(trl);
   outmat(trl, 3) = 1; % task 1
   

end
Screen('Flip', win);
WaitSecs(1);
DrawFormattedText(win, 'Jetzt Bewegung nur vorstellen!','center', 'center')
%Screen('DrawText', win, 'Jetzt Bewegung nur Vorstellen!', width/2, height/2);
Screen('Flip', win);
WaitSecs(3);

for trl = 1:ntrials
    if LeftOrRight(trl) == 1
    trect = lrects;
    trect = [trect; trect(3:-1:1,:)];
    angl = -180;
    else
    trect = rrects;
    trect = [trect; trect(3:-1:1,:)];
    angl = 0;
    end

    Screen('DrawTexture', win, fcross, [], fixRect);
    crossFliptime = Screen('Flip', win, targetFliptime + isi2(trl));
    WaitSecs(1+rand*0.5)
    Screen('DrawTexture', win, rarrow, [], fixRect, angl, [], [], [255 0 0]);
    Screen('Flip', win, targetFliptime + isi2(trl));
    board_shim.insert_marker(LeftOrRight(trl)+2, preset);
    tsample = board_shim.get_board_data_count(preset);

    WaitSecs(2+rand());
    
    for j = 1:size(trect, 1)
    %Screen('DrawTexture', win, fcross, [], fixRect);
    Screen('DrawTexture', win, rarrow, [], fixRect, angl, [], [], [255 0 0]);
    %Screen('DrawTexture', win, rarrow, [], fixRect, angl);
    Screen('FillOval', win, [255 255 255], trect(j,:)');
    Screen('Flip', win);
%    DrawFormattedText(win, 'test');
    WaitSecs(2);
    end
   outmat(trl+ntrials, 1) = tsample;
   outmat(trl+ntrials, 2) = LeftOrRight(trl);
   outmat(trl+ntrials, 3) = 2; % task 2

end
Screen('Flip', win);
WaitSecs(1);
   
catch
    Screen('CloseAll');
    psychrethrow(psychlasterror);
    
end


Screen('CloseAll');


board_shim.stop_stream();
board_shim.release_session();
save(fnamemat, "outmat");
