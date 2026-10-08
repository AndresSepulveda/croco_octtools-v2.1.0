%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Test the vertical grid
%
%
%  Pierrick Penven, IRD, 2002.
%
%  Version of 2-Oct-2002
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
crocotools_param
%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Read the grid
%
ncid = netcdf.open(grdname, 'NC_NOWRITE');
h=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'));
mask=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'));
lon=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'));
lat=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'));
netcdf.close(ncid);
%
% Get the vertical levels
%
hmin=min(min(h(mask==1)));
hmax=max(max(h(mask==1)));
disp(['hmin = ',num2str(hmin)])
if (vtransform==1)
    if hc > hmin
        error([' hc (',num2str(hc),' m) > hmin (',num2str(hmin),' m)'])
    end
end
zw=oct_zlevs(h,0.*h,theta_s,theta_b,hc,N,'w',vtransform);
dz=zw(2:end,:,:)-zw(1:end-1,:,:);
dzsurf(:,:)=dz(end,:,:);
dzbot(:,:)=dz(1,:,:);
disp(['Surface : minimum = ',num2str(min(min(dzsurf(mask==1)))),...
      ' - maximum = ',num2str(max(max(dzsurf(mask==1))))])
disp(['Bottom : minimum = ',num2str(min(min(dzbot(mask==1)))),...
      ' - maximum = ',num2str(max(max(dzbot(mask==1))))])
%
% Make  a plot
%
npts=20;
hmax=1000;
h=(hmin:(hmax-hmin)/(npts-1):hmax);
x=(1:npts);
z=(1:N);
[xr,zr]=meshgrid(x,z);
zr=squeeze(oct_zlevs(h,0.*h,theta_s,theta_b,hc,N,'r',vtransform));
zw=squeeze(oct_zlevs(h,0.*h,theta_s,theta_b,hc,N,'w',vtransform));
dz=zw(2:end,:)-zw(1:end-1,:);
figure
pcolor(xr,zr,dz)
colorbar

%save 'Vgrid_Vtransf_2.mat' xr zr zw dz
%dz(end,end)
