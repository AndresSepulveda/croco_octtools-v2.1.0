function oct_vinterp_bry(bryname,grdname,Zbryname,vname,obcndx)
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
%  Octave version (Sep-2026): netcdf.* API of the octave-netcdf package.
%
%
% Bathymetry along the boundary. h(eta,xi) in the file is (xi,eta) for
% netcdf.getVar: start/count are given in that order and the result is
% returned as a row vector.
%
ng_id = netcdf.open(grdname, 'NC_NOWRITE');
[~,L]=netcdf.inqDim(ng_id, netcdf.inqDimID(ng_id, 'xi_rho'));
[~,M]=netcdf.inqDim(ng_id, netcdf.inqDimID(ng_id, 'eta_rho'));
vid_h=netcdf.inqVarID(ng_id, 'h');
if obcndx==1
  h=double(netcdf.getVar(ng_id, vid_h, [0 0],   [L 1]));   % h(1,:)
  suffix='_south';
elseif obcndx==2
  h=double(netcdf.getVar(ng_id, vid_h, [L-1 0], [1 M]));   % h(:,L)
  suffix='_east';
elseif obcndx==3
  h=double(netcdf.getVar(ng_id, vid_h, [0 M-1], [L 1]));   % h(M,:)
  suffix='_north';
elseif obcndx==4
  h=double(netcdf.getVar(ng_id, vid_h, [0 0],   [1 M]));   % h(:,1)
  suffix='_west';
end
h=h(:).';
netcdf.close(ng_id);
nx=length(h);
%
% open the boundary file  
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
  disp([' USE VTRANSFORM default value vtransform = 1'])
end
%
% open the Z-boundary file  
% 
noa_id = netcdf.open(Zbryname, 'NC_NOWRITE');
z=-double(netcdf.getVar(noa_id, netcdf.inqVarID(noa_id, 'Z')));
t=double(netcdf.getVar(noa_id, netcdf.inqVarID(noa_id, 'bry_time')));
z=z(:);
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
vid_in=netcdf.inqVarID(noa_id, vname);
vid_out=netcdf.inqVarID(ncid, vname);
for l=1:tlen
  disp([' Time index: ',num2str(l),' of total: ',num2str(tlen)])
% vname(bry_time,Z,x) -> getVar (x,Z) -> transpose to (Z,x)
  var=double(netcdf.getVar(noa_id, vid_in, [0 0 l-1], [nx Nz0 1])).';
  if addsurf
    var=cat(1,var(1,:),var);
  end
  if addbot
    var=cat(1,var,var(end,:));
  end
  var=var(1:Nz,:);
  var=oct_ztosigma_1d(flip(var,1),zcroco,flipud(z));
% (N,x) -> Fortran order [x N time]
  netcdf.putVar(ncid, vid_out, [0 0 l-1], [nx N 1], var.');
end
netcdf.close(ncid);
netcdf.close(noa_id);
return
