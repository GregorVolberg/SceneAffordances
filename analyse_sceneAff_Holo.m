%%%%%%%%%%%%%%%%%%%%%%%%%%
% data analysis for scene affordance
%%%%%%%%%%%%%%%%%%%%%%%%

% set up ft
addpath('./../../m-lib/fieldtrip'); ft_defaults;  
addpath('./func');

% 8-channel layout, OpenBCI Cyton Board run with EasyCap and AgCl electrodes
Cyton.OpenBCI   = {'SRB', 'N1P', 'N2P', 'N3P', 'N4P', 'N5P', 'N6P', 'N7P', 'N8P', 'BIAS'};
Cyton.TenTwenty = {'REF(Oz)', 'AF1', 'AFz', 'AF2', 'C3', 'Cz', 'C4', 'CP3', 'CP4', 'GND(Pz)'};
Cyton.EasyCap   = {'C42', 'C33', 'C19', 'C20', 'C16', 'C63', 'C10', 'C15', 'C11', 'C13'}; % 63 is marked as REF

% electrode files for plot positioning
[lay, elec] = make_cyton_layout('./org/63equidistant_elec_GV.mat', Cyton);

% read csv
raw = LSL2ft('./data/eeg_2024-06-24-withHololens.csv', Cyton);

% filter
cfg = [];
cfg.lpfilter  = 'yes';
cfg.hpfilter  = 'yes';
cfg.lpfreq    = 30;
cfg.hpfreq    = 0.5;
cfg.reref     = 'no';
preproc = ft_preprocessing(cfg, raw);

% view 
cfg = [];
cfg.viewmode   = 'vertical';
cfg.continuous = 'yes';
cfg = ft_databrowser(cfg, preproc); % artefact identification

% ICA
badchannels = {};
goodchannels = setdiff(preproc.label,badchannels);

cfg = [];
cfg.channel = goodchannels;
ic = ft_componentanalysis(cfg, preproc);

cfg = [];
cfg.viewmode='component';
cfg.continuous = 'yes';
cfg.layout = lay;
ft_databrowser(cfg, ic);

cfg=[];
cfg.component = [1];
preclean = ft_rejectcomponent(cfg, ic);

