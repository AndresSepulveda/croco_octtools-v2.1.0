function varargout = oct_nestgui(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OCT_NESTGUI : GUI to generate embedded (AGRIF) CROCO grid, forcing,
%  bulk, frcbio, initial, restart and climatology netcdf files.
%
%  Octave version of nestgui. The Matlab version is built with GUIDE
%  from nestgui.fig, a file that Octave cannot read. Here the same
%  interface (same buttons, same tags, same layout and same callbacks)
%  is built programmatically with uicontrol/uimenu, so it works in GNU
%  Octave (graphics toolkit qt) and also in Matlab.
%
%  Usage:
%    oct_nestgui                      % asks for the parent grid file
%    oct_nestgui('croco_grd.nc')      % opens this parent grid directly
%    fig = oct_nestgui(...)           % returns the figure handle
%
%  Steps (as in nestgui):
%    1: Define child  - two mouse clicks on the map (or edit
%                       imin/imax/jmin/jmax, Lchild/Mchild)
%    2: Interp child  - creates croco_grd.nc.1 (options: new child
%                       topography, match volume, r-factor, n-band,
%                       hmin, hmax coast, filters)
%    3: Interp forcing / bulk / frcbio
%    4: Interp initial (or restart), Interp clim
%    5: Create croco.in.# and AGRIF_FixedGrids.in
%  The parent files are chosen in the "Files" menu (or when the
%  corresponding button is pressed).
%
%  Further Information:
%  http://www.croco-ocean.org
%
%  This file is part of CROCOTOOLS
%
%  CROCOTOOLS is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation; either version 2 of the License,
%  or (at your option) any later version.
%
%  Copyright (c) 2004-2006 by Pierrick Penven
%  e-mail:Pierrick.Penven@ird.fr
%
%  Updated    22-Sep-2006 by Pierrick Penven (hmax coast, filter deep, filter final)
%  Updated    28-Sep-2006 by Pierrick Penven (bulk files)
%  Updated    Sep-2026 : programmatic GUI for GNU Octave (no .fig file),
%                        netcdf.* API of the octave-netcdf package
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==0 || (nargin==1 && ~isempty(strfind(varargin{1},'.nc')))
%
% LAUNCH GUI
%
  fig = build_gui();
  handles = guidata(fig);
  handles = oct_reset_handle(fig,handles);
  if nargin==1
    handles = oct_set_parentgrid(fig,handles,varargin{1});
  else
    handles = oct_get_parentgrdname(fig,handles);
  end
  guidata(fig,handles);
  if nargout > 0
    varargout{1} = fig;
  end
elseif ischar(varargin{1})
%
% INVOKE NAMED SUBFUNCTION OR CALLBACK (compatibility with nestgui)
%
  try
    [varargout{1:nargout}] = feval(varargin{:});
  catch err
    disp(err.message);
  end
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  BUILD THE GUI (layout of nestgui.fig, normalized units)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fig = build_gui()
bg = get(0,'defaultUicontrolBackgroundColor');
scr = get(0,'ScreenSize');
W = min(1100,max(800,0.8*scr(3)));
H = min(760,max(560,0.8*scr(4)));
fig = figure('Name','NESTGUI (Octave)','NumberTitle','off',...
             'IntegerHandle','off',...          % keep figure(1) free for the plots
             'MenuBar','none','ToolBar','figure',...
             'Color',bg,'Units','pixels',...
             'Position',[max(1,(scr(3)-W)/2) max(1,(scr(4)-H)/2) W H],...
             'Tag','figure1');
handles.figure1 = fig;
handles.axes1 = axes('Parent',fig,'Units','normalized',...
                     'Position',[0.2463 0.1036 0.7302 0.7309],'Tag','axes1');
%
% Menus
%
mf = uimenu(fig,'Label','Files');
menus = {'parentgrid',    'Parent grid file';
         'childgrid',     'Child grid file';
         'topo',          'Topography file';
         'parentforcing', 'Parent forcing file';
         'parentbulk',    'Parent bulk file';
         'parentdust',    'Parent frcbio file';
         'parentinitial', 'Parent initial file';
         'parentrst',     'Parent restart file';
         'parentclm',     'Parent climatology file'};
for k=1:size(menus,1)
  handles.(menus{k,1}) = uimenu(mf,'Label',menus{k,2},'Tag',menus{k,1},...
                                'Callback',{@dispatch,[menus{k,1},'_Callback']});
end
%
% Push buttons: {tag, string, position}
%
pb = {'findgridpos',      '1: Define child',            [0.0309 0.9007 0.1671 0.0604];
      'interpchild',      '2: Interp child',            [0.0309 0.4144 0.1671 0.0604];
      'interpforcing',    '3: Interp forcing',          [0.0297 0.3519 0.1671 0.0604];
      'interpbulk',       '3(bis): Interp bulk',        [0.0297 0.2903 0.1671 0.0604];
      'interpdust',       '3(ter): Interp frcbio',      [0.0297 0.2288 0.1671 0.0590];
      'interpinitial',    '4: Interp initial',          [0.0309 0.0043 0.1671 0.0604];
      'interprestart',    '4(bis): Interp restart',     [0.2178 0.0029 0.1671 0.0604];
      'create_crocoin',   '5: Create croco.in.#',       [0.4035 0.0029 0.1671 0.0604];
      'zoomin',           'Zoom in',                    [0.5916 0.0129 0.1002 0.0504];
      'zoomout',          'Zoom out',                   [0.6906 0.0129 0.1002 0.0504];
      'interpclim',       'Interp clim',                [0.8094 0.0029 0.1671 0.0604];
      'agrif_fixed_grid', 'Create AGRIF_FixedGrids.in', [0.3082 0.8532 0.2488 0.0460];
      'addriver',         'River',                      [0.7005 0.9036 0.0903 0.0460]};
for k=1:size(pb,1)
  handles.(pb{k,1}) = uicontrol(fig,'Style','pushbutton','Units','normalized',...
      'Position',pb{k,3},'String',pb{k,2},'Tag',pb{k,1},...
      'Callback',{@dispatch,[pb{k,1},'_Callback']});
end
%
% Edit boxes: {tag, default string, position, callback}
%
ed = {'editLchild',          '?',   [0.1411 0.8604 0.0594 0.0403], 'editLchild_Callback';
      'editMchild',          '?',   [0.1411 0.8201 0.0594 0.0403], 'editMchild_Callback';
      'edit_rcoef',          '3',   [0.5223 0.9281 0.0582 0.0432], 'edit_rcoef_Callback';
      'editrfactor',         '0.2', [0.1361 0.6763 0.0594 0.0403], 'editrfactor_Callback';
      'editnband',           '15',  [0.1361 0.6374 0.0594 0.0403], 'editnband_Callback';
      'edithmin',            '?',   [0.1361 0.5957 0.0594 0.0403], 'edithmin_Callback';
      'edithmax_coast',      '500', [0.1361 0.5554 0.0594 0.0403], 'edithmax_Callback';
      'edit_n_filter_deep',  '4',   [0.1361 0.5165 0.0594 0.0403], 'edit_n_filter_deep_Callback';
      'edit_n_filter_final', '2',   [0.1361 0.4748 0.0594 0.0403], 'edit_n_filter_final_Callback';
      'edit_imin',           '?',   [0.2723 0.9281 0.0582 0.0432], 'edit_imin_Callback';
      'edit_imax',           '?',   [0.3329 0.9281 0.0582 0.0432], 'edit_imax_Callback';
      'edit_jmin',           '?',   [0.3911 0.9281 0.0582 0.0432], 'edit_jmin_Callback';
      'edit_jmax',           '?',   [0.4493 0.9281 0.0582 0.0432], 'edit_jmax_Callback';
      'edit_Isrcparent',     '?',   [0.8441 0.9252 0.0582 0.0432], 'edit_Isrcparent_Callback';
      'edit_Jsrcparent',     '?',   [0.8441 0.8878 0.0582 0.0432], 'edit_Jsrcparent_Callback';
      'edit_Isrcchild',      '?',   [0.9134 0.9266 0.0582 0.0432], 'edit_Isrcchild_Callback';
      'edit_Jsrcchild',      '?',   [0.9134 0.8863 0.0582 0.0432], 'edit_Jsrcchild_Callback'};
for k=1:size(ed,1)
  handles.(ed{k,1}) = uicontrol(fig,'Style','edit','Units','normalized',...
      'Position',ed{k,3},'String',ed{k,2},'Tag',ed{k,1},...
      'BackgroundColor',[1 1 1],'Callback',{@dispatch,ed{k,4}});
end
%
% Radio buttons: {tag, string, position, initial value}
%
rb = {'newtopo_button',     'New child topo',       [0.0309 0.7439 0.1671 0.0302], 0;
      'matchvolume_button', 'Match volume',         [0.0309 0.7151 0.1671 0.0302], 0;
      'vcorrec_button',     'Vertical corrections', [0.0309 0.1914 0.1671 0.0302], 1;
      'extrap_button',      'Extrapolations',       [0.0309 0.1583 0.1671 0.0302], 1;
      'biol_button',        'Biol',                 [0.0322 0.1237 0.0656 0.0296], 0;
      'bioebus_button',     'Bioebus',              [0.1225 0.1237 0.0990 0.0228], 0;
      'pisces_button',      'Pisces',               [0.1225 0.0793 0.0780 0.0296], 0};
cbk = struct('newtopo_button','newtopo_Callback','matchvolume_button','matchvolume_Callback',...
             'vcorrec_button','vcorrec_Callback','extrap_button','extrap_Callback',...
             'biol_button','biol_Callback','bioebus_button','bioebus_Callback',...
             'pisces_button','pisces_Callback');
for k=1:size(rb,1)
  handles.(rb{k,1}) = uicontrol(fig,'Style','radiobutton','Units','normalized',...
      'Position',rb{k,3},'String',rb{k,2},'Tag',rb{k,1},'Value',rb{k,4},...
      'BackgroundColor',bg,'Callback',{@dispatch,cbk.(rb{k,1})});
end
%
% Static texts: {tag, string, position}
%
tx = {'text1',  'Lchild = ',    [0.0347 0.8604 0.0891 0.0403];
      'text3',  'Mchild = ',    [0.0347 0.8201 0.0891 0.0403];
      'text4',  'refine coeff', [0.4938 0.9050 0.1176 0.0230];
      'text5',  'r-factor',     [0.0297 0.6748 0.0891 0.0403];
      'text22', 'n-band',       [0.0297 0.6354 0.0891 0.0403];
      'text7',  'Hmin',         [0.0297 0.5957 0.0891 0.0403];
      'text17', 'Hmax coast',   [0.0297 0.5540 0.0891 0.0403];
      'text18', 'filter deep',  [0.0297 0.5137 0.0891 0.0403];
      'text19', 'filter final', [0.0297 0.4748 0.0891 0.0403];
      'text8',  'imin',         [0.2698 0.9065 0.0569 0.0230];
      'text10', 'imax',         [0.3304 0.9065 0.0532 0.0230];
      'text11', 'jmin',         [0.3886 0.9022 0.0619 0.0273];
      'text12', 'jmax',         [0.4468 0.9036 0.0606 0.0259];
      'text13', 'Isrc',         [0.8020 0.9396 0.0384 0.0230];
      'text14', 'Jsrc',         [0.7983 0.9007 0.0433 0.0230];
      'text15', 'Parent',       [0.8379 0.8633 0.0656 0.0245];
      'text16', 'Child',        [0.9084 0.8633 0.0681 0.0230]};
for k=1:size(tx,1)
  handles.(tx{k,1}) = uicontrol(fig,'Style','text','Units','normalized',...
      'Position',tx{k,3},'String',tx{k,2},'Tag',tx{k,1},'BackgroundColor',bg);
end
guidata(fig,handles);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Generic callback: get the handles, call the named callback,
%  errors are displayed (the GUI stays alive)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dispatch(src,evt,cbname)
fig = ancestor(src,'figure');
handles = guidata(fig);
try
  feval(cbname,fig,evt,handles);
catch err
  disp(['NESTGUI error in ',cbname,': ',err.message]);
  errordlg(err.message,'NESTGUI');
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  CALLBACKS (same as nestgui.m)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MENU : OPEN PARENT GRID FILE
function varargout = parentgrid_Callback(h, eventdata, handles, varargin)
handles=oct_get_parentgrdname(h,handles);
guidata(h,handles)
return
% MENU : OPEN CHILD GRID FILE
function varargout = childgrid_Callback(h, eventdata, handles, varargin)
handles=oct_get_childgrdname(h,handles);
guidata(h,handles)
return
% MENU : OPEN PARENT FORCING FILE
function varargout = parentforcing_Callback(h, eventdata, handles, varargin)
handles=oct_get_parentfrcname(h,handles);
guidata(h,handles)
return
% MENU : OPEN PARENT BULK FILE
function varargout = parentbulk_Callback(h, eventdata, handles, varargin)
handles=oct_get_parentblkname(h,handles);
guidata(h,handles)
return
% MENU : OPEN PARENT DUST FILE
function varargout = parentdust_Callback(h, eventdata, handles, varargin)
handles=oct_get_parentdustname(h,handles);
guidata(h,handles)
return
% MENU : OPEN PARENT INITIAL FILE
function varargout = parentinitial_Callback(h, eventdata, handles, varargin)
handles=oct_get_parentininame(h,handles);
guidata(h,handles)
return
% MENU : OPEN TOPO FILE
function varargout = topo_Callback(h, eventdata, handles, varargin)
handles=oct_get_topofile(h,handles);
guidata(h,handles)
return
% MENU : OPEN PARENT RESTART FILE
function varargout = parentrst_Callback(h, eventdata, handles, varargin)
handles=oct_get_parentrstname(h,handles);
guidata(h,handles)
return
% MENU : OPEN PARENT CLIMATOLOGY FILE
function varargout = parentclm_Callback(h, eventdata, handles, varargin)
handles=oct_get_parentclmname(h,handles);
guidata(h,handles)
return
%  ZOOMS
function varargout = zoomin_Callback(h, eventdata, handles, varargin)
handles=oct_zoomin(h,handles);
guidata(h,handles)
return
function varargout = zoomout_Callback(h, eventdata, handles, varargin)
handles=oct_zoomout(h,handles);
guidata(h,handles)
return
% Get the child grid position
function varargout = findgridpos_Callback(h, eventdata, handles, varargin)
handles=oct_get_findgridpos(h,handles);
guidata(h,handles)
return
% L,M
function varargout = editLchild_Callback(h, eventdata, handles, varargin)
handles=oct_get_Lchild(h,handles);
guidata(h,handles)
return
function varargout = editMchild_Callback(h, eventdata, handles, varargin)
handles=oct_get_Mchild(h,handles);
guidata(h,handles)
return
% IMIN
function varargout = edit_imin_Callback(h, eventdata, handles, varargin)
handles=oct_get_imin(h,handles);
guidata(h,handles)
return
% IMAX
function varargout = edit_imax_Callback(h, eventdata, handles, varargin)
handles=oct_get_imax(h,handles);
guidata(h,handles)
return
% JMIN
function varargout = edit_jmin_Callback(h, eventdata, handles, varargin)
handles=oct_get_jmin(h,handles);
guidata(h,handles)
return
% JMAX
function varargout = edit_jmax_Callback(h, eventdata, handles, varargin)
handles=oct_get_jmax(h,handles);
guidata(h,handles)
return
% Refinment coefficient
function varargout = edit_rcoef_Callback(h, eventdata, handles, varargin)
handles=oct_get_rcoef(h,handles);
guidata(h,handles)
return
% r-factor
function varargout = editrfactor_Callback(h, eventdata, handles, varargin)
handles=oct_get_rfactor(h,handles);
guidata(h,handles)
return
% n-band
function varargout = editnband_Callback(h, eventdata, handles, varargin)
handles=oct_get_nband(h,handles);
guidata(h,handles)
return
% Hmin
function varargout = edithmin_Callback(h, eventdata, handles, varargin)
handles=oct_get_hmin(h,handles);
guidata(h,handles)
return
% Hmax coast
function varargout = edithmax_Callback(h, eventdata, handles, varargin)
handles=oct_get_hmax_coast(h,handles);
guidata(h,handles)
return
% edit_n_filter_deep
function varargout = edit_n_filter_deep_Callback(h, eventdata, handles, varargin)
handles=oct_get_n_filter_deep(h,handles);
guidata(h,handles)
return
% edit_n_filter_final
function varargout = edit_n_filter_final_Callback(h, eventdata, handles, varargin)
handles=oct_get_n_filter_final(h,handles);
guidata(h,handles)
return
% New topo switch
function varargout = newtopo_Callback(h, eventdata, handles, varargin)
handles=oct_get_newtopobutton(h,handles);
guidata(h,handles)
return
% Match volume switch
function varargout = matchvolume_Callback(h, eventdata, handles, varargin)
handles=oct_get_matchvolumebutton(h,handles);
guidata(h,handles)
return
% Interp the child grid
function varargout = interpchild_Callback(h, eventdata, handles, varargin)
handles=oct_interp_child(h,handles);
guidata(h,handles)
return
% Interp the child forcing
function varargout=interpforcing_Callback(h, eventdata, handles, varargin)
handles=oct_interp_forcing(h,handles);
guidata(h,handles)
return
% Interp the child bulk
function varargout=interpbulk_Callback(h, eventdata, handles, varargin)
handles=oct_interp_bulk(h,handles);
guidata(h,handles)
return
% Interp the child dust
function varargout=interpdust_Callback(h, eventdata, handles, varargin)
handles=oct_interp_dust(h,handles);
guidata(h,handles)
return
% Interp the child initial conditions
function varargout=interpinitial_Callback(h, eventdata, handles, varargin)
handles=oct_interp_initial(h,handles);
guidata(h,handles)
return
% Interp the child restart conditions
function varargout=interprestart_Callback(h, eventdata, handles, varargin)
handles=oct_interp_restart(h,handles);
guidata(h,handles)
return
% Interp the child boundary conditions
function varargout=interpclim_Callback(h, eventdata, handles, varargin)
handles=oct_interp_clim(h,handles);
guidata(h,handles)
return
% Vertical correction switch
function varargout = vcorrec_Callback(h, eventdata, handles, varargin)
handles.vertical_correc=get(handles.vcorrec_button,'Value');
guidata(h,handles)
return
%  Extrapolations switch
function varargout = extrap_Callback(h, eventdata, handles, varargin)
handles.extrapmask=get(handles.extrap_button,'Value');
guidata(h,handles)
return
%  Biologie switch
function varargout = biol_Callback(h, eventdata, handles, varargin)
handles=oct_get_biolbutton(h,handles);
guidata(h,handles)
return
% Bioebus switch
function varargout = bioebus_Callback(h, eventdata, handles, varargin)
handles=oct_get_bioebusbutton(h,handles);
guidata(h,handles)
return
% Pisces switch
function varargout = pisces_Callback(h, eventdata, handles, varargin)
handles=oct_get_piscesbutton(h,handles);
guidata(h,handles)
return
% Rivers
function varargout = addriver_Callback(h, eventdata, handles, varargin)
handles=oct_get_river(h,handles);
guidata(h,handles)
return
function varargout = edit_Isrcparent_Callback(h, eventdata, handles, varargin)
set(handles.edit_Isrcparent,'String',num2str(handles.Isrcparent));
guidata(h,handles)
return
function varargout = edit_Jsrcparent_Callback(h, eventdata, handles, varargin)
set(handles.edit_Jsrcparent,'String',num2str(handles.Jsrcparent));
guidata(h,handles)
return
function varargout = edit_Isrcchild_Callback(h, eventdata, handles, varargin)
set(handles.edit_Isrcchild,'String',num2str(handles.Isrcchild));
guidata(h,handles)
return
function varargout = edit_Jsrcchild_Callback(h, eventdata, handles, varargin)
set(handles.edit_Jsrcchild,'String',num2str(handles.Jsrcchild));
guidata(h,handles)
return
% Create the croco.in.# file
function create_crocoin_Callback(h, eventdata, handles, varargin)
[filename,pathname]=uigetfile({'*.in*','All input files (*.in*)';...
		    '*.*','All Files (*.*)'},'PARENT INPUT FILE');
if isequal([filename,pathname],[0,0])
  return
end
crocoin_parent_name=fullfile(pathname,filename);
lev=str2num(crocoin_parent_name(end));
if isempty(lev)
  crocoin_child_name=[crocoin_parent_name,'.1'];
else
  crocoin_child_name=[crocoin_parent_name(1:end-1),num2str(lev+1)];
end
oct_create_crocoin(crocoin_parent_name,crocoin_child_name,handles.rcoeff,lev)
guidata(h,handles)
return
% Create the Agrif_FixedGrids.in file
function agrif_fixed_grid_Callback(h, eventdata, handles, varargin)
oct_create_agrif_fixedgrids_in(handles.imin,handles.imax,handles.jmin,...
                           handles.jmax,handles.rcoeff)
guidata(h,handles)
return
