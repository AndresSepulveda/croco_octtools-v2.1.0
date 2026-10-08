close all
clear all
clim_file='croco_clm.nc';
ini_file='croco_ini.nc';
grid_file='croco_grd.nc';
tracer='temp'
l=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Test the climatology and initial files.
% pierrick 1/2000
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ncid = netcdf.open(clim_file, 'NC_NOWRITE');
var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, tracer)));
[N M L]=size(var);
theta_s=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_s'));
if isempty(theta_s)
  theta_s=ncid.theta_s(:);
  theta_b=ncid.theta_b(:);
  hc=ncid.hc(:);
else
  theta_b=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_b'));
  hc=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'hc'));
end
netcdf.close(ncid);
ncid = netcdf.open(grid_file, 'NC_NOWRITE');
lat=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'));
lon=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'));
pm=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'pm'));
h=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'));
angle=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'));
mask=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'));
netcdf.close(ncid);
mask(mask==0)=NaN;
ncid = netcdf.open(ini_file, 'NC_NOWRITE');
var=var-squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, tracer)));
netcdf.close(ncid);

jstep=round((M/3)-1);
image=0;
z = oct_zlevs(h,0*h,theta_s,theta_b,hc,N,'r');
for j=1:jstep:M
  index=j;
  image=image+1;
  subplot(2,2,image)
  field=squeeze(var(:,j,:));
  topo=squeeze(h(j,:));
  mask_vert=squeeze(mask(j,:));
  dx=1./squeeze(pm(j,:));
  xrad(1)=0;
  for i=2:L
    xrad(i)=xrad(i-1)+0.5*(dx(i)+dx(i-1));
  end
  x=zeros(N,L);
  masksection=zeros(N,L);
  for i=1:L
    for k=1:N
      x(k,i)=xrad(i);
      masksection(k,i)=mask_vert(i);
    end
  end
  xrad=xrad/1000;
  x=x/1000;
  field=masksection.*field;
  pcolor(x,squeeze(z(:,j,:)),field) 
  colorbar
  shading interp
  hold on
  plot(xrad,-topo,'k')
  hold off
  title(num2str(j))
end
