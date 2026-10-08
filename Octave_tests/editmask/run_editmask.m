oct_start; graphics_toolkit qt

mkdir('EM'); copyfile('CROCO_FILES/croco_grd.nc','EM/grd.nc'); G=[pwd,'/EM/grd.nc'];
% synthetic coastline: 0.5 contour of the mask in lon/lat
nc=netcdf.open(G,'NC_NOWRITE'); lon=netcdf.getVar(nc,netcdf.inqVarID(nc,'lon_rho')); lat=netcdf.getVar(nc,netcdf.inqVarID(nc,'lat_rho')); m0=double(netcdf.getVar(nc,netcdf.inqVarID(nc,'mask_rho'))); netcdf.close(nc);
c=contourc(double(m0.'),[0.5 0.5]); k=1; X=[];Y=[];
while k<size(c,2), n=c(2,k); X=[X c(1,k+1:k+n) NaN]; Y=[Y c(2,k+1:k+n) NaN]; k=k+n+1; end
cl=interp2(double(lon.'),X,Y); ct=interp2(double(lat.'),X,Y); lon=cl(:); lat=ct(:); save('-v7','EM/coast_mask.mat','lon','lat');
fig=oct_editmask(G,'EM/coast_mask.mat');
S=guidata(fig); printf('size %dx%d sea %d\n',S.Lp,S.Mp,sum(S.mask(:)));
drawnow; pause(1); system('import -window root EM/em1.png');
ax=S.ax;
function click(fig,ax,p,type)
  set(ax,'CurrentPoint',[p 1;p 0]); set(fig,'SelectionType',type);
  f=get(fig,'WindowButtonDownFcn'); f(fig,[]);
end
function move(fig,ax,p)
  set(ax,'CurrentPoint',[p 1;p 0]); f=get(fig,'WindowButtonMotionFcn'); f(fig,[]);
end
function up(fig,ax,p)
  set(ax,'CurrentPoint',[p 1;p 0]); f=get(fig,'WindowButtonUpFcn'); f(fig,[]);
end
% 1 point toggle at (5,5)
v0=S.mask(6,6); click(fig,ax,[5 5],'normal'); up(fig,ax,[5 5]); S=guidata(fig); printf('point toggle %d->%d\n',v0,S.mask(6,6));
% 2 brush set land drag with size 3
set_land=S.hmode(2); cb=get(set_land,'Callback'); cb{1}(set_land,[],cb{2:end});
set(S.hbrush,'Value',2); cb=get(S.hbrush,'Callback'); cb(S.hbrush,[]);
click(fig,ax,[10 10],'normal'); for x=10:20, move(fig,ax,[x 10]); end; up(fig,ax,[20 10]);
S=guidata(fig); printf('brush land cells row: %d (expect 33)\n',sum(sum(S.mask(10:22,10:12)==0)));
% 3 rectangle set sea
h=S.hmode(3); cb=get(h,'Callback'); cb{1}(h,[],cb{2:end});
h=S.htool(2); cb=get(h,'Callback'); cb{1}(h,[],cb{2:end});
click(fig,ax,[2 20],'normal'); move(fig,ax,[6 25]); up(fig,ax,[6 25]);
S=guidata(fig); printf('rect sea all: %d\n',all(all(S.mask(3:7,21:26)==1)));
% 4 polygon set land
h=S.hmode(2); cb=get(h,'Callback'); cb{1}(h,[],cb{2:end});
h=S.htool(3); cb=get(h,'Callback'); cb{1}(h,[],cb{2:end});
for p=[25 5; 35 5; 30 15]', click(fig,ax,p','normal'); up(fig,ax,p'); end
click(fig,ax,[30 15],'alt');
S=guidata(fig); printf('poly land at (30,8): %d  undo levels %d\n',S.mask(31,9)==0,numel(S.undo));
% 5 undo
cb=get(S.hbut(3),'Callback'); cb(S.hbut(3),[]); S=guidata(fig); printf('after undo (30,8) mask=%d\n',S.mask(31,9));
% 6 zoom double click and right click
click(fig,ax,[20 20],'open'); printf('xlim after dblclick %s\n',mat2str(xlim(ax),3));
click(fig,ax,[20 20],'alt'); printf('xlim after right %s\n',mat2str(xlim(ax),3));
% 7 remove isolated
cb=get(S.hbut(5),'Callback'); cb(S.hbut(5),[]);
drawnow; pause(1); system('import -window root EM/em2.png');
% 8 save & exit
S=guidata(fig); mk=S.mask;
cb=get(S.hbut(6),'Callback'); cb(S.hbut(6),[]);
nc=netcdf.open(G,'NC_NOWRITE'); m1=netcdf.getVar(nc,netcdf.inqVarID(nc,'mask_rho')); mu=netcdf.getVar(nc,netcdf.inqVarID(nc,'mask_u')); mp=netcdf.getVar(nc,netcdf.inqVarID(nc,'mask_psi')); netcdf.close(nc);
[u2,v2,p2]=uvp_masks(mk);
printf('saved ok: %d %d %d\n',isequal(double(m1),mk),isequal(double(mu),u2),isequal(double(mp),p2));
cb=get(S.hbut(7),'Callback'); cb(S.hbut(7),[]); printf('closed: %d\n',~ishghandle(fig));
disp('EDITMASK OK')
