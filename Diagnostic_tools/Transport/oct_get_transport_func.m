%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  oct_get_transport_func: Compute a streamfunction for a transport
% between two depths.
%
% problem: for the moment work with 1 island max
%
%  Pierrick Penven 2015
%
%                                             
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%
crocotools_param
%
% Directory and file names
%
directory=[RUN_dir,'SCRATCH/'];
model='croco';
%
% CROCO average name
%
fname=[directory,model,'_Smean.nc'];
%
% Time index: 5 annual mean
%
l=5;
%
%  !!! WARNING weak point: vtransform should be the one used for CROCO
%
vtransform=1;
%
% Lower level (NaN=bottom)
%
z1=-1000;
%
% Upper level (NaN=surface)
%
z2=NaN;
%
% Output matlab file
%
outname='transport_croco.mat';
%
% Read data
%
ncid = netcdf.open(fname, 'NC_NOWRITE');
pm=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'pm'));
pn=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'pn'));
lon=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'));
lat=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'));
rmask=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'));
h=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'));
theta_s=ncid.theta_s(:);
theta_b=ncid.theta_b(:);
hc=ncid.hc(:);
[~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
zeta=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'zeta')));
u=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'u')));
v=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'v')));
T=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'temp')));
netcdf.close(ncid);
%
%  Get the transport between the surface and z0
%
%
%
zw=oct_zlevs(h,zeta,theta_s,theta_b,hc,N,'w',vtransform);
zr=oct_zlevs(h,zeta,theta_s,theta_b,hc,N,'r',vtransform);
%
[u,hu]=oct_vintegr2(u,oct_rho2u_3d(zw),oct_rho2u_3d(zr),z1,z2);
[v,hv]=oct_vintegr2(v,oct_rho2v_3d(zw),oct_rho2v_3d(zr),z1,z2);
[T,h0]=oct_vintegr2(T,zw,zr,z1,z2);
%
% Compute PSI
%
[u,v]=oct_get_obcvolcons(u,v,pm,pn,rmask,[1 1 1 1]);
[psi0,psi1,island]=oct_get_psi0(u,v,pm,pn,rmask);  
if sum(sum(island))==0
  A=0;
else
  A=oct_get_a(u,v,psi0,psi1,island,pm,pn);
end
psi=psi0+A*psi1;
mask=rmask;
mask(mask==0)=NaN;
save(outname,'lon','lat','mask','u','v','psi','h','z1','z2')
%
% PLot
%
oct_plot_transport(outname)
