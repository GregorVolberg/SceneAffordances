% data analysis for scene affordance
addpath("./../../m-lib/fieldtrip"); ft_defaults;  


tmpeeg = textread('scene_aff_visual_2024-05-07-103106.csv');
tmpmat = load('scene_aff_visual_2024-05-07-103106.mat', 'outmat');


tapeeg = [];
tapeeg.fsample  = 250;
tapeeg.trial    = {tmpeeg(:, 2:9)'};
tapeeg.time     = {[0:1:(size(tmpeeg, 1)-1)] *1/tapeeg.fsample};
tapeeg.label    = {'F1','F3','C3','C4','O1','O2','TP9','TP10'}';
tapeeg.sampleinfo = [1 size(tmpeeg,1)];
tapeeg.hdr.Fs = 250;
tapeeg.hdr.nchans = 8;
tapeeg.hdr.label    = {'F1','F3','C3','C4','O1','O2','TP9','TP10'}';
tapeeg.hdr.nSamples    = size(tmpeeg,1);
tapeeg.hdr.nSamplesPre = 0;
tapeeg.hdr.nTrials = 1;
%viseeg.hdr.chantype = {repmat({'eeg'}, 8,1)};
%viseeg.hdr.chanunit = {repmat({'uV'}, 8,1)};

cfg = [];
cfg.lpfilter = 'yes';
cfg.hpfilter = 'yes';
cfg.lpfreq    = 30;
cfg.hpfreq    = 0.5;
cfg.reref = 'yes';
cfg.refchannel = {'TP9'}; % TP 10 sehr rauschig
dat = ft_preprocessing(cfg, tapeeg);
eeg = dat.trial{1}; clear dat

tapeeg.trialinfo = tmpmat.outmat(:,2:end);
mrk = (find(tmpeeg(:,24) == 1));
tapeeg.sampleinfo = [mrk-50, mrk + 200];

for k = 1:size(tapeeg.trialinfo,1)
tapeeg.trial{k} = eeg(:, tapeeg.sampleinfo(k,1):tapeeg.sampleinfo(k,2));
tapeeg.time{k}  = -0.2:0.004:0.8;
end
clear eeg

cfg= [];
cfg.viewmode='vertical';
cfg.continuous = 'no';
cfg = ft_databrowser(cfg, tapeeg); 
clean = ft_rejectartifact(cfg, tapeeg); 

cfg = [];
cfg.keeptrials = 'no';
tl = ft_timelockanalysis(cfg, clean);

cfg = [];
cfg.baseline = [-0.2 0];
tlb = ft_timelockbaseline(cfg, tl);

cfg = [];
cfg.channel = {'O1', 'O2'};
ft_singleplotER(cfg, tlb);


%%==================
tmpbeta    = textread('scene_aff_tapping_2024-05-07-104326.csv');
tmpmatbeta = load('scene_aff_tapping_2024-05-07-104326.mat', 'outmat');

tapeeg = [];
tapeeg.fsample  = 250;
tapeeg.trial    = {tmpbeta(:, 2:9)'};
tapeeg.time     = {[0:1:(size(tmpbeta, 1)-1)] *1/tapeeg.fsample};
tapeeg.label    = {'F1','F3','C3','C4','O1','O2','TP9','TP10'}';
tapeeg.sampleinfo = [1 size(tmpbeta,1)];
tapeeg.hdr.Fs = 250;
tapeeg.hdr.nchans = 8;
tapeeg.hdr.label    = {'F1','F3','C3','C4','O1','O2','TP9','TP10'}';
tapeeg.hdr.nSamples    = size(tmpbeta,1);
tapeeg.hdr.nSamplesPre = 0;
tapeeg.hdr.nTrials = 1;

cfg = [];
cfg.lpfilter = 'yes';
cfg.hpfilter = 'yes';
cfg.lpfreq    = 40;
cfg.hpfreq    = 0.5;
cfg.reref = 'yes';
cfg.refchannel = {'TP9'}; % TP 10 sehr rauschig
dat = ft_preprocessing(cfg, tapeeg);
eeg = dat.trial{1}; clear dat

tapeeg.trialinfo = tmpmatbeta.outmat(:,2:end);
mrk = find(ismember(tmpbeta(:,24), [1,2,3,4]));
tapeeg.sampleinfo = [mrk-250, mrk + 2000];

for k = 1:size(tapeeg.trialinfo,1)
tapeeg.trial{k} = eeg(:, tapeeg.sampleinfo(k,1):tapeeg.sampleinfo(k,2));
tapeeg.time{k}  = -1:0.004:8;
end
clear eeg

cfgtfr = [];
cfgtfr.output             = 'pow';
cfgtfr.method             = 'mtmconvol';
cfgtfr.taper              = 'hanning';
cfgtfr.foi                = 4:1:30; % 4 to 40 Hz
cfgtfr.t_ftimwin          = 7./cfgtfr.foi;
cfgtfr.toi                = -1:0.01:7;% 

trnums{1} = find(tapeeg.trialinfo(:,1) == 1 & tapeeg.trialinfo(:,2) == 1); % left, actual movement
trnums{2} = find(tapeeg.trialinfo(:,1) == 2 & tapeeg.trialinfo(:,2) == 1); % right, actual movement
trnums{3} = find(tapeeg.trialinfo(:,1) == 1 & tapeeg.trialinfo(:,2) == 2); % left, imagined movement
trnums{4} = find(tapeeg.trialinfo(:,1) == 2 & tapeeg.trialinfo(:,2) == 2); % right, imagined movement

cfgb = [];
cfgb.baseline = [-0.7 -0.1];
cfgb.baselinetype = 'relchange';

for m = 1: numel(trnums)
cfgtfr.trials = trnums{m};
tmp = ft_freqanalysis(cfgtfr, tapeeg);
tfr{m} = ft_freqbaseline(cfgb, tmp);
end

cfgp = [];
cfgp.channel = {'C4'};
cfgp.ylim = [4 20];
cfgp.zlim = [-2 2];
ft_singleplotTFR(cfgp, tfr{4})

[b1, i1] = min(tfr{1}.freq(tfr{1}.freq > 12));
[b2, i2] = max(tfr{1}.freq(tfr{1}.freq < 15));


