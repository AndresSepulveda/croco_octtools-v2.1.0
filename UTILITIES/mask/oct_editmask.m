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
%   COAST_FILE : optional MAT file with the coastline, either as
%                (lon,lat) vectors (e.g. the *_mask.mat file written by
%                oct_make_coast) or as a structure C with C.Icst, C.Jcst
%                (grid indices, as written by ijcoast).
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
  coast_file='';
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
S.xl=[-0.5 S.Lp-0.5];
S.yl=[-0.5 S.Mp-0.5];
%
% Coastline in (I,J) coordinates
%
[S.xcst,S.ycst]=read_coast(coast_file,S);
%
% Figure
%
CMAP=[.5 1 0; 1 1 0; 0 0 .7; 0 0 1];   % land (2 tones), sea (2 tones)
fig=figure('NumberTitle','off','Name',S.figname,'tag','oct_maskeditor',...
           'MenuBar','none','ToolBar','none','Color',[.94 .94 .94],...
           'IntegerHandle','off','Units','normalized',...
           'Position',[.08 .08 .8 .8]);
S.fig=fig;
S.ax=axes('Parent',fig,'Units','normalized','Position',[0.06 0.08 0.72 0.86]);
S.himg=image(0:S.Lp-1,0:S.Mp-1,cdata(S).','Parent',S.ax,'CDataMapping','direct');
set(fig,'Colormap',CMAP);
set(S.ax,'YDir','normal','Layer','top','TickDir','out','Box','on');
hold(S.ax,'on');
S.hcst=plot(S.ax,S.xcst,S.ycst,'k','LineWidth',1);
S.hrect=plot(S.ax,NaN,NaN,'r-','LineWidth',1.5);
S.hpoly=plot(S.ax,NaN,NaN,'r.-','LineWidth',1.5,'MarkerSize',12);
hold(S.ax,'off');
xlim(S.ax,S.xl); ylim(S.ax,S.yl);
xlabel(S.ax,'I (xi\_rho index - 1)'); ylabel(S.ax,'J (eta\_rho index - 1)');
axis(S.ax,'image'); xlim(S.ax,S.xl); ylim(S.ax,S.yl);
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
function [xc,yc]=read_coast(coast_file,S)
xc=NaN; yc=NaN;
if isempty(coast_file), return, end
if ~exist(coast_file,'file')
  warning(['oct_editmask: coast file not found: ',coast_file]); return
end
D=load(coast_file);
if isfield(D,'C') && isfield(D.C,'Icst')
  xc=D.C.Icst(:); yc=D.C.Jcst(:); return
end
if ~(isfield(D,'lon') && isfield(D,'lat'))
  warning('oct_editmask: the coast file should contain "lon" and "lat" (or C.Icst/C.Jcst)');
  return
end
if isempty(S.lon)
  warning('oct_editmask: no lon_rho/lat_rho in the grid: coastline not drawn'); return
end
lon=D.lon(:); lat=D.lat(:);
rlon=S.lon;
if any(rlon(:)>180) && ~any(lon>180)
  rlon=mod(rlon+180,360)-180;           % same convention as the coastline
end
%
% Keep the coastline points near the grid (NaN separators are kept)
%
dx=2*max(abs(diff(rlon(:,1)))); dy=2*max(abs(diff(S.lat(1,:))));
if isempty(dx) || dx==0, dx=1; end
if isempty(dy) || dy==0, dy=1; end
out=lon<min(rlon(:))-dx | lon>max(rlon(:))+dx | lat<min(S.lat(:))-dy | lat>max(S.lat(:))+dy;
lon(out)=NaN; lat(out)=NaN;
keep=~isnan(lon);
keep=keep | [false; keep(1:end-1)] | [keep(2:end); false];
lon=lon(keep); lat=lat(keep);
disp('oct_editmask: converting the coastline (lon,lat) to (I,J) grid indices...')
ok=~isnan(lon);
xc=NaN(size(lon)); yc=xc;
if any(ok)
  xc(ok)=griddata(rlon(:),S.lat(:),S.mx(:),lon(ok),lat(ok),'linear');
  yc(ok)=griddata(rlon(:),S.lat(:),S.my(:),lon(ok),lat(ok),'linear');
end
return
%
function c=cdata(S)
c=S.mask*2+S.checker+1;
return
%
function refresh_mask(fig)
S=guidata(fig);
set(S.himg,'CData',cdata(S).');
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
i=round(p(1))+1; j=round(p(2))+1;
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
          i=min(max(round(p(1))+1,1),S.Lp); j=min(max(round(p(2))+1,1),S.Mp);
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
  i=round(p(1)); j=round(p(2));
  i1=min(max(i+1,1),S.Lp); j1=min(max(j+1,1),S.Mp);
  s={sprintf('I,J = %d, %d',i,j)};
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
    sel=(S.mx-S.p0(1)).*(S.mx-p(1))<=0 & (S.my-S.p0(2)).*(S.my-p(2))<=0;
    if abs(p(1)-S.p0(1))<0.5 && abs(p(2)-S.p0(2))<0.5    % simple click
      sel=S.mx==round(p(1)) & S.my==round(p(2));
    end
    S=apply_sel(S,sel);
    S=cancel_action(S);
  case 'zoom'
    if abs(p(1)-S.p0(1))<0.5 || abs(p(2)-S.p0(2))<0.5
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
  sel=inpolygon(S.mx,S.my,P([1:end 1],1),P([1:end 1],2));
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
if diff(xn)>0.5 && diff(yn)>0.5
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
