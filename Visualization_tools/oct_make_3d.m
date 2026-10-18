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
%     Horizontal section : variable at a constant depth z (m, z <= 0:
%                          negative down, 0 = surface level; positive
%                          values are rejected), optional velocity
%                          vectors (u,v at the same depth, rotated to
%                          east/north with the grid angle);
%     Vertical section W-E (constant J), Vertical section S-N (constant
%                          I): variable along a grid line, from the
%                          bottom to the free surface. The section is
%                          defined by the grid index (J or I, 0-based) or
%                          by a latitude (W-E) / longitude (S-N): menu
%                          left of the position box; the fields are then
%                          interpolated at that latitude/longitude;
%     Isosurface         : surface where the variable is equal to a
%                          value (on regular z levels), transparency;
%     Wind vectors (output file) / Wind vectors from BLK/FRC file...:
%                          wind (u10/v10, uwnd/vwnd, Uwind/Vwind) or
%                          wind stress (taux/tauy, sustr/svstr) vectors
%                          drawn on a horizontal plane ABOVE the sea
%                          surface (height in m, editable), coloured by
%                          the magnitude, rotated to east/north with the
%                          grid angle. From the his/avg file: record of
%                          the current time; from a BLK/FRC file: record
%                          nearest to the model time (cycle_length of the
%                          forcing time taken into account). The pair of
%                          variables is chosen in the "Variable" menu.
%                          Magnitude shown by colour + length, colour
%                          only (equal arrows) or length only (black or
%                          white arrows, reference arrow with its value);
%                          Scale = arrow length in grid cells per unit
%                          (m/s or N/m2), Skip = one arrow every SKIP cells.
%   Z range (m): minimum and maximum of the vertical axis (empty: auto,
%   from the deepest point to above the land / the wind planes); the
%   automatic vertical exaggeration follows this range.
%   Layers panel (right): list of the layers; for the selected layer:
%   variable (3D variables of the file and "speed"), position (depth,
%   J or I index / latitude or longitude, iso value), colour range
%   (min/max, Auto), colormap, transparency, visibility, velocity vectors
%   (skip, scale), Remove.
%   Colours: the colour range and the colormap belong to the VARIABLE:
%   all the layers of a variable (e.g. temp on horizontal and vertical
%   sections and isosurfaces) use the same range and colormap; editing
%   them in one layer changes all of them. Default range: whole 3D field
%   of the variable in the domain at the first time drawn (symmetric
%   around 0 for velocities, zeta, vorticity...), kept fixed in time;
%   "Auto" recomputes it at the current time. Default colormaps: cmocean
%   (oct_cmocean, oct_cmocean_var): temp thermal, salt haline, rho
%   dense, u/v/w/zeta balance, speed and wind speed, O2 oxy, CHLA
%   algae, nutrients matter...; other Octave colormaps (viridis, jet...)
%   remain available in the menu.
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
%  Octave version (Oct-2026).
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
%  CROCOTOOLS is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
%  MA  02111-1307  USA
%
%  Copyright (c) 2026 by Andres Sepulveda
%  Andres Sepulveda 2026 - Octave adaptations
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
layers=[]; vr=[];
if ~isempty(S.f3) && ishghandle(S.f3)
  T0=guidata(S.f3);
  if strcmp(T0.hisfile,S.hisfile), layers=T0.layers; end
  for k=1:numel(layers), layers(k).hg=[]; end
  if ~isempty(layers) && ~isfield(layers,'src'), [layers.src]=deal([]); end
  if ~isempty(layers) && ~isfield(layers,'pmode'), [layers.pmode]=deal(0); end
  vr=[]; if strcmp(T0.hisfile,S.hisfile) && isfield(T0,'vr'), vr=T0.vr; end
  setappdata(S.f3,'stop',1);
  delete(S.f3);
end
T=make_state(S);
if ~isempty(layers), T.layers=layers; end
if ~isempty(vr), T.vr=vr; end
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
                'alpha',{},'visible',{},'vec',{},'vskip',{},'vscale',{},'hg',{},'src',{},'pmode',{});
T.vr=struct('var',{},'cmin',{},'cmax',{},'cmap',{});   % colour range and map per variable
T.zrange=[NaN NaN];
T.zl=[];
T.sel=0;
T.cache=struct('key',{},'val',{});
T.vars={}; T.vinfo=struct('name',{},'grid',{},'w',{},'fill',{},'scale',{},'offset',{});
T.nt=0; T.time=[]; T.tindex=1; T.N=0;
om={'viridis','parula','turbo','jet','hot','cool','bone','cubehelix'};
om=om(cellfun(@(c) exist(c)>0,om));
T.cmaps=[oct_cmocean(),om];                  % cmocean maps first (default)
T.cmaplab=[strcat('cmo.',oct_cmocean()),om];
T.hiswind=[];
if ~isempty(T.hisfile) && exist(T.hisfile,'file')
  T=read_his_info(T);
  T.hiswind=wind_source(T.hisfile,1);
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
uimenu(ha,'Label','Wind vectors (output file)','Callback',{@cb_add,'w'},'Separator','on',...
       'Enable',ifelse(~isempty(T.hiswind),'on','off'));
uimenu(ha,'Label','Wind vectors from BLK/FRC file...','Callback',{@cb_add,'wfile'});
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
T.hposmode=uicontrol(f3,'Style','popupmenu','Units','normalized','Position',[x0 y .1 .037],...
          'String',{'J index','Latitude'},'Value',1,'Callback',@cb_prop,'Visible','off',...
          'TooltipString','Section defined by a grid index or by a longitude/latitude');
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
          'String','Auto','Callback',@cb_auto,...
          'TooltipString','Range of the whole 3D field of the variable at this time (all its layers)');
T.hcmap=uicontrol(f3,'Style','popupmenu','Units','normalized','Position',[x0+.07 y .12 .037],...
          'String',T.cmaplab,'Callback',@cb_prop,...
          'TooltipString','Colormap of the variable (cmo.: cmocean), shared by all its layers');
y=y-.045;
uicontrol(f3,'Style','text','Units','normalized','Position',[x0 y .11 .035],'String','Opacity (0-1)',...
          'HorizontalAlignment','left','BackgroundColor',bg);
T.halpha=uicontrol(f3,'Style','edit','Units','normalized','Position',[x0+.11 y .08 .037],...
          'String','','Callback',@cb_prop);
y=y-.05;
T.hvec=uicontrol(f3,'Style','checkbox','Units','normalized','Position',[x0 y w .035],...
          'String','Velocity vectors (u,v)','BackgroundColor',bg,'Callback',@cb_prop);
T.hwmode=uicontrol(f3,'Style','popupmenu','Units','normalized','Position',[x0 y w .037],...
          'String',{'Magnitude: colour + length','Magnitude: colour only','Magnitude: length (black)',...
          'Magnitude: length (white)'},'Value',1,'Callback',@cb_prop,'Visible','off',...
          'TooltipString','How the wind magnitude is shown');
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
y=y-.055;
uicontrol(f3,'Style','text','Units','normalized','Position',[x0 y .07 .035],'String','Z range (m)',...
          'HorizontalAlignment','left','BackgroundColor',bg);
T.hzmin=uicontrol(f3,'Style','edit','Units','normalized','Position',[x0+.07 y .06 .037],...
          'String','','Callback',@cb_zrange,'TooltipString','Bottom of the z axis (m, e.g. -500); empty: auto');
T.hzmax=uicontrol(f3,'Style','edit','Units','normalized','Position',[x0+.13 y .06 .037],...
          'String','','Callback',@cb_zrange,'TooltipString','Top of the z axis (m); empty: auto');
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
T.ztop=ztop; T.ztopo=ifelse(isempty(topo),0,ztop);
T=apply_zlim(T);
return
%
function T=apply_zlim(T)
%
% Limits of the z axis: Z range of the panel, or automatic (deepest point
% to above the land and the wind planes); then the vertical aspect
%
zl=[-max(T.h(:)) T.ztop];
for k=1:numel(T.layers)
  if strcmp(T.layers(k).type,'w') && T.layers(k).visible
    zl(2)=max(zl(2),1.15*T.layers(k).pos);
  end
end
if isfinite(T.zrange(1)), zl(1)=T.zrange(1); end
if isfinite(T.zrange(2)), zl(2)=T.zrange(2); end
if zl(2)<=zl(1), zl=[-max(T.h(:)) T.ztop]; end
zlim(T.ax,zl);
T.zl=zl;
T=apply_aspect(T);
return
%
function T=apply_aspect(T)
if ~isfield(T,'hexag') || isempty(T.zl), return, end
v=get(T.hexag,'String'); v=v{get(T.hexag,'Value')};
xyr=max((max(T.lon(:))-min(T.lon(:)))*T.coslat,max(T.lat(:))-min(T.lat(:)));
zr=diff(T.zl);
if strcmp(v,'auto')
  dz=zr/(0.35*xyr);
else
  dz=111e3/str2double(v);
end
set(T.ax,'DataAspectRatio',[1/T.coslat 1 dz]);
T.exagval=111e3/dz;
return
%
function cb_zrange(src,~)
f3=ancestor(src,'figure'); T=guidata(f3);
v=[str2double(get(T.hzmin,'String')) str2double(get(T.hzmax,'String'))];
if all(isfinite(v)) && v(2)<=v(1)
  set_status3(f3,'Z range: the maximum must be larger than the minimum'); return
end
T.zrange=v;
set(T.hzmin,'String',ifelse(isfinite(v(1)),num2str(v(1)),''));
set(T.hzmax,'String',ifelse(isfinite(v(2)),num2str(v(2)),''));
T=apply_zlim(T);
guidata(f3,T); update_title(f3);
set_status3(f3,sprintf('z axis: %g to %g m',T.zl));
return
%
function set_exag(f3)
T=guidata(f3);
T=apply_aspect(T);
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
  case 'vj'
    if L.pmode, s=sprintf('V W-E %s lat=%g',L.var,L.pos); else, s=sprintf('V W-E %s J=%d',L.var,L.pos); end
  case 'vi'
    if L.pmode, s=sprintf('V S-N %s lon=%g',L.var,L.pos); else, s=sprintf('V S-N %s I=%d',L.var,L.pos); end
  case 'iso', s=sprintf('ISO %s = %g',L.var,L.pos);
  case 'w',   s=sprintf('WIND %s z=+%g m (%s)',L.var,L.pos,short_name(L.src.file));
end
if L.vec, s=[s,' +vec']; end
if ~L.visible, s=[s,' (hidden)']; end
return
%
function cb_add(src,~,type)
f3=ancestor(src,'figure'); T=guidata(f3);
var='';
if ~isempty(T.vars), var=ifelse(any(strcmp(T.vars,'temp')),'temp',T.vars{1}); end
L=struct('type',type,'var',var,'pos',0,'cmin',NaN,'cmax',NaN,'cmap',1,...
         'alpha',1,'visible',1,'vec',0,'vskip',max(1,round(numel(T.ii)/20)),'vscale',1,'hg',[],'src',[],'pmode',0);
if any(strcmp(type,{'w','wfile'}))
  if strcmp(type,'w')
    S=T.hiswind;
  else
    [fn,pth]=uigetfile({'*blk*.nc;*frc*.nc','CROCO bulk/forcing files';'*.nc','All netcdf files'},...
                       'Select the BLK or FRC file (wind or wind stress)');
    if isequal(fn,0), return, end
    S=wind_source(fullfile(pth,fn),0);
  end
  if isempty(S)
    set_status3(f3,'No wind/stress variables (u10/v10, uwnd/vwnd, Uwind/Vwind, taux/tauy, sustr/svstr) in the file');
    return
  end
  if S.nx~=T.Lp || S.ny~=T.Mp
    set_status3(f3,sprintf('%s: grid size %dx%d differs from the model grid %dx%d',...
                short_name(S.file),S.nx,S.ny,T.Lp,T.Mp));
    return
  end
  L.type='w'; L.src=S; L.var=S.labels{1};
  L.src.wmode=1;
  L.pos=round_sig(max(1.3*T.ztop,0.08*max(T.h(:))),2);
  [ue,vn]=get_wind(T,L);                         % default scale: largest
  mag=sqrt(ue.^2+vn.^2);                         % arrow = SKIP cells
  L.vscale=round_sig(L.vskip/max(max(mag(:)),eps),2);
  type='w';
end
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
update_panel(f3); update_title(f3);
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
if strcmp(L.type,'w')
  [ue,vn,L.src]=get_wind(T,L);
  mag=sqrt(ue.^2+vn.^2);
  [T,L]=sync_range(T,L,mag);
  cm=get_cmap(T,L.cmap,128); cr=[L.cmin L.cmax];
  hold(ax,'on');
  L.hg=draw_wind(T,ax,ue,vn,L,cm,cr);
  hold(ax,'off');
  if ~L.visible, set(L.hg,'Visible','off'); end
  T.layers(k)=L;
  T=apply_zlim(T);
  return
end
if T.nt==0, T.layers(k)=L; return, end
[V,T]=get_var(T,L.var);
[Z,T]=get_var(T,'z_r');
[T,L]=sync_range(T,L,V);                       % range of the whole 3D field,
cm=get_cmap(T,L.cmap,128); cr=[L.cmin L.cmax];   % shared by the layers of L.var
hold(ax,'on');
switch L.type
  case 'h'
    d=min(L.pos,0);                            % depth: <=0 (checked in cb_prop)
    C=hslice(Z,V,d);
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
    if L.pmode                                 % constant latitude/longitude
      [x,y,z,v,h,m]=geo_section(T,Z,V,L.type,L.pos);
      if numel(x)<2
        hold(ax,'off'); T.layers(k)=L; return
      end
    elseif strcmp(L.type,'vj')
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
    L.hg=surface(repmat(x,1,n),repmat(y,1,n),z,val2rgb(v,cm,cr),'Parent',ax,...
                 'EdgeColor','none','FaceColor','interp','FaceAlpha',L.alpha,'FaceLighting','none');
  case 'iso'
    L.hg=draw_iso(T,ax,Z,V,L.pos,cm,cr,L.alpha);
end
hold(ax,'off');
if ~L.visible
  set(L.hg,'Visible','off');
end
T.layers(k)=L;
T=apply_zlim(T);
return
%
function [T,L]=sync_range(T,L,C)
%
% Colour range and colormap of the variable L.var, the same for all the
% layers of that variable (T.vr). Not defined yet: range of C (the whole
% 3D field of the variable in the domain at the current time, or the
% wind magnitude), symmetric around 0 for signed variables, and the
% default cmocean colormap of the variable (oct_cmocean_var).
%
k=find(strcmp({T.vr.var},L.var),1);
if isempty(k) || ~isfinite(T.vr(k).cmin) || ~isfinite(T.vr(k).cmax)
  [nm,div]=oct_cmocean_var(L.var);
  c=C(isfinite(C));
  if isempty(c), c=[0 1]; end
  if div
    a=round_out(max(abs(c)),2,1); if a==0, a=1; end
    r=[-a a];
  else
    r=[round_out(min(c),3,-1) round_out(max(c),3,1)];   % range contains the data
    if r(2)<=r(1), r(2)=r(1)+1; end
  end
  if isempty(k)
    k=numel(T.vr)+1;
    cmap=find(strcmp(T.cmaps,nm),1); if isempty(cmap), cmap=1; end
  else
    cmap=T.vr(k).cmap;
  end
  T.vr(k)=struct('var',L.var,'cmin',r(1),'cmax',r(2),'cmap',cmap);
end
L.cmin=T.vr(k).cmin; L.cmax=T.vr(k).cmax; L.cmap=T.vr(k).cmap;
return
%
function v=round_out(v,n,d)
%
% v rounded to n significant digits, down (d<0) or up (d>0)
%
if v==0 || ~isfinite(v), return, end
p=10^(n-1-floor(log10(abs(v))));
if d<0, v=floor(v*p)/p; else, v=ceil(v*p)/p; end
return
%
function cm=get_cmap(T,k,n)
name=T.cmaps{min(max(k,1),numel(T.cmaps))};
if oct_cmocean('-isname',name)
  cm=oct_cmocean(name,n);
else
  cm=feval(name,n);
end
return
%
function [x,y,z,v,h,m]=geo_section(T,Z,V,type,val)
%
% Vertical section at a constant latitude (type 'vj', W-E) or longitude
% ('vi', S-N): for each I (resp. J) the fields are interpolated linearly
% in J (resp. I) at the given latitude (longitude). Rows that do not
% cross the latitude (longitude) are removed.
%
lon=T.lon; lat=T.lat; hh=T.h; mk=T.mask;
if strcmp(type,'vj')
  A=lat;
else                                      % constant longitude: swap I,J
  A=lon'; lon=lon'; lat=lat'; hh=hh'; mk=mk';
  Z=permute(Z,[2 1 3]); V=permute(V,[2 1 3]);
end
[ni,nj,N]=size(Z);
x=NaN(ni,1); y=x; h=x; m=zeros(ni,1); z=NaN(ni,N); v=z;
for i=1:ni
  a=A(i,:);
  kk=find((a(1:end-1)-val).*(a(2:end)-val)<=0 & a(1:end-1)~=a(2:end),1);
  if isempty(kk), continue, end
  w=(val-a(kk))/(a(kk+1)-a(kk));
  x(i)=(1-w)*lon(i,kk)+w*lon(i,kk+1);
  y(i)=(1-w)*lat(i,kk)+w*lat(i,kk+1);
  h(i)=(1-w)*hh(i,kk)+w*hh(i,kk+1);
  kn=kk+(w>=0.5);
  m(i)=mk(i,kn);
  z(i,:)=(1-w)*squeeze(Z(i,kk,:))+w*squeeze(Z(i,kk+1,:));
  v1=squeeze(V(i,kk,:)); v2=squeeze(V(i,kk+1,:));
  vi=(1-w)*v1+w*v2;
  vn=squeeze(V(i,kn,:));
  vi(~isfinite(vi))=vn(~isfinite(vi));      % near the coast: nearest value
  v(i,:)=vi;
end
ok=isfinite(x);
x=x(ok); y=y(ok); h=h(ok); m=m(ok); z=z(ok,:); v=v(ok,:);
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
h=[T.hvis T.hremove T.hvar T.hpos T.hposmode T.hcmin T.hcmax T.hauto T.hcmap T.halpha T.hvec T.hvskip T.hvscale];
set(T.hvscale,'TooltipString','1: the largest vector = SKIP cells');
if T.sel<1 || T.sel>n
  set(T.hwmode,'Visible','off'); set(T.hvec,'Visible','on');
  set(T.hposmode,'Visible','off'); set(T.hposlab,'Visible','on');
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
if strcmp(L.type,'w')
  set(T.hvar,'String',L.src.labels,'Value',max(1,find(strcmp(L.src.labels,L.var),1)));
else
  set(T.hvar,'String',ifelse(isempty(T.vars),{'-'},T.vars),'Value',max(1,find(strcmp(T.vars,L.var),1)));
end
set(T.hpos,'String',num2str(L.pos));
isv=any(strcmp(L.type,{'vj','vi'}));
set(T.hposmode,'Visible',ifelse(isv,'on','off')); set(T.hposlab,'Visible',ifelse(isv,'off','on'));
if isv
  set(T.hposmode,'String',ifelse(strcmp(L.type,'vj'),{'J index','Latitude'},{'I index','Longitude'}),...
      'Value',L.pmode+1);
end
switch L.type
  case 'h'
    set(T.hposlab,'String','Depth (m)');
    set(T.hposinfo,'String','z (m) <= 0: 0 surface, negative below');
  case 'vj'
    set(T.hposlab,'String','J index');
    if L.pmode
      set(T.hposinfo,'String',sprintf('domain lat %.2f..%.2f',min(T.lat(:)),max(T.lat(:))));
    else
      [~,c]=min(abs(T.jj-1-L.pos));
      set(T.hposinfo,'String',sprintf('lat %.3f (J %d..%d)',mean(T.lat(:,c)),T.jj(1)-1,T.jj(end)-1));
    end
  case 'vi'
    set(T.hposlab,'String','I index');
    if L.pmode
      set(T.hposinfo,'String',sprintf('domain lon %.2f..%.2f',min(T.lon(:)),max(T.lon(:))));
    else
      [~,c]=min(abs(T.ii-1-L.pos));
      set(T.hposinfo,'String',sprintf('lon %.3f (I %d..%d)',mean(T.lon(c,:)),T.ii(1)-1,T.ii(end)-1));
    end
  case 'iso'
    set(T.hposlab,'String','Iso value');
    set(T.hposinfo,'String','');
  case 'w'
    set(T.hposlab,'String','Height (m)');
    if wind_mode(L)==2
      set(T.hposinfo,'String',L.src.info);
    else
      set(T.hposinfo,'String',sprintf('%s; %g cells per %s',L.src.info,L.vscale,wind_units(L)));
    end
end
set(T.hcmin,'String',num2str(L.cmin)); set(T.hcmax,'String',num2str(L.cmax));
set(T.hcmap,'Value',L.cmap);
set(T.halpha,'String',num2str(L.alpha));
set(T.hvec,'Value',L.vec); set(T.hvskip,'String',num2str(L.vskip)); set(T.hvscale,'String',num2str(L.vscale));
set(T.hvec,'Visible',ifelse(strcmp(L.type,'w'),'off','on'));
set(T.hwmode,'Visible',ifelse(strcmp(L.type,'w'),'on','off'));
if strcmp(L.type,'w')
  set(T.hwmode,'Value',wind_mode(L));
  set(T.hvscale,'TooltipString','Arrow length in grid cells per unit of the variable (m/s or N/m2)');
  if wind_mode(L)==2, set(T.hvscale,'Enable','off'); end
  if wind_mode(L)>=3, set([T.hcmin T.hcmax T.hauto T.hcmap],'Enable','off'); end
elseif ~strcmp(L.type,'h') || ~any(strcmp(T.vars,'u'))
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
if strcmp(L.type,'w') && wind_mode(L)>=3        % magnitude shown by the length
  set(T.cax,'Visible','off'); title(T.cax,'');
  guidata(f3,T); return
end
cm=get_cmap(T,L.cmap,128);
hold(T.cax,'on');
T.hcbar=image([0 1],[L.cmin L.cmax],reshape(cm,[size(cm,1) 1 3]),'Parent',T.cax);
if strcmp(L.type,'iso')
  T.hcbar(2)=plot(T.cax,[0 1],[1 1]*L.pos,'w-','LineWidth',3);
  T.hcbar(3)=plot(T.cax,[0 1],[1 1]*L.pos,'k-','LineWidth',1);
end
hold(T.cax,'off');
set(T.cax,'Visible','on','YDir','normal','XTick',[],'YAxisLocation','right','XLim',[0 1],...
          'YLim',[L.cmin L.cmax],'Box','on');
if strcmp(L.type,'w')
  title(T.cax,{L.var,L.src.units{find(strcmp(L.src.labels,L.var),1)}},'Interpreter','none');
else
  title(T.cax,L.var,'Interpreter','none');
end
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
% A property of the selected layer was changed: redraw the layer. The
% colour range and the colormap belong to the variable: a change is
% applied to all the layers of that variable.
%
f3=ancestor(src,'figure'); T=guidata(f3);
if T.sel<1, return, end
L=T.layers(T.sel);
num=@(h,def) ifelse(isfinite(str2double(get(h,'String'))),str2double(get(h,'String')),def);
oldvar=L.var; old=[L.cmin L.cmax L.cmap];
L.visible=get(T.hvis,'Value');
if strcmp(L.type,'w')
  L.var=L.src.labels{min(get(T.hvar,'Value'),numel(L.src.labels))};
  L.src.wmode=get(T.hwmode,'Value');
elseif ~isempty(T.vars)
  L.var=T.vars{get(T.hvar,'Value')};
end
msg='';
pos=num(T.hpos,L.pos);
switch L.type
  case 'h'                                     % depth: z <= 0
    if pos>0
      msg=sprintf('Depth %g m rejected: horizontal sections need z <= 0 (e.g. -%g)',pos,pos);
      pos=L.pos;
    end
  case {'vj','vi'}
    pm=get(T.hposmode,'Value')-1;
    if strcmp(L.type,'vj'), A=T.lat; idx=T.jj; dim=1; else, A=T.lon; idx=T.ii; dim=2; end
    if pm~=L.pmode                             % index <-> lon/lat
      if pm                                    % index -> lat (lon) of the line
        [~,c]=min(abs(idx-1-L.pos));
        if dim==1, pos=round_sig(mean(A(:,c)),5); else, pos=round_sig(mean(A(c,:)),5); end
      else                                     % lat (lon) -> nearest index
        if dim==1, a=mean(A,1); else, a=mean(A,2)'; end
        [~,c]=min(abs(a-L.pos)); pos=idx(c)-1;
      end
      L.pmode=pm;
    elseif pm && (pos<min(A(:)) || pos>max(A(:)))
      msg=sprintf('%s %g outside the domain (%.3f..%.3f)',ifelse(dim==1,'Latitude','Longitude'),...
                  pos,min(A(:)),max(A(:)));
      pos=L.pos;
    end
end
L.pos=pos;
if ~strcmp(oldvar,L.var)
  L.cmin=NaN; L.cmax=NaN;                       % new variable: its own range
  if strcmp(L.type,'iso')
    T.layers(T.sel)=L;
    [V,T]=get_var(T,L.var);
    L.pos=round_sig(median(V(isfinite(V))),3);
  end
  changed=false;
else
  L.cmin=num(T.hcmin,L.cmin); L.cmax=num(T.hcmax,L.cmax);
  if L.cmax<=L.cmin, L.cmin=old(1); L.cmax=old(2); msg='The colour maximum must be larger than the minimum'; end
  L.cmap=get(T.hcmap,'Value');
  changed=~isequal(old,[L.cmin L.cmax L.cmap]);
  if changed                                   % range of the variable
    k=find(strcmp({T.vr.var},L.var),1);
    if isempty(k), k=numel(T.vr)+1; end
    T.vr(k)=struct('var',L.var,'cmin',L.cmin,'cmax',L.cmax,'cmap',L.cmap);
  end
end
L.alpha=min(max(num(T.halpha,L.alpha),0),1);
L.vec=get(T.hvec,'Value');
L.vskip=max(1,round(num(T.hvskip,L.vskip)));
L.vscale=num(T.hvscale,L.vscale);
T.layers(T.sel)=L;
set_status3(f3,'Computing the layer...'); drawnow;
T=render_layer(T,T.sel);
if changed, T=render_var(T,L.var,T.sel); end
guidata(f3,T); update_panel(f3); update_title(f3);
set_status3(f3,msg);
return
%
function T=render_var(T,var,skip)
%
% Redraw the layers of the variable VAR (except layer SKIP)
%
for k=1:numel(T.layers)
  if k~=skip && strcmp(T.layers(k).var,var)
    T=render_layer(T,k);
  end
end
return
%
function cb_auto(src,~)
%
% Automatic colour range of the variable of the selected layer: range of
% its whole 3D field at the current time (wind: magnitude), for all the
% layers of that variable
%
f3=ancestor(src,'figure'); T=guidata(f3);
if T.sel<1, return, end
var=T.layers(T.sel).var;
k=find(strcmp({T.vr.var},var),1);
if ~isempty(k), T.vr(k).cmin=NaN; T.vr(k).cmax=NaN; end
T=render_layer(T,T.sel);
T=render_var(T,var,T.sel);
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
T=apply_zlim(T);
guidata(f3,T); update_panel(f3); update_title(f3);
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
update_panel(f3);
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
%
%---------------------------------------------------------------------
% Wind / wind stress above the sea surface
%---------------------------------------------------------------------
%
function S=wind_source(file,isout)
%
% Pairs of wind (u10/v10, uwnd/vwnd...) or wind stress (taux/tauy,
% sustr/svstr) variables of FILE, with their grid (r/u/v), units and time
% axis (days). isout: 1 for the his/avg file (record = model record).
%
S=[];
cands={{'u10','v10'},{'U10','V10'},{'uwnd','vwnd'},{'Uwind','Vwind'},{'wind_u','wind_v'},...
       {'taux','tauy'},{'sustr','svstr'},{'tx','ty'},{'TAUX','TAUY'}};
nc=netcdf.open(file,'NC_NOWRITE');
P={}; G={}; U={}; TV={}; TT={}; CY=[]; HT=[];
nx=NaN; ny=NaN;
for k=1:numel(cands)
  try
    vu=netcdf.inqVarID(nc,cands{k}{1}); vv=netcdf.inqVarID(nc,cands{k}{2});
  catch
    continue
  end
  [~,~,du]=netcdf.inqVar(nc,vu); [~,~,dv]=netcdf.inqVar(nc,vv);
  if numel(du)<2 || numel(du)>3 || numel(dv)~=numel(du), continue, end
  dn=@(d) netcdf.inqDim(nc,d);
  gu=grid_letter(dn(du(1)),dn(du(2))); gv=grid_letter(dn(dv(1)),dn(dv(2)));
  [~,n1]=netcdf.inqDim(nc,du(1)); [~,n2]=netcdf.inqDim(nc,du(2));
  if gu=='u', n1=n1+1; end
  if gu=='v', n2=n2+1; end
  nx=n1; ny=n2;
  units='';
  try, units=netcdf.getAtt(nc,vu,'units'); end
  tday=[]; cyc=0; ht=numel(du)==3;
  if ht && ~isout
    tname=dn(du(3));
    try
      vt=netcdf.inqVarID(nc,tname);
      tday=double(netcdf.getVar(nc,vt)); tday=tday(:);
      tu='days';
      try, tu=netcdf.getAtt(nc,vt,'units'); end
      if ~isempty(strfind(lower(tu),'sec')), tday=tday/86400; end
      if ~isempty(strfind(lower(tu),'hour')), tday=tday/24; end
      try, cyc=double(netcdf.getAtt(nc,vt,'cycle_length')); end
    end
  end
  P{end+1}=cands{k}; G{end+1}=[gu gv]; U{end+1}=units; TT{end+1}=tday; CY(end+1)=cyc; HT(end+1)=ht;
end
netcdf.close(nc);
if isempty(P), return, end
S.file=file; S.isout=isout; S.pairs=P; S.grid=G; S.units=U; S.time=TT; S.cycle=CY; S.hastime=HT;
S.labels=cellfun(@(p) [p{1},'/',p{2}],P,'UniformOutput',false);
S.nx=nx; S.ny=ny; S.info='';
return
%
function g=grid_letter(d1,d2)
g='r';
if strcmp(d1,'xi_u'), g='u'; elseif strcmp(d2,'eta_v'), g='v'; end
return
%
function [ue,vn,S]=get_wind(T,L)
%
% East/north components of the selected pair on the rho points of the
% block, at the record of the current time
%
S=L.src;
k=find(strcmp(S.labels,L.var),1); if isempty(k), k=1; end
rec=1; tday=NaN;
if S.isout
  rec=T.tindex; tday=T.time(T.tindex)/86400;
elseif S.hastime(k) && ~isempty(S.time{k})
  t=S.time{k};
  if T.nt>0, tm=T.time(T.tindex)/86400; else, tm=t(1); end
  d=abs(t-tm);
  if S.cycle(k)>0
    d=mod(t-tm,S.cycle(k)); d=min(d,S.cycle(k)-d);
  end
  [~,rec]=min(d); tday=t(rec);
end
u=read_2d(T,S.file,S.pairs{k}{1},S.grid{k}(1),rec,S.hastime(k));
v=read_2d(T,S.file,S.pairs{k}{2},S.grid{k}(2),rec,S.hastime(k));
a=T.angle;
ue=u.*cos(a)-v.*sin(a); vn=u.*sin(a)+v.*cos(a);
if isfinite(tday)
  S.info=sprintf('record %d (day %.2f) of %s',rec,tday,short_name(S.file));
else
  S.info=sprintf('record %d of %s',rec,short_name(S.file));
end
return
%
function X=read_2d(T,file,name,g,rec,hastime)
% 2D field (record rec) on the rho points of the block (nI,nJ)
nc=netcdf.open(file,'NC_NOWRITE');
vid=netcdf.inqVarID(nc,name);
switch g
  case 'u'
    a=max(T.i1-1,1); b=min(T.i2,T.Lp-1); st=[a-1 T.j1-1]; ct=[b-a+1 T.j2-T.j1+1];
  case 'v'
    a=max(T.j1-1,1); b=min(T.j2,T.Mp-1); st=[T.i1-1 a-1]; ct=[T.i2-T.i1+1 b-a+1];
  otherwise
    st=[T.i1-1 T.j1-1]; ct=[T.i2-T.i1+1 T.j2-T.j1+1];
end
if hastime, st(end+1)=rec-1; ct(end+1)=1; end
X=double(netcdf.getVar(nc,vid,st,ct));
fv=[]; sc=1; of=0;
try, fv=double(netcdf.getAtt(nc,vid,'_FillValue')); end
try, sc=double(netcdf.getAtt(nc,vid,'scale_factor')); end
try, of=double(netcdf.getAtt(nc,vid,'add_offset')); end
netcdf.close(nc);
if ~isempty(fv), X(X==fv)=NaN; end
X=X*sc+of; X(abs(X)>1e30)=NaN;
switch g
  case 'u'
    if T.i1==1, X=[X(1,:); X]; end
    if T.i2==T.Lp, X=[X; X(end,:)]; end
    X=0.5*(X(1:end-1,:)+X(2:end,:));
  case 'v'
    if T.j1==1, X=[X(:,1) X]; end
    if T.j2==T.Mp, X=[X X(:,end)]; end
    X=0.5*(X(:,1:end-1)+X(:,2:end));
end
X=X(T.ri,T.rj);
return
%
function hg=draw_wind(T,ax,ue,vn,L,cm,cr)
%
% Arrows on the plane z=L.pos (m above the sea surface). Display mode
% L.src.wmode:
%   1 colour + length : coloured by the magnitude, length = scale * value
%   2 colour only     : coloured by the magnitude, all arrows SKIP cells long
%   3/4 length only   : black / white arrows, length = scale * value
% scale (L.vscale) = arrow length in grid cells per unit of the variable
% (m/s or N/m2). A reference arrow with its value is drawn in the
% length modes. Outline of the plane in grey.
%
z=L.pos;
mode=wind_mode(L);
sk=max(1,round(L.vskip));
ii=1:sk:size(ue,1); jj=1:sk:size(ue,2);
x=T.lon(ii,jj); y=T.lat(ii,jj); u=ue(ii,jj); v=vn(ii,jj);
ok=isfinite(u) & isfinite(v) & (u~=0 | v~=0);
x=x(ok); y=y(ok); u=u(ok); v=v(ok);
mag=sqrt(u.^2+v.^2);
dl=cell_deg(T);
if mode==2
  f=0.9*sk*dl./max(mag,eps);                    % same length for all arrows
else
  f=L.vscale*dl;                                % degrees (lat) per unit
end
X=x*T.coslat;                                   % ~isotropic coordinates
[XX,YY]=arrow_lines(X,y,f.*u,f.*v);
hg=[];
% plane outline (boundary of the block)
bxo=[T.lon(:,1); T.lon(end,:)'; flipud(T.lon(:,end)); flipud(T.lon(1,:)')];
byo=[T.lat(:,1); T.lat(end,:)'; flipud(T.lat(:,end)); flipud(T.lat(1,:)')];
hg(end+1)=line(bxo,byo,z*ones(size(bxo)),'Parent',ax,'Color',[0.5 0.5 0.5],'LineStyle','--');
if mode>=3                                      % one colour
  col=ifelse(mode==3,[0 0 0],[1 1 1]);
  hg(end+1)=line(XX(:)/T.coslat,YY(:),z*ones(numel(XX),1),'Parent',ax,'Color',col,'LineWidth',1.5);
else                                            % colour classes
  nb=16;
  kb=min(max(floor((mag-cr(1))/max(cr(2)-cr(1),eps)*nb)+1,1),nb);
  for b=1:nb
    sel=find(kb==b);
    if isempty(sel), continue, end
    xs=XX(:,sel); ys=YY(:,sel);
    c=cm(max(1,round((b-0.5)/nb*size(cm,1))),:);
    hg(end+1)=line(xs(:)/T.coslat,ys(:),z*ones(numel(xs),1),'Parent',ax,'Color',c,'LineWidth',1.5);
  end
end
if mode~=2 && ~isempty(mag)                    % reference arrow
  ref=ref_value(max(mag));
  x0=min(T.lon(:))+0.03*(max(T.lon(:))-min(T.lon(:)));    % SW corner of the plane
  y0=min(T.lat(:))+0.04*(max(T.lat(:))-min(T.lat(:)));
  [RX,RY]=arrow_lines(x0*T.coslat,y0,L.vscale*dl*ref,0);
  col=ifelse(mode==4,[1 1 1],[0 0 0]);
  hg(end+1)=line(RX(:)/T.coslat,RY(:),z*ones(numel(RX),1),'Parent',ax,'Color',col,'LineWidth',2);
  hg(end+1)=text(x0+(L.vscale*dl*ref)/T.coslat*1.1,y0,z,sprintf(' %g %s',ref,wind_units(L)),...
                 'Parent',ax,'Color',col,'FontSize',10,'FontWeight','bold','Interpreter','none');
end
return
%
function [XX,YY]=arrow_lines(X,Y,dx,dy)
% shaft + head of the arrows (columns, NaN separated) in isotropic coordinates
X=X(:).'; Y=Y(:).'; dx=dx(:).'; dy=dy(:).';
len=sqrt(dx.^2+dy.^2);
X1=X+dx; Y1=Y+dy;
bx=-dx./max(len,eps); by=-dy./max(len,eps);
hl=0.3*len; a=25*pi/180;
H1x=X1+hl.*(bx*cos(a)-by*sin(a)); H1y=Y1+hl.*(bx*sin(a)+by*cos(a));
H2x=X1+hl.*(bx*cos(a)+by*sin(a)); H2y=Y1+hl.*(-bx*sin(a)+by*cos(a));
n=numel(X);
XX=[X; X1; NaN(1,n); H1x; X1; H2x; NaN(1,n)];
YY=[Y; Y1; NaN(1,n); H1y; Y1; H2y; NaN(1,n)];
return
%
function dl=cell_deg(T)
dl=median(abs(diff(T.lat(1,:))));
if ~(dl>0), dl=median(abs(diff(T.lat(:,1)))); end
if ~(dl>0), dl=0.1; end
return
%
function r=ref_value(m)
% round reference value (1, 2 or 5 x 10^n) not larger than m
if ~(m>0), r=1; return, end
p=10^floor(log10(m)); c=[1 2 5 10]*p;
r=c(find(c<=m,1,'last'));
return
%
function m=wind_mode(L)
m=1;
if isstruct(L.src) && isfield(L.src,'wmode'), m=L.src.wmode; end
return
%
function u=wind_units(L)
u='';
k=find(strcmp(L.src.labels,L.var),1);
if ~isempty(k), u=L.src.units{k}; end
return
