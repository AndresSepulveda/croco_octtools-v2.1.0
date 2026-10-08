function fig_out=oct_editmask(grid_file,coast_file)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% OCT_EDITMASK  Interactive Land/Sea mask editor for CROCO (Octave)
%
%   oct_editmask(GRID_FILE,COAST_FILE)
%   oct_editmask(GRID_FILE)
%   oct_editmask
%   fig = oct_editmask(...)        % returns the figure handle
%
%   Octave version (Sep-2026) of EDITMASK (A. Shcherbina, 2001) using the
%   netcdf.* API of the octave-netcdf package and function-handle
%   callbacks (no rbbox, no eval strings, no erasemode/drawmode).
%
%   The mask on RHO-points is edited in (I,J) grid coordinates (I along
%   xi, J along eta, starting at 0 as in the original editmask). When
%   saving, the U-, V- and PSI-masks are recomputed (uvp_masks) and the
%   four masks are written in GRID_FILE.
%
%   GRID_FILE  : CROCO grid NetCDF file.
%   COAST_FILE : optional MAT file with the coastline:
%                - lon, lat vectors (the *_mask.mat file written by
%                  oct_make_coast),
%                - ncst (N,2) [lon lat] (the GSHHS file saved by
%                  m_gshhs_X('save',...), e.g. coastline_l.mat),
%                - a structure C with C.Icst, C.Jcst (grid indices,
%                  as written by ijcoast),
%                - or any (N,2) [lon lat] array.
%                If COAST_FILE is not given, the coastfilemask /
%                coastfileplot files of crocotools_param.m (current
%                folder) are used if they exist, else a *_mask.mat file
%                of the current folder.
%                Menu "Coastline": load another file, or generate the
%                coastline from GSHHS (crude ... full resolution) with
%                m_map, or remove it.
%                The coastline longitudes are wrapped to the longitude
%                convention of the grid (0/360 or -180/180).
%                COAST_FILE can also be an ESRI shapefile (.shp, polyline
%                or polygon, geographic lon/lat coordinates).
%
%   View (menu "View"): by default the mask is drawn in geographic
%   coordinates (each cell with its real lon/lat shape) and the coastline
%   is superposed with its original resolution (its vertices are not
%   moved nor interpolated on the model grid). The grid index view (I,J)
%   is still available (faster for very large grids; there the coastline
%   vertices are mapped to (I,J) coordinates).
%   If GRID_FILE is missing, a file dialog is opened.
%
%   Tools (right panel):
%     Point / brush : click to edit one cell, click and drag to paint.
%                     "Brush size" gives the width in cells.
%     Rectangle     : click and drag a rectangle.
%     Polygon       : click the vertices; double click, right click or
%                     Enter closes the polygon and applies it; Esc cancels.
%   Edit modes: toggle Land/Sea, set Land, set Sea. In toggle mode, the
%   value given to the first cell is used for the whole stroke/area.
%
%   Mouse / keyboard shortcuts:
%     double click      : zoom in (x2) around the pointer
%     right click       : zoom out to the full grid
%     middle click      : next edit mode
%     arrows            : pan          + / -  : zoom in / out
%     u  (or Ctrl+z)    : undo last change
%     s                 : save
%
%   Buttons: Zoom in (drag a box), Zoom out, Undo (several levels),
%   Revert (last saved mask), Remove isolated (sea cells with no sea
%   neighbour in the 4 directions become land, and land cells
%   surrounded by sea become sea), Save, Exit.
%
%   In oct_make_grid the editor is opened with uiwait/waitfor, so the
%   script continues once the window is closed.
%
%  This file is part of CROCOTOOLS (GNU General Public License).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<1 || isempty(grid_file)
  [fn,pth]=uigetfile('*.nc','Select CROCO grid file...');
  if isequal(fn,0), if nargout>0, fig_out=[]; end, return, end
  grid_file=[pth,fn];
end
if nargin<2
  coast_file=find_coast_file();
end
if ~exist(grid_file,'file')
  error(['oct_editmask: grid file not found: ',grid_file])
end
%
% Only one editor at a time
%
old=findobj(0,'tag','oct_maskeditor');
if ~isempty(old), delete(old); end
%
% Read the grid (netcdf.getVar returns (xi,eta) = (Lp,Mp), which is the
% (I,J) layout used by the editor: no transpose here)
%
S=struct();
S.file=grid_file;
S.figname='Land/Sea Mask Editor';
ncid=netcdf.open(grid_file,'NC_NOWRITE');
[~,S.Lp]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'xi_rho'));
[~,S.Mp]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'eta_rho'));
S.mask=ones(S.Lp,S.Mp);
try
  S.mask=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'mask_rho')));
end
S.lon=[]; S.lat=[];
for nm={{'lon_rho','lat_rho'},{'x_rho','y_rho'}}
  try
    S.lon=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,nm{1}{1})));
    S.lat=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,nm{1}{2})));
    S.lonname=nm{1}{1}(1:3); S.latname=nm{1}{2}(1:3);
    break
  end
end
S.h=[];
for nm={'hraw','h'}
  try
    tmp=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,nm{1})));
    S.h=tmp(:,:,end);         % hraw can have a record dimension
    break
  end
end
netcdf.close(ncid);
S.mask=double(S.mask>0.5);
S.saved=S.mask;              % last saved mask
S.undo={};                   % undo stack
S.maxundo=30;
S.changed=0;
S.mode=1;                    % 1 toggle, 2 land, 3 sea
S.tool=1;                    % 1 point/brush, 2 rectangle, 3 polygon
S.brush=1;
S.action='';                 % '', 'paint', 'rect', 'zoom', 'poly'
S.p0=[0 0];
S.paintval=1;
S.poly=zeros(0,2);
S.lastclick=-inf;
S.zoomnext=0;
[S.mx,S.my]=ndgrid(0:S.Lp-1,0:S.Mp-1);
S.checker=mod(S.mx+S.my,2);
%
% Geographic view: cell corners (lon/lat), scale for distances
%
if ~isempty(S.lon)
  [S.xcor,S.ycor]=cell_corners(S.lon,S.lat);
  S.coslat=cos(mean(S.lat(:))*pi/180);
  S.view='geo';
else
  S.view='ij';
end
%
% Coastline: raw (lon,lat) vertices (original resolution)
%
S.cst=read_coast(coast_file,S);
%
% Figure
%
CMAP=[.5 1 0; 1 1 0; 0 0 .7; 0 0 1];   % land (2 tones), sea (2 tones)
fig=figure('NumberTitle','off','Name',S.figname,'tag','oct_maskeditor',...
           'MenuBar','none','ToolBar','none','Color',[.94 .94 .94],...
           'IntegerHandle','off','Units','normalized',...
           'Position',[.08 .08 .8 .8]);
S.fig=fig;
hm=uimenu(fig,'Label','Coastline');
uimenu(hm,'Label','Load coastline file (.mat or .shp)...','Callback',@cb_coastfile);
uimenu(hm,'Label','Load shapefile (.shp)...','Callback',@cb_shapefile);
res={'c','crude';'l','low';'i','intermediate';'h','high';'f','full'};
for k=1:size(res,1)
  uimenu(hm,'Label',['GSHHS ',res{k,2},' resolution'],'Callback',{@cb_gshhs,res{k,1}},...
         'Separator',ifelse(k==1,'on','off'));
end
uimenu(hm,'Label','Remove coastline','Callback',@cb_nocoast,'Separator','on');
hv=uimenu(fig,'Label','View');
S.hview(1)=uimenu(hv,'Label','Geographic (lon/lat)','Callback',{@cb_view,'geo'});
S.hview(2)=uimenu(hv,'Label','Grid indices (I,J)','Callback',{@cb_view,'ij'});
if isempty(S.lon), set(S.hview(1),'Enable','off'); end
S.ax=axes('Parent',fig,'Units','normalized','Position',[0.06 0.08 0.72 0.86]);
set(fig,'Colormap',CMAP);
hold(S.ax,'on');
S.himg=image(0:S.Lp-1,0:S.Mp-1,cdata(S).','Parent',S.ax,'CDataMapping','direct');
S.hsurf=[];
if ~isempty(S.lon)
  S.hsurf=surface(S.xcor,S.ycor,zeros(size(S.xcor)),pad_cdata(cdata(S)),'Parent',S.ax,...
                  'FaceColor','flat','EdgeColor','none','CDataMapping','direct');
end
S.hcst=plot(S.ax,NaN,NaN,'k','LineWidth',1);
S.hrect=plot(S.ax,NaN,NaN,'r-','LineWidth',1.5);
S.hpoly=plot(S.ax,NaN,NaN,'r.-','LineWidth',1.5,'MarkerSize',12);
hold(S.ax,'off');
set(S.ax,'YDir','normal','Layer','top','TickDir','out','Box','on');
S=set_view(S,S.view);
%
% Right panel
%
x0=0.81; w=0.17;
uicontrol(fig,'Style','text','Units','normalized','Position',[x0 .955 w .03],...
          'String','Pointer','FontWeight','bold','BackgroundColor',[.94 .94 .94]);
S.hinfo=uicontrol(fig,'Style','text','Units','normalized','Position',[x0 .83 w .125],...
          'String',{'---'},'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
uicontrol(fig,'Style','text','Units','normalized','Position',[x0 .79 w .03],...
          'String','Edit mode','FontWeight','bold','BackgroundColor',[.94 .94 .94]);
modes={'Toggle Land/Sea','Set Land','Set Sea'};
for k=1:3
  S.hmode(k)=uicontrol(fig,'Style','radiobutton','Units','normalized',...
     'Position',[x0 .79-0.035*k w .033],'String',modes{k},'Value',k==S.mode,...
     'BackgroundColor',[.94 .94 .94],'Callback',{@set_mode,k});
end
uicontrol(fig,'Style','text','Units','normalized','Position',[x0 .64 w .03],...
          'String','Edit tool','FontWeight','bold','BackgroundColor',[.94 .94 .94]);
tools={'Point / brush','Rectangle','Polygon'};
for k=1:3
  S.htool(k)=uicontrol(fig,'Style','radiobutton','Units','normalized',...
     'Position',[x0 .64-0.035*k w .033],'String',tools{k},'Value',k==S.tool,...
     'BackgroundColor',[.94 .94 .94],'Callback',{@set_tool,k});
end
uicontrol(fig,'Style','text','Units','normalized','Position',[x0 .49 .09 .03],...
          'String','Brush size','HorizontalAlignment','left','BackgroundColor',[.94 .94 .94]);
S.hbrush=uicontrol(fig,'Style','popupmenu','Units','normalized','Position',[x0+.09 .49 .08 .035],...
          'String',{'1','3','5','9','15'},'Value',1,'Callback',@set_brush);
bt={'Zoom in (box)',@cb_zoomin; 'Zoom out',@cb_zoomout; 'Undo',@cb_undo;...
    'Revert to saved',@cb_revert; 'Remove isolated',@cb_isolated;...
    'Save',@cb_save; 'Exit',@cb_exit};
ypos=[.43 .385 .32 .275 .21 .12 .06];
for k=1:size(bt,1)
  S.hbut(k)=uicontrol(fig,'Style','pushbutton','Units','normalized',...
     'Position',[x0 ypos(k) w .04],'String',bt{k,1},'Callback',bt{k,2});
end
S.hstat=uicontrol(fig,'Style','text','Units','normalized','Position',[x0 .005 w .045],...
          'String','','HorizontalAlignment','left','BackgroundColor',[.94 .94 .94]);
set(fig,'WindowButtonDownFcn',@cb_down,'WindowButtonMotionFcn',@cb_move,...
        'WindowButtonUpFcn',@cb_up,'KeyPressFcn',@cb_key,...
        'CloseRequestFcn',@cb_exit);
guidata(fig,S);
refresh_mask(fig);
if nargout>0, fig_out=fig; end
return
%
%======================================================================
%                          Local functions
%======================================================================
%
function C=read_coast(coast_file,S)
%
% Coastline of a MAT file or of a shapefile: raw (lon,lat) vertices
% (C.lon, C.lat, longitudes wrapped to the grid convention) or grid
% indices (C.icst, C.jcst) for the files written by ijcoast.
%
C=struct('lon',[],'lat',[],'icst',[],'jcst',[],'ij',[]);
if isempty(coast_file), return, end
if ~exist(coast_file,'file')
  warning(['oct_editmask: coast file not found: ',coast_file]); return
end
[~,~,ext]=fileparts(coast_file);
if strcmpi(ext,'.shp')
  [lon,lat]=read_shapefile(coast_file);
  disp(sprintf('oct_editmask: %d coastline points read in the shapefile %s',sum(isfinite(lon)),coast_file))
  C=set_coast_lonlat(C,lon,lat,S);
  return
end
D=load(coast_file);
if isfield(D,'C') && isstruct(D.C) && isfield(D.C,'Icst')
  C.icst=D.C.Icst(:); C.jcst=D.C.Jcst(:);
  disp(['oct_editmask: coastline (I,J) read in ',coast_file]); return
end
if isfield(D,'lon') && isfield(D,'lat')
  lon=D.lon(:); lat=D.lat(:);
elseif isfield(D,'ncst')
  lon=D.ncst(:,1); lat=D.ncst(:,2);
else
  lon=[]; lat=[];
  f=fieldnames(D);
  for k=1:numel(f)
    v=D.(f{k});
    if isnumeric(v) && ismatrix(v) && size(v,2)==2 && size(v,1)>2
      lon=v(:,1); lat=v(:,2); break
    end
  end
  if isempty(lon)
    warning(['oct_editmask: no coastline in ',coast_file,...
             ' (variables lon/lat, ncst or C.Icst/C.Jcst expected)']);
    return
  end
end
disp(['oct_editmask: coastline read in ',coast_file])
C=set_coast_lonlat(C,double(lon),double(lat),S);
return
%
function C=set_coast_lonlat(C,lon,lat,S)
%
% Keep the coastline vertices near the grid (original resolution, NaN
% separators kept), longitudes in the convention of the grid
%
C.lon=[]; C.lat=[]; C.icst=[]; C.jcst=[]; C.ij=[];
lon=lon(:); lat=lat(:);
if isempty(S.lon)
  warning('oct_editmask: no lon_rho/lat_rho in the grid: coastline not drawn'); return
end
rlon=S.lon;
lon0=mean(rlon(:));
w=lon<lon0-180 | lon>=lon0+180;          % only these vertices are shifted by 360
lon(w)=mod(lon(w)-lon0+180,360)-180+lon0;
dx=2*max(abs(diff(rlon(:,1)))); dy=2*max(abs(diff(S.lat(1,:))));
if isempty(dx) || dx==0, dx=1; end
if isempty(dy) || dy==0, dy=1; end
out=lon<min(rlon(:))-dx | lon>max(rlon(:))+dx | lat<min(S.lat(:))-dy | lat>max(S.lat(:))+dy;
lon(out)=NaN; lat(out)=NaN;
keep=~isnan(lon);
keep=keep | [false; keep(1:end-1)] | [keep(2:end); false];
lon=lon(keep); lat=lat(keep);
if ~any(isfinite(lon))
  warning(['oct_editmask: no coastline point inside the grid domain ',...
           sprintf('(lon %.2f/%.2f, lat %.2f/%.2f)',min(rlon(:)),max(rlon(:)),min(S.lat(:)),max(S.lat(:)))]);
  return
end
C.lon=lon; C.lat=lat;
disp(sprintf('oct_editmask: %d coastline points inside the domain',sum(isfinite(lon))))
return
%
function [x,y]=coast_xy(S)
%
% Coastline coordinates in the current view
%
x=NaN; y=NaN;
C=S.cst;
if strcmp(S.view,'geo')
  if ~isempty(C.lon)
    x=C.lon; y=C.lat;                         % original vertices
  elseif ~isempty(C.icst)                     % (I,J) file: to lon/lat
    x=interp2(S.lon.',C.icst+1,C.jcst+1);
    y=interp2(S.lat.',C.icst+1,C.jcst+1);
  end
else
  if ~isempty(C.icst)
    x=C.icst; y=C.jcst;
  elseif ~isempty(C.lon)
    [x,y]=coast2ij(C.lon,C.lat,S);
  end
end
return
%
function [xc,yc]=coast2ij(lon,lat,S)
%
% (lon,lat) vertices -> (I,J) coordinates of the grid index view (each
% vertex is mapped, none is added or removed)
%
xc=NaN(size(lon)); yc=xc;
ok=isfinite(lon);
if any(ok)
  xc(ok)=griddata(S.lon(:),S.lat(:),S.mx(:),lon(ok),lat(ok),'linear');
  yc(ok)=griddata(S.lon(:),S.lat(:),S.my(:),lon(ok),lat(ok),'linear');
end
return
%
function [lon,lat]=read_shapefile(fname)
%
% Minimal ESRI shapefile reader (no toolbox needed): polyline and polygon
% shapes (types 3, 5, 13, 15, 23, 25), parts separated by NaN.
% The coordinates must be geographic (lon/lat degrees).
%
[p,b]=fileparts(fname);
prj=fullfile(p,[b,'.prj']);
if exist(prj,'file')
  t=fileread(prj);
  if ~isempty(strfind(upper(t),'PROJCS'))
    warning(['oct_editmask: ',fname,' is in projected coordinates (',prj,...
             '): convert it to geographic lon/lat (e.g. ogr2ogr -t_srs EPSG:4326)']);
  end
end
fid=fopen(fname,'r','ieee-be');
if fid<0, error(['oct_editmask: cannot open ',fname]), end
code=fread(fid,1,'int32');
if code~=9994
  fclose(fid); error(['oct_editmask: ',fname,' is not a shapefile'])
end
fseek(fid,24,'bof');
flen=2*fread(fid,1,'int32');            % file length (bytes)
fseek(fid,32,'bof');
stype=fread(fid,1,'int32',0,'ieee-le');
if ~any(stype==[3 5 13 15 23 25])
  fclose(fid);
  error(sprintf('oct_editmask: shapefile type %d not supported (polyline or polygon expected)',stype))
end
fseek(fid,100,'bof');
X={}; Y={};
while ftell(fid)<flen
  hdr=fread(fid,2,'int32',0,'ieee-be');
  if numel(hdr)<2, break, end
  clen=2*hdr(2);                         % content length (bytes)
  pos=ftell(fid);
  t=fread(fid,1,'int32',0,'ieee-le');
  if any(t==[3 5 13 15 23 25])
    fread(fid,4,'double',0,'ieee-le');   % bounding box
    nparts=fread(fid,1,'int32',0,'ieee-le');
    npts=fread(fid,1,'int32',0,'ieee-le');
    parts=fread(fid,nparts,'int32',0,'ieee-le');
    xy=fread(fid,[2 npts],'double',0,'ieee-le');
    parts=[parts(:); npts];
    for k=1:nparts
      ii=parts(k)+1:parts(k+1);
      X{end+1}=[xy(1,ii) NaN]; Y{end+1}=[xy(2,ii) NaN];
    end
  end
  fseek(fid,pos+clen,'bof');
end
fclose(fid);
lon=[X{:}]'; lat=[Y{:}]';
if isempty(lon)
  warning(['oct_editmask: no line in ',fname]); lon=NaN; lat=NaN;
end
return
%
function [xc,yc]=cell_corners(lon,lat)
%
% Corners of the rho cells (Lp+1,Mp+1): rho grid extrapolated by one
% point on each side, then averaged over 2x2 points
%
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
% CData of the corner surface (flat shading: colour of the lower corner)
c=[c c(:,end); c(end,:) c(end,end)];
return
%
function S=set_view(S,view)
%
% Switch between the geographic view (surface of the cells in lon/lat)
% and the grid index view (image in I,J)
%
if strcmp(view,'geo') && isempty(S.lon), view='ij'; end
S.view=view;
if strcmp(view,'geo')
  S.px=S.lon; S.py=S.lat;
  S.xl=[min(S.xcor(:)) max(S.xcor(:))];
  S.yl=[min(S.ycor(:)) max(S.ycor(:))];
  S.tol=0.5*median(abs(diff(S.lat(1,:))));
  if ~(S.tol>0), S.tol=0.01; end
  set(S.himg,'Visible','off'); set(S.hsurf,'Visible','on');
  xlabel(S.ax,'Longitude'); ylabel(S.ax,'Latitude');
  set(S.ax,'DataAspectRatio',[1/S.coslat 1 1]);
else
  S.px=S.mx; S.py=S.my;
  S.xl=[-0.5 S.Lp-0.5]; S.yl=[-0.5 S.Mp-0.5];
  S.tol=0.5;
  set(S.himg,'Visible','on');
  if ~isempty(S.hsurf), set(S.hsurf,'Visible','off'); end
  xlabel(S.ax,'I (xi\_rho index - 1)'); ylabel(S.ax,'J (eta\_rho index - 1)');
  set(S.ax,'DataAspectRatio',[1 1 1]);
end
[x,y]=coast_xy(S);
set(S.hcst,'XData',x,'YData',y);
set(S.hrect,'XData',NaN,'YData',NaN); set(S.hpoly,'XData',NaN,'YData',NaN);
xlim(S.ax,S.xl); ylim(S.ax,S.yl);
if isfield(S,'hview')
  set(S.hview(1),'Checked',ifelse(strcmp(view,'geo'),'on','off'));
  set(S.hview(2),'Checked',ifelse(strcmp(view,'ij'),'on','off'));
end
return
%
function cb_view(src,~,view)
fig=ancestor(src,'figure'); S=guidata(fig);
S=cancel_action(S);
S=set_view(S,view);
guidata(fig,S); refresh_mask(fig);
return
%
function [i,j]=p2ij(S,p)
%
% (1-based) cell indices of a point of the current view
%
if strcmp(S.view,'geo')
  d=((S.lon-p(1))*S.coslat).^2+(S.lat-p(2)).^2;
  [~,k]=min(d(:));
  [i,j]=ind2sub([S.Lp S.Mp],k);
else
  i=min(max(round(p(1))+1,1),S.Lp); j=min(max(round(p(2))+1,1),S.Mp);
end
return
%
function f=find_coast_file()
%
% Default coastline file: coastfilemask/coastfileplot of crocotools_param.m
% (current folder), else a *_mask.mat file of the current folder
%
f='';
if exist(fullfile(pwd,'crocotools_param.m'),'file')
  try
    P=param_coast();
    for c={P.mask,P.plot}
      if ~isempty(c{1}) && exist(c{1},'file')
        f=c{1}; return
      end
    end
  end
end
d=dir('*_mask.mat');
if ~isempty(d)
  f=d(1).name;
end
return
%
function P=param_coast()
str=evalc('crocotools_param');
P.mask=''; P.plot='';
if exist('coastfilemask','var'), P.mask=coastfilemask; end
if exist('coastfileplot','var'), P.plot=coastfileplot; end
return
%
function [lon,lat]=gshhs_coast(S,res)
%
% Coastline from the GSHHS database of m_map (m_gshhs_<res>) around the
% grid. If the GSHHS files are not installed, m_map uses its coarse
% default coastline.
%
lon0=min(S.lon(:)); lon1=max(S.lon(:));
lat0=min(S.lat(:)); lat1=max(S.lat(:));
dl=0.1*max(lon1-lon0,lat1-lat0);
m_proj('mercator','lon',[lon0-dl lon1+dl],'lat',[max(lat0-dl,-89) min(lat1+dl,89)]);
f=[tempname(),'.mat'];
feval(['m_gshhs_',res],'save',f);
D=load(f);
delete(f);
lon=D.ncst(:,1); lat=D.ncst(:,2);
return
%
function v=ifelse(c,a,b)
if c, v=a; else, v=b; end
return
%
function set_coast(fig,C)
S=guidata(fig);
S.cst=C;
[x,y]=coast_xy(S);
set(S.hcst,'XData',x,'YData',y);
guidata(fig,S);
return
%
function cb_coastfile(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
[fn,pth]=uigetfile({'*.mat;*.shp','Coastline (*.mat, *.shp)';'*.mat','MAT files';'*.shp','Shapefiles'},...
                   'Select a coastline file');
if isequal(fn,0), return, end
set_coast(fig,read_coast(fullfile(pth,fn),S));
return
%
function cb_shapefile(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
[fn,pth]=uigetfile('*.shp','Select a coastline shapefile (lon/lat)');
if isequal(fn,0), return, end
set_coast(fig,read_coast(fullfile(pth,fn),S));
return
%
function cb_gshhs(src,~,res)
fig=ancestor(src,'figure'); S=guidata(fig);
set(S.hstat,'String','Reading GSHHS coastline...'); drawnow
try
  [lon,lat]=gshhs_coast(S,res);
  C=set_coast_lonlat(S.cst,lon,lat,S);
  set_coast(fig,C);
catch err
  errordlg(['GSHHS coastline: ',err.message],'Mask editor');
end
refresh_mask(fig);
return
%
function cb_nocoast(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
set_coast(fig,struct('lon',[],'lat',[],'icst',[],'jcst',[],'ij',[]));
return
%
function c=cdata(S)
c=S.mask*2+S.checker+1;
return
%
function refresh_mask(fig)
S=guidata(fig);
c=cdata(S);
if strcmp(S.view,'geo')
  set(S.hsurf,'CData',pad_cdata(c));
else
  set(S.himg,'CData',c.');
end
nm=[S.figname,' - ',S.file];
if S.changed, nm=[nm,' *']; end
set(fig,'Name',nm);
set(S.hstat,'String',sprintf('sea: %d  land: %d\nundo levels: %d',...
    sum(S.mask(:)),numel(S.mask)-sum(S.mask(:)),numel(S.undo)));
return
%
function p=cur_point(S)
cp=get(S.ax,'CurrentPoint');
p=cp(1,1:2);
return
%
function r=inside(S,p)
xl=xlim(S.ax); yl=ylim(S.ax);
r=p(1)>=xl(1) && p(1)<=xl(2) && p(2)>=yl(1) && p(2)<=yl(2) && ...
  p(1)>=S.xl(1) && p(1)<=S.xl(2) && p(2)>=S.yl(1) && p(2)<=S.yl(2);
return
%
function S=push_undo(S)
S.undo{end+1}=S.mask;
if numel(S.undo)>S.maxundo, S.undo(1)=[]; end
return
%
function v=target_value(S,cur)
switch S.mode
  case 1, v=1-cur;       % toggle
  case 2, v=0;           % land
  otherwise, v=1;        % sea
end
return
%
function S=paint(S,p)
[i,j]=p2ij(S,p);
r=(S.brush-1)/2;
ii=max(1,i-r):min(S.Lp,i+r);
jj=max(1,j-r):min(S.Mp,j+r);
if isempty(ii) || isempty(jj), return, end
S.mask(ii,jj)=S.paintval;
return
%
function S=apply_sel(S,sel)
if ~any(sel(:)), return, end
S=push_undo(S);
if S.mode==1
  cur=S.mask(sel);
  S.mask(sel)=1-cur;       % toggle every cell of the area
else
  S.mask(sel)=target_value(S,0);
end
S.changed=1;
return
%
function set_mode(src,~,k)
fig=ancestor(src,'figure'); S=guidata(fig);
S.mode=k;
for n=1:3, set(S.hmode(n),'Value',n==k); end
guidata(fig,S);
return
%
function set_tool(src,~,k)
fig=ancestor(src,'figure'); S=guidata(fig);
S=cancel_action(S);
S.tool=k;
for n=1:3, set(S.htool(n),'Value',n==k); end
guidata(fig,S);
return
%
function set_brush(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
v=get(src,'String'); S.brush=str2double(v{get(src,'Value')});
guidata(fig,S);
return
%
function S=cancel_action(S)
S.action=''; S.poly=zeros(0,2); S.zoomnext=0;
set(S.hrect,'XData',NaN,'YData',NaN);
set(S.hpoly,'XData',NaN,'YData',NaN);
return
%
function draw_rect(S,p0,p1)
set(S.hrect,'XData',[p0(1) p1(1) p1(1) p0(1) p0(1)],...
            'YData',[p0(2) p0(2) p1(2) p1(2) p0(2)]);
return
%
%---------------------------------------------------------------------
% Mouse callbacks
%---------------------------------------------------------------------
%
function cb_down(fig,~)
S=guidata(fig);
p=cur_point(S);
if ~inside(S,p), return, end
sel=get(fig,'SelectionType');
switch sel
  case 'alt'                                  % right click
    if S.tool==3 && size(S.poly,1)>=3
      S=close_poly(S);
    else
      S=cancel_action(S);
      xlim(S.ax,S.xl); ylim(S.ax,S.yl);
    end
  case 'extend'                               % middle click
    guidata(fig,S);
    set_mode(S.hmode(1),[],mod(S.mode,3)+1);
    return
  case 'open'                                 % double click
    if S.tool==3 && size(S.poly,1)>=3
      S=close_poly(S);
    else
%     cancel the edit made by the first click of the double click
      if ~isempty(S.undo) && (now-S.lastclick)*86400<1
        S.mask=S.undo{end}; S.undo(end)=[];
      end
      S=cancel_action(S);
      zoom_at(S,p,0.5);
    end
  otherwise                                   % left click
    if S.zoomnext
      S.action='zoom'; S.p0=p; draw_rect(S,p,p);
    else
      switch S.tool
        case 1
          S=push_undo(S);
          [i,j]=p2ij(S,p);
          S.paintval=target_value(S,S.mask(i,j));
          S=paint(S,p);
          S.changed=1;
          S.action='paint';
          S.lastclick=now;
        case 2
          S.action='rect'; S.p0=p; draw_rect(S,p,p);
        case 3
          S.action='poly';
          S.poly(end+1,:)=p;
          set(S.hpoly,'XData',S.poly(:,1),'YData',S.poly(:,2));
      end
    end
end
guidata(fig,S);
refresh_mask(fig);
return
%
function cb_move(fig,~)
S=guidata(fig);
p=cur_point(S);
if inside(S,p)
  [i1,j1]=p2ij(S,p);
  s={sprintf('I,J = %d, %d',i1-1,j1-1)};
  if ~isempty(S.lon)
    s{end+1}=sprintf('%s = %.4f',S.lonname,S.lon(i1,j1));
    s{end+1}=sprintf('%s = %.4f',S.latname,S.lat(i1,j1));
  end
  if ~isempty(S.h), s{end+1}=sprintf('h = %.1f m',S.h(i1,j1)); end
  if S.mask(i1,j1), s{end+1}='mask = 1 (sea)'; else, s{end+1}='mask = 0 (land)'; end
  set(S.hinfo,'String',s);
  set(fig,'Pointer','crosshair');
else
  set(S.hinfo,'String',{'---'});
  set(fig,'Pointer','arrow');
end
switch S.action
  case 'paint'
    if inside(S,p)
      S=paint(S,p); guidata(fig,S); refresh_mask(fig);
    end
  case {'rect','zoom'}
    draw_rect(S,S.p0,p);
  case 'poly'
    if ~isempty(S.poly)
      set(S.hpoly,'XData',[S.poly(:,1);p(1)],'YData',[S.poly(:,2);p(2)]);
    end
end
return
%
function cb_up(fig,~)
S=guidata(fig);
p=cur_point(S);
switch S.action
  case 'paint'
    S.action='';
  case 'rect'
    sel=(S.px-S.p0(1)).*(S.px-p(1))<=0 & (S.py-S.p0(2)).*(S.py-p(2))<=0;
    if abs(p(1)-S.p0(1))<S.tol && abs(p(2)-S.p0(2))<S.tol    % simple click
      [i,j]=p2ij(S,p);
      sel=false(S.Lp,S.Mp); sel(i,j)=true;
    end
    S=apply_sel(S,sel);
    S=cancel_action(S);
  case 'zoom'
    if abs(p(1)-S.p0(1))<S.tol || abs(p(2)-S.p0(2))<S.tol
      zoom_at(S,p,0.5);                       % simple click: zoom x2
    else
      xlim(S.ax,sort([S.p0(1) p(1)])); ylim(S.ax,sort([S.p0(2) p(2)]));
    end
    S=cancel_action(S);
end
guidata(fig,S);
refresh_mask(fig);
return
%
function S=close_poly(S)
P=S.poly;
if size(P,1)>=3
  sel=inpolygon(S.px,S.py,P([1:end 1],1),P([1:end 1],2));
  S=apply_sel(S,sel);
end
S=cancel_action(S);
return
%
function zoom_at(S,p,f)
xl=xlim(S.ax); yl=ylim(S.ax);
w=diff(xl)*f/2; h=diff(yl)*f/2;
xn=p(1)+[-w w]; yn=p(2)+[-h h];
xn=min(max(xn,S.xl(1)),S.xl(2)); yn=min(max(yn,S.yl(1)),S.yl(2));
if diff(xn)>S.tol && diff(yn)>S.tol
  xlim(S.ax,xn); ylim(S.ax,yn);
end
return
%
function pan(S,dx,dy)
xl=xlim(S.ax); yl=ylim(S.ax);
sx=dx*diff(xl)/4; sy=dy*diff(yl)/4;
sx=min(max(sx,S.xl(1)-xl(1)),S.xl(2)-xl(2));
sy=min(max(sy,S.yl(1)-yl(1)),S.yl(2)-yl(2));
xlim(S.ax,xl+sx); ylim(S.ax,yl+sy);
return
%
function cb_key(fig,evt)
S=guidata(fig);
key=evt.Key;
ctrl=any(strcmp(evt.Modifier,'control'));
switch key
  case 'leftarrow',  pan(S,-1,0);
  case 'rightarrow', pan(S,1,0);
  case 'uparrow',    pan(S,0,1);
  case 'downarrow',  pan(S,0,-1);
  case {'add','plus','equal'}
    zoom_at(S,[mean(xlim(S.ax)) mean(ylim(S.ax))],0.5);
  case {'subtract','minus','hyphen'}
    zoom_at(S,[mean(xlim(S.ax)) mean(ylim(S.ax))],2);
  case 'escape'
    S=cancel_action(S); guidata(fig,S);
  case 'return'
    if S.tool==3, S=close_poly(S); guidata(fig,S); refresh_mask(fig); end
  case 'u'
    cb_undo(fig,[]);
  case 'z'
    if ctrl, cb_undo(fig,[]); end
  case 's'
    cb_save(fig,[]);
end
return
%
%---------------------------------------------------------------------
% Buttons
%---------------------------------------------------------------------
%
function cb_zoomin(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
S=cancel_action(S); S.zoomnext=1;
set(S.hstat,'String','Zoom: drag a box (or click)');
guidata(fig,S);
return
%
function cb_zoomout(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
xlim(S.ax,S.xl); ylim(S.ax,S.yl);
return
%
function cb_undo(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
if ~isempty(S.undo)
  S.mask=S.undo{end}; S.undo(end)=[];
  S.changed=~isequal(S.mask,S.saved);
  guidata(fig,S); refresh_mask(fig);
end
return
%
function cb_revert(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
S=push_undo(S);
S.mask=S.saved; S.changed=0;
guidata(fig,S); refresh_mask(fig);
return
%
function cb_isolated(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
m=S.mask;
pad=zeros(S.Lp+2,S.Mp+2); pad(2:end-1,2:end-1)=m;
nsea=pad(1:end-2,2:end-1)+pad(3:end,2:end-1)+pad(2:end-1,1:end-2)+pad(2:end-1,3:end);
nb=4*ones(S.Lp,S.Mp);          % number of neighbours inside the grid
nb([1 end],:)=nb([1 end],:)-1; nb(:,[1 end])=nb(:,[1 end])-1;
newm=m;
newm(m==1 & nsea==0)=0;        % isolated sea point -> land
newm(m==0 & nsea==nb)=1;       % isolated land point -> sea
n=sum(newm(:)~=m(:));
if n>0
  S=push_undo(S); S.mask=newm; S.changed=1;
end
guidata(fig,S); refresh_mask(fig);
set(S.hstat,'String',sprintf('%d isolated points changed',n));
return
%
function cb_save(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
rmask=S.mask;
[Lp,Mp]=size(rmask); L=Lp-1; M=Mp-1;
umask=rmask(2:Lp,:).*rmask(1:L,:);
vmask=rmask(:,2:Mp).*rmask(:,1:M);
pmask=rmask(1:L,1:M).*rmask(2:Lp,1:M).*rmask(1:L,2:Mp).*rmask(2:Lp,2:Mp);
ncid=netcdf.open(S.file,'NC_WRITE');
names={'mask_rho','mask_u','mask_v','mask_psi'};
dims={{'xi_rho','eta_rho'},{'xi_u','eta_u'},{'xi_v','eta_v'},{'xi_psi','eta_psi'}};
lnames={'mask on RHO-points','mask on U-points','mask on V-points','mask on PSI-points'};
vals={rmask,umask,vmask,pmask};
%
% Define the missing mask variables (dims in Fortran order: xi,eta)
%
redef=0;
for k=1:4
  try
    netcdf.inqVarID(ncid,names{k});
  catch
    if ~redef, netcdf.reDef(ncid); redef=1; end
    d1=netcdf.inqDimID(ncid,dims{k}{1}); d2=netcdf.inqDimID(ncid,dims{k}{2});
    vid=netcdf.defVar(ncid,names{k},'double',[d1 d2]);
    netcdf.putAtt(ncid,vid,'long_name',lnames{k});
    netcdf.putAtt(ncid,vid,'option_0','land');
    netcdf.putAtt(ncid,vid,'option_1','water');
  end
end
if redef, netcdf.endDef(ncid); end
for k=1:4
  vid=netcdf.inqVarID(ncid,names{k});
  netcdf.putVar(ncid,vid,[0 0],size(vals{k}),vals{k});
end
netcdf.close(ncid);
S.saved=S.mask; S.changed=0;
guidata(fig,S); refresh_mask(fig);
disp(['oct_editmask: mask saved in ',S.file])
return
%
function cb_exit(src,~)
fig=ancestor(src,'figure'); S=guidata(fig);
if isempty(S), delete(fig); return, end
if S.changed
  res=questdlg('The mask has been changed. Save?',S.figname,'Yes','No','Cancel','Yes');
  switch res
    case 'Yes'
      cb_save(fig,[]);
      disp('Mask has been saved');
    case 'No'
      disp('Mask has NOT been saved');
    otherwise
      return
  end
end
delete(fig);
return
