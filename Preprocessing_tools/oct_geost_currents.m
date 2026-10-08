function oct_geost_currents(clmname,grdname,oaname,frcname,zref,obc,tini)
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
conserv=1;
%
%  grid parameters
%
%disp(' Read grid parameters ...');
%
% Grid (netcdf.getVar gives (xi,eta): transpose to (eta,xi))
%
ncid = netcdf.open(grdname, 'NC_NOWRITE');
pm=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'pm'))).';
pn=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'pn'))).';
h=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'))).';
f=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'f'))).';
lon=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'))).';
lat=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'))).';
rmask=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'))).';
umask=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_u'))).';
vmask=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_v'))).';
[M,L]=size(rmask);
netcdf.close(ncid);
%
% OA file
%
noa_id = netcdf.open(oaname, 'NC_NOWRITE');
Z=-double(netcdf.getVar(noa_id, netcdf.inqVarID(noa_id, 'Z'))); 
Z=Z(:);
NL=length(Z);
time=double(netcdf.getVar(noa_id, netcdf.inqVarID(noa_id, 'tclm_time')));
time=time(:);
tlen=length(time);
vid_T=netcdf.inqVarID(noa_id, 'temp');
vid_S=netcdf.inqVarID(noa_id, 'salt');
%
% Climatology (or initial) file
%
ncid = netcdf.open(clmname, 'NC_WRITE');
theta_s = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_s')));
theta_b = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_b')));
hc      = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'hc')));
try
  vtransform=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Vtransform')));
catch
  vtransform=1; %Old Vtransform
  disp([' NO VTRANSFORM parameter found'])
  disp([' USE TRANSFORM default value vtransform = 1'])
end
[~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
%
% get the reference level
%
kref=min(find(Z<=zref));
if isempty(kref);
  kref=length(Z);
  disp(['Warning zref not found. Taking :',num2str(Z(kref))])
end
Z=Z(1:kref);
zref=Z(kref);
z=reshape(Z,kref,1,1);
z=repmat(z,[1 M L]);
%
% Open the forcing file
%
use_frc = ~isempty(frcname) && exist(frcname,'file');
if use_frc
  nfrc_id = netcdf.open(frcname, 'NC_NOWRITE');
end
%%%%%%%%%%%%%%%%%%%
% START MAIN LOOP
%%%%%%%%%%%%%%%%%%%
%
% loop on time
%
if tini ~= 0  % initial file 
  tlen=1;
end
for l=1:tlen
%for l=1:1
  if tini == 0
    disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  else
    l=find(time==tini);
    disp(['time index: ',num2str(l)])
  end
  if tini == 0
    lout=l;      % climatology file: same record as the OA file
  else
    lout=1;      % initial file: single record
  end
%
% read T and S
%
% (file order (T,Z,eta,xi) -> getVar (xi,eta,Z) -> permute to (Z,eta,xi))
  T3d=permute(double(netcdf.getVar(noa_id,vid_T,[0 0 0 l-1],[L M NL 1])),[3 2 1]);
  S3d=permute(double(netcdf.getVar(noa_id,vid_S,[0 0 0 l-1],[L M NL 1])),[3 2 1]);
  T3d=T3d(1:kref,:,:);
  S3d=S3d(1:kref,:,:);
  Ts=squeeze(T3d(1,:,:));
  Ss=squeeze(S3d(1,:,:));
  rhos=oct_rho_eos(Ts,Ss,0);
  rho=oct_rho_eos(T3d,S3d,z);
  rho_w=.5*(rho(1:kref-1,:,:)+rho(2:kref,:,:));
  z_w=.5*(z(1:kref-1,:,:)+z(2:kref,:,:));
  dz_w=z(1:kref-1,:,:)-z(2:kref,:,:);
%
%  COMPUTE PRESSURE
%
%  disp('Pressure field and sea level ...')
  pres=0*T3d;
%  initialize pressure at kref in Pascal
  pres(kref,:,:)=-zref*1.e4;
  for k=kref-1:-1:1;
    pres(k,:,:)=pres(k+1,:,:)-rho_w(k,:,:).*g.*dz_w(k,:,:);
  end
%
%  compute SSH and remove area averaged
%
  ssh=squeeze(pres(1,:,:))./(rhos*g);
  avgssh=sum(sum(rmask.*ssh./(pm.*pn)))/sum(sum(rmask./(pm.*pn)));
  ssh=ssh-avgssh;
  avgp=oct_tridim(avgssh.*rhos*g,kref);
  pres=pres-avgp;
%
%  COMPUTE GEOSTROPHIC BAROCLINIC VELOCITIES
%
%  disp('Baroclinic geostrophic component ...')

  p_u=oct_rho2u_3d(pres);
  p_v=oct_rho2v_3d(pres);
  
  px(:,:,2:L-1)=p_u(:,:,2:L-1)-p_u(:,:,1:L-2);
  px(:,:,1)=2.*px(:,:,2)-px(:,:,3);
  px(:,:,L)=2.*px(:,:,L-1)-px(:,:,L-2);
  
  py(:,2:M-1,:)=p_v(:,2:M-1,:)-p_v(:,1:M-2,:);
  py(:,1,:)=2.*py(:,2,:)-py(:,3,:);
  py(:,M,:)=2.*py(:,M-1,:)-py(:,M-2,:);

  pn3d=oct_tridim(pn,kref); 
  pm3d=oct_tridim(pm,kref); 
  f3d=oct_tridim(f,kref); 
  m3d=oct_tridim(rmask,kref);   
  u_r=-m3d.*pn3d.*py./(rho0*f3d);
  v_r=m3d.*pm3d.*px./(rho0*f3d);
%
% Ekman transport
%
  if use_frc
    disp('Add the Ekman transport')
    [~,nsms]=netcdf.inqDim(nfrc_id, netcdf.inqDimID(nfrc_id, 'sms_time'));
    lf=min(l,nsms);
    sustr=double(netcdf.getVar(nfrc_id, netcdf.inqVarID(nfrc_id, 'sustr'),[0 0 lf-1],[L-1 M 1])).';
    svstr=double(netcdf.getVar(nfrc_id, netcdf.inqVarID(nfrc_id, 'svstr'),[0 0 lf-1],[L M-1 1])).';
%    rhoA=1.3; Cd=1.4e-3;
%    W=sqrt(oct_u2rho_2d(sustr).^2+oct_v2rho_2d(svstr).^2);
%    De=mean(mean(  sqrt(W).* ...
%       min(250,4.3./sqrt(rhoA.*Cd.*sin(abs(lat.*pi/180)))) ));
    k_ekman=min(find(Z<=-De));
    u_r(1:k_ekman,:,:)=u_r(1:k_ekman,:,:)+oct_tridim(rmask.*...
                       oct_v2rho_2d(svstr)./(rho0*De*f),k_ekman);
    v_r(1:k_ekman,:,:)=v_r(1:k_ekman,:,:)+oct_tridim(-rmask.*...
                       oct_u2rho_2d(sustr)./(rho0*De*f),k_ekman);
  end
%
% Replace/interpolate Equatorial values 
%
  equatlat=(lat>=-2 & lat<=2);
  if sum(sum(equatlat))~=0
%    disp('Extrapole values outside the Equator')
    D=find(~equatlat);
    if length(D)~=0
      for k=1:kref
        u_r(k,:,:)=griddata(lon(D),lat(D),u_r(k,D),lon,lat);
        v_r(k,:,:)=griddata(lon(D),lat(D),v_r(k,D),lon,lat);
      end
    else
%      disp('No values outside the Equator to extrapole')
    end
  end
%
% Correct ssh over dry cells
% and extend masking area over shallow waters
%  (to avoid problems with poisson solver in oct_get_psi)
%
  Dcrit=0.2;
  h(h==0)=eps;
  ssh(ssh<(Dcrit-h))=Dcrit-h(ssh<(Dcrit-h));
  rmask(h<20)=0;
  umask=rmask(1:end,2:end).*rmask(1:end,1:end-1);
  vmask=rmask(2:end,1:end).*rmask(1:end-1,1:end);
%
%  Masking
%  
  umask3d=oct_tridim(umask,kref); 
  vmask3d=oct_tridim(vmask,kref); 
  u=umask3d.*oct_rho2u_3d(u_r);
  v=vmask3d.*oct_rho2v_3d(v_r);
  ssh=ssh.*rmask; 
%
% Vertical interpolation of baroclinic fields
%
%  disp('Vertical interpolation ...')
  zcroco=oct_zlevs(h,ssh,theta_s,theta_b,hc,N,'r',vtransform);
  zu=0.5*(zcroco(:,:,1:end-1)+zcroco(:,:,2:end));
  zv=0.5*(zcroco(:,1:end-1,:)+zcroco(:,2:end,:));
%
% Add non gradient velocities at the top and nul velocities 
% at -10000m for vertical extrapolation.
%
  u=cat(1,u(1,:,:),u);
  v=cat(1,v(1,:,:),v);
  u=flip(cat(1,u,0*u(1,:,:)),1);
  v=flip(cat(1,v,0*v(1,:,:)),1);
  z1=flipud([100;Z;-10000]);
%
% Do the interpolation
%
  u=oct_ztosigma(u,zu,z1);
  v=oct_ztosigma(v,zv,z1);
%
%  Barotropic velocities
%
%  disp('Barotropic component ...')
  zw=oct_zlevs(h,ssh,theta_s,theta_b,hc,N,'w',vtransform);
  dz=zw(2:end,:,:)-zw(1:end-1,:,:);
  dzu=0.5*(dz(:,:,1:end-1)+dz(:,:,2:end));
  dzv=0.5*(dz(:,1:end-1,:)+dz(:,2:end,:));
  hu(:,:)=sum(dzu.*u);
  hv(:,:)=sum(dzv.*v);
  D_u(:,:)=sum(dzu);
  D_v(:,:)=sum(dzv);
  ubar(:,:)=hu./D_u;
  vbar(:,:)=hv./D_v;
  u=u-oct_tridim(ubar,N);
  v=v-oct_tridim(vbar,N);
%
% Mass conservation
%
  %conserv=0
  if conserv==1
%    disp('Volume conservation enforcement ...')
    [hu,hv]=oct_get_obcvolcons(hu,hv,pm,pn,rmask,obc);
%
% Get the stream function
%
    psi=oct_get_psi(hu,hv,pm,pn,rmask); 
    hu(2:end-1,1:end)=-0.5*umask(2:end-1,1:end).*...
                      (psi(2:end,1:end)-psi(1:end-1,1:end)).*...
                      (pn(2:end-1,2:end)+pn(2:end-1,1:end-1));
    hv(1:end,2:end-1)=0.5*vmask(1:end,2:end-1).*...
                     (psi(1:end,2:end)-psi(1:end,1:end-1)).*...
                     (pm(2:end,2:end-1)+pm(1:end-1,2:end-1));
    [hu,hv]=oct_get_obcvolcons(hu,hv,pm,pn,rmask,obc);
    ubar(:,:)=hu./D_u;
    vbar(:,:)=hv./D_v;
  end
  u=u+oct_tridim(ubar,N);
  v=v+oct_tridim(vbar,N);
%
% corners
%
  ubar(1,1)=0.5*(ubar(1,2)+ubar(2,1)); 
  ubar(end,1)=0.5*(ubar(end,2)+ubar(end-1,1)); 
  ubar(1,end)=0.5*(ubar(1,end-1)+ubar(2,end)); 
  ubar(end,end)=0.5*(ubar(end,end-1)+ubar(end-1,end)); 
  vbar(1,1)=0.5*(vbar(1,2)+vbar(2,1)); 
  vbar(end,1)=0.5*(vbar(end,2)+vbar(end-1,1)); 
  vbar(1,end)=0.5*(vbar(1,end-1)+vbar(2,end)); 
  vbar(end,end)=0.5*(vbar(end,end-1)+vbar(end-1,end)); 
  u(:,1,1)=0.5*(u(:,1,2)+u(:,2,1)); 
  u(:,end,1)=0.5*(u(:,end,2)+u(:,end-1,1)); 
  u(:,1,end)=0.5*(u(:,1,end-1)+u(:,2,end)); 
  u(:,end,end)=0.5*(u(:,end,end-1)+u(:,end-1,end)); 
  v(:,1,1)=0.5*(v(:,1,2)+v(:,2,1)); 
  v(:,end,1)=0.5*(v(:,end,2)+v(:,end-1,1)); 
  v(:,1,end)=0.5*(v(:,1,end-1)+v(:,2,end)); 
  v(:,end,end)=0.5*(v(:,end,end-1)+v(:,end-1,end)); 
%
%  Write into file
%
%  disp('Writes into climatology file ...')
%
% Write record lout: 3D (N,eta,xi) -> (xi,eta,N), 2D (eta,xi) -> (xi,eta)
%
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'u'), [0 0 0 lout-1], [L-1 M N 1], permute(u,[3 2 1]));
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'v'), [0 0 0 lout-1], [L M-1 N 1], permute(v,[3 2 1]));
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ubar'), [0 0 lout-1], [L-1 M 1], ubar.');
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'vbar'), [0 0 lout-1], [L M-1 1], vbar.');
  if tini == 0
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'SSH'), [0 0 lout-1], [L M 1], ssh.');
  end
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'zeta'), [0 0 lout-1], [L M 1], ssh.');
end
netcdf.close(ncid);
netcdf.close(noa_id);
%
% Close the forcing file
%
if use_frc
  netcdf.close(nfrc_id);
end
if nargin==0
  close all
  oct_test_clim(clmname,grdname,'temp',1)
end
