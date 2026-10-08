%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO grid file
%
%
%  Pierrick Penven, IRD, 2002.
%
%  Version of 10-Oct-2002
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
%  Title 
%
title='TEST';
config='test';
%
%  Grid file name
%
grdname='test_grd.nc';
%
% Slope parameter (r=grad(h)/h) maximum value for topography smoothing
%
rtarget=0.15;
%
% Grid dimensions:
%   lonmin : Minimum longitude [degree east]
%   lonmax : Maximum longitude [degree east]
%   latmin : Minimum latitude [degree north]
%   latmax : Maximum latitude [degree north]
if config=='test'
%
%  Test
  lon1=43.9;
  lat1=8.7;
  lon2=34.1;
  lat2=31.2;
  lon3=46.9;
  lat3=10.7;
  
end
%
% Grid resolution [degree]
%
dl=1/4;
%
% Minimum depth [m]
%
hmin=10;
%
%  Topography netcdf file name (ETOPO 2)
%
topofile='../Topo/etopo2.nc';
%
%  GSHSS user defined coastline (see m_map) 
%
coastfileplot='';
%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Title
%
disp(' ')
disp([' Making the grid: ',grdname])
disp(' ')
disp([' Title: ',title])
disp(' ')
disp([' Resolution: 1/',num2str(1/dl),' deg'])
%
% Get the Longitude and latitude
%
oct_theta=atan((lat3-lat1)/(lon3-lon1))
l=(lon2-lon1)*cos(oct_theta)+(lat2-lat1)*sin(oct_theta)
L=(lat2-lat1)*cos(oct_theta)-(lon2-lon1)*sin(oct_theta)
x=(0:dl:l);
y=(0:dl:L);
[xr,yr]=meshgrid(x,y);
Lonr=lon1+xr*cos(oct_theta)-yr*sin(oct_theta);
Latr=lat1+xr*sin(oct_theta)+yr*cos(oct_theta);
[Lonu,Lonv,Lonp]=oct_rho2uvp(Lonr); 
[Latu,Latv,Latp]=oct_rho2uvp(Latr);
%
% Create the grid file
%
disp(' ')
disp(' Create the grid file...')
[M,L]=size(Latp);
disp([' LLm = ',num2str(L-1)])
disp([' MMm = ',num2str(M-1)])
oct_create_grid(L,M,grdname,title)
%
% Fill the grid file
%
disp(' ')
disp(' Fill the grid file...')
ncid = netcdf.open(grdname, 'NC_WRITE');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat_u'), Latu);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon_u'), Lonu);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat_v'), Latv);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon_v'), Lonv);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'), Latr);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'), Lonr);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat_psi'), Latp);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon_psi'), Lonp);
netcdf.close(ncid);
%
%  Compute the metrics
%
disp(' ')
disp(' Compute the metrics...')
[pm,pn,dndx,dmde]=oct_get_metrics(grdname);
xr=0.*pm;
yr=xr;
for i=1:L
  xr(:,i+1)=xr(:,i)+2./(pm(:,i+1)+pm(:,i));
end
for j=1:M
  yr(j+1,:)=yr(j,:)+2./(pn(j+1,:)+pn(j,:));
end
[xu,xv,xp]=oct_rho2uvp(xr);
[yu,yv,yp]=oct_rho2uvp(yr);
dx=1./pm;
dy=1./pn;
dxmax=max(max(dx/1000));
dxmin=min(min(dx/1000));
dymax=max(max(dy/1000));
dymin=min(min(dy/1000));
disp(' ')
disp([' Min dx=',num2str(dxmin),' km - Max dx=',num2str(dxmax),' km'])
disp([' Min dy=',num2str(dymin),' km - Max dy=',num2str(dymax),' km'])
%
%  Add topography from topofile
%
disp(' ')
disp(' Add topography...')
h=oct_add_topo(grdname,topofile);
%
% Compute the mask
%
maskr=h>0;
maskr=oct_process_mask(maskr);
if config=='kago'
 maskr(Latr>45.5)=0;
end
if config=='test'
 maskr(Lonr<41.5 & Latr<14.4)=0.;
 maskr(Lonr<40.5 & Latr<14.6)=0.;
end
[masku,maskv,maskp]=oct_uvp_mask(maskr);
%
%  Smooth the topography
%
h = oct_smoothgrid(h,hmin,rtarget);
%
%  Angle between XI-axis and the direction
%  to the EAST at RHO-points [radians].
%
angle=oct_get_angle(Latu,Lonu);
%
%  Coriolis parameter
%
f=4*pi*sin(pi*Latr/180)*366.25/(24*3600*365.25);
%
%  Write it down
%
disp(' ')
disp(' Write it down...')
ncid = netcdf.open(grdname, 'NC_WRITE');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'h'), h);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'pm'), pm);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'pn'), pn);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'dndx'), dndx);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'dmde'), dmde);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'mask_u'), masku);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'mask_v'), maskv);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'mask_psi'), maskp);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'), maskr);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'x_u'), xu);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'y_u'), yu);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'x_v'), xv);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'y_v'), yv);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'x_rho'), xr);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'y_rho'), yr);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'x_psi'), xp);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'y_psi'), yp);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'angle'), angle);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'f'), f);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'spherical'), 'T');
netcdf.close(ncid);
disp(' ')
disp(['  Size of the grid:  L = ',...
      num2str(L),' - M = ',num2str(M)])
%
% make a plot
%
disp(' ')
disp(' Do a plot...')
themask=ones(size(maskr));
themask(maskr==0)=NaN; 
domaxis=[min(min(Lonr)) max(max(Lonr)) min(min(Latr)) max(max(Latr))];
colaxis=[min(min(h)) max(max(h))];
oct_fixcolorbar([0.25 0.05 0.5 0.03],colaxis,...
            'Topography',10)
width=1;
height=0.8;
subplot('position',[0. 0.14 width height])
m_proj('mercator',...
       'lon',[domaxis(1) domaxis(2)],...
       'lat',[domaxis(3) domaxis(4)]);
m_pcolor(Lonr,Latr,h.*themask);
%shading interp
caxis(colaxis)
hold on
m_contour(Lonr,Latr,h,[hmin 100 200 500 1000 2000 4000],'k--');
if ~isempty(coastfileplot)
  m_usercoast(coastfileplot,'patch',[.9 .9 .9]);
else
%  m_gshhs_l('patch',[.9 .9 .9])
end
m_grid('box','fancy',...
       'xtick',5,'ytick',5,'tickdir','out',...
       'fontsize',7);
hold off
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
