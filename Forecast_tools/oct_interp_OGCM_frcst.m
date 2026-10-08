function oct_interp_OGCM_frcst(OGCM_name,Roa,interp_method,...
                           lonU,latU,lonV,latV,lonT,latT,Z,tin,...
		           nc_clm,ncid_bry,lon,lat,angle,h,pm,pn,rmask,...
                           tout,vtransform,obc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% Read the local OGCM files and perform the interpolations
%
% Ok, I am lazy and I did not do something special for the bry files...
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
%  Copyright (c) 2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    9-Sep-2006 by Pierrick Penven
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
conserv=1; % same barotropic velocities as the OGCM
%
disp(['  Horizontal interpolation: ',OGCM_name])
%
% CROCO grid angle
%
cosa=cos(angle);
sina=sin(angle);
%
% Open the OGCM file
%
ncid = netcdf.open(OGCM_name, 'NC_NOWRITE');
%
% Interpole data on the OGCM Z grid and CROCO horizontal grid
%
%
% Read and extrapole the 2D variables
%
zeta=oct_ext_data_OGCM(ncid,lonT,latT,'ssh',tin,lon,lat,1,Roa,interp_method);
u2d=oct_ext_data_OGCM(ncid,lonU,latU,'ubar',tin,lon,lat,1,Roa,interp_method);
v2d=oct_ext_data_OGCM(ncid,lonV,latV,'vbar',tin,lon,lat,1,Roa,interp_method);
ubar=oct_rho2u_2d(u2d.*cosa+v2d.*sina);
vbar=oct_rho2v_2d(v2d.*cosa-u2d.*sina);
%
% Read and extrapole the 3D variables
%
NZ=length(Z);
[M,L]=size(lon);
dz=gradient(Z);
temp=zeros(NZ,M,L);
salt=zeros(NZ,M,L);
u=zeros(NZ,M,L-1);
v=zeros(NZ,M-1,L);
for k=1:NZ
  if rem(k,10)==0
    disp(['  Level ',num2str(k),' of ',num2str(NZ)])
  end
  u2d=oct_ext_data_OGCM(ncid,lonU,latU,'u',tin,lon,lat,...
                    k,Roa,interp_method);
  v2d=oct_ext_data_OGCM(ncid,lonV,latV,'v',tin,lon,lat,...
                    k,Roa,interp_method);
  u(k,:,:)=oct_rho2u_2d(u2d.*cosa+v2d.*sina);
  v(k,:,:)=oct_rho2v_2d(v2d.*cosa-u2d.*sina);
  temp(k,:,:)=oct_ext_data_OGCM(ncid,lonT,latT,'temp',tin,lon,lat,...
                            k,Roa,interp_method);
  salt(k,:,:)=oct_ext_data_OGCM(ncid,lonT,latT,'salt',tin,lon,lat,...
                            k,Roa,interp_method);
end
%
% Close the OGCM file
%
netcdf.close(ncid);
%
% Get the CROCO vertical grid
%
disp('  Vertical interpolations')
if ~isempty(nc_clm)
  theta_s=nc_clm{'theta_s'}(:);
  theta_b=nc_clm{'theta_b'}(:);
  hc=nc_clm{'hc'}(:);
  N=length(nc_clm('s_rho'));
end
if ~isempty(ncid_bry)
  theta_s=netcdf.getVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'theta_s'));
  theta_b=netcdf.getVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'theta_b'));
  hc=netcdf.getVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'hc'));
  [~,N]=netcdf.inqDim(ncid_bry, netcdf.inqDimID(ncid_bry, 's_rho'));
end
zr=oct_zlevs(h,zeta,theta_s,theta_b,hc,N,'r',vtransform);
zu=oct_rho2u_3d(zr);
zv=oct_rho2v_3d(zr);
zw=oct_zlevs(h,zeta,theta_s,theta_b,hc,N,'w',vtransform);
dzr=zw(2:end,:,:)-zw(1:end-1,:,:);
dzu=oct_rho2u_3d(dzr);
dzv=oct_rho2v_3d(dzr);
%
% Add an extra bottom layer (-100000m) and an extra surface layer (+100m)
% to prevent vertical extrapolations
%
Z=[100;Z;-100000];
u=cat(1,u(1,:,:),u);
u=cat(1,u,u(end,:,:));
v=cat(1,v(1,:,:),v);
v=cat(1,v,v(end,:,:));
temp=cat(1,temp(1,:,:),temp);
temp=cat(1,temp,temp(end,:,:));
salt=cat(1,salt,salt(end,:,:));
salt=cat(1,salt(1,:,:),salt);
% 
% Perform the vertical interpolations 
%
temp=oct_ztosigma(flip(temp,1),zr,flipud(Z));
salt=oct_ztosigma(flip(salt,1),zr,flipud(Z));
u=oct_ztosigma(flip(u,1),zu,flipud(Z));
v=oct_ztosigma(flip(v,1),zv,flipud(Z));
%
% Correct the horizontal transport 
% i.e. remove the interpolated tranport and add 
%      the OGCM transport
%
if conserv==1
  u=u-oct_tridim(squeeze(sum(u.*dzu)./sum(dzu)),N);
  v=v-oct_tridim(squeeze(sum(v.*dzv)./sum(dzv)),N);
  u=u+oct_tridim(ubar,N);
  v=v+oct_tridim(vbar,N);
end
%
% Barotropic velocities
%
ubar=squeeze(sum(u.*dzu)./sum(dzu));
vbar=squeeze(sum(v.*dzv)./sum(dzv));
%
%  fill the files
%
if ~isempty(nc_clm)
  nc_clm{'zeta'}(tout,:,:)=zeta;
  nc_clm{'SSH'}(tout,:,:)=zeta;
  nc_clm{'temp'}(tout,:,:,:)=temp;
  nc_clm{'salt'}(tout,:,:,:)=salt;
  nc_clm{'u'}(tout,:,:,:)=u;
  nc_clm{'v'}(tout,:,:,:)=v;
  nc_clm{'ubar'}(tout,:,:,:)=ubar;
  nc_clm{'vbar'}(tout,:,:,:)=vbar;
end
if ~isempty(ncid_bry)
  for obcndx=1:4
    if obcndx==1
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'zeta_south'), tout,:-1, 1, zeta(1,:));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'temp_south'), tout,:,:-1, 1, temp(:,1,:));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'salt_south'), tout,:,:-1, 1, salt(:,1,:));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'u_south'), tout,:,:-1, 1, u(:,1,:));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'v_south'), tout,:,:-1, 1, v(:,1,:));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'ubar_south'), tout,:,:-1, 1, ubar(1,:));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'vbar_south'), tout,:,:-1, 1, vbar(1,:));  % [conv] 0-based
   elseif obcndx==2
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'zeta_east'), tout,:-1, 1, zeta(:,end));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'temp_east'), tout,:,:-1, 1, temp(:,:,end));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'salt_east'), tout,:,:-1, 1, salt(:,:,end));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'u_east'), tout,:,:-1, 1, u(:,:,end));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'v_east'), tout,:,:-1, 1, v(:,:,end));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'ubar_east'), tout,:,:-1, 1, ubar(:,end));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'vbar_east'), tout,:,:-1, 1, vbar(:,end));  % [conv] 0-based
    elseif obcndx==3
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'zeta_north'), tout,:-1, 1, zeta(end,:));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'temp_north'), tout,:,:-1, 1, temp(:,end,:));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'salt_north'), tout,:,:-1, 1, salt(:,end,:));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'u_north'), tout,:,:-1, 1, u(:,end,:));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'v_north'), tout,:,:-1, 1, v(:,end,:));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'ubar_north'), tout,:,:-1, 1, ubar(end,:));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'vbar_north'), tout,:,:-1, 1, vbar(end,:));  % [conv] 0-based
    elseif obcndx==4
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'zeta_west'), tout,:-1, 1, zeta(:,1));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'temp_west'), tout,:,:-1, 1, temp(:,:,1));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'salt_west'), tout,:,:-1, 1, salt(:,:,1));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'u_west'), tout,:,:-1, 1, u(:,:,1));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'v_west'), tout,:,:-1, 1, v(:,:,1));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'ubar_west'), tout,:,:-1, 1, ubar(:,1));  % [conv] 0-based
      netcdf.putVar(ncid_bry, netcdf.inqVarID(ncid_bry, 'vbar_west'), tout,:,:-1, 1, vbar(:,1));  % [conv] 0-based
    end
  end
end
