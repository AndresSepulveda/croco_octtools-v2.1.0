function varargout = oct_easy(varargin)
%
%====================================================================
%  OCT_EASY  Interactive grid maker for CROCO (Octave version)
%
%  oct_easy            % opens the window (called by oct_make_grid)
%  fig = oct_easy;     % returns the figure handle
%
%  The grid parameters are initialised from crocotools_param.m
%  (lonmin, lonmax, latmin, latmax, dl) or from easy_grid_params.mat
%  if it exists (written by "Update").
%
%  Input : x/y size (km), rotation (deg, |rot|<=45), centre lon/lat
%          and mesh size dl (deg).
%  Output: number of interior points Lm, Mm.
%  "Update": recompute the grid, plot it (outline, grid, topo, pn, pm,
%            angle) and save the parameters in easy_grid_params.mat.
%  "Apply" : write the grid (lon/lat at rho/u/v/psi points) in grdname
%            (crocotools_param.m) and close the window. oct_make_grid
%            then goes on (topography, mask, smoothing).
%
%  Octave version (Oct-2026): Octave cannot read easy.fig nor use the
%  GUIDE functions (gui_mainfcn): the window is built by code with the
%  same layout, tags and callbacks. Needs the qt graphics toolkit
%  (octave with GUI or octave --no-gui, not octave-cli).
%
%  (c) 2008, Jeroen Molemaker
%      2019, P. Marchesiello, modified for croco_tools
%                             (called by oct_make_grid)
%====================================================================
%
if nargin==0
  fig = build_gui();
  handles = guidata(fig);
  try
    init_grid(handles);
  catch err
    disp(['EASY error: ',err.message]);
    errordlg(err.message,'EASY');
  end
  if nargout>0
    varargout{1} = fig;
  end
elseif ischar(varargin{1})                     % callbacks by name
  try
    [varargout{1:nargout}] = feval(varargin{:});
  catch err
    disp(err.message);
  end
end
return
%
%======================================================================
%
function fig = build_gui()
%
% Layout of easy.fig (normalized positions, same tags and callbacks)
%
old = findobj(0,'tag','oct_easy');
if ~isempty(old), delete(old); end
bg = [0.94 0.94 0.94];
fig = figure('Units','pixels','Position',[150 100 950 640],'Name','Easy grid maker',...
             'NumberTitle','off','MenuBar','none','ToolBar','none','Color',bg,...
             'IntegerHandle','off','Tag','oct_easy','HandleVisibility','callback');
handles = struct('figure1',fig);
handles.axes1 = axes('Parent',fig,'Units','normalized',...
                     'Position',[0.299 0.124 0.663 0.67],'Tag','axes1');
%
% File menu
%
handles.FileMenu = uimenu(fig,'Label','File','Tag','FileMenu');
uimenu(handles.FileMenu,'Label','Save figure ...','Callback',{@dispatch,'PrintMenuItem_Callback'});
uimenu(handles.FileMenu,'Label','Close','Callback',{@dispatch,'CloseMenuItem_Callback'});
%
% Buttons and plot type
%
handles.pushbutton1 = uicontrol(fig,'Style','pushbutton','Units','normalized',...
     'Position',[0.04 0.848 0.175 0.116],'String','Update','FontSize',14,...
     'FontWeight','bold','Tag','pushbutton1','Callback',{@dispatch,'pushbutton1_Callback'});
handles.pushbutton4 = uicontrol(fig,'Style','pushbutton','Units','normalized',...
     'Position',[0.745 0.843 0.206 0.118],'String','Apply','FontSize',14,...
     'FontWeight','bold','Tag','pushbutton4','Callback',{@dispatch,'pushbutton4_Callback'});
handles.popupmenu1 = uicontrol(fig,'Style','popupmenu','Units','normalized',...
     'Position',[0.403 0.86 0.206 0.06],'FontSize',12,'Tag','popupmenu1',...
     'String',{'outline','grid','topo','pn','pm','angle'},'Value',1,...
     'Callback',{@dispatch,'pushbutton1_Callback'});
uicontrol(fig,'Style','text','Units','normalized','Position',[0.403 0.925 0.206 0.04],...
     'String','Plot','FontSize',11,'BackgroundColor',bg);
%
% Edit boxes and labels
%
ctl = {...
  'edit1','edit','xsize',[0.0731 0.7386 0.1134 0.0700];...
  'edit2','edit','ysize',[0.0731 0.6467 0.1134 0.0700];...
  'edit3','edit','Rotation',[0.0731 0.5548 0.1134 0.0700];...
  'edit4','edit','Lon',[0.0731 0.4608 0.1134 0.0700];...
  'edit5','edit','Lat',[0.0731 0.3649 0.1134 0.0700];...
  'edit10','edit','dl',[0.0731 0.2635 0.1134 0.0613];...
  'edit6','edit','nx',[0.0731 0.1491 0.1134 0.0613];...
  'edit7','edit','ny',[0.0731 0.0837 0.1134 0.0613];...
  'text1','text','xsize (km)',[0.1900 0.7516 0.1000 0.0408];...
  'text2','text','ysize (km)',[0.1900 0.6600 0.1000 0.0408];...
  'text3','text','Rotation',[0.1900 0.5700 0.1000 0.0408];...
  'text4','text','Longitude',[0.1900 0.4758 0.1000 0.0408];...
  'text5','text','Latitude',[0.1900 0.3800 0.1000 0.0408];...
  'text8','text','Mesh size',[0.1900 0.2850 0.1000 0.0347];...
  'text11','text','(deg)',[0.1900 0.2471 0.1000 0.0347];...
  'text6','text','Lm',[0.1900 0.1593 0.0761 0.0347];...
  'text7','text','Mm',[0.1900 0.0960 0.0761 0.0347];...
  'text9','text','Output',[0.0015 0.2050 0.0761 0.0347];...
  'text13','text','Input',[0.0015 0.8100 0.0761 0.0347];...
  };
for k=1:size(ctl,1)
  args = {'Parent',fig,'Units','normalized','Style',ctl{k,2},'String',ctl{k,3},...
          'Position',ctl{k,4},'Tag',ctl{k,1},'FontSize',11};
  if strcmp(ctl{k,2},'edit')
    args = [args,{'BackgroundColor',[1 1 1]}];
  else
    args = [args,{'BackgroundColor',bg,'HorizontalAlignment','left'}];
  end
  handles.(ctl{k,1}) = uicontrol(args{:});
end
set([handles.text9 handles.text13],'FontWeight','bold');
set([handles.edit6 handles.edit7],'Enable','inactive');   % outputs
guidata(fig,handles);
return
%
%----------------------------------------------------------------------
%  Generic callback: errors are shown, the window stays open
%----------------------------------------------------------------------
%
function dispatch(src,evt,cbname)
fig = ancestor(src,'figure');
handles = guidata(fig);
try
  feval(cbname,fig,evt,handles);
catch err
  disp(['EASY error in ',cbname,': ',err.message]);
  set(handles.pushbutton1,'Enable','on');
  errordlg(err.message,'EASY');
end
return
%
%----------------------------------------------------------------------
%  Parameters of crocotools_param.m
%----------------------------------------------------------------------
%
function P = read_params()
str = evalc('crocotools_param');
P.lonmin = lonmin; P.lonmax = lonmax;
P.latmin = latmin; P.latmax = latmax;
P.dl = dl; P.grdname = grdname; P.CROCO_title = CROCO_title;
P.topofile = '';
if exist('topofile','var'), P.topofile = topofile; end
return
%
%----------------------------------------------------------------------
%  Opening: initial parameters and first plot (easy_OpeningFcn)
%----------------------------------------------------------------------
%
function init_grid(handles)
P = read_params();
R_earth = 6367442.76;   % Earth radius
deg2rad = pi/180;
rotate  = 0;
tra_lon = (P.lonmin+P.lonmax)/2.;
tra_lat = (P.latmin+P.latmax)/2.;
size_x  = R_earth*cos(tra_lat*deg2rad)*(P.lonmax-P.lonmin)*deg2rad;
size_y  = R_earth*(P.latmax-P.latmin)*deg2rad;
if size_x>100.e3, size_x=1.e3*floor(size_x/1.e3); end
if size_y>100.e3, size_y=1.e3*floor(size_y/1.e3); end
dl = P.dl;
dx = R_earth*dl*deg2rad;   % nx,ny grid sizes from the resolution dl (deg)
nx = floor(size_x/dx);
ny = floor(size_y/dx);
%
% Recover the parameters of a previous session if available
%
if exist('easy_grid_params.mat','file')
  S = load('easy_grid_params.mat');
  for v={'nx','ny','dl','size_x','size_y','rotate','tra_lon','tra_lat'}
    if isfield(S,v{1}), eval([v{1},'=S.',v{1},';']); end
  end
  disp(' Easy: parameters read in easy_grid_params.mat')
end
set(handles.edit1,'String',num2str(size_x/1.e3));  % size_x (km)
set(handles.edit2,'String',num2str(size_y/1.e3));  % size_y (km)
set(handles.edit3,'String',num2str(rotate));       % Rotation
set(handles.edit4,'String',num2str(tra_lon));      % Lon Center
set(handles.edit5,'String',num2str(tra_lat));      % Lat Center
set(handles.edit6,'String',num2str(nx));           % nx
set(handles.edit7,'String',num2str(ny));           % ny
set(handles.edit10,'String',num2str(dl));          % Mesh size dl (deg)
G = compute_grid(handles,0);
plot_grid(handles,G,1);
return
%
%----------------------------------------------------------------------
%  Read the edit boxes, update nx, ny and compute the grid
%----------------------------------------------------------------------
%
function G = compute_grid(handles,dosave)
R_earth = 6367442.76;
deg2rad = pi/180;
rad2deg = 180/pi;
size_x = str2double(get(handles.edit1,'String'))*1e3;
size_y = str2double(get(handles.edit2,'String'))*1e3;
rotate = str2double(get(handles.edit3,'String'));
tra_lon= str2double(get(handles.edit4,'String'));
tra_lat= str2double(get(handles.edit5,'String'));
dl     = str2double(get(handles.edit10,'String'));
vals = [size_x size_y rotate tra_lon tra_lat dl];
if any(~isfinite(vals))
  error('Easy: all the input boxes must contain numbers')
end
if size_x<=0 || size_y<=0 || dl<=0
  error('Easy: sizes and mesh size must be positive')
end
if abs(rotate) > 45
  rotate = sign(rotate)*45;
  set(handles.edit3,'String',num2str(rotate));
end
%
% nx,ny from the sizes and the mesh size
%
dx = R_earth*dl*deg2rad;
nx = max(floor(size_x/dx),5);
ny = max(floor(size_y/dx),5);
if nx==5, dl=(size_x/nx)/R_earth*rad2deg; end
[lon,lat,pm,pn,ang] = oct_easy_grid(nx,ny,dl,size_x,size_y,tra_lon,tra_lat,rotate);
%
% Correct nx,ny if needed
%
[Mp,Lp] = size(lon);
nx = Lp-2;
ny = Mp-2;
set(handles.edit6,'String',num2str(nx));
set(handles.edit7,'String',num2str(ny));
set(handles.edit10,'String',num2str(dl));
if dosave
  save('-v7','easy_grid_params.mat',...
       'nx','ny','dl','size_x','size_y','rotate','tra_lon','tra_lat')
end
G = struct('lon',lon,'lat',lat,'pm',pm,'pn',pn,'ang',ang,'nx',nx,'ny',ny,...
           'dl',dl,'size_x',size_x,'size_y',size_y,'rotate',rotate,...
           'tra_lon',tra_lon,'tra_lat',tra_lat);
return
%
%----------------------------------------------------------------------
%  Plot (outline, grid, topo, pn, pm, angle)
%----------------------------------------------------------------------
%
function plot_grid(handles,G,itype)
R_earth = 6367442.76;
rad2deg = 180/pi;
fig = handles.figure1;
set(0,'CurrentFigure',fig);
set(fig,'CurrentAxes',handles.axes1);
cla(handles.axes1,'reset');
delete(findobj(fig,'type','colorbar'));
set(fig,'Colormap',jet(256));
lon = G.lon; lat = G.lat;
radius = sqrt(G.size_x^2+G.size_y^2)/R_earth*rad2deg;
dll = 0.1*radius;
lonmin0 = min(lon(:)) - dll;  lonmax0 = max(lon(:)) + dll;
latmin0 = min(lat(:)) - dll;  latmax0 = max(lat(:)) + dll;
if G.rotate==0 || radius>40
  m_proj('miller cylindrical','longitude',[lonmin0 lonmax0],'latitude',[latmin0 latmax0]);
else
  m_proj('Gnomonic','lon',G.tra_lon,'lat',G.tra_lat,'rad',radius,'rec','on');
end
out_lon = [lon(1,:) lon(:,end)' lon(end,end:-1:1) lon(end:-1:1,1)'];
out_lat = [lat(1,:) lat(:,end)' lat(end,end:-1:1) lat(end:-1:1,1)'];
switch itype
  case 1                                        % outline
    m_grid
    hold on
    coast(G)
    m_plot(out_lon,out_lat,'r','linewidth',1.5)
    hold off
  case 2                                        % grid points
    m_grid
    hold on
    coast(G)
    m_plot(lon,lat,'.b')
    hold off
  case 3                                        % topography
    di = read_topo(lon,lat);
    di(di>10) = 10.;
    m_pcolor(lon,lat,di); shading flat; colorbar
    m_grid
    hold on
    coast(G)
    m_plot(out_lon,out_lat,'r')
    hold off
  case {4,5,6}                                  % pn, pm, angle
    names = {'pn','pm','ang'};
    m_pcolor(lon,lat,G.(names{itype-3})); shading flat; colorbar
    m_grid
    hold on
    coast(G)
    hold off
    title(names{itype-3})
end
drawnow
return
%
function coast(G)
%
% GSHHS coastline (full resolution for small domains). If the GSHHS
% files are not installed, the coarse m_map coastline is used.
%
try
  if min(G.size_x,G.size_y)<100.e3
    m_gshhs_f('patch',[.7 .7 .7],'edgecolor','k');
  else
    m_gshhs_i('patch',[.7 .7 .7],'edgecolor','k');
  end
catch
  try
    m_gshhs_l('patch',[.7 .7 .7],'edgecolor','k');
  catch
    try
      m_coast('patch',[.7 .7 .7],'edgecolor','k');
    catch
      disp(' Easy: no coastline data available')
    end
  end
end
return
%
function di = read_topo(lon,lat)
%
% Topography (topofile of crocotools_param) interpolated on the grid.
% Only the latitude band of the grid is read (octave-netcdf hyperslab,
% Fortran order (lon,lat), transposed to (lat,lon)).
%
P = read_params();
if isempty(P.topofile) || ~exist(P.topofile,'file')
  error(['Easy: topography file not found: ',P.topofile])
end
nc = netcdf.open(P.topofile,'NC_NOWRITE');
x = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'lon'))); x = x(:);
y = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'lat'))); y = y(:);
j = find(y>=min(lat(:))-1 & y<=max(lat(:))+1);
if isempty(j)
  netcdf.close(nc);
  error('Easy: the grid is outside the topography file')
end
vid = netcdf.inqVarID(nc,'topo');
d = double(netcdf.getVar(nc,vid,[0 j(1)-1],[numel(x) numel(j)])).';
netcdf.close(nc);
y = y(j);
%
% Longitudes on 3 periods so that any grid convention is covered
%
if max(x)-min(x) > 300
  xx = [x-360; x; x+360];
  dd = [d d d];
else
  xx = x; dd = d;
end
[xx,is] = unique(xx);
dd = dd(:,is);
di = interp2(xx,y,dd,lon,lat);
return
%
%----------------------------------------------------------------------
%  "Update" button (and plot type menu)
%----------------------------------------------------------------------
%
function pushbutton1_Callback(hObject, eventdata, handles)
set(handles.pushbutton1,'Enable','off'); drawnow
G = compute_grid(handles,1);
plot_grid(handles,G,get(handles.popupmenu1,'Value'));
set(handles.pushbutton1,'Enable','on');
return
%
%----------------------------------------------------------------------
%  "Apply" button: write the grid file and close the window
%----------------------------------------------------------------------
%
function pushbutton4_Callback(hObject, eventdata, handles)
bgClr = get(handles.pushbutton4,'BackgroundColor');
set(handles.pushbutton4,'BackgroundColor',[0 0 1]); drawnow
P = read_params();
G = compute_grid(handles,1);
nx = G.nx; ny = G.ny;
%
% Make grid file and fill lat,lon fields
%
oct_create_grid(nx+1,ny+1,P.grdname,P.CROCO_title)
lon_rho = G.lon;
lat_rho = G.lat;
[lon_u,lon_v,lon_p] = oct_rho2uvp(lon_rho);
[lat_u,lat_v,lat_p] = oct_rho2uvp(lat_rho);
ncid = netcdf.open(P.grdname,'NC_WRITE');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lon_rho'),lon_rho.');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lat_rho'),lat_rho.');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lon_u'),lon_u.');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lat_u'),lat_u.');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lon_v'),lon_v.');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lat_v'),lat_v.');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lon_psi'),lon_p.');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lat_psi'),lat_p.');
netcdf.close(ncid);
disp([' Easy: grid written in ',P.grdname,' (LLm = ',num2str(nx),...
      ', MMm = ',num2str(ny),')'])
pause(0.1)
set(handles.pushbutton4,'BackgroundColor',bgClr);
delete(handles.figure1)
return
%
%----------------------------------------------------------------------
%  File menu
%----------------------------------------------------------------------
%
function PrintMenuItem_Callback(hObject, eventdata, handles)
oct_savefig(handles.figure1,'easy_grid');
return
%
function CloseMenuItem_Callback(hObject, eventdata, handles)
selection = questdlg(['Close ',get(handles.figure1,'Name'),'?'],...
                     ['Close ',get(handles.figure1,'Name'),'...'],...
                     'Yes','No','Yes');
if strcmp(selection,'Yes')
  delete(handles.figure1)
end
return
