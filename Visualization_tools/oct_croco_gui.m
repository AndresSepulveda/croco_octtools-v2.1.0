function varargout = oct_croco_gui(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OCT_CROCO_GUI  Visualization of CROCO model outputs (Octave version)
%
%  oct_croco_gui                         % asks for the history file
%  oct_croco_gui('croco_his.nc')         % grid read in the history file
%  oct_croco_gui('croco_avg.nc','croco_grd.nc')
%  fig = oct_croco_gui(...)
%
%  Octave version (Sep-2026) of croco_gui.m. Octave cannot read the
%  croco_gui.fig file: the window is built by code (build_gui) with the
%  same layout, tags, menus and callbacks. The NetCDF files are read
%  with the netcdf.* API of the octave-netcdf package (oct_get_var,
%  oct_get_hslice, oct_get_depths...). Needs the qt graphics toolkit
%  (octave with GUI or octave --no-gui, not octave-cli).
%
%  Menus: History file, Grid file, Coastline file, Town names file,
%         View bathymetry.
%  Mouse selections (Vertical section, Hovmuller, Time series, Vertical
%  profile) use ginput on the map: click the 2 ends of the section or
%  the point of the profile/time series.
%  Animation: the frames are saved as PNG files in <var>_z<level>_frames/
%  and assembled in an animated GIF (and an MP4 if ffmpeg is installed).
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
%  Copyright (c) 2002-2006 by Pierrick Penven
%  e-mail:Pierrick.Penven@ird.fr
%
%  Updated 02-Nov-2006 by Pierrick Penven (Yorig)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
isfile_arg = (nargin>=1) && ischar(varargin{1}) && ...
             (exist(varargin{1},'file')==2) && ~isempty(regexp(varargin{1},'\.nc','once'));
if nargin==0 || isfile_arg
  if ~any(strcmp(graphics_toolkit(),{'qt','fltk'}))
    try
      graphics_toolkit('qt');
    end
  end
  fig = build_gui();
  handles = guidata(fig);
  handles = reset_handles(fig,handles);
  if isfile_arg
    gfile = '';
    if nargin>=2, gfile = varargin{2}; end
    open_hisfile(fig,handles,varargin{1},gfile);
  else
    hisfile_callback(fig,[],handles);
  end
  if nargout > 0
    varargout{1} = fig;
  end
elseif ischar(varargin{1})                % INVOKE NAMED SUBFUNCTION OR CALLBACK
  try
    [varargout{1:nargout}] = feval(varargin{:});  % FEVAL switchyard
  catch err
    disp(err.message);
  end
end
return

function fig = build_gui()
%
% Layout of croco_gui.fig (normalized positions, same tags and callbacks)
%
bg=[0.94 0.94 0.94];
fig=figure('Units','normalized','Position',[0.1 0.06 0.62 0.86],'Name','CROCO HORIZONTAL PLOTTER',...
  'NumberTitle','off','MenuBar','none','ToolBar','figure','Color',bg,'IntegerHandle','off',...
  'Tag','figure1','HandleVisibility','callback','CloseRequestFcn',{@dispatch,'close_Callback'});
handles=struct('figure1',fig);
handles.axes1=axes('Parent',fig,'Units','normalized','Position',[0.165 0.322 0.666 0.634],'Tag','axes1');
handles.axes2=axes('Parent',fig,'Units','normalized','Position',[0.842 0.402 0.019 0.485],'Tag','axes2','Visible','off');
menus={...
  'hisfile','History file','hisfile_callback';...
  'gridfile','Grid file','gridfile_callback';...
  'coastfile','Coastline file','coastfile_callback';...
  'townfile','Town names file','townfile_callback';...
  'viewtopo','View bathymetry','viewtopo_Callback';...
  };
for k=1:size(menus,1)
  handles.(menus{k,1})=uimenu(fig,'Label',menus{k,2},'Tag',menus{k,1},'Callback',{@dispatch,menus{k,3}});
end
ctl={...
  'text2','text',{'Vertical Level:','>0 : S-level','<0 : Depth','=0 : ubar vec'},[0.9035 0.5794 0.1002 0.0652],'';...
  'update','pushbutton','Reset plot',[0.0248 0.9645 0.1101 0.0332],'update_Callback';...
  'listvar','listbox',{'Open ','history ','file'},[0.0012 0.6291 0.1101 0.3104],'listvar_Callback';...
  'null','text','CROCO variables',[-0.0012 0.9396 0.12 0.0201],'';...
  'pushbutton2','pushbutton','<<',[0.4501 0.2709 0.0297 0.032],'downtindex_Callback';...
  'uptindex','pushbutton','>>',[0.5194 0.2709 0.0297 0.032],'uptindex_Callback';...
  'edittindex','edit','1',[0.4798 0.2709 0.0396 0.032],'edittindex_Callback';...
  'editvlev','edit','-10',[0.9233 0.6777 0.0594 0.0332],'editvlev_Callback';...
  'text3','text','Time index',[0.4526 0.2496 0.0903 0.0213],'';...
  'upvlevel','pushbutton','^',[0.9381 0.7121 0.0297 0.0332],'upvlevel_Callback';...
  'pushbutton5','pushbutton','v',[0.9381 0.6434 0.0297 0.0332],'downvlevel_Callback';...
  'editlatmin','edit','-99',[0.9332 0.4076 0.0396 0.0332],'editlatmin_Callback';...
  'text4','text',{'Latitude','South'},[0.9183 0.3412 0.0705 0.032],'';...
  'uplatmin','pushbutton','^',[0.9381 0.4419 0.0297 0.0332],'uplatmin_Callback';...
  'pushbutton8','pushbutton','v',[0.9381 0.3732 0.0297 0.0332],'downlatmin_Callback';...
  'editlatmax','edit','99',[0.9332 0.84 0.0396 0.0332],'editlatmax_Callback';...
  'uplatmax','pushbutton','^',[0.9381 0.8744 0.0297 0.0332],'uplatmax_Callback';...
  'downlatmax','pushbutton','v',[0.9381 0.8057 0.0297 0.0332],'downlatmax_Callback';...
  'downlonmin','pushbutton','<<',[0.2298 0.2709 0.0297 0.032],'downlonmin_Callback';...
  'uplonmin','pushbutton','>>',[0.2991 0.2709 0.0297 0.032],'uplonmin_Callback';...
  'editlonmin','edit','-99',[0.2595 0.2709 0.0396 0.032],'editlonmin_Callback';...
  'text6','text',{'Longitude','West'},[0.2372 0.2389 0.0804 0.032],'';...
  'pushbutton13','pushbutton','<<',[0.663 0.2709 0.0297 0.032],'downlonmax_Callback';...
  'uplonmax','pushbutton','>>',[0.7323 0.2709 0.0297 0.032],'uplonmax_Callback';...
  'editlonmax','edit','99',[0.6927 0.2709 0.0396 0.032],'editlonmax_Callback';...
  'text7','text',{'Longitude','East'},[0.6704 0.2389 0.0804 0.032],'';...
  'downcstep','pushbutton','<<',[0.203 0.1872 0.0297 0.032],'downcstep_Callback';...
  'upcstep','pushbutton','>>',[0.2723 0.1872 0.0297 0.032],'upcstep_Callback';...
  'editcstep','edit','0',[0.2327 0.1872 0.0396 0.032],'editcstep_Callback';...
  'text8','text',{'Vectors','<0: Streamlines',' 0: no vector'},[0.1994 0.128 0.1004 0.06],'';...
  'slidercscale','slider',{},[0.3149 0.1643 0.1004 0.0237],'slidercscale_Callback';...
  'editcscale','edit','1',[0.3342 0.1872 0.0606 0.032],'editcscale_Callback';...
  'text9','text','Vectors scale',[0.3124 0.1445 0.1077 0.0213],'';...
  'downcunit','pushbutton','<<',[0.422 0.1872 0.0297 0.032],'downcunit_Callback';...
  'pushbutton18','pushbutton','>>',[0.4913 0.1872 0.0297 0.032],'upcunit_Callback';...
  'editcunit','edit','0.1',[0.4517 0.1872 0.0396 0.032],'editcunit_Callback';...
  'text10','text',{'Vector unit','(m/s)'},[0.4332 0.1457 0.0804 0.0427],'';...
  'editcolmin','edit','',[0.6621 0.1872 0.0705 0.032],'editcolmin_Callback';...
  'editcolmax','edit','',[0.7327 0.1872 0.0705 0.032],'editcolmax_Callback';...
  'editncol','edit','10',[0.8329 0.1872 0.0396 0.032],'editncol_Callback';...
  'text11','text','Color min',[0.6473 0.1671 0.0804 0.0213],'';...
  'text12','text','Color max',[0.7339 0.1671 0.0804 0.0213],'';...
  'text13','text',{'Number of ','color levels'},[0.802 0.1457 0.1002 0.0427],'';...
  'pcolor','pushbutton','pcolor',[0.2048 0.0383 0.0804 0.032],'pcolor_Callback';...
  'contourf','pushbutton','contourf',[0.2048 0.0063 0.0804 0.032],'contourf_Callback';...
  'contour','pushbutton','contour',[0.2852 0.0715 0.0804 0.032],'contour_Callback';...
  'downncol','pushbutton','<<',[0.8032 0.1872 0.0297 0.032],'downncol_Callback';...
  'upncol','pushbutton','>>',[0.8725 0.1872 0.0297 0.032],'upncol_Callback';...
  'buttonplot','pushbutton','Separate plot',[0.4183 0.0498 0.1002 0.0379],'outplot_Callback';...
  'editlongname','edit','Variable name',[0.729 0.0794 0.2512 0.0273],'edit13_Callback';...
  'editunits','edit','Unit',[0.729 0.0521 0.2512 0.0273],'edit14_Callback';...
  'editdate','edit','Date',[0.729 0.0249 0.2512 0.0273],'editdate_Callback';...
  'text16','text',{'Latitude ','North'},[0.9183 0.7737 0.0705 0.032],'';...
  'pushbutton25','pushbutton','Reset colors',[0.5644 0.1872 0.0978 0.032],'resetcolors_Callback';...
  'text17','text','Name :',[0.6646 0.0806 0.0606 0.0213],'';...
  'text18','text','Unit :',[0.6584 0.0533 0.0606 0.0213],'';...
  'text19','text','Date :',[0.6584 0.0249 0.0606 0.0213],'';...
  'text20','text','Plot style:',[0.2048 0.0786 0.0804 0.0213],'';...
  'editnptsW','edit','1',[0.0309 0.1576 0.0297 0.032],'editnptsW_Callback';...
  'editnptsE','edit','1',[0.0606 0.1576 0.0297 0.032],'editnptsE_Callback';...
  'editnptsN','edit','1',[0.12 0.1576 0.0297 0.032],'editnptsN_Callback';...
  'editnptsS','edit','1',[0.0903 0.1576 0.0297 0.032],'editnptsS_Callback';...
  'text21','text','W',[0.0309 0.1363 0.0297 0.0213],'';...
  'text22','text','E',[0.0606 0.1363 0.0297 0.0213],'';...
  'text24','text','N',[0.12 0.1363 0.0297 0.0213],'';...
  'text25','text','Remove boundary points:',[0.0161 0.1876 0.151 0.032],'';...
  'text26','text','S',[0.0903 0.1363 0.0297 0.0213],'';...
  'editisobath','edit','0 500 1000',[-0.0012 0.2358 0.1807 0.032],'editisobath_Callback';...
  'text27','text','Plot isobaths (m):',[0.0136 0.2678 0.151 0.0213],'';...
  'print','pushbutton','Print',[0.5186 0.0498 0.1002 0.0379],'print_Callback';...
  'listdvar','listbox',{'          ','*Ke','*Rho','*Rho_pot','*Bvf','*Vort','*Pot_vort','*Psi','*Speed','*Transport','*Okubo','*Chla','*z_SST-1C','*z_rho-1.25','*z_max_bvf','*z_max_dTdZ','*z_20C','*z_15C','*z_sig27','*z_sig26','*Lorbacher_MLD','*rfactor',''},[0.0012 0.2986 0.1101 0.3104],'listdvar_Callback';...
  'null','text','Derived variables',[-0.0012 0.609 0.12 0.0201],'';...
  'vsection','pushbutton','Vertical section',[0.0322 0.0972 0.12 0.032],'vsection_Callback';...
  'hovmull','pushbutton','Hovmuller',[0.0322 0.0664 0.12 0.032],'hovmull_Callback';...
  'pushbutton30','pushbutton','gray cont.',[0.2852 0.0395 0.0804 0.032],'graycontour_Callback';...
  'editcoef','edit','1',[0.9183 0.1872 0.0606 0.032],'editcoef_Callback';...
  'text29','text',{'Coefficient','(cff * var)'},[0.8998 0.1457 0.1002 0.0427],'';...
  'remcoast','pushbutton','Remove coast',[0.1349 0.9645 0.1101 0.0332],'remcoast_Callback';...
  'remtowns','pushbutton','Remove towns',[0.245 0.9645 0.1101 0.0332],'remtowns_Callback';...
  'edittitle','edit','Title',[0.3824 0.9645 0.2512 0.0332],'edittitle_Callback';...
  'zoom_in','pushbutton','Zoom in',[0.9134 0.5237 0.0804 0.032],'zoom_in_Callback';...
  'zoom_out','pushbutton','Zoom out',[0.9134 0.4964 0.0804 0.032],'zoom_out_Callback';...
  'animation','pushbutton','Animation',[0.4084 0.0059 0.1101 0.0332],'animation_Callback';...
  'editskipanim','edit','1',[0.5186 0.0059 0.0297 0.0332],'editskipanim_Callback';...
  'text30','text','Step/image',[0.5507 0.0083 0.0891 0.0261],'';...
  'pushbutton38','pushbutton','seawifs',[0.2852 0.0075 0.0804 0.032],'seawifs_Callback';...
  'editnlev','edit','0',[0.9457 0.2571 0.0297 0.0332],'editnlev_Callback';...
  'text31','text',{'Number of','child models : '},[0.8469 0.2579 0.1002 0.0355],'';...
  'plotbutton','pushbutton','PLOT',[0.4183 0.0865 0.1002 0.0379],'plotbutton_Callback';...
  'holdplot','pushbutton','Hold plot',[0.5186 0.0865 0.1002 0.0379],'holdplot_Callback';...
  'tseries','pushbutton','Time series',[0.0322 0.0344 0.12 0.032],'tseries_Callback';...
  'vprofile','pushbutton','Vertical profile',[0.0322 0.0047 0.12 0.032],'vprofile_Callback';...
  'text32','text','Year origin (nan=climato): ',[0.6733 0.9716 0.1906 0.0201],'';...
  'edit_Yorig','edit','NaN',[0.8639 0.9656 0.0804 0.032],'edit_Yorig_Callback';...
  };
for k=1:size(ctl,1)
  st=ctl{k,2};
  args={'Parent',fig,'Units','normalized','Style',st,'String',ctl{k,3},...
        'Position',ctl{k,4},'Tag',ctl{k,1},'FontSize',8};
  if any(strcmp(st,{'edit','listbox'}))
    args=[args,{'BackgroundColor',[1 1 1]}];
  elseif strcmp(st,'text')
    args=[args,{'BackgroundColor',bg,'FontSize',7}];
  end
  if ~isempty(ctl{k,5})
    args=[args,{'Callback',{@dispatch,ctl{k,5}}}];
  end
  hk=uicontrol(args{:});
  tag=ctl{k,1};
  if ~strcmp(tag,'null') && ~isempty(tag)
    handles.(tag)=hk;
  end
end
set(handles.slidercscale,'Min',0,'Max',1,'Value',0.01);
set(handles.listvar,'Max',1,'Value',1);
set(handles.listdvar,'Max',1,'Value',1);
guidata(fig,handles);
return

% ------------------------------------------------------------
%  Generic callback: get the handles, call the named callback.
%  Errors are displayed and the GUI stays alive.
% ------------------------------------------------------------
function dispatch(src,evt,cbname)
fig = ancestor(src,'figure');
handles = guidata(fig);
try
  feval(cbname,fig,evt,handles);
catch err
  disp(['CROCO_GUI error in ',cbname,': ',err.message]);
  for k=1:min(3,numel(err.stack))
    disp(['   ',err.stack(k).name,' line ',num2str(err.stack(k).line)])
  end
  errordlg(err.message,'CROCO_GUI');
end
return
% ------------------------------------------------------------
% Callback for the Close button
% ------------------------------------------------------------
function varargout = close_Callback(h, eventdata, handles, varargin_id)
delete(handles.figure1)
return
% ------------------------------------------------------------
% Text boxes without action (name, unit, date, title)
% ------------------------------------------------------------
function varargout = edit13_Callback(h, eventdata, handles, varargin_id)
return
function varargout = edit14_Callback(h, eventdata, handles, varargin_id)
return
function varargout = editdate_Callback(h, eventdata, handles, varargin_id)
return
function varargout = edittitle_Callback(h, eventdata, handles, varargin_id)
return
%% ------------------------------------------------------------
% ------------------------------------------------------------
%   Reset everything
% ------------------------------------------------------------
% ------------------------------------------------------------
function handles = reset_handles(h,handles)
handles.hisfile='';
handles.gridfile='';
handles.L=[];
handles.M=[];
handles.N=[];
handles.T=[];
handles.hmax=[];
handles.ng=[];
handles.coastfile=[];
handles.vname='zeta';
handles.vlevel=-10;
handles.pltstyle=1;
handles.lonmin=-99;
handles.tindex=1;
handles.lonmax=99;
handles.latmin=-99;
handles.latmax=99;
handles.cstep=0;
handles.cscale=1;
handles.cunit=0.1;
handles.colmin=[];
handles.colmax=[];
handles.ncol=10;
handles.coef=1;
handles.gridlevs=0;
handles.day=[];
handles.month=[];
handles.year=[];
handles.thedate='';
handles.rempts=[1 1 1 1];
handles.units='';
handles.longname='';
handles.townfile=[];
handles.isobath='0 200 1000';
handles.skipanim=1;
handles.plot=1;
handles.Yorig=NaN;
set(handles.slidercscale,'Value',handles.cscale/100);
set(handles.editcoef,'String',num2str(handles.coef))
set(handles.editlonmin,'String',num2str(round(handles.lonmin*10)/10))
set(handles.editlonmax,'String',num2str(round(handles.lonmax*10)/10))
set(handles.editlatmin,'String',num2str(round(handles.latmin*10)/10))
set(handles.editlatmax,'String',num2str(round(handles.latmax*10)/10))
guidata(h,handles)
return
% ------------------------------------------------------------
% ------------------------------------------------------------

% ------------------------------------------------------------
% -------------------- OPEN FILES ----------------------------
% ------------------------------------------------------------
% Callback for Open History file
% ------------------------------------------------------------
function varargout = hisfile_callback(h, eventdata, handles, varargin_id)
[filename, pathname] = uigetfile( ...
	{'*.nc', 'All netcdf-Files (*.nc)'; ...
		'*.*','All Files (*.*)'}, ...
	'SELECT A CROCO HISTORY NETCDF FILE');
if isequal(filename,0)
  return
end
open_hisfile(h,handles,fullfile(pathname,filename),'');
return
% ------------------------------------------------------------
function open_hisfile(h,handles,hisfile,gridfile)
try
  ncid = netcdf.open(hisfile, 'NC_NOWRITE');
catch
  errordlg(['This is not a netcdf file: ',hisfile],'CROCO_GUI');
  return
end
try
  netcdf.inqVarID(ncid,'pm');
  haspm = 1;
catch
  haspm = 0;
end
netcdf.close(ncid);
handles = reset_handles(h,handles);
handles.hisfile = hisfile;
if ~isempty(gridfile)
  handles.gridfile = gridfile;
elseif ~haspm
  guidata(h,handles)
  gridfile_callback(h, [], handles);
  return
end
guidata(h,handles)
update_listbox(h, [], handles);
return
% ------------------------------------------------------------
% Callback for Open Grid file
% ------------------------------------------------------------
function varargout = gridfile_callback(h, eventdata, handles, varargin_id)
[filename, pathname] = uigetfile( ...
	{'*.nc', 'All netcdf-Files (*.nc)'; ...
		'*.*','All Files (*.*)'}, ...
	'SELECT A CROCO GRID NETCDF FILE');
if isequal(filename,0)
  return
end
handles.gridfile = fullfile(pathname,filename);
try
  ncid = netcdf.open(handles.gridfile, 'NC_NOWRITE');
  netcdf.close(ncid);
catch
  errordlg(['This is not a netcdf file: ',handles.gridfile],'CROCO_GUI');
  handles.gridfile='';
  return
end
guidata(h,handles)
if ~isempty(handles.hisfile)
  update_listbox(h, eventdata, handles);
end
return
% ------------------------------------------------------------
% Callback for Open Coastfile
% ------------------------------------------------------------
function varargout = coastfile_callback(h, eventdata, handles, varargin_id)
% Use UIGETFILE to allow for the selection of a custom address book.
[filename, pathname] = uigetfile( ...
	{'*.mat', 'All MAT-Files (*.mat)'; ...
		'*.*','All Files (*.*)'}, ...
	'SELECT A GHRR COASTLINE FILE');
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
  return
% Otherwise construct the fullfilename and Check and load the file.
else
  handles.coastfile = fullfile(pathname,filename);
  if handles.plot==1
    inplot(h, eventdata, handles);
  else
    disp('Push ''PLOT'' button')
  end
  guidata(h,handles)
end
return
% ------------------------------------------------------------
% Callback for remove the coastline
% ------------------------------------------------------------
function varargout = remcoast_Callback(h, eventdata, handles, varargin_id)
handles.coastfile=[];
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
% Callback for Open Townfile
% ------------------------------------------------------------
function varargout = townfile_callback(h, eventdata, handles, varargin_id)
% Use UIGETFILE to allow for the selection of a custom address book.
[filename, pathname] = uigetfile( ...
	{'*.dat', 'All MAT-Files (*.dat)'; ...
		'*.*','All Files (*.*)'}, ...
	'SELECT A ASCII TOWN FILE');
% If "Cancel" is selected then return
if isequal([filename,pathname],[0,0])
  return
% Otherwise construct the fullfilename and Check and load the file.
else
  handles.townfile = fullfile(pathname,filename);
  if handles.plot==1
    inplot(h, eventdata, handles);
  else
    disp('Push ''PLOT'' button')
  end
  guidata(h,handles)
end
return
% ------------------------------------------------------------
% Callback for remove the towns
% ------------------------------------------------------------
function varargout = remtowns_Callback(h, eventdata, handles, varargin_id)
handles.townfile=[];
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
% ------------------------------------------------------------
% ------------------------------------------------------------
% ------------------------------------------------------------

% ------------------------------------------------------------
% Callback for update button
% ------------------------------------------------------------
function varargout = update_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the uicontrol handles.pushbutton1.
handles=update_listbox(h, eventdata, handles);
guidata(h,handles)
return
% ------------------------------------------------------------
% Update the variable list box
% ------------------------------------------------------------
function handles = update_listbox(h, eventdata, handles, varargin_id)
%
% Variables with at least 3 dimensions (time + 2 horizontal)
%
ncid = netcdf.open(handles.hisfile, 'NC_NOWRITE');
[~,nvar] = netcdf.inq(ncid);
Varnames = {};
for v=0:nvar-1
  [vname,~,dimids] = netcdf.inqVar(ncid,v);
  if numel(dimids)>2
    Varnames{end+1} = vname;
  end
end
if isempty(Varnames)
  netcdf.close(ncid);
  error('No variable with a least 3 dimensions found')
end
index_selected = find(strcmp(Varnames,handles.vname));
if isempty(index_selected)
  disp([handles.vname,' not found...'])
  index_selected = 1;
  handles.vname = Varnames{1};
end
handles.colmin=[];
handles.colmax=[];
set(handles.editcolmin,'String','')
set(handles.editcolmax,'String','')
[handles.units,handles.longname] = get_units(ncid,handles.vname);
set(handles.editunits,'String',handles.units)
set(handles.editlongname,'String',handles.longname)
handles.coef=1;
set(handles.editcoef,'String',num2str(handles.coef))
set(handles.listvar,'String',Varnames,'Value',index_selected);
set(handles.listdvar,'Value',1);
%
% Number of levels and of records
%
try
  [~,handles.N] = netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
catch
  handles.N = 1;
end
handles.T = 0;
for tn={'time','time_counter','tclm_time','ocean_time'}
  try
    [~,handles.T] = netcdf.inqDim(ncid, netcdf.inqDimID(ncid, tn{1}));
  end
  if handles.T>0, break, end
end
if handles.T==0
  [~,~,~,unlimdim] = netcdf.inq(ncid);
  if unlimdim>=0
    [~,handles.T] = netcdf.inqDim(ncid, unlimdim);
  end
end
netcdf.close(ncid);
if handles.T==0
  error('No time dimension found')
end
if isempty(handles.gridfile)
  handles.gridfile=handles.hisfile;
end
%
% Grid: size, max depth, domain limits
%
ncid = netcdf.open(handles.gridfile, 'NC_NOWRITE');
[~,handles.L] = netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_rho'));
[~,handles.M] = netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_rho'));
handles.hmax = max(max(double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h')))));
lat = oct_rempoints(oct_readlat(ncid),handles.rempts);
lon = oct_rempoints(oct_readlon(ncid),handles.rempts);
netcdf.close(ncid);
handles.lonmin=min(min(lon));
handles.lonmax=max(max(lon));
handles.latmin=min(min(lat));
handles.latmax=max(max(lat));
set(handles.editlonmin,'String',num2str(round(handles.lonmin*10)/10))
set(handles.editlonmax,'String',num2str(round(handles.lonmax*10)/10))
set(handles.editlatmin,'String',num2str(round(handles.latmin*10)/10))
set(handles.editlatmax,'String',num2str(round(handles.latmax*10)/10))
handles.tindex=min(handles.tindex,handles.T);
set(handles.edittindex,'String',num2str(handles.tindex))
set(handles.editvlev,'String',num2str(handles.vlevel))
[~,nm,ext]=fileparts(handles.hisfile);
set(handles.figure1,'Name',['CROCO HORIZONTAL PLOTTER - ',nm,ext]);
guidata(h,handles)
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
return
% ------------------------------------------------------------
% Units and long name of a variable ('' if absent)
% ------------------------------------------------------------
function [units,longname]=get_units(ncid,vname)
units=''; longname='';
try
  vid=netcdf.inqVarID(ncid,vname);
catch
  return
end
try
  units=netcdf.getAtt(ncid,vid,'units');
end
try
  longname=netcdf.getAtt(ncid,vid,'long_name');
end
return
% ------------------------------------------------------------
% Callback for variable listbox
% ------------------------------------------------------------
function varargout = listvar_Callback(h, eventdata, handles, varargin_id)
list_entries = get(handles.listvar,'String');
index_selected = get(handles.listvar,'Value');
if length(index_selected) ~= 1 || ~iscell(list_entries) || isempty(handles.hisfile)
  errordlg('You must select 1 variable','Incorrect Selection','modal')
  return
end
handles.vname=list_entries{index_selected(1)};
handles.colmin=[];
set(handles.editcolmin,'String','');
handles.colmax=[];
set(handles.editcolmax,'String','');
ncid = netcdf.open(handles.hisfile, 'NC_NOWRITE');
[handles.units,handles.longname] = get_units(ncid,handles.vname);
netcdf.close(ncid);
set(handles.editunits,'String',handles.units)
set(handles.editlongname,'String',handles.longname)
handles.coef=1;
set(handles.editcoef,'String',num2str(handles.coef))
guidata(h,handles)
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
return
% ------------------------------------------------------------
% Callback for derived variable listbox
% ------------------------------------------------------------
function varargout = listdvar_Callback(h, eventdata, handles, varargin_id)
list_entries = get(handles.listdvar,'String');
index_selected = get(handles.listdvar,'Value');
if length(index_selected) ~= 1
	errordlg('You must select 1 variables','Incorrect Selection','modal')
else
  varname = list_entries{index_selected(1)};
  if ~isempty(strtrim(varname))
    handles.vname=varname;
    handles.colmin=[];
    set(handles.editcolmin,'String',num2str(handles.colmin));
    handles.colmax=[];
    set(handles.editcolmax,'String',num2str(handles.colmax));
    handles.units='';
    set(handles.editunits,'String',num2str(handles.units))
    handles.longname='';
    set(handles.editlongname,'String',num2str(handles.vname))
    handles.coef=1;
    set(handles.editcoef,'String',num2str(handles.coef))
    if handles.plot==1
      inplot(h, eventdata, handles);
    else
      disp('Push ''PLOT'' button')
    end
    guidata(h,handles)
  end 
end 
return
% ------------------------------------------------------------
% ------------------------------------------------------------
% ------------------------------------------------------------
% ------------------------------------------------------------

% ------------------------------------------------------------
% vertical levels
% ------------------------------------------------------------
function varargout = upvlevel_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the pushbutton 'up vertical level'
if handles.vlevel < 0.
   handles.vlevel=handles.vlevel+100;
   if handles.vlevel >= 0.
     handles.vlevel=handles.N;
   end
else
   handles.vlevel=handles.vlevel + 1;
   if handles.vlevel >= handles.N
     handles.vlevel=handles.N;
   end
end
set(handles.editvlev,'String',num2str(handles.vlevel))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = downvlevel_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the pushbutton 'down vertical level'
if handles.vlevel < 1
   handles.vlevel=handles.vlevel-100;
   if handles.vlevel <= -handles.hmax
     handles.vlevel=round(100-handles.hmax);
   end
else
   handles.vlevel=handles.vlevel - 1;
   if handles.vlevel < 1 
     handles.vlevel=handles.vlevel-100;
     if handles.vlevel <= 100-handles.hmax
       handles.vlevel=round(100-handles.hmax);
     end
   end
end
set(handles.editvlev,'String',num2str(handles.vlevel))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = editvlev_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the vlevel text box
handles.vlevel = str2num(get(handles.editvlev,'String'));
if handles.vlevel >= handles.N
  handles.vlevel=handles.N;
  set(handles.editvlev,'String',num2str(handles.vlevel))
end
if handles.vlevel <= 100-handles.hmax
  handles.vlevel=round(100-handles.hmax);
  set(handles.editvlev,'String',num2str(handles.vlevel))
end
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
% end vertical levels
% ------------------------------------------------------------

% ------------------------------------------------------------
% plot style (pcolor, contourf, etc..)
% ------------------------------------------------------------
function varargout = pcolor_Callback(h, eventdata, handles, varargin_id)
handles.pltstyle=1;
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = contourf_Callback(h, eventdata, handles, varargin_id)
handles.pltstyle=2;
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = contour_Callback(h, eventdata, handles, varargin_id)
handles.pltstyle=3;
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = graycontour_Callback(h, eventdata, handles, varargin_id)
handles.pltstyle=4;
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = seawifs_Callback(h, eventdata, handles, varargin_id)
handles.pltstyle=5;
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
% end plotbutton style
% ------------------------------------------------------------

% ------------------------------------------------------------
% lon min
% ------------------------------------------------------------
function varargout = uplonmin_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the pushbutton 'up longitude minimum'
handles.lonmin=handles.lonmin + 1;
if handles.lonmin >= handles.lonmax
  handles.lonmin=handles.lonmax-0.01;
end
set(handles.editlonmin,'String',num2str(round(handles.lonmin*10)/10))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = downlonmin_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the pushbutton 'down longitude minimum'
handles.lonmin=handles.lonmin - 1;
set(handles.editlonmin,'String',num2str(round(handles.lonmin*10)/10))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = editlonmin_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the lonmin text box
handles.lonmin = str2num(get(handles.editlonmin,'String'));
if handles.lonmin >= handles.lonmax
  handles.lonmin=handles.lonmax-0.01;
  set(handles.editlonmin,'String',num2str(handles.lonmin))
end
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
%  end lon min
% ------------------------------------------------------------

% ------------------------------------------------------------
% lon max
% ------------------------------------------------------------
function varargout = uplonmax_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the pushbutton 'up longitude maximum'
handles.lonmax=handles.lonmax + 1;
set(handles.editlonmax,'String',num2str(round(handles.lonmax*10)/10))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = downlonmax_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the pushbutton 'down longitude maximum'
handles.lonmax=handles.lonmax - 1;
if handles.lonmax <= handles.lonmin
  handles.lonmax=handles.lonmin+0.01;
end
set(handles.editlonmax,'String',num2str(round(handles.lonmax*10)/10))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = editlonmax_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the lonmax text box
handles.lonmax = str2num(get(handles.editlonmax,'String'));
if handles.lonmax <= handles.lonmin
  handles.lonmax=handles.lonmax+0.01;
  set(handles.editlonmax,'String',num2str(handles.lonmax))
end
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
%  end lon max
% ------------------------------------------------------------

% ------------------------------------------------------------
% lat min
% ------------------------------------------------------------
function varargout = uplatmin_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the pushbutton 'up latitude minimum'
handles.latmin=handles.latmin + 1;
if handles.latmin >= handles.latmax
  handles.latmin=handles.latmax-0.01;
end
set(handles.editlatmin,'String',num2str(round(handles.latmin*10)/10))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = downlatmin_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the pushbutton 'down latitude minimum'
handles.latmin=handles.latmin - 1;
set(handles.editlatmin,'String',num2str(round(handles.latmin*10)/10))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = editlatmin_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the latmin text box
handles.latmin = str2num(get(handles.editlatmin,'String'));
if handles.latmin >= handles.latmax
  handles.latmin=handles.latmax-0.01;
  set(handles.editlatmin,'String',num2str(handles.latmin))
end
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
%  end lat min
% ------------------------------------------------------------

% ------------------------------------------------------------
% lat max
% ------------------------------------------------------------
function varargout = uplatmax_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the pushbutton 'up latitude maximum'
handles.latmax=handles.latmax + 1;
set(handles.editlatmax,'String',num2str(round(handles.latmax*10)/10))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = downlatmax_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the pushbutton 'down latitude maximum'
handles.latmax=handles.latmax - 1;
if handles.latmax <= handles.latmin
  handles.latmax=handles.latmin+0.01;
end
set(handles.editlatmax,'String',num2str(round(handles.latmax*10)/10))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = editlatmax_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the latmax text box
handles.latmax = str2num(get(handles.editlatmax,'String'));
if handles.latmax <= handles.latmin
  handles.latmax=handles.latmax+0.01;
  set(handles.editlatmax,'String',num2str(handles.latmax))
end
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
%  end lat max
% ------------------------------------------------------------
% ------------------------------------------------------------
%  zoom in
% ------------------------------------------------------------
function varargout = zoom_in_Callback(h, eventdata, handles, varargin_id)
handles.latmin=handles.latmin + 1;
handles.latmax=handles.latmax - 1;
handles.lonmin=handles.lonmin + 1;
handles.lonmax=handles.lonmax - 1;
if handles.lonmax <= handles.lonmin
  handles.lonmax=handles.lonmax+1;
  handles.lonmin=handles.lonmin-1;
end
if handles.latmax <= handles.latmin
  handles.latmax=handles.latmax+1;
  handles.latmin=handles.latmin-1;
end
set(handles.editlatmin,'String',num2str(round(handles.latmin*10)/10))
set(handles.editlatmax,'String',num2str(round(handles.latmax*10)/10))
set(handles.editlonmin,'String',num2str(round(handles.lonmin*10)/10))
set(handles.editlonmax,'String',num2str(round(handles.lonmax*10)/10))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
%  end zoom in
% ------------------------------------------------------------
% ------------------------------------------------------------
%  zoom out
% ------------------------------------------------------------
function varargout = zoom_out_Callback(h, eventdata, handles, varargin_id)
handles.latmin=handles.latmin - 1;
handles.latmax=handles.latmax + 1;
handles.lonmin=handles.lonmin - 1;
handles.lonmax=handles.lonmax + 1;
set(handles.editlatmin,'String',num2str(round(handles.latmin*10)/10))
set(handles.editlatmax,'String',num2str(round(handles.latmax*10)/10))
set(handles.editlonmin,'String',num2str(round(handles.lonmin*10)/10))
set(handles.editlonmax,'String',num2str(round(handles.lonmax*10)/10))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
%  end zoom out
% ------------------------------------------------------------

% ------------------------------------------------------------
% tindex
% ------------------------------------------------------------
function varargout = uptindex_Callback(h, eventdata, handles, varargin_id)
handles.tindex=handles.tindex + 1;
if handles.tindex >= handles.T
  handles.tindex=handles.T;
end
set(handles.edittindex,'String',num2str(handles.tindex))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = downtindex_Callback(h, eventdata, handles, varargin_id)
handles.tindex=handles.tindex - 1;
if handles.tindex <= 1
  handles.tindex=1;
end
set(handles.edittindex,'String',num2str(handles.tindex))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = edittindex_Callback(h, eventdata, handles, varargin_id)
handles.tindex = floor(str2num(get(handles.edittindex,'String')));
if handles.tindex <= 1
  handles.tindex=1;
  set(handles.edittindex,'String',num2str(handles.tindex))
end
if handles.tindex >= handles.T
  handles.tindex=handles.T;
  set(handles.edittindex,'String',num2str(handles.tindex))
end
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
%  end tindex
% ------------------------------------------------------------

% ------------------------------------------------------------
% cstep
% ------------------------------------------------------------
function varargout = upcstep_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the pushbutton 'up cstep'
handles.cstep=handles.cstep + 1;
set(handles.editcstep,'String',num2str(handles.cstep))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = downcstep_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the pushbutton 'down cstep'
handles.cstep=handles.cstep - 1;
if handles.cstep < 0
  handles.cstep=-1;
end
set(handles.editcstep,'String',num2str(handles.cstep))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = editcstep_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the cstep text box
handles.cstep = floor(str2num(get(handles.editcstep,'String')));
if handles.cstep < 0
  handles.cstep=-1;
  set(handles.editcstep,'String',num2str(handles.cstep))
end
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
%  end cstep
% ------------------------------------------------------------

% ------------------------------------------------------------
% cscale
% ------------------------------------------------------------
function varargout = slidercscale_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the cscale slider
handles.cscale = 100*get(handles.slidercscale,'Value');
set(handles.editcscale,'String',num2str(handles.cscale,3))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = editcscale_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the cscale text box
handles.cscale = str2num(get(handles.editcscale,'String'));
if handles.cscale <= 1.e-6
  handles.cscale=1.e-6;
  set(handles.editcscale,'String',num2str(handles.cscale))
end
if handles.cscale >= 100
  handles.cscale=100;
  set(handles.editcscale,'String',num2str(handles.cscale))
end
set(handles.slidercscale,'Value',handles.cscale/100)
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
% end cscale
% ------------------------------------------------------------

% ------------------------------------------------------------
% cunit
% ------------------------------------------------------------
function varargout = upcunit_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the pushbutton 'up cunit'
handles.cunit=handles.cunit + 0.01;
set(handles.editcunit,'String',num2str(handles.cunit))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = downcunit_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the pushbutton 'down cunit'
handles.cunit=handles.cunit - 0.01;
if handles.cunit <= 0.01
  handles.cunit=0.01;
end
set(handles.editcunit,'String',num2str(handles.cunit))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = editcunit_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the cunit text box
handles.cunit = str2num(get(handles.editcunit,'String'));

if handles.cunit < 0.01
  handles.cunit=0.01;
  set(handles.editcunit,'String',num2str(handles.cunit))
end
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
%  end cunit
% ------------------------------------------------------------

% ------------------------------------------------------------
% ncol
% ------------------------------------------------------------
function varargout = upncol_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the pushbutton 'up ncol'
handles.ncol=handles.ncol + 1;
set(handles.editncol,'String',num2str(handles.ncol))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = downncol_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the pushbutton 'down ncol'
handles.ncol=handles.ncol - 1;
if handles.ncol <= 2
  handles.ncol=2;
end
set(handles.editncol,'String',num2str(handles.ncol))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = editncol_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the ncol text box
handles.ncol = floor(str2num(get(handles.editncol,'String')));
if handles.ncol <= 2
  handles.ncol=2;
  set(handles.editncol,'String',num2str(handles.ncol))
end
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
%  end ncol
% ------------------------------------------------------------

% ------------------------------------------------------------
%  colmin
% ------------------------------------------------------------
function varargout = editcolmin_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the ncol text box
handles.colmin = str2num(get(handles.editcolmin,'String'));
if handles.colmin >= handles.colmax
  handles.colmin=handles.colmax-0.01;
  set(handles.editcolmin,'String',num2str(handles.colmin))
end
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
%  end colmin
% ------------------------------------------------------------

% ------------------------------------------------------------
%  colmax
% ------------------------------------------------------------
function varargout = editcolmax_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the ncol text box
handles.colmax = str2num(get(handles.editcolmax,'String'));
if handles.colmax <= handles.colmin
  handles.colmax=handles.colmin+0.01;
  set(handles.editcolmax,'String',num2str(handles.colmax))
end
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
%  end colmax
% ------------------------------------------------------------

% ------------------------------------------------------------
%  resetcolors
% ------------------------------------------------------------
function varargout = resetcolors_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the uicontrol handles.pushbutton25.
handles.colmax = [];
handles.colmin = [];
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
%  end resetcolors
% ------------------------------------------------------------

% ------------------------------------------------------------
%  boundary points
% ------------------------------------------------------------
function varargout = editnptsW_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the uicontrol handles.editnptsW.
handles.rempts(1)=floor(min([((handles.L-4)/2)  ...
                         abs(str2num(get(handles.editnptsW,'String')))]));
set(handles.editnptsW,'String',num2str(handles.rempts(1)))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = editnptsE_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the uicontrol handles.editnptsE.
handles.rempts(2)=floor(min([((handles.L-4)/2)  ...
                         abs(str2num(get(handles.editnptsE,'String')))]));
set(handles.editnptsE,'String',num2str(handles.rempts(2)))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = editnptsS_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the uicontrol handles.editnptsS.
handles.rempts(3)=floor(min([((handles.M-4)/2)  ...
                         abs(str2num(get(handles.editnptsS,'String')))]));
set(handles.editnptsS,'String',num2str(handles.rempts(3)))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
function varargout = editnptsN_Callback(h, eventdata, handles, varargin_id)
% Stub for Callback of the uicontrol handles.editnptsN.
handles.rempts(4)=floor(min([((handles.M-4)/2)  ...
                         abs(str2num(get(handles.editnptsN,'String')))]));
set(handles.editnptsN,'String',num2str(handles.rempts(4)))
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
%  end boundary points
% ------------------------------------------------------------

% ------------------------------------------------------------
%  isobath
% ------------------------------------------------------------
function varargout = editisobath_Callback(h, eventdata, handles, varargin_id)
handles.isobath=get(handles.editisobath,'String');
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
%  end isobath
% ------------------------------------------------------------

% ------------------------------------------------------------
%  coeff
% ------------------------------------------------------------
function varargout = editcoef_Callback(h, eventdata, handles, varargin_id)
handles.coef=str2num(get(handles.editcoef,'String'));
guidata(h,handles)
resetcolors_Callback(h, eventdata, handles);
return
% ------------------------------------------------------------
%  end coeff
% ------------------------------------------------------------

% ------------------------------------------------------------
%  Number of embedded levels
% ------------------------------------------------------------
function varargout = editnlev_Callback(h, eventdata, handles, varargin_id)
handles.gridlevs=str2num(get(handles.editnlev,'String'));
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
%  end number of embedded levels
% ------------------------------------------------------------

% ------------------------------------------------------------
% ------------------------------------------------------------
% ------------------------------------------------------------
% ------------------------------------------------------------
%  Hold plot in the gui
% ------------------------------------------------------------
function holdplot_Callback(h, eventdata, handles, varargin_id)
handles.plot=0;
guidata(h,handles)
return
% ------------------------------------------------------------
%  Restore plot in the gui
% ------------------------------------------------------------
function plotbutton_Callback(h, eventdata, handles, varargin_id)
handles.plot=1;
guidata(h,handles)
inplot(h, eventdata, handles);
return
% ------------------------------------------------------------
%  Do a plotbutton in the GUI
% ------------------------------------------------------------
function varargout = inplot(h, eventdata, handles, varargin_id)
oct_horizslice(handles.hisfile,handles.vname,handles.tindex,...
           handles.vlevel,handles.rempts,handles.coef,handles.gridlevs,...
	   handles.colmin,handles.colmax,handles.lonmin,handles.lonmax,...
           handles.latmin,handles.latmax,handles.ncol,...
           handles.pltstyle,handles.isobath,handles.cstep,...
           handles.cscale,handles.cunit,handles.coastfile,...
           handles.townfile,handles.gridfile,h,handles,...
	   handles.Yorig)
return
% ------------------------------------------------------------
%  Separate figure (figure 1): cleared, File > Save / Save As open
%  oct_savefig (the file extension follows the selected format) with a
%  suggested name built from the plot type, variable, time and level
% ------------------------------------------------------------
function sepfig(handles,kind)
figure(1); clf
vn=handles.vname; vn(vn=='*')='';
switch kind
  case 'plot'
    base=sprintf('%s_t%d_z%g',vn,handles.tindex,handles.vlevel);
  case 'vsection'
    base=sprintf('vsection_%s_t%d',vn,handles.tindex);
  case 'hovmuller'
    base=sprintf('hovmuller_%s_z%g',vn,handles.vlevel);
  case 'tseries'
    base=sprintf('tseries_%s_z%g',vn,handles.vlevel);
  case 'vprofile'
    base=sprintf('vprofile_%s_t%d',vn,handles.tindex);
  otherwise
    base=vn;
end
oct_savefig('install',1,base);
return
% ------------------------------------------------------------
%  Do a plotbutton outside of the GUI
% ------------------------------------------------------------
function varargout = outplot_Callback(h, eventdata, handles, varargin_id)
sepfig(handles,'plot')
oct_horizslice(handles.hisfile,handles.vname,handles.tindex,...
           handles.vlevel,handles.rempts,handles.coef,handles.gridlevs,...
	   handles.colmin,handles.colmax,handles.lonmin,handles.lonmax,...
           handles.latmin,handles.latmax,handles.ncol,...
           handles.pltstyle,handles.isobath,handles.cstep,...
           handles.cscale,handles.cunit,handles.coastfile,...
           handles.townfile,handles.gridfile,[],[],...
	   handles.Yorig)
return
% ------------------------------------------------------------
%  Print (EPS and PNG of the separate plot)
% ------------------------------------------------------------
function varargout = print_Callback(h, eventdata, handles, varargin_id)
outplot_Callback(h, eventdata, handles)
[day,month,year,imonth,thedate]=...
oct_get_date(handles.hisfile,handles.tindex,handles.Yorig);
if handles.vname(1)=='*'
  vn=regexprep(handles.vname(2:end),'[^\w\-\.]','');
else
  vn=handles.vname;
end
fname=[vn,num2str(day),strtrim(month),num2str(year),'_z',num2str(handles.vlevel)];
disp(['EPS and PNG files : ',fname,'.eps ',fname,'.png'])
print(1,'-depsc2',[fname,'.eps'])
print(1,'-dpng','-r150',[fname,'.png'])
return
% ------------------------------------------------------------
% ------------------------------------------------------------

% ------------------------------------------------------------
% ------------------------------------------------------------
%    Animation
% ------------------------------------------------------------
% ------------------------------------------------------------
function varargout = animation_Callback(h, eventdata, handles, varargin_id)
oct_animation(handles)

return
function varargout = editskipanim_Callback(h, eventdata, handles, varargin_id)
handles.skipanim=floor(abs(str2num(get(handles.editskipanim,'String'))));
set(handles.editskipanim,'String',num2str(handles.skipanim))
guidata(h,handles)
return
% ------------------------------------------------------------
% ------------------------------------------------------------

% ------------------------------------------------------------
% --------------------- SPECIAL PLOTS ------------------------
% ------------------------------------------------------------
% ------------------------------------------------------------
%    Vertical section
% ------------------------------------------------------------
function varargout = vsection_Callback(h, eventdata, handles, varargin_id)
[lon1,lat1,lon2,lat2]=oct_get_mouse(handles);
sepfig(handles,'vsection')
oct_vertslice(handles.hisfile,handles.gridfile,[lon1 lon2],[lat1 lat2],...
          handles.vname,handles.tindex,handles.coef,[],[],...
	  handles.ncol,[],[],[],[],handles.pltstyle,[],[],...
	  handles.Yorig)
return
% ------------------------------------------------------------
%    Hovmuller diagram
% ------------------------------------------------------------
function varargout = hovmull_Callback(h, eventdata, handles, varargin_id)
[lon1,lat1,lon2,lat2]=oct_get_mouse(handles);
sepfig(handles,'hovmuller')
oct_hovmuller(handles.hisfile,handles.gridfile,[lon1 lon2],[lat1 lat2],...
          handles.vname,[1:handles.T],handles.vlevel,handles.coef,...
          [],[],handles.ncol,[],[],[],[],handles.pltstyle)
return
% ------------------------------------------------------------
%    Time series
% ------------------------------------------------------------
function varargout = tseries_Callback(h, eventdata, handles, varargin_id)
[lon0,lat0]=oct_get_mouse_1(handles);
sepfig(handles,'tseries')
oct_time_series(handles.hisfile,handles.gridfile,lon0,lat0,...
            handles.vname,handles.vlevel,handles.coef)
return
% ------------------------------------------------------------
%    Vertical profile
% ------------------------------------------------------------
function varargout = vprofile_Callback(h, eventdata, handles, varargin_id)
[lon0,lat0]=oct_get_mouse_1(handles);
sepfig(handles,'vprofile')
oct_vert_profile(handles.hisfile,handles.gridfile,lon0,lat0,...
             handles.vname,handles.tindex,handles.coef,...
	     handles.Yorig)
return
% ------------------------------------------------------------
%    View bathymetry
% ------------------------------------------------------------
function varargout = viewtopo_Callback(h, eventdata, handles, varargin_id)
handles.vname='h';
handles.vlevel=0;
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
return
% ------------------------------------------------------------
% ------------------------------------------------------------

% ------------------------------------------------------------
%  Year origin
% ------------------------------------------------------------
function edit_Yorig_Callback(h, eventdata, handles, varargin_id)
handles.Yorig=str2num(get(handles.edit_Yorig,'String'));
if handles.plot==1
  inplot(h, eventdata, handles);
else
  disp('Push ''PLOT'' button')
end
guidata(h,handles)
% ------------------------------------------------------------
% ------------------------------------------------------------



% ------------------------------------------------------------
% ------------------------------------------------------------
% ------------------------------------------------------------
% ------------------------------------------------------------
% ------------------------------------------------------------
% ---------------------------   fin   ------------------------
% ------------------------------------------------------------
% ------------------------------------------------------------
