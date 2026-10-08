function oct_vinterp_bry_bgc(bryname,grdname,Zbryname,time,vname,obcndx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Vertical interpolation from a Z-grid to a sigma-grid in the
%  case of boundary (bry) files.
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
%  Copyright (c) 2005-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% open the grid file  
% 
ng_id = netcdf.open(grdname, 'NC_NOWRITE');
[~,L]=netcdf.inqDim(ng_id, netcdf.inqDimID(ng_id, 'xi_rho'));
[~,M]=netcdf.inqDim(ng_id, netcdf.inqDimID(ng_id, 'eta_rho'));
if obcndx==1
  h=netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'h'));
elseif obcndx==2
  h=netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'h'));
elseif obcndx==3
  h=netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'h'));
elseif obcndx==4
  h=netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'h'));
end
netcdf.close(ng_id);
%
% open the boundary file  
% 
ncid = netcdf.open(bryname, 'NC_WRITE');
theta_s = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_s'));
theta_b =  netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_b'));
hc  =  netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'hc'));
[~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
vtransform = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Vtransform'));
if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
end
% open the oa file  
% 
noa_id = netcdf.open(Zbryname, 'NC_NOWRITE');
z=-netcdf.getVar(noa_id, netcdf.inqVarID(noa_id, 'Z'));
t=netcdf.getVar(noa_id, netcdf.inqVarID(noa_id, time));
tlen=length(t);
Nz0=length(z);
%
% Get the sigma depths
%
zcroco=squeeze(oct_zlevs(h,0.*h,theta_s,theta_b,hc,N,'r',vtransform));
zmin=min(min(zcroco));
zmax=max(max(zcroco));
%
% Check if the min z level is below the min sigma level 
%    (if not add a deep layer)
%
addsurf=max(z)<zmax;
addbot=min(z)>zmin;
if addsurf
 z=[100;z];
end
if addbot
 z=[z;-100000];
end
Nz=min(find(z<zmin));
z=z(1:Nz);
%
% loop on time
%

for l=1:tlen
%for l=1:1
  disp([' Time index: ',num2str(l),' of total: ',num2str(tlen)])
  var=squeeze(netcdf.getVar(noa_id, netcdf.inqVarID(noa_id, vname)));
  if addsurf
    var=cat(1,var(1,:),var);
  end
  if addbot
    var=cat(1,var,var(end,:));
  end
  var=var(1:Nz,:);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, vname), l,:,:-1, 1, oct_ztosigma_1d(flip(var,1),zcroco,flipud(z)));  % [conv] 0-based
end
netcdf.close(ncid);
netcdf.close(noa_id);

return
