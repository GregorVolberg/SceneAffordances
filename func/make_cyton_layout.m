function[lay, elec] = make_cyton_layout(elecfile, Cyton)

tmpelec = load(elecfile);
[iscyton, indx] = ismember(tmpelec.elec.label, Cyton.EasyCap(2:9));
tmplabel = Cyton.TenTwenty(2:9);

elec.pnt = tmpelec.elec.pnt(ismember(tmpelec.elec.label, Cyton.EasyCap(2:9)),:);
elec.label   = tmplabel(indx(iscyton))';

cfg = [];
cfg.elec = elec;
lay = ft_prepare_layout(cfg);

% cfg = [];
% cfg.layout = lay;
% ft_layoutplot(cfg)


