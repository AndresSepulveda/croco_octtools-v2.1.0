%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% OCT_MAKE_3D  3D views of a part of a CROCO domain (Octave GUI)
%
%   oct_make_3d
%   oct_make_3d(GRIDFILE)
%   oct_make_3d(GRIDFILE,HISFILE)
%   oct_make_3d(GRIDFILE,HISFILE,TOPOFILE)
%   fig = oct_make_3d(...)          % handle of the selection window
%
%   GRIDFILE : CROCO grid file (h, mask_rho, lon_rho, lat_rho, angle).
%              Default: CROCO_FILES/croco_grd.nc if it exists, else a
%              file dialog.
%   HISFILE  : CROCO output file (croco_his.nc, croco_avg.nc ...) with
%              the 3D variables (temp, salt, u, v, w, ...) and the
%              s-coordinate parameters. Default: CROCO_FILES/croco_his.nc
%              (or croco_avg.nc) if it exists. Without it, only the
%              bathymetry and the land mask are drawn.
%   TOPOFILE : topography file (etopo2.nc ..., read as in oct_make_grid /
%              oct_add_topo: lon, lat, topo positive up) for the relief
%              of the land cells (mask_rho=0). Default: topofile of the
%              crocotools_param.m of the current folder, if it exists.
%              '' : no topography. Button "Topo..." to change it.
%
%   SELECTION WINDOW: map of the bathymetry (land in brown) with black
%   bathymetry contours (checkbox, depths editable, default 0 50 100 200
%   500 m; 0 m = limit of the land mask; the same contours are used by
%   the 3D view). Drag a
%   rectangle on the map (or type the I/J ranges, 0-based grid indices)
%   to select the part of the domain, then "Make 3D". "Max cells"
%   limits the number of cells per direction of the 3D view (the grid is
%   subsampled with a constant stride).
%
%   3D WINDOW: bathymetry (z=-h, blue shades) and land mask (cells with
%   mask_rho=0): land topography of TOPOFILE (terrain colours, menu
%   View > Land topography to switch it off) or a brown plateau at sea
%   level, lighting, rotation with the
%   mouse, vertical exaggeration (auto or 1...2000), black bathymetry
%   contours (checkbox, depths editable, default 0 50 100 200 500 m;
%   0 m = limit of the land mask).
%   Menu "Add":
%     Horizontal section : variable at a constant depth (m, negative
%                          down; 0 = surface level), optional velocity
%                          vectors (u,v at the same depth, rotated to
%                          east/north with the grid angle);
%     Vertical section W-E (constant J), Vertical section S-N (constant
%                          I): variable along a grid line, from the
%                          bottom to the free surface;
%     Isosurface         : surface where the variable is equal to a
%                          value (on regular z levels), transparency.
%   Layers panel (right): list of the layers; for the selected layer:
%   variable (3D variables of the file and "speed"), position (depth,
%   J or I index, iso value), colour range (min/max, Auto), colormap,
%   transparency, visibility, velocity vectors (skip, scale), Remove.
%   The colour bar shows the selected layer.
%   Time: "<" / ">" or the time index box (all the layers are updated).
%   Animation: "Animate" plays the time steps "from"-"to" (button "Stop"
%   to interrupt); with "Record MP4" the frames (3D view and colour bar)
%   are written in the MP4 file (ffmpeg needed; if it is missing the PNG
%   frames are kept in a folder).
%   File menu: save the 3D view as PNG, close.
%
%   Arrays are kept in the (xi,eta,s) order of netcdf.getVar
%   (octave-netcdf), no transposition. Needs the qt graphics toolkit.
%
%  Octave version (Oct-2026). This file is part of CROCOTOOLS (GNU GPL).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fig_out=oct_make_3d(gridfile,hisfile,topofile)
if nargin<1 || isempty(gridfile)
  gridfile='';
  if exist(fullfile('CROCO_FILES','croco_grd.nc'),'file')
    gridfile=fullfile('CROCO_FILES','croco_grd.nc');
  else
    [fn,pth]=uigetfile('*.nc','Select the CROCO grid file...');
    if isequal(fn,0), if nargout>0, fig_out=[]; end, return, end
    gridfile=[pth,fn];
  end
end
if nargin<2
  hisfile='';
  for f={'croco_his.nc','croco_avg.nc'}
    if exist(fullfile('CROCO_FILES',f{1}),'file')
      hisfile=fullfile('CROCO_FILES',f{1}); break
    end
  end
end
if ~any(strcmp(graphics_toolkit(),{'qt','fltk'}))
  try
    graphics_toolkit('qt');
  end
end
old=findobj(0,'tag','oct_make_3d');
if ~isempty(old), delete(old); end
if nargin<3
  topofile=find_topo();
end
S=read_grid(gridfile);
S.hisfile=hisfile;
S=set_topo(S,topofile);
S.f3=[];
S.action=''; S.p0=[0 0];
S.maxcells=150;
S.i1=1; S.i2=S.Lp; S.j1=1; S.j2=S.Mp;
%
% Selection window
%
bg=[.94 .94 .94];
fig=figure('NumberTitle','off','Name','3D view: domain selection','tag','oct_make_3d',...
           'MenuBar','none','ToolBar','none','Color',bg,'IntegerHandle','off',...
           'Units','normalized','Position',[.05 .1 .6 .7]);
S.fig=fig;
S.ax=axes('Parent',fig,'Units','normalized','Position',[0.08 0.1 0.6 0.85]);
S.hmap=surface(S.xcor,S.ycor,zeros(size(S.xcor)),pad_cdata(map_rgb(S)),'Parent',S.ax,...
               'FaceColor','flat','EdgeColor','none');
hold(S.ax,'on');
S.hblk=plot(S.ax,NaN,NaN,'r-','LineWidth',2);
S.hrect=plot(S.ax,NaN,NaN,'m--','LineWidth',1.5);
S.hcontour=plot(S.ax,NaN,NaN,'k-','LineWidth',0.8);
hold(S.ax,'off');
set(S.ax,'Layer','top','Box','on','TickDir','out','DataAspectRatio',[1/S.coslat 1 1]);
axis(S.ax,[min(S.xcor(:)) max(S.xcor(:)) min(S.ycor(:)) max(S.ycor(:))]);
xlabel(S.ax,'Longitude'); ylabel(S.ax,'Latitude');
title(S.ax,'Drag a rectangle to select the area');
x0=0.72; w=0.26; y=0.92;
uicontrol(fig,'Style','text','Units','normalized','Position',[x0 y w .04],'String','Files',...
          'FontWeight','bold','BackgroundColor',bg);
y=y-0.05;
S.hgfile=uicontrol(fig,'Style','text','Units','normalized','Position',[x0 y w-.08 .04],...
          'String',short_name(S.gridfile),'HorizontalAlignment','left','BackgroundColor',bg);
uicontrol(fig,'Style','pushbutton','Units','normalized','Position',[x0+w-.075 y .075 .04],...
          'String','Grid...','Callback',@cb_opengrid);
y=y-0.05;
S.hhfile=uicontrol(fig,'Style','text','Units','normalized','Position',[x0 y w-.08 .04],...
          'String',short_name(S.hisfile),'HorizontalAlignment','left','BackgroundColor',bg);
uicontrol(fig,'Style','pushbutton','Units','normalized','Position',[x0+w-.075 y .075 .04],...
          'String','Output...','Callback',@cb_openhis);
y=y-0.05;
S.htfile=uicontrol(fig,'Style','text','Units','normalized','Position',[x0 y w-.08 .04],...
          'String',topo_label(S),'HorizontalAlignment','left','BackgroundColor',bg,...
          'TooltipString','Land topography (etopo2.nc ...), used on the cells with mask_rho=0');
uicontrol(fig,'Style','pushbutton','Units','normalized','Position',[x0+w-.075 y .075 .04],...
          'String','Topo...','Callback',@cb_opentopo);
y=y-0.06;
uicontrol(fig,'Style','text','Units','normalized','Position',[x0 y w .04],...
          'String','Area (0-based grid indices)','FontWeight','bold','BackgroundColor',bg);
lab={'I from','I to','J from','J to'}; fld={'i1','i2','j1','j2'};
for k=1:4
  y=y-0.05;
  uicontrol(fig,'Style','text','Units','normalized','Position',[x0 y .1 .04],'String',lab{k},...
            'HorizontalAlignment','left','BackgroundColor',bg);
  S.hidx(k)=uicontrol(fig,'Style','edit','Units','normalized','Position',[x0+.1 y .08 .045],...
            'String','','Callback',@cb_index);
end
y=y-0.05;
S.hlonlat=uicontrol(fig,'Style','text','Units','normalized','Position',[x0 y w .045],...
          'String','','HorizontalAlignment','left','BackgroundColor',bg);
y=y-0.06;
uicontrol(fig,'Style','pushbutton','Units','normalized','Position',[x0 y w .045],...
          'String','Whole grid','Callback',@cb_whole);
y=y-0.06;
uicontrol(fig,'Style','text','Units','normalized','Position',[x0 y .12 .04],'String','Max cells',...
          'HorizontalAlignment','left','BackgroundColor',bg);
S.hmaxc=uicontrol(fig,'Style','popupmenu','Units','normalized','Position',[x0+.12 y .1 .045],...
          'String',{'50','100','150','200','300','500'},'Value',3,'Callback',@cb_maxc);
y=y-0.06;
S.hcont=uicontrol(fig,'Style','checkbox','Units','normalized','Position',[x0 y w .04],...
          'String','Bathymetry contours (m)','Value',1,'BackgroundColor',bg,'Callback',@cb_selcontours,...
          'TooltipString','Black isobaths (0 m: land/sea mask limit); also used by the 3D view');
y=y-0.05;
S.hclev=uicontrol(fig,'Style','edit','Units','normalized','Position',[x0 y w .045],...
          'String','0 50 100 200 500','Callback',@cb_selcontours,...
          'TooltipString','Depths of the contours (m), separated by spaces or commas');
y=y-0.09;
uicontrol(fig,'Style','pushbutton','Units','normalized','Position',[x0 y w .06],...
          'String','Make 3D','FontWeight','bold','Callback',@cb_make3d);
S.hstat=uicontrol(fig,'Style','text','Units','normalized','Position',[x0 .01 w .1],...
          'String','','HorizontalAlignment','left','BackgroundColor',bg);
set(fig,'WindowButtonDownFcn',@cb_down,'WindowButtonMotionFcn',@cb_move,...
        'WindowButtonUpFcn',@cb_up,'CloseRequestFcn',@cb_close);
guidata(fig,S);
update_block(fig);
cb_selcontours(fig,[]);
if nargout>0, fig_out=fig; end
return
%
%======================================================================
%                          Local functions
%======================================================================
%
function v=ifelse(c,a,b)
if c, v=a; else, v=b; end
return
%
function s=short_name(f)
if isempty(f), s='(none)'; return, end
[~,n,e]=fileparts(f); s=[n,e];
return
%
function S=read_grid(gridfile)
if ~exist(gridfile,'file')
  error(['oct_make_3d: grid file not found: ',gridfile])
end
S.gridfile=gridfile;
nc=netcdf.open(gridfile,'NC_NOWRITE');
S.h=double(netcdf.getVar(nc,netcdf.inqVarID(nc,'h')));
S.lon=double(netcdf.getVar(nc,netcdf.inqVarID(nc,'lon_rho')));
S.lat=double(netcdf.getVar(nc,netcdf.inqVarID(nc,'lat_rho')));
[S.Lp,S.Mp]=size(S.h);
S.mask=ones(S.Lp,S.Mp);
try
  S.mask=double(netcdf.getVar(nc,netcdf.inqVarID(nc,'mask_rho'))>0.5);
end
S.angle=zeros(S.Lp,S.Mp);
try
  S.angle=double(netcdf.getVar(nc,netcdf.inqVarID(nc,'angle')));
end
netcdf.close(nc);
[S.xcor,S.ycor]=cell_corners(S.lon,S.lat);
S.coslat=cos(mean(S.lat(:))*pi/180);
return
%
function [xc,yc]=cell_corners(lon,lat)
xe=extrap(lon); ye=extrap(lat);
xc=0.25*(xe(1:end-1,1:end-1)+xe(2:end,1:end-1)+xe(1:end-1,2:end)+xe(2:end,2:end));
yc=0.25*(ye(1:end-1,1:end-1)+ye(2:end,1:end-1)+ye(1:end-1,2:end)+ye(2:end,2:end));
return
%
function e=extrap(a)
[L,M]=size(a);
e=zeros(L+2,M+2);
e(2:end-1,2:end-1)=a;
e(1,2:end-1)=2*a(1,:)-a(min(2,L),:);
e(end,2:end-1)=2*a(end,:)-a(max(L-1,1),:);
e(:,1)=2*e(:,2)-e(:,min(3,M+1));
e(:,end)=2*e(:,end-1)-e(:,max(end-2,1));
return
%
function c=pad_cdata(c)
c=cat(1,c,c(end,:,:));
c=cat(2,c,c(:,end,:));
return
%
function rgb=val2rgb(v,cmap,cr)
% true colours of V with the colormap CMAP and the range CR (NaN: grey)
n=size(cmap,1);
k=round((v-cr(1))/max(cr(2)-cr(1),eps)*(n-1))+1;
bad=~isfinite(k);
k(bad)=1;
k=min(max(k,1),n);
rgb=reshape(cmap(k(:),:),[size(v) 3]);
N=numel(v);
for c=1:3
  rgb(find(bad)+(c-1)*N)=0.7;
end
return
%
function cm=bathy_cmap()
% light blue (shallow) to dark blue (deep)
cm=interp1([0 0.5 1],[0.80 0.90 0.97; 0.35 0.60 0.80; 0.05 0.12 0.35],linspace(0,1,64));
return
%
function rgb=map_rgb(S)
h=S.h; h(S.mask==0)=NaN;
rgb=val2rgb(h,bathy_cmap(),[min(h(:)) max(h(:))]);
rgb=land_rgb(rgb,S.mask,S.topo);
return
%
function cm=terrain_cmap()
% land: green (low) - brown - grey - white (high)
cm=interp1([0 0.15 0.45 0.75 1],[0.20 0.55 0.25; 0.55 0.70 0.35; 0.62 0.48 0.28;...
           0.55 0.47 0.42; 0.96 0.96 0.96],linspace(0,1,64));
return
%
function rgb=land_rgb(rgb,mask,topo)
% colours of the land cells: brown, or terrain colours of the elevation
land=find(mask==0); N=numel(mask);
if isempty(land), return, end
if isempty(topo)
  lc=[0.75 0.68 0.5];
  for c=1:3, rgb(land+(c-1)*N)=lc(c); end
else
  e=max(topo,0);
  tmax=max(e(land)); if ~(tmax>0), tmax=1; end
  lr=val2rgb(e,terrain_cmap(),[0 tmax]);
  for c=1:3, rgb(land+(c-1)*N)=lr(land+(c-1)*N); end
end
return
%
%---------------------------------------------------------------------
% Land topography (etopo2.nc as in oct_make_grid / oct_add_topo)
%---------------------------------------------------------------------
%
function f=find_topo()
% topofile of crocotools_param.m (current folder), if it exists
f='';
if exist(fullfile(pwd,'crocotools_param.m'),'file')
  try
    f=param_topo();
  end
end
if ~isempty(f) && ~exist(f,'file'), f=''; end
return
%
function f=param_topo()
str=evalc('crocotools_param');
f='';
if exist('topofile','var'), f=topofile; end
return
%
function s=topo_label(S)
if isempty(S.topo)
  s='Topo: (none)';
else
  s=['Topo: ',short_name(S.topofile)];
end
return
%
function S=set_topo(S,topofile)
S.topofile=topofile; S.topo=[];
if isempty(topofile), return, end
if ~exist(topofile,'file')
  warning(['oct_make_3d: topography file not found: ',topofile]); return
end
try
  S.topo=read_topo(topofile,S.lon,S.lat);
  disp(sprintf('oct_make_3d: land topography from %s (max %.0f m on land)',topofile,...
       max([0; S.topo(S.mask==0)])))
catch err
  warning(['oct_make_3d: cannot read the topography in ',topofile,': ',err.message]);
  S.topo=[];
end
return
%
function e=read_topo(fname,lon,lat)
%
% Elevation (m, positive up) of the topography file at the points
% (lon,lat), read as in oct_add_topo: 1D lon/lat, variable topo(lon,lat)
% (netcdf.getVar order), longitudes -360/0/+360, the data are averaged
% (resolution halved) while they are finer than the grid
%
nc=netcdf.open(fname,'NC_NOWRITE');
vn={{'lon','lat','topo'},{'x','y','z'},{'lon','lat','elevation'},{'longitude','latitude','topo'}};
ok=0;
for k=1:numel(vn)
  try
    tlon=double(netcdf.getVar(nc,netcdf.inqVarID(nc,vn{k}{1})));
    tlat=double(netcdf.getVar(nc,netcdf.inqVarID(nc,vn{k}{2})));
    vid=netcdf.inqVarID(nc,vn{k}{3});
    ok=1; break
  end
end
if ~ok
  netcdf.close(nc); error('no lon/lat/topo variables');
end
tlon=tlon(:); tlat=tlat(:);
dgrid=max(median(abs(diff(lat(1,:)))),median(abs(diff(lon(:,1)))));
if ~(dgrid>0), dgrid=0.1; end
dl=max(2*dgrid,0.1);
lonmin=min(lon(:))-dl; lonmax=max(lon(:))+dl;
latmin=min(lat(:))-dl; latmax=max(lat(:))+dl;
j=find(tlat>=latmin & tlat<=latmax);
x=[]; T=[];
for sh=[-360 0 360]
  i=find(tlon+sh>=lonmin & tlon+sh<=lonmax);
  if isempty(i) || isempty(j), continue, end
  t=double(netcdf.getVar(nc,vid,[i(1)-1 j(1)-1],[numel(i) numel(j)]));
  x=[x; tlon(i)+sh]; T=[T; t];
end
netcdf.close(nc);
if isempty(T), error('the topography file does not cover the grid'); end
y=tlat(j);
if y(1)>y(end), y=flipud(y); T=fliplr(T); end
T(abs(T)>1e5)=NaN;
dg=abs(mean(diff(x)));
while dgrid>2*dg && numel(x)>3 && numel(y)>3     % smooth the finer data
  x=0.5*(x(1:2:end-1)+x(2:2:end)); y=0.5*(y(1:2:end-1)+y(2:2:end));
  T=0.25*(T(1:2:end-1,1:2:end-1)+T(2:2:end,1:2:end-1)+T(1:2:end-1,2:2:end)+T(2:2:end,2:2:end));
  dg=abs(mean(diff(x)));
end
e=interp2(x,y,T.',lon,lat,'linear');
e(isnan(e))=0;
return
%
function cb_opentopo(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
[fn,pth]=uigetfile('*.nc','Select the topography file (etopo2.nc ...), Cancel: none');
if isequal(fn,0)
  S=set_topo(S,'');
else
  set(S.hstat,'String','Reading the topography...'); drawnow;
  S=set_topo(S,[pth,fn]);
end
set(S.htfile,'String',topo_label(S));
set(S.hmap,'CData',pad_cdata(map_rgb(S)));
set(S.hstat,'String','');
guidata(fig,S);
return
%
%---------------------------------------------------------------------
% Selection window
%---------------------------------------------------------------------
%
function set_status(fig,str)
S=guidata(fig); set(S.hstat,'String',str);
return
%
function update_block(fig)
S=guidata(fig);
v=[S.i1 S.i2 S.j1 S.j2]-1;
for k=1:4, set(S.hidx(k),'String',num2str(v(k))); end
i=S.i1:S.i2; j=S.j1:S.j2;
x=[S.lon(i,S.j1); S.lon(S.i2,j)'; flipud(S.lon(i,S.j2)); flipud(S.lon(S.i1,j)')];
y=[S.lat(i,S.j1); S.lat(S.i2,j)'; flipud(S.lat(i,S.j2)); flipud(S.lat(S.i1,j)')];
set(S.hblk,'XData',x,'YData',y);
st=max(1,ceil(max(numel(i),numel(j))/S.maxcells));
set(S.hlonlat,'String',sprintf('lon %.2f/%.2f  lat %.2f/%.2f\n%d x %d cells (stride %d)',...
    min(min(S.lon(i,j))),max(max(S.lon(i,j))),min(min(S.lat(i,j))),max(max(S.lat(i,j))),...
    numel(i),numel(j),st));
return
%
function p=cur_point(ax)
cp=get(ax,'CurrentPoint'); p=cp(1,1:2);
return
%
function r=inside(ax,p)
xl=xlim(ax); yl=ylim(ax);
r=p(1)>=xl(1) && p(1)<=xl(2) && p(2)>=yl(1) && p(2)<=yl(2);
return
%
function cb_down(fig,~)
S=guidata(fig);
p=cur_point(S.ax);
if ~inside(S.ax,p), return, end
S.action='rect'; S.p0=p;
set(S.hrect,'XData',p(1)*[1 1 1 1 1],'YData',p(2)*[1 1 1 1 1]);
guidata(fig,S);
return
%
function cb_move(fig,~)
S=guidata(fig);
if ~strcmp(S.action,'rect'), return, end
p=cur_point(S.ax); p0=S.p0;
set(S.hrect,'XData',[p0(1) p(1) p(1) p0(1) p0(1)],'YData',[p0(2) p0(2) p(2) p(2) p0(2)]);
return
%
function cb_up(fig,~)
S=guidata(fig);
if ~strcmp(S.action,'rect'), return, end
S.action='';
p=cur_point(S.ax); p0=S.p0;
set(S.hrect,'XData',NaN,'YData',NaN);
sel=(S.lon-p0(1)).*(S.lon-p(1))<=0 & (S.lat-p0(2)).*(S.lat-p(2))<=0;
[I,J]=find(sel);
if numel(unique(I))<2 || numel(unique(J))<2
  guidata(fig,S); set_status(fig,'The area must contain at least 2x2 cells'); return
end
S.i1=min(I); S.i2=max(I); S.j1=min(J); S.j2=max(J);
guidata(fig,S); update_block(fig); set_status(fig,'');
return
%
function cb_index(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
v=arrayfun(@(h) str2double(get(h,'String')),S.hidx)+1;
if all(isfinite(v))
  v=round(v);
  v(1:2)=sort(min(max(v(1:2),1),S.Lp)); v(3:4)=sort(min(max(v(3:4),1),S.Mp));
  if v(2)>v(1) && v(4)>v(3)
    S.i1=v(1); S.i2=v(2); S.j1=v(3); S.j2=v(4);
  end
end
guidata(fig,S); update_block(fig);
return
%
function cb_whole(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
S.i1=1; S.i2=S.Lp; S.j1=1; S.j2=S.Mp;
guidata(fig,S); update_block(fig);
return
%
function cb_maxc(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
v=get(src,'String'); S.maxcells=str2double(v{get(src,'Value')});
guidata(fig,S); update_block(fig);
return
%
function cb_opengrid(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
[fn,pth]=uigetfile('*.nc','Select the CROCO grid file...');
if isequal(fn,0), return, end
his=S.hisfile;
delete(fig);
oct_make_3d([pth,fn],his);
return
%
function cb_openhis(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
[fn,pth]=uigetfile('*.nc','Select the CROCO output file (his/avg)...');
if isequal(fn,0), return, end
S.hisfile=[pth,fn];
set(S.hhfile,'String',short_name(S.hisfile));
guidata(fig,S);
return
%
function cb_close(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
if ~isempty(S) && ~isempty(S.f3) && ishghandle(S.f3)
  setappdata(S.f3,'stop',1);
  delete(S.f3);
end
delete(fig);
return
%
%---------------------------------------------------------------------
% 3D window: creation
%---------------------------------------------------------------------
%
function cb_make3d(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
set_status(fig,'Building the 3D view...'); drawnow;
layers=[];
if ~isempty(S.f3) && ishghandle(S.f3)
  T0=guidata(S.f3);
  if strcmp(T0.hisfile,S.hisfile), layers=T0.layers; end
  for k=1:numel(layers), layers(k).hg=[]; end
  setappdata(S.f3,'stop',1);
  delete(S.f3);
end
T=make_state(S);
if ~isempty(layers), T.layers=layers; end
T.contours=get(S.hcont,'Value'); T.clevels=get(S.hclev,'String');
f3=create_3d_window(T,fig);
S.f3=f3; guidata(fig,S);
T=guidata(f3);
T=render_all(T);
guidata(f3,T);
update_panel(f3);
set_status(fig,sprintf('3D view: %d x %d cells',numel(T.ii),numel(T.jj)));
return
%
function T=make_state(S)
st=max(1,ceil(max(S.i2-S.i1+1,S.j2-S.j1+1)/S.maxcells));
T.ii=unique([S.i1:st:S.i2 S.i2]); T.jj=unique([S.j1:st:S.j2 S.j2]);
T.i1=S.i1; T.i2=S.i2; T.j1=S.j1; T.j2=S.j2;
T.ri=T.ii-S.i1+1; T.rj=T.jj-S.j1+1;          % indices in the read block
T.stride=st;
T.Lp=S.Lp; T.Mp=S.Mp;
T.lon=S.lon(T.ii,T.jj); T.lat=S.lat(T.ii,T.jj);
T.h=S.h(T.ii,T.jj); T.mask=S.mask(T.ii,T.jj); T.angle=S.angle(T.ii,T.jj);
T.topo=[]; T.showtopo=1;
if ~isempty(S.topo), T.topo=S.topo(T.ii,T.jj); end
T.coslat=cos(mean(T.lat(:))*pi/180);
T.gridfile=S.gridfile; T.hisfile=S.hisfile;
T.layers=struct('type',{},'var',{},'pos',{},'cmin',{},'cmax',{},'cmap',{},...
                'alpha',{},'visible',{},'vec',{},'vskip',{},'vscale',{},'hg',{});
T.sel=0;
T.cache=struct('key',{},'val',{});
T.vars={}; T.vinfo=struct('name',{},'grid',{},'w',{},'fill',{},'scale',{},'offset',{});
T.nt=0; T.time=[]; T.tindex=1; T.N=0;
T.cmaps={'jet','parula','viridis','turbo','hot','cool','gray','bone','cubehelix'};
T.cmaps=T.cmaps(cellfun(@(c) exist(c)>0,T.cmaps));
if ~isempty(T.hisfile) && exist(T.hisfile,'file')
  T=read_his_info(T);
end
return
%
function T=read_his_info(T)
nc=netcdf.open(T.hisfile,'NC_NOWRITE');
gid=netcdf.getConstant('NC_GLOBAL');
[~,T.N]=netcdf.inqDim(nc,netcdf.inqDimID(nc,'s_rho'));
p=struct('theta_s',[],'theta_b',[],'hc',[],'Vtransform',[]);
for f=fieldnames(p)'
  try
    p.(f{1})=double(netcdf.getVar(nc,netcdf.inqVarID(nc,f{1})));
  catch
    try
      p.(f{1})=double(netcdf.getAtt(nc,gid,f{1}));
    end
  end
  if ~isempty(p.(f{1})), p.(f{1})=p.(f{1})(1); end
end
if isempty(p.Vtransform)
  p.Vtransform=1;
  try
    if strcmpi(strtrim(netcdf.getAtt(nc,gid,'VertCoordType')),'NEW'), p.Vtransform=2; end
  end
end
if isempty(p.hc)
  try, p.hc=double(netcdf.getAtt(nc,gid,'Tcline')); end
end
T.sc=p;
[~,nv]=netcdf.inq(nc);
for v=0:nv-1
  [name,~,dims]=netcdf.inqVar(nc,v);
  if numel(dims)~=4, continue, end
  dn=cell(1,4);
  for k=1:4, dn{k}=netcdf.inqDim(nc,dims(k)); end
  if ~any(strcmp(dn{3},{'s_rho','s_w'})), continue, end
  g='r';
  if strcmp(dn{1},'xi_u'), g='u'; elseif strcmp(dn{2},'eta_v'), g='v'; end
  I.name=name; I.grid=g; I.w=strcmp(dn{3},'s_w');
  I.fill=[]; I.scale=1; I.offset=0;
  try, I.fill=double(netcdf.getAtt(nc,v,'_FillValue')); end
  try, I.scale=double(netcdf.getAtt(nc,v,'scale_factor')); end
  try, I.offset=double(netcdf.getAtt(nc,v,'add_offset')); end
  T.vinfo(end+1)=I;
end
T.vars={T.vinfo.name};
if any(strcmp(T.vars,'u')) && any(strcmp(T.vars,'v'))
  T.vars{end+1}='speed';
end
T.time=[];
for tn={'scrum_time','time','ocean_time'}
  try
    T.time=double(netcdf.getVar(nc,netcdf.inqVarID(nc,tn{1})));
    break
  end
end
T.haszeta=1;
try
  netcdf.inqVarID(nc,'zeta');
catch
  T.haszeta=0;
end
try
  [~,T.nt]=netcdf.inqDim(nc,netcdf.inqDimID(nc,'time'));
catch
  T.nt=numel(T.time);
end
netcdf.close(nc);
if isempty(T.time), T.time=(0:T.nt-1)'; end
if numel(T.vars)==0
  warning(['oct_make_3d: no 3D variable in ',T.hisfile]);
end
return
%
function f3=create_3d_window(T,fig0)
bg=[.94 .94 .94];
f3=figure('NumberTitle','off','Name',['3D view - ',short_name(T.gridfile),' ',short_name(T.hisfile)],...
          'tag','oct_make_3d_view','MenuBar','none','ToolBar','figure','Color',bg,...
          'IntegerHandle','off','Units','normalized','Position',[.08 .06 .84 .84]);
T.fig=f3; T.fig0=fig0;
setappdata(f3,'stop',0);
hf=uimenu(f3,'Label','File');
uimenu(hf,'Label','Save view as PNG...','Callback',@cb_savepng);
uimenu(hf,'Label','Close','Callback',@(s,e) delete(f3),'Separator','on');
ha=uimenu(f3,'Label','Add');
en=ifelse(T.nt>0 && ~isempty(T.vars),'on','off');
uimenu(ha,'Label','Horizontal section (depth)','Callback',{@cb_add,'h'},'Enable',en);
uimenu(ha,'Label','Vertical section W-E (constant J)','Callback',{@cb_add,'vj'},'Enable',en);
uimenu(ha,'Label','Vertical section S-N (constant I)','Callback',{@cb_add,'vi'},'Enable',en);
uimenu(ha,'Label','Isosurface','Callback',{@cb_add,'iso'},'Enable',en);
hv=uimenu(f3,'Label','View');
uimenu(hv,'Label','Reset view','Callback',@cb_resetview);
uimenu(hv,'Label','View from above','Callback',@(s,e) view(guidata(f3).ax,0,90));
uimenu(hv,'Label','Hide/show bathymetry','Callback',@cb_togglebathy);
T.htopomenu=uimenu(hv,'Label','Land topography','Callback',@cb_toggletopo,'Checked','on',...
                   'Enable',ifelse(isempty(T.topo),'off','on'));
T.ax=axes('Parent',f3,'Units','normalized','Position',[0.05 0.17 0.63 0.78]);
T.cax=axes('Parent',f3,'Units','normalized','Position',[0.72 0.25 0.018 0.6]);
set(T.cax,'XTick',[],'YAxisLocation','right','Box','on','Visible','off');
T.hcbar=[];
%
% Layers panel
%
x0=0.8; w=0.19; y=0.93;
uicontrol(f3,'Style','text','Units','normalized','Position',[x0 y w .03],'String','Layers (menu Add)',...
          'FontWeight','bold','BackgroundColor',bg);
T.hlist=uicontrol(f3,'Style','listbox','Units','normalized','Position',[x0 y-.16 w .155],...
          'String',{},'Callback',@cb_select);
y=y-.205;
T.hvis=uicontrol(f3,'Style','checkbox','Units','normalized','Position',[x0 y .09 .035],...
          'String','Visible','BackgroundColor',bg,'Callback',@cb_prop);
T.hremove=uicontrol(f3,'Style','pushbutton','Units','normalized','Position',[x0+.1 y .09 .035],...
          'String','Remove','Callback',@cb_remove);
y=y-.045;
uicontrol(f3,'Style','text','Units','normalized','Position',[x0 y .07 .035],'String','Variable',...
          'HorizontalAlignment','left','BackgroundColor',bg);
T.hvar=uicontrol(f3,'Style','popupmenu','Units','normalized','Position',[x0+.07 y .12 .037],...
          'String',ifelse(isempty(T.vars),{'-'},T.vars),'Callback',@cb_prop);
y=y-.045;
T.hposlab=uicontrol(f3,'Style','text','Units','normalized','Position',[x0 y .1 .035],'String','Position',...
          'HorizontalAlignment','left','BackgroundColor',bg);
T.hpos=uicontrol(f3,'Style','edit','Units','normalized','Position',[x0+.1 y .09 .037],...
          'String','','Callback',@cb_prop);
y=y-.035;
T.hposinfo=uicontrol(f3,'Style','text','Units','normalized','Position',[x0 y w .03],'String','',...
          'HorizontalAlignment','left','BackgroundColor',bg);
y=y-.045;
uicontrol(f3,'Style','text','Units','normalized','Position',[x0 y .07 .035],'String','Colours',...
          'HorizontalAlignment','left','BackgroundColor',bg);
T.hcmin=uicontrol(f3,'Style','edit','Units','normalized','Position',[x0+.07 y .06 .037],...
          'String','','Callback',@cb_prop,'TooltipString','Minimum of the colour range');
T.hcmax=uicontrol(f3,'Style','edit','Units','normalized','Position',[x0+.13 y .06 .037],...
          'String','','Callback',@cb_prop,'TooltipString','Maximum of the colour range');
y=y-.045;
T.hauto=uicontrol(f3,'Style','pushbutton','Units','normalized','Position',[x0 y .07 .037],...
          'String','Auto','Callback',@cb_auto,'TooltipString','Range of the layer at this time');
T.hcmap=uicontrol(f3,'Style','popupmenu','Units','normalized','Position',[x0+.07 y .12 .037],...
          'String',T.cmaps,'Callback',@cb_prop);
y=y-.045;
uicontrol(f3,'Style','text','Units','normalized','Position',[x0 y .11 .035],'String','Opacity (0-1)',...
          'HorizontalAlignment','left','BackgroundColor',bg);
T.halpha=uicontrol(f3,'Style','edit','Units','normalized','Position',[x0+.11 y .08 .037],...
          'String','','Callback',@cb_prop);
y=y-.05;
T.hvec=uicontrol(f3,'Style','checkbox','Units','normalized','Position',[x0 y w .035],...
          'String','Velocity vectors (u,v)','BackgroundColor',bg,'Callback',@cb_prop);
y=y-.042;
uicontrol(f3,'Style','text','Units','normalized','Position',[x0 y .04 .035],'String','Skip',...
          'HorizontalAlignment','left','BackgroundColor',bg);
T.hvskip=uicontrol(f3,'Style','edit','Units','normalized','Position',[x0+.04 y .05 .037],...
          'String','','Callback',@cb_prop,'TooltipString','One vector every SKIP cells');
uicontrol(f3,'Style','text','Units','normalized','Position',[x0+.1 y .045 .035],'String','Scale',...
          'HorizontalAlignment','left','BackgroundColor',bg);
T.hvscale=uicontrol(f3,'Style','edit','Units','normalized','Position',[x0+.145 y .045 .037],...
          'String','','Callback',@cb_prop,'TooltipString','1: the largest vector = SKIP cells');
y=y-.07;
uicontrol(f3,'Style','text','Units','normalized','Position',[x0 y .11 .035],'String','Vert. exaggeration',...
          'HorizontalAlignment','left','BackgroundColor',bg);
T.hexag=uicontrol(f3,'Style','popupmenu','Units','normalized','Position',[x0+.11 y .08 .037],...
          'String',{'auto','1','5','10','20','50','100','200','500','1000','2000'},'Value',1,...
          'Callback',@cb_exag);
y=y-.05;
T.hcont=uicontrol(f3,'Style','checkbox','Units','normalized','Position',[x0 y w .035],...
          'String','Bathymetry contours (m)','Value',T.contours,'BackgroundColor',bg,'Callback',@cb_contours,...
          'TooltipString','Black isobaths on the bathymetry (0 m: land/sea mask limit)');
y=y-.042;
T.hclev=uicontrol(f3,'Style','edit','Units','normalized','Position',[x0 y w .037],...
          'String',T.clevels,'Callback',@cb_contours,...
          'TooltipString','Depths of the contours (m), separated by spaces or commas');
T.hcontour=[];
%
% Time and animation (bottom)
%
y=0.075;
uicontrol(f3,'Style','text','Units','normalized','Position',[0.05 y .05 .035],'String','Time',...
          'FontWeight','bold','HorizontalAlignment','left','BackgroundColor',bg);
T.hprev=uicontrol(f3,'Style','pushbutton','Units','normalized','Position',[0.1 y .03 .037],...
          'String','<','Callback',{@cb_step,-1});
T.htime=uicontrol(f3,'Style','edit','Units','normalized','Position',[0.135 y .05 .037],...
          'String','1','Callback',@cb_time);
T.hnext=uicontrol(f3,'Style','pushbutton','Units','normalized','Position',[0.19 y .03 .037],...
          'String','>','Callback',{@cb_step,1});
T.htlab=uicontrol(f3,'Style','text','Units','normalized','Position',[0.225 y .25 .035],...
          'String','','HorizontalAlignment','left','BackgroundColor',bg);
y=0.025;
uicontrol(f3,'Style','text','Units','normalized','Position',[0.05 y .08 .035],'String','Animation',...
          'FontWeight','bold','HorizontalAlignment','left','BackgroundColor',bg);
uicontrol(f3,'Style','text','Units','normalized','Position',[0.13 y .035 .035],'String','from',...
          'BackgroundColor',bg);
T.hafrom=uicontrol(f3,'Style','edit','Units','normalized','Position',[0.165 y .04 .037],'String','1');
uicontrol(f3,'Style','text','Units','normalized','Position',[0.21 y .02 .035],'String','to',...
          'BackgroundColor',bg);
T.hato=uicontrol(f3,'Style','edit','Units','normalized','Position',[0.235 y .04 .037],...
          'String',num2str(max(T.nt,1)));
uicontrol(f3,'Style','text','Units','normalized','Position',[0.28 y .03 .035],'String','fps',...
          'BackgroundColor',bg);
T.hfps=uicontrol(f3,'Style','edit','Units','normalized','Position',[0.31 y .035 .037],'String','4');
T.hrec=uicontrol(f3,'Style','checkbox','Units','normalized','Position',[0.355 y .1 .035],...
          'String','Record MP4','BackgroundColor',bg);
T.hmp4=uicontrol(f3,'Style','edit','Units','normalized','Position',[0.455 y .14 .037],...
          'String','oct_make_3d.mp4','TooltipString','MP4 file');
T.hanim=uicontrol(f3,'Style','pushbutton','Units','normalized','Position',[0.6 y .08 .045],...
          'String','Animate','FontWeight','bold','Callback',@cb_animate);
T.hstat=uicontrol(f3,'Style','text','Units','normalized','Position',[0.69 0.005 0.3 0.06],...
          'String','','HorizontalAlignment','left','BackgroundColor',bg);
if T.nt==0
  set([T.hprev T.hnext T.htime T.hanim T.hrec],'Enable','off');
end
set(f3,'CloseRequestFcn',@cb_close3d);
%
% Bathymetry and land mask
%
T=draw_bathy(T);
T=draw_contours(T);
guidata(f3,T);
set_exag(f3);
view(T.ax,-35,35);
update_time_label(f3);
return
%
function T=draw_bathy(T)
ax=T.ax;
cla(ax); hold(ax,'on');
T=redraw_bathy_surface(T);
try
  T.hlight=light('Parent',ax,'Position',[-1 1 3],'Style','infinite');
end
hold(ax,'off');
set(ax,'Box','on','Projection','perspective');
grid(ax,'on');
xlabel(ax,'Longitude'); ylabel(ax,'Latitude'); zlabel(ax,'z (m)');
xlim(ax,[min(T.lon(:)) max(T.lon(:))]); ylim(ax,[min(T.lat(:)) max(T.lat(:))]);
return
%
function T=redraw_bathy_surface(T)
%
% Surface of the bottom (z=-h) and of the land cells (mask_rho=0):
% topography of the topography file (terrain colours) or a brown plateau
% at sea level
%
ax=T.ax;
Z=-T.h;
land=T.mask==0;
hl=max(T.h(:));
topo=[];
if T.showtopo && ~isempty(T.topo), topo=T.topo; end
if isempty(topo)
  Z(land)=0.01*hl;                             % land: plateau at sea level
  ztop=0.05*hl;
else
  Z(land)=max(topo(land),0);                   % land: topography
  ztop=max([0.05*hl; 1.05*Z(land)]);
end
hs=T.h; hs(land)=NaN;
rgb=val2rgb(hs,bathy_cmap(),[min(hs(:)) max(hs(:))]);
if isempty(topo)
  N=numel(Z); lc=[0.62 0.5 0.32];
  for c=1:3, rgb(find(land)+(c-1)*N)=lc(c); end
else
  rgb=land_rgb(rgb,T.mask,topo);
end
if isfield(T,'hbathy') && ~isempty(T.hbathy) && ishghandle(T.hbathy)
  delete(T.hbathy);
end
T.hbathy=surface(T.lon,T.lat,Z,rgb,'Parent',ax,'EdgeColor','none','FaceColor','interp');
try
  set(T.hbathy,'FaceLighting','gouraud','AmbientStrength',0.5,'DiffuseStrength',0.7,'SpecularStrength',0.05);
end
zlim(ax,[-hl ztop]);
T.ztop=ztop; T.ztopo=ifelse(isempty(topo),0,ztop);
return
%
function set_exag(f3)
T=guidata(f3);
v=get(T.hexag,'String'); v=v{get(T.hexag,'Value')};
xyr=max((max(T.lon(:))-min(T.lon(:)))*T.coslat,max(T.lat(:))-min(T.lat(:)));
zr=max(T.h(:))+T.ztopo;
if strcmp(v,'auto')
  dz=zr/(0.35*xyr);
else
  dz=111e3/str2double(v);
end
set(T.ax,'DataAspectRatio',[1/T.coslat 1 dz]);
T.exagval=111e3/dz;
guidata(f3,T);
update_title(f3);
return
%
function cb_exag(src,~)
f3=ancestor(src,'figure'); set_exag(f3);
return
%
function cb_resetview(src,~)
f3=ancestor(src,'figure'); T=guidata(f3);
view(T.ax,-35,35);
return
%
function cb_togglebathy(src,~)
f3=ancestor(src,'figure'); T=guidata(f3);
vis=ifelse(strcmp(get(T.hbathy,'Visible'),'on'),'off','on');
set(T.hbathy,'Visible',vis);
if ~isempty(T.hcontour) && ishghandle(T.hcontour)
  set(T.hcontour,'Visible',ifelse(get(T.hcont,'Value'),vis,'off'));
end
return
%
function cb_toggletopo(src,~)
f3=ancestor(src,'figure'); T=guidata(f3);
T.showtopo=~T.showtopo;
set(T.htopomenu,'Checked',ifelse(T.showtopo,'on','off'));
vis=get(T.hbathy,'Visible');
hold(T.ax,'on');
T=redraw_bathy_surface(T);
hold(T.ax,'off');
set(T.hbathy,'Visible',vis);
guidata(f3,T);
set_exag(f3);
return
%
function cb_contours(src,~)
f3=ancestor(src,'figure'); T=guidata(f3);
T=draw_contours(T);
guidata(f3,T);
return
%
function T=draw_contours(T)
%
% Black isobaths on the bathymetry surface. Levels > 0: contours of h on
% the sea cells; level 0: limit of the land/sea mask (coastline of the
% model)
%
if ~isempty(T.hcontour) && ishghandle(T.hcontour), delete(T.hcontour); end
T.hcontour=[];
lev=parse_levels(T.hclev);
if ~get(T.hcont,'Value') || isempty(lev), return, end
[X,Y,Z]=contour_lines(T.lon,T.lat,T.h,T.mask,lev,0.004*max(T.h(:)));
if isempty(X), return, end
T.hcontour=line(X,Y,Z,'Parent',T.ax,'Color','k','LineWidth',1);
if strcmp(get(T.hbathy,'Visible'),'off'), set(T.hcontour,'Visible','off'); end
return
%
function cb_close3d(src,~)
f3=ancestor(src,'figure');
setappdata(f3,'stop',1);
delete(f3);
return
%
function update_title(f3)
T=guidata(f3);
s=sprintf('I=%d:%d J=%d:%d (stride %d), vertical exaggeration x%.0f',T.i1-1,T.i2-1,T.j1-1,T.j2-1,...
          T.stride,T.exagval);
if T.nt>0
  s=sprintf('%s\ntime %d/%d: %s',s,T.tindex,T.nt,time_str(T));
end
title(T.ax,s);
return
%
function s=time_str(T)
t=T.time(T.tindex);
s=sprintf('%.2f days',t/86400);
return
%
function update_time_label(f3)
T=guidata(f3);
if T.nt==0
  set(T.htlab,'String','no output file: bathymetry only');
else
  set(T.htime,'String',num2str(T.tindex));
  set(T.htlab,'String',sprintf('/ %d   %s',T.nt,time_str(T)));
end
update_title(f3);
return
%
function set_status3(f3,str)
T=guidata(f3); set(T.hstat,'String',str);
return
%
%---------------------------------------------------------------------
% Reading the output file
%---------------------------------------------------------------------
%
function [V,T]=get_var(T,name)
%
% Variable NAME at the time T.tindex on the rho points of the block,
% (nI,nJ,N) array (NaN on land). Cached.
%
key=sprintf('%s@%d',name,T.tindex);
k=find(strcmp({T.cache.key},key),1);
if ~isempty(k), V=T.cache(k).val; return, end
switch name
  case 'speed'
    [u,T]=get_var(T,'u'); [v,T]=get_var(T,'v');
    V=sqrt(u.^2+v.^2);
  case 'z_r'
    V=zr_block(T);
  otherwise
    V=read_block(T,name);
end
T.cache(end+1)=struct('key',key,'val',V);
return
%
function V=read_block(T,name)
I=T.vinfo(strcmp({T.vinfo.name},name));
t0=T.tindex-1;
nk=T.N+I.w;
nc=netcdf.open(T.hisfile,'NC_NOWRITE');
vid=netcdf.inqVarID(nc,name);
switch I.grid
  case 'u'
    a=max(T.i1-1,1); b=min(T.i2,T.Lp-1);
    X=double(netcdf.getVar(nc,vid,[a-1 T.j1-1 0 t0],[b-a+1 T.j2-T.j1+1 nk 1]));
  case 'v'
    a=max(T.j1-1,1); b=min(T.j2,T.Mp-1);
    X=double(netcdf.getVar(nc,vid,[T.i1-1 a-1 0 t0],[T.i2-T.i1+1 b-a+1 nk 1]));
  otherwise
    X=double(netcdf.getVar(nc,vid,[T.i1-1 T.j1-1 0 t0],[T.i2-T.i1+1 T.j2-T.j1+1 nk 1]));
end
netcdf.close(nc);
if ~isempty(I.fill), X(X==I.fill)=NaN; end
X=X*I.scale+I.offset;
X(abs(X)>1e30)=NaN;
switch I.grid                                % to rho points
  case 'u'
    if T.i1==1, X=cat(1,X(1,:,:),X); end
    if T.i2==T.Lp, X=cat(1,X,X(end,:,:)); end
    X=0.5*(X(1:end-1,:,:)+X(2:end,:,:));
  case 'v'
    if T.j1==1, X=cat(2,X(:,1,:),X); end
    if T.j2==T.Mp, X=cat(2,X,X(:,end,:)); end
    X=0.5*(X(:,1:end-1,:)+X(:,2:end,:));
end
if I.w                                       % w levels -> rho levels
  X=0.5*(X(:,:,1:end-1)+X(:,:,2:end));
end
V=X(T.ri,T.rj,:);
m=repmat(T.mask==0,[1 1 size(V,3)]);
V(m)=NaN;
return
%
function z=zr_block(T)
% depth of the rho points of the block (nI,nJ,N)
zeta=zeros(size(T.h));
if T.haszeta
  nc=netcdf.open(T.hisfile,'NC_NOWRITE');
  X=double(netcdf.getVar(nc,netcdf.inqVarID(nc,'zeta'),[T.i1-1 T.j1-1 T.tindex-1],...
                         [T.i2-T.i1+1 T.j2-T.j1+1 1]));
  netcdf.close(nc);
  zeta=X(T.ri,T.rj);
  zeta(~isfinite(zeta) | abs(zeta)>1e3)=0;
end
p=T.sc; N=T.N; h=T.h;
sc=((1:N)-N-0.5)/N;
ts=p.theta_s; tb=p.theta_b; hc=p.hc;
z=zeros([size(h) N]);
if p.Vtransform==2
  if ts>0, Cs=(1-cosh(ts*sc))/(cosh(ts)-1); else, Cs=-sc.^2; end
  if tb>0, Cs=(exp(tb*Cs)-1)/(1-exp(-tb)); end
  for k=1:N
    z0=(hc*sc(k)+Cs(k)*h)./(hc+h);
    z(:,:,k)=zeta+(zeta+h).*z0;
  end
else
  Cs=(1-tb)*sinh(ts*sc)/sinh(ts)+tb*(tanh(ts*(sc+0.5))/(2*tanh(0.5*ts))-0.5);
  hh=h; hh(hh==0)=1e-2;
  for k=1:N
    z0=hc*(sc(k)-Cs(k))+Cs(k)*hh;
    z(:,:,k)=z0+zeta.*(1+z0./hh);
  end
end
return
%
function out=hslice(Z,V,d)
% V at the depth d (d>=0 or above the upper level: upper level value)
[L,M,N]=size(Z);
out=NaN(L,M);
top=Z(:,:,N);
m=d>=top;
v=V(:,:,N); out(m)=v(m);
for k=1:N-1
  z1=Z(:,:,k); z2=Z(:,:,k+1);
  m=isnan(out) & z1<=d & z2>=d;
  if any(m(:))
    v1=V(:,:,k); v2=V(:,:,k+1);
    w=(d-z1(m))./max(z2(m)-z1(m),eps);
    out(m)=v1(m)+w.*(v2(m)-v1(m));
  end
end
return
%
%---------------------------------------------------------------------
% Layers
%---------------------------------------------------------------------
%
function s=layer_name(T,L)
switch L.type
  case 'h',   s=sprintf('H %s z=%g m',L.var,L.pos);
  case 'vj',  s=sprintf('V W-E %s J=%d',L.var,L.pos);
  case 'vi',  s=sprintf('V S-N %s I=%d',L.var,L.pos);
  case 'iso', s=sprintf('ISO %s = %g',L.var,L.pos);
end
if L.vec, s=[s,' +vec']; end
if ~L.visible, s=[s,' (hidden)']; end
return
%
function cb_add(src,~,type)
f3=ancestor(src,'figure'); T=guidata(f3);
var=ifelse(any(strcmp(T.vars,'temp')),'temp',T.vars{1});
L=struct('type',type,'var',var,'pos',0,'cmin',NaN,'cmax',NaN,'cmap',1,...
         'alpha',1,'visible',1,'vec',0,'vskip',max(1,round(numel(T.ii)/20)),'vscale',1,'hg',[]);
switch type
  case 'h'
    L.pos=0;
  case 'vj'
    L.pos=T.jj(round(end/2))-1;
  case 'vi'
    L.pos=T.ii(round(end/2))-1;
  case 'iso'
    [V,T]=get_var(T,var);
    L.pos=round_sig(median(V(isfinite(V))),3);
    L.alpha=0.8;
end
T.layers(end+1)=L;
T.sel=numel(T.layers);
set_status3(f3,'Computing the layer...'); drawnow;
T=render_layer(T,T.sel);
guidata(f3,T);
update_panel(f3);
set_status3(f3,'');
return
%
function v=round_sig(v,n)
if v==0 || ~isfinite(v), return, end
p=10^(n-1-floor(log10(abs(v))));
v=round(v*p)/p;
return
%
function T=render_all(T)
for k=1:numel(T.layers)
  T=render_layer(T,k);
end
return
%
function T=render_layer(T,k)
%
% (Re)draw layer k at the current time
%
L=T.layers(k);
for h=L.hg(:)'
  if ishghandle(h), delete(h); end
end
L.hg=[];
ax=T.ax;
if T.nt==0, T.layers(k)=L; return, end
cm=feval(T.cmaps{min(L.cmap,numel(T.cmaps))},128);
[V,T]=get_var(T,L.var);
[Z,T]=get_var(T,'z_r');
hold(ax,'on');
switch L.type
  case 'h'
    d=L.pos; if d>0, d=-d; end
    C=hslice(Z,V,d);
    [L,cr]=auto_range(L,C);
    Zs=d*ones(size(C)); Zs(~isfinite(C))=NaN;
    L.hg=surface(T.lon,T.lat,Zs,val2rgb(C,cm,cr),'Parent',ax,'EdgeColor','none',...
                 'FaceColor','interp','FaceAlpha',L.alpha,'FaceLighting','none');
    if L.vec
      [u,T]=get_var(T,'u'); [v,T]=get_var(T,'v');
      us=hslice(Z,u,d); vs=hslice(Z,v,d);
      a=T.angle;
      ue=us.*cos(a)-vs.*sin(a); vn=us.*sin(a)+vs.*cos(a);
      sk=max(1,round(L.vskip));
      ii=1:sk:size(C,1); jj=1:sk:size(C,2);
      x=T.lon(ii,jj); y=T.lat(ii,jj); ue=ue(ii,jj); vn=vn(ii,jj);
      sp=sqrt(ue.^2+vn.^2); smax=max(sp(:));
      if smax>0
        dl=median(abs(diff(T.lat(1,:))));
        if ~(dl>0), dl=median(abs(diff(T.lat(:,1)))); end
        f=L.vscale*sk*dl/smax;
        ok=isfinite(ue) & isfinite(vn);
        L.hg(end+1)=quiver3(ax,x(ok),y(ok),(d+1e-3*abs(d)+0.01)*ones(sum(ok(:)),1),...
                            f*ue(ok)/T.coslat,f*vn(ok),zeros(sum(ok(:)),1),0,'k');
        set(L.hg(end),'LineWidth',1);
      end
    end
  case {'vj','vi'}
    if strcmp(L.type,'vj')
      [~,c]=min(abs(T.jj-1-L.pos)); L.pos=T.jj(c)-1;
      x=T.lon(:,c); y=T.lat(:,c); z=squeeze(Z(:,c,:)); v=squeeze(V(:,c,:)); h=T.h(:,c); m=T.mask(:,c);
    else
      [~,c]=min(abs(T.ii-1-L.pos)); L.pos=T.ii(c)-1;
      x=T.lon(c,:)'; y=T.lat(c,:)'; z=squeeze(Z(c,:,:)); v=squeeze(V(c,:,:)); h=T.h(c,:)'; m=T.mask(c,:)';
    end
    z=[-h z max(z(:,end),0)];                  % bottom ... surface
    v=[v(:,1) v v(:,end)];
    n=size(z,2);
    z(m==0,:)=NaN;
    [L,cr]=auto_range(L,v);
    L.hg=surface(repmat(x,1,n),repmat(y,1,n),z,val2rgb(v,cm,cr),'Parent',ax,...
                 'EdgeColor','none','FaceColor','interp','FaceAlpha',L.alpha,'FaceLighting','none');
  case 'iso'
    [L,cr]=auto_range(L,V);
    L.hg=draw_iso(T,ax,Z,V,L.pos,cm,cr,L.alpha);
end
hold(ax,'off');
if ~L.visible
  set(L.hg,'Visible','off');
end
T.layers(k)=L;
return
%
function [L,cr]=auto_range(L,C)
if ~isfinite(L.cmin) || ~isfinite(L.cmax) || L.cmax<=L.cmin
  c=C(isfinite(C));
  if isempty(c), c=[0 1]; end
  L.cmin=round_sig(min(c),3); L.cmax=round_sig(max(c),3);
  if L.cmax<=L.cmin, L.cmax=L.cmin+1; end
end
cr=[L.cmin L.cmax];
return
%
function hp=draw_iso(T,ax,Z,V,iso,cm,cr,alpha)
%
% Isosurface V=iso: V interpolated on regular z levels, isosurface in
% (i,j,z) space, vertices mapped to lon/lat, faces under the bottom or
% on land removed
%
hp=[];
[nI,nJ,~]=size(V);
nz=40;
zr=linspace(-max(T.h(:)),0,nz);
R=NaN(nI,nJ,nz);
bot=V(:,:,1);
for k=1:nz
  s=hslice(Z,V,zr(k));
  u=isnan(s) & T.mask>0;                       % under the bottom: bottom value
  s(u)=bot(u);
  R(:,:,k)=s;
end
v=V(isfinite(V));
if isempty(v) || iso<min(v) || iso>max(v), return, end
R(isnan(R))=ifelse(iso>median(v),min(v)-1,max(v)+1);   % land: outside the iso
[I,J,K]=ndgrid(1:nI,1:nJ,zr);
[F,P]=isosurface(permute(I,[2 1 3]),permute(J,[2 1 3]),permute(K,[2 1 3]),permute(R,[2 1 3]),iso);
if isempty(F), return, end
hv=interp2(T.h.',P(:,1),P(:,2));
mk=interp2(T.mask.',P(:,1),P(:,2),'nearest');
bad=P(:,3)<-hv-1 | mk==0;
F=F(~any(bad(F),2),:);
if isempty(F), return, end
lon=interp2(T.lon.',P(:,1),P(:,2)); lat=interp2(T.lat.',P(:,1),P(:,2));
col=squeeze(val2rgb(iso,cm,cr))';
hp=patch('Parent',ax,'Faces',F,'Vertices',[lon lat P(:,3)],'FaceColor',col,...
         'EdgeColor','none','FaceAlpha',alpha);
try
  set(hp,'FaceLighting','gouraud','AmbientStrength',0.5);
end
return
%
%---------------------------------------------------------------------
% Layers panel
%---------------------------------------------------------------------
%
function update_panel(f3)
T=guidata(f3);
n=numel(T.layers);
names=cell(1,n);
for k=1:n, names{k}=layer_name(T,T.layers(k)); end
set(T.hlist,'String',names);
h=[T.hvis T.hremove T.hvar T.hpos T.hcmin T.hcmax T.hauto T.hcmap T.halpha T.hvec T.hvskip T.hvscale];
if T.sel<1 || T.sel>n
  set(T.hlist,'Value',max(1,min(n,1)));
  set(h,'Enable','off');
  set(T.hposlab,'String','Position'); set(T.hposinfo,'String','');
  draw_cbar(f3);
  return
end
set(h,'Enable','on');
L=T.layers(T.sel);
set(T.hlist,'Value',T.sel);
set(T.hvis,'Value',L.visible);
set(T.hvar,'Value',find(strcmp(T.vars,L.var)));
set(T.hpos,'String',num2str(L.pos));
switch L.type
  case 'h'
    set(T.hposlab,'String','Depth (m)');
    set(T.hposinfo,'String','0: surface level, negative: depth');
  case 'vj'
    set(T.hposlab,'String','J index');
    [~,c]=min(abs(T.jj-1-L.pos));
    set(T.hposinfo,'String',sprintf('lat %.3f (J %d..%d)',mean(T.lat(:,c)),T.jj(1)-1,T.jj(end)-1));
  case 'vi'
    set(T.hposlab,'String','I index');
    [~,c]=min(abs(T.ii-1-L.pos));
    set(T.hposinfo,'String',sprintf('lon %.3f (I %d..%d)',mean(T.lon(c,:)),T.ii(1)-1,T.ii(end)-1));
  case 'iso'
    set(T.hposlab,'String','Iso value');
    set(T.hposinfo,'String','');
end
set(T.hcmin,'String',num2str(L.cmin)); set(T.hcmax,'String',num2str(L.cmax));
set(T.hcmap,'Value',L.cmap);
set(T.halpha,'String',num2str(L.alpha));
set(T.hvec,'Value',L.vec); set(T.hvskip,'String',num2str(L.vskip)); set(T.hvscale,'String',num2str(L.vscale));
if ~strcmp(L.type,'h') || ~any(strcmp(T.vars,'u'))
  set([T.hvec T.hvskip T.hvscale],'Enable','off');
end
draw_cbar(f3);
return
%
function draw_cbar(f3)
T=guidata(f3);
if ~isempty(T.hcbar) && all(ishghandle(T.hcbar)), delete(T.hcbar); end
T.hcbar=[];
if T.sel<1 || T.sel>numel(T.layers)
  set(T.cax,'Visible','off'); title(T.cax,'');
  guidata(f3,T); return
end
L=T.layers(T.sel);
cm=feval(T.cmaps{min(L.cmap,numel(T.cmaps))},128);
hold(T.cax,'on');
T.hcbar=image([0 1],[L.cmin L.cmax],reshape(cm,[size(cm,1) 1 3]),'Parent',T.cax);
if strcmp(L.type,'iso')
  T.hcbar(2)=plot(T.cax,[0 1],[1 1]*L.pos,'w-','LineWidth',3);
  T.hcbar(3)=plot(T.cax,[0 1],[1 1]*L.pos,'k-','LineWidth',1);
end
hold(T.cax,'off');
set(T.cax,'Visible','on','YDir','normal','XTick',[],'YAxisLocation','right','XLim',[0 1],...
          'YLim',[L.cmin L.cmax],'Box','on');
title(T.cax,L.var,'Interpreter','none');
guidata(f3,T);
return
%
function cb_select(src,~)
f3=ancestor(src,'figure'); T=guidata(f3);
if isempty(T.layers), return, end
T.sel=get(src,'Value');
guidata(f3,T); update_panel(f3);
return
%
function cb_prop(src,~)
%
% A property of the selected layer was changed: redraw the layer
%
f3=ancestor(src,'figure'); T=guidata(f3);
if T.sel<1, return, end
L=T.layers(T.sel);
num=@(h,def) ifelse(isfinite(str2double(get(h,'String'))),str2double(get(h,'String')),def);
oldvar=L.var;
L.visible=get(T.hvis,'Value');
if ~isempty(T.vars), L.var=T.vars{get(T.hvar,'Value')}; end
L.pos=num(T.hpos,L.pos);
L.cmin=num(T.hcmin,L.cmin); L.cmax=num(T.hcmax,L.cmax);
if ~strcmp(oldvar,L.var)
  L.cmin=NaN; L.cmax=NaN;                       % new variable: auto range
  if strcmp(L.type,'iso')
    T.layers(T.sel)=L;
    [V,T]=get_var(T,L.var);
    L.pos=round_sig(median(V(isfinite(V))),3);
  end
end
L.cmap=get(T.hcmap,'Value');
L.alpha=min(max(num(T.halpha,L.alpha),0),1);
L.vec=get(T.hvec,'Value');
L.vskip=max(1,round(num(T.hvskip,L.vskip)));
L.vscale=num(T.hvscale,L.vscale);
T.layers(T.sel)=L;
set_status3(f3,'Computing the layer...'); drawnow;
T=render_layer(T,T.sel);
guidata(f3,T); update_panel(f3);
set_status3(f3,'');
return
%
function cb_auto(src,~)
f3=ancestor(src,'figure'); T=guidata(f3);
if T.sel<1, return, end
T.layers(T.sel).cmin=NaN; T.layers(T.sel).cmax=NaN;
T=render_layer(T,T.sel);
guidata(f3,T); update_panel(f3);
return
%
function cb_remove(src,~)
f3=ancestor(src,'figure'); T=guidata(f3);
if T.sel<1, return, end
for h=T.layers(T.sel).hg(:)'
  if ishghandle(h), delete(h); end
end
T.layers(T.sel)=[];
T.sel=min(T.sel,numel(T.layers));
guidata(f3,T); update_panel(f3);
return
%
%---------------------------------------------------------------------
% Time, animation
%---------------------------------------------------------------------
%
function set_time(f3,t)
T=guidata(f3);
if T.nt==0, return, end
t=min(max(round(t),1),T.nt);
T.tindex=t;
T.cache=T.cache([]);
T=render_all(T);
guidata(f3,T);
update_time_label(f3);
return
%
function cb_step(src,~,d)
f3=ancestor(src,'figure'); T=guidata(f3);
set_time(f3,T.tindex+d);
return
%
function cb_time(src,~)
f3=ancestor(src,'figure');
t=str2double(get(src,'String'));
T=guidata(f3);
if ~isfinite(t), t=T.tindex; end
set_time(f3,t);
return
%
function cb_animate(src,~)
f3=ancestor(src,'figure'); T=guidata(f3);
if strcmp(get(T.hanim,'String'),'Stop')
  setappdata(f3,'stop',1); return
end
t1=round(str2double(get(T.hafrom,'String'))); t2=round(str2double(get(T.hato,'String')));
if ~isfinite(t1), t1=1; end
if ~isfinite(t2), t2=T.nt; end
t1=min(max(t1,1),T.nt); t2=min(max(t2,1),T.nt);
step=ifelse(t2>=t1,1,-1);
rec=get(T.hrec,'Value');
fps=str2double(get(T.hfps,'String')); if ~(fps>0), fps=4; end
mp4=strtrim(get(T.hmp4,'String'));
if rec
  if isempty(mp4), mp4='oct_make_3d.mp4'; end
  [p,n]=fileparts(mp4); if isempty(p), p=pwd; end
  fdir=fullfile(p,[n,'_frames']);
  if ~exist(fdir,'dir'), mkdir(fdir); end
  delete(fullfile(fdir,'f_*.png'));
end
setappdata(f3,'stop',0);
set(T.hanim,'String','Stop');
nf=0; rect=[];
for t=t1:step:t2
  if ~ishghandle(f3) || getappdata(f3,'stop'), break, end
  set_time(f3,t);
  drawnow;
  if rec
    [img,rect]=capture_view(f3,rect);
    nf=nf+1;
    imwrite(img,fullfile(fdir,sprintf('f_%04d.png',nf)));
  else
    pause(1/fps);
  end
end
if ~ishghandle(f3), return, end
set(T.hanim,'String','Animate');
if rec && nf>0
  set_status3(f3,'Writing the MP4 file...'); drawnow;
  [ok,msg]=make_mp4(fdir,mp4,fps,nf);
  set_status3(f3,msg);
  disp(['oct_make_3d: ',msg])
end
return
%
function [img,rect]=capture_view(f3,rect)
%
% Image of the 3D view and of the colour bar (same size for all frames)
%
T=guidata(f3);
fr=getframe(f3);
img=fr.cdata;
if isempty(rect)
  [H,W,~]=size(img);
  u=get(f3,'Units'); set(f3,'Units','pixels'); fp=get(f3,'Position'); set(f3,'Units',u);
  sx=W/fp(3); sy=H/fp(4);
  pa=getpixelposition(T.ax); pc=getpixelposition(T.cax);
  x1=max(1,floor(pa(1)*sx)); x2=min(W,ceil((pc(1)+pc(3))*sx)+60);
  y1=max(1,floor(H-(pa(2)+pa(4))*sy)-50); y2=min(H,ceil(H-pa(2)*sy)+5);
  rect=[x1 x2 y1 y2];
  rect(2)=rect(1)+2*floor((rect(2)-rect(1)+1)/2)-1;   % even sizes (H.264)
  rect(4)=rect(3)+2*floor((rect(4)-rect(3)+1)/2)-1;
end
img=img(rect(3):rect(4),rect(1):rect(2),:);
return
%
function [ok,msg]=make_mp4(fdir,mp4,fps,nf)
ok=0;
[st,~]=system('ffmpeg -version');
if st~=0
  msg=sprintf('ffmpeg not found: the %d PNG frames are in %s',nf,fdir);
  return
end
in=fullfile(fdir,'f_%04d.png');
cmd={sprintf('ffmpeg -y -loglevel error -framerate %g -i "%s" -c:v libx264 -pix_fmt yuv420p "%s"',fps,in,mp4),...
     sprintf('ffmpeg -y -loglevel error -framerate %g -i "%s" -c:v mpeg4 -q:v 2 "%s"',fps,in,mp4)};
for k=1:2
  [st,out]=system(cmd{k});
  if st==0 && exist(mp4,'file'), ok=1; break, end
end
if ok
  delete(fullfile(fdir,'f_*.png'));
  try, rmdir(fdir); end
  msg=sprintf('%d frames written in %s',nf,mp4);
else
  msg=sprintf('ffmpeg error (%s): the PNG frames are in %s',strtrim(out),fdir);
end
return
%
function cb_savepng(src,~)
f3=ancestor(src,'figure');
[fn,pth]=uiputfile('*.png','Save the 3D view as','oct_make_3d.png');
if isequal(fn,0), return, end
img=capture_view(f3,[]);
imwrite(img,fullfile(pth,fn));
set_status3(f3,['Saved: ',fullfile(pth,fn)]);
return
%
function lev=parse_levels(h)
str=strrep(get(h,'String'),',',' ');
lev=unique(abs(sscanf(str,'%f')))';
set(h,'String',strtrim(sprintf('%g ',lev)));
return
%
function [X,Y,Z]=contour_lines(lon,lat,h,mask,lev,dz)
%
% Isobaths of h (sea cells) for the depths LEV, in lon/lat (NaN
% separated), Z=-depth+DZ. Level 0: limit of the land/sea mask (Z=0).
% Contours computed in grid index space (curvilinear grids).
%
[nI,nJ]=size(h);
hs=h; hs(mask==0)=NaN;
X=[]; Y=[]; Z=[];
for l=lev
  if l==0
    C=contourc(1:nI,1:nJ,double(mask).',[0.5 0.5]); zl=0;
  else
    C=contourc(1:nI,1:nJ,hs.',[l l]); zl=-l+dz;
  end
  k=1;
  while k<size(C,2)
    n=C(2,k);
    xi=C(1,k+1:k+n)'; yi=C(2,k+1:k+n)';
    X=[X; interp2(lon.',xi,yi); NaN];
    Y=[Y; interp2(lat.',xi,yi); NaN];
    Z=[Z; zl*ones(n,1); NaN];
    k=k+n+1;
  end
end
return
%
function cb_selcontours(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
lev=parse_levels(S.hclev);
X=NaN; Y=NaN;
if get(S.hcont,'Value') && ~isempty(lev)
  [X,Y]=contour_lines(S.lon,S.lat,S.h,S.mask,lev,0);
  if isempty(X), X=NaN; Y=NaN; end
end
set(S.hcontour,'XData',X,'YData',Y);
return
