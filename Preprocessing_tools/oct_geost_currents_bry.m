function oct_geost_currents_bry(bryname,grdname,Zbryname,frcname,zref,obcndx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% compute SSH and the geostrophic currents from Hydrology data
%
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
%  Adapted from a previous program of Patrick Marchesiello (IRD).
%
%  Copyright (c) 2001-2006 by Patrick Marchesiello and Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rho0=1025; % Bousinesq background density [kg.m-3]
g=9.8;     % Gravity acceleration [m.s-2]
De=40;     % Ekman depth [m]
%
%  grid parameters
%
% disp(' Read grid parameters ...');
%
% Read the grid along the boundary. Variables are (eta,xi) in the file,
% i.e. (xi,eta) for netcdf.getVar: start/count are 0-based [xi eta].
% All boundary vectors are returned as row vectors (as in the Matlab
% version: v(1,:), v(M,:), v(:,L)', v(:,1)').
%
ncid = netcdf.open(grdname, 'NC_NOWRITE');
[~,L]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_rho'));
[~,M]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_rho'));
latr=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'))).';
lonr=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'))).';
if obcndx==1
  st_r=[0 0];   ct_r=[L 1];        % rho row j=1
  st_u=[0 0];   ct_u=[L-1 1];      % u row j=1
  st_v=[0 0];   ct_v=[L 1];        % v row j=1
  suffix='_south';
elseif obcndx==2
  st_r=[L-1 0]; ct_r=[1 M];        % rho column i=L
  st_u=[L-2 0]; ct_u=[1 M];        % u column i=L-1
  st_v=[L-1 0]; ct_v=[1 M-1];      % v column i=L
  suffix='_east';
elseif obcndx==3
  st_r=[0 M-1]; ct_r=[L 1];        % rho row j=M
  st_u=[0 M-1]; ct_u=[L-1 1];      % u row j=M
  st_v=[0 M-2]; ct_v=[L 1];        % v row j=M-1
  suffix='_north';
elseif obcndx==4
  st_r=[0 0];   ct_r=[1 M];        % rho column i=1
  st_u=[0 0];   ct_u=[1 M];        % u column i=1
  st_v=[0 0];   ct_v=[1 M-1];      % v column i=1
  suffix='_west';
end
h    =double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'),       st_r, ct_r)); h=h(:).';
pm   =double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'pm'),      st_r, ct_r)); pm=pm(:).';
pn   =double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'pn'),      st_r, ct_r)); pn=pn(:).';
f    =double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'f'),       st_r, ct_r)); f=f(:).';
lat  =double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'), st_r, ct_r)); lat=lat(:).';
lon  =double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'), st_r, ct_r)); lon=lon(:).';
rmask=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'),st_r, ct_r)); rmask=rmask(:).';
umask=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_u'),  st_u, ct_u)); umask=umask(:).';
vmask=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_v'),  st_v, ct_v)); vmask=vmask(:).';
Nx=length(h);
Nu=length(umask);
Nv=length(vmask);
netcdf.close(ncid);
%
% Z-boundary file
%
noa_id = netcdf.open(Zbryname, 'NC_NOWRITE');
Z=-double(netcdf.getVar(noa_id, netcdf.inqVarID(noa_id, 'Z')));
Z=Z(:);
NL=length(Z);
time=double(netcdf.getVar(noa_id, netcdf.inqVarID(noa_id, 'bry_time')));
tlen=length(time);
vid_T=netcdf.inqVarID(noa_id, ['temp',suffix]);
vid_S=netcdf.inqVarID(noa_id, ['salt',suffix]);
%
% Boundary file
%
ncid = netcdf.open(bryname, 'NC_WRITE');
theta_s = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_s')));
theta_b = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_b')));
hc      = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'hc')));
[~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
try
  vtransform = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Vtransform')));
catch
  vtransform=1; %Old Vtransform
  disp([' NO VTRANSFORM parameter found'])
  disp([' USE TRANSFORM default value vtransform = 1'])
end
%
% get the reference level
%
kref=min(find(Z<=zref));
if isempty(kref);
  kref=length(Z);
  disp(['Warning zref not found. Taking :',num2str(Z(kref))])
end
Z=Z(1:kref);
z=reshape(Z,kref,1,1);
z=repmat(z,[1 Nx]);
%
% Open the forcing file
%
use_frc = ~isempty(frcname) && exist(frcname,'file');
if use_frc
  nfrc_id = netcdf.open(frcname, 'NC_NOWRITE');
  [~,nsms]=netcdf.inqDim(nfrc_id, netcdf.inqDimID(nfrc_id, 'sms_time'));
  vid_su=netcdf.inqVarID(nfrc_id, 'sustr');
  vid_sv=netcdf.inqVarID(nfrc_id, 'svstr');
end
%%%%%%%%%%%%%%%%%%%
% START MAIN LOOP
%%%%%%%%%%%%%%%%%%%
%
% loop on time
%
for l=1:tlen
%for l=1:1
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
%
% read T and S
%
% (bry_time,Z,x) in the file -> getVar (x,Z) -> transpose to (Z,x), levels 1:kref
  T3d=double(netcdf.getVar(noa_id, vid_T, [0 0 l-1], [Nx NL 1])).';
  S3d=double(netcdf.getVar(noa_id, vid_S, [0 0 l-1], [Nx NL 1])).';
  T3d=T3d(1:kref,:);
  S3d=S3d(1:kref,:);
  Ts=squeeze(T3d(1,:));
  Ss=squeeze(S3d(1,:));
  rhos=oct_rho_eos(Ts,Ss,0);
  rho=oct_rho_eos(T3d,S3d,z);
  rho_w=.5*(rho(1:kref-1,:)+rho(2:kref,:));
  z_w=.5*(z(1:kref-1,:)+z(2:kref,:));
  dz_w=z(1:kref-1,:)-z(2:kref,:);
%
%  COMPUTE PRESSURE
%
%  disp('Pressure field and sea level ...')
  pres=0*T3d;
%  initialize pressure at kref in Pascal
  pres(kref,:)=-zref*1.e4;
  for k=kref-1:-1:1;
    pres(k,:)=pres(k+1,:)-rho_w(k,:).*g.*dz_w(k,:);
  end
%
%  compute SSH 
%
  ssh=(squeeze(pres(1,:))./(rhos*g));
%  avgssh=sum(rmask.*ssh./(pm.*pn))/sum(rmask./(pm.*pn));
%  ssh=ssh-avgssh;
%  avgp=squeeze(oct_tridim(avgssh.*rhos*g,kref));
%  pres=pres-avgp; 
%
%  COMPUTE GEOSTROPHIC BAROCLINIC VELOCITIES
%
%  disp('Baroclinic geostrophic component ...')
  pn3d=squeeze(oct_tridim(pn,kref)); 
  pm3d=squeeze(oct_tridim(pm,kref)); 
  f3d=squeeze(oct_tridim(f,kref)); 
  m3d=squeeze(oct_tridim(rmask,kref));   
  if  obcndx==1 |  obcndx==3
    p_u=0.5*(pres(:,1:Nx-1)+pres(:,2:Nx));
    px(:,2:Nx-1)=p_u(:,2:Nx-1)-p_u(:,1:Nx-2);
    px(:,1)=2.*px(:,2)-px(:,3);
    px(:,Nx)=2.*px(:,Nx-1)-px(:,Nx-2);
    v_r=m3d.*pm3d.*px./(rho0*f3d);
    u_r=0*v_r;
  end
  if  obcndx==2 |  obcndx==4
    p_v=0.5*(pres(:,1:Nx-1)+pres(:,2:Nx));
    py(:,2:Nx-1)=p_v(:,2:Nx-1)-p_v(:,1:Nx-2);
    py(:,1)=2.*py(:,2)-py(:,3);
    py(:,Nx)=2.*py(:,Nx-1)-py(:,Nx-2);
    u_r=-m3d.*pn3d.*py./(rho0*f3d);
    v_r=0*u_r;
  end
%
% Ekman transport
%
   if use_frc
    disp('Add the Ekman transport')
    lf=min(l,nsms);
%   sustr(sms_time,eta_u,xi_u), svstr(sms_time,eta_v,xi_v): Fortran order [xi eta time]
    if obcndx==1
      tmp=double(netcdf.getVar(nfrc_id, vid_su, [0 0 lf-1],   [L-1 1 1])); tmp=tmp(:).';
      sustr=0*h; 
      sustr(2:end-1)=0.5*(tmp(1:end-1)+tmp(2:end)); 
      sustr(1)=sustr(2);
      sustr(end)=sustr(end-1);
      svstr=double(netcdf.getVar(nfrc_id, vid_sv, [0 0 lf-1],   [L 1 1]));   svstr=svstr(:).';
    elseif obcndx==2
      sustr=double(netcdf.getVar(nfrc_id, vid_su, [L-2 0 lf-1], [1 M 1]));   sustr=sustr(:).';
      svstr=0*h; 
      tmp=double(netcdf.getVar(nfrc_id, vid_sv, [L-1 0 lf-1], [1 M-1 1])); tmp=tmp(:).';
      svstr(2:end-1)=0.5*(tmp(1:end-1)+tmp(2:end)); 
      svstr(1)=svstr(2);
      svstr(end)=svstr(end-1);
    elseif obcndx==3
      tmp=double(netcdf.getVar(nfrc_id, vid_su, [0 M-1 lf-1], [L-1 1 1])); tmp=tmp(:).';
      sustr=0*h; 
      sustr(2:end-1)=0.5*(tmp(1:end-1)+tmp(2:end)); 
      sustr(1)=sustr(2);
      sustr(end)=sustr(end-1);
      svstr=double(netcdf.getVar(nfrc_id, vid_sv, [0 M-2 lf-1], [L 1 1]));   svstr=svstr(:).';
    elseif obcndx==4
      sustr=double(netcdf.getVar(nfrc_id, vid_su, [0 0 lf-1],   [1 M 1]));   sustr=sustr(:).';
      svstr=0*h; 
      tmp=double(netcdf.getVar(nfrc_id, vid_sv, [0 0 lf-1],   [1 M-1 1])); tmp=tmp(:).';
      svstr(2:end-1)=0.5*(tmp(1:end-1)+tmp(2:end)); 
      svstr(1)=svstr(2);
      svstr(end)=svstr(end-1);
    end
    k_ekman=min(find(Z<=-De));

    try 
       u_r(1:k_ekman,:)=u_r(1:k_ekman,:)+squeeze(oct_tridim(rmask.*...
                       svstr./(rho0*De*f),k_ekman));
    catch
       u_r(1:k_ekman,:)=u_r(1:k_ekman,:)+squeeze(oct_tridim(rmask.*...
                       svstr'./(rho0*De*f),k_ekman));
    end

    try
       v_r(1:k_ekman,:)=v_r(1:k_ekman,:)+squeeze(oct_tridim(-rmask.*...
                      sustr./(rho0*De*f),k_ekman));
    catch                      
       v_r(1:k_ekman,:)=v_r(1:k_ekman,:)+squeeze(oct_tridim(-rmask.*...
                      sustr'./(rho0*De*f),k_ekman));
    end
 end



% Replace/interpolate Equatorial values 
 %
 if  obcndx==2 | obcndx==4
     equatlat=(lat >=-2 & lat <=2);
     disp(['OBCNDX=',num2str(obcndx)])
     if sum(sum(equatlat))==0
         disp('No values outside the Equator to extrapole')
     else
         disp('Extrapole values outside the Equator')
         D=find(~equatlat);
         if length(D)~=0
             for k=1:kref
                 u_r(k,:)=interp1(lat(D),u_r(k,D),lat,'spline','extrap');
                 v_r(k,:)=interp1(lat(D),v_r(k,D),lat,'spline','extrap');
             end
         else
             disp('No values outside the Equator to extrapole')
         end
     end

 elseif obcndx==1
     disp(['OBCNDX=',num2str(obcndx)])
     if (latr(1,1) < -2 | latr(1,1) > 2 )
         disp(['OK South boundary outside of the equatorial band'])
     else
         error(['Replace your South boundary'])
     end
%
 elseif obcndx==3
     disp(['OBCNDX=',num2str(obcndx)])
     if ( latr(end,1) < -2 | latr(end,1) > 2)
         disp(['OK North boundary outside of the equatorial band'])
     else
         error(['Replace your North boundary'])
     end
 end
%
%  Masking
%  
  umask3d=squeeze(oct_tridim(umask,kref)); 
  vmask3d=squeeze(oct_tridim(vmask,kref)); 
  if  obcndx==1 |  obcndx==3
    u=umask3d.*0.5.*(u_r(:,1:end-1)+u_r(:,2:end));
    v=vmask3d.*v_r;
  end
  if  obcndx==2 |  obcndx==4
    u=umask3d.*u_r;
    v=vmask3d.*0.5.*(v_r(:,1:end-1)+v_r(:,2:end));
  end
  ssh=ssh.*rmask; 
%
% Vertical interpolation of baroclinic fields
%
%  disp('Vertical interpolation ...')
  zcroco=squeeze(oct_zlevs(h,0*h,theta_s,theta_b,hc,N,'r',vtransform));
  if  obcndx==1 |  obcndx==3
    zu=0.5*(zcroco(:,1:end-1)+zcroco(:,2:end));
    zv=zcroco;
  end
  if  obcndx==2 |  obcndx==4
    zu=zcroco;
    zv=0.5*(zcroco(:,1:end-1)+zcroco(:,2:end));
  end
%
% Add non gradient velocities at the top and nul velocities 
% at -10000m for vertical extrapolation.
%
  u=cat(1,u(1,:),u);
  v=cat(1,v(1,:),v);
  u=flip(cat(1,u,0*u(1,:)),1);
  v=flip(cat(1,v,0*v(1,:)),1);
  z1=flipud([100;Z;-10000]);
%
% Do the interpolation
%
  u=oct_ztosigma_1d(u,zu,z1);
  v=oct_ztosigma_1d(v,zv,z1);
%
%  Barotropic velocities
%
%  disp('Barotropic component ...')
  zw=squeeze(oct_zlevs(h,0*h,theta_s,theta_b,hc,N,'w',vtransform));
  dz=zw(2:end,:)-zw(1:end-1,:);
  if  obcndx==1 |  obcndx==3
    dzu=0.5*(dz(:,1:end-1)+dz(:,2:end));
    dzv=dz;
  end
  if  obcndx==2 |  obcndx==4
    dzu=dz;
    dzv=0.5*(dz(:,1:end-1)+dz(:,2:end));
  end
  hu=sum(dzu.*u);
  hv=sum(dzv.*v);
  D_u=sum(dzu);
  D_v=sum(dzv);
  ubar=hu./D_u;
  vbar=hv./D_v;
%
% corners     (beurk.....)
%
  ubar(1)=0.5*ubar(2); 
  ubar(end)=0.5*ubar(end-1); 
  vbar(1)=0.5*vbar(2); 
  vbar(end)=0.5*vbar(end-1); 
  u(:,1)=0.5*u(:,2); 
  u(:,end)=0.5*u(:,end-1); 
  v(:,1)=0.5*v(:,2); 
  v(:,end)=0.5*v(:,end-1); 
%
%  Write into file
%
%  disp('Writes into climatology file ...')
% Write record l: (N,x) -> Fortran order [x N time]; 1D (x) -> [x time]
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, ['u',suffix]),    [0 0 l-1], [Nu N 1], u.');
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, ['v',suffix]),    [0 0 l-1], [Nv N 1], v.');
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, ['ubar',suffix]), [0 l-1],   [Nu 1],   ubar(:));
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, ['vbar',suffix]), [0 l-1],   [Nv 1],   vbar(:));
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, ['zeta',suffix]), [0 l-1],   [Nx 1],   ssh(:));
end
netcdf.close(ncid);
netcdf.close(noa_id);
%
% Close the forcing file
%
if use_frc
  netcdf.close(nfrc_id);
end
