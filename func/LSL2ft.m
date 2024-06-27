function[eeg] = LSL2ft(csvfile, Cyton)

tmpeeg = csvread(csvfile, 2, 1); % from LabStreamLayer

% dummy ft structure
eeg = [];
eeg.fsample  = 250;
eeg.trial    = {tmpeeg(:, 2:9)'};
eeg.time     = {[0:1:(size(tmpeeg, 1)-1)] *1/eeg.fsample};
eeg.label    = Cyton.TenTwenty(2:9)';
eeg.sampleinfo = [1 size(tmpeeg,1)];
eeg.hdr.Fs = 250;
eeg.hdr.nchans = 8;
eeg.hdr.label    = Cyton.TenTwenty(2:9)';
eeg.hdr.nSamples    = size(tmpeeg,1);
eeg.hdr.nSamplesPre = 0;
eeg.hdr.nTrials = 1;
%viseeg.hdr.chantype = {repmat({'eeg'}, 8,1)};
%viseeg.hdr.chanunit = {repmat({'uV'}, 8,1)};

cfg = [];
%cfg.lpfilter  = 'yes';
%cfg.hpfilter  = 'yes';
%cfg.lpfreq    = 30;
%cfg.hpfreq    = 0.5;
%cfg.reref     = 'no';

eeg = ft_preprocessing(cfg, eeg);
eeg.trialinfo = tmpeeg(:,end)';

