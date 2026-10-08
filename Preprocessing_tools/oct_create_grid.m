function  oct_create_grid(L,M,grdname,title)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	Create an empty netcdf gridfile
%       L: total number of psi points in x direction  
%       M: total number of psi points in y direction  
%       grdname: name of the grid file
%       title: title in the netcdf file  
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
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    Sep-2026 : rewritten for Octave + octave-netcdf (netcdf.* API).
%             Dimension ids are given to netcdf.defVar in Fortran order
%             (fastest first: xi, eta, ...) so that the file stores
%             h(eta_rho,xi_rho) as CROCO expects.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Lp=L+1;
Mp=M+1;
%
%  Create the netcdf file (clobber existing)
%
ncid = netcdf.create(grdname,'CLOBBER');
%
%  Dimensions
%
d_xi_u    = netcdf.defDim(ncid,'xi_u',L);
d_eta_u   = netcdf.defDim(ncid,'eta_u',Mp);
d_xi_v    = netcdf.defDim(ncid,'xi_v',Lp);
d_eta_v   = netcdf.defDim(ncid,'eta_v',M);
d_xi_rho  = netcdf.defDim(ncid,'xi_rho',Lp);
d_eta_rho = netcdf.defDim(ncid,'eta_rho',Mp);
d_xi_psi  = netcdf.defDim(ncid,'xi_psi',L);
d_eta_psi = netcdf.defDim(ncid,'eta_psi',M);
d_one     = netcdf.defDim(ncid,'one',1);
d_two     = netcdf.defDim(ncid,'two',2);
d_four    = netcdf.defDim(ncid,'four',4);
d_bath    = netcdf.defDim(ncid,'bath',1);
%
%  Dimension lists in Fortran order (reverse of the CDL/ncdump order)
%
rho = [d_xi_rho d_eta_rho];
u   = [d_xi_u   d_eta_u];
v   = [d_xi_v   d_eta_v];
psi = [d_xi_psi d_eta_psi];
%
%  Variables and attributes
%
id = netcdf.defVar(ncid,'xl','NC_DOUBLE',d_one);
netcdf.putAtt(ncid,id,'long_name','domain length in the XI-direction');
netcdf.putAtt(ncid,id,'units','meter');
id = netcdf.defVar(ncid,'el','NC_DOUBLE',d_one);
netcdf.putAtt(ncid,id,'long_name','domain length in the ETA-direction');
netcdf.putAtt(ncid,id,'units','meter');
id = netcdf.defVar(ncid,'depthmin','NC_DOUBLE',d_one);
netcdf.putAtt(ncid,id,'long_name','Shallow bathymetry clipping depth');
netcdf.putAtt(ncid,id,'units','meter');
id = netcdf.defVar(ncid,'depthmax','NC_DOUBLE',d_one);
netcdf.putAtt(ncid,id,'long_name','Deep bathymetry clipping depth');
netcdf.putAtt(ncid,id,'units','meter');
id = netcdf.defVar(ncid,'spherical','NC_CHAR',d_one);
netcdf.putAtt(ncid,id,'long_name','Grid type logical switch');
netcdf.putAtt(ncid,id,'option_T','spherical');
netcdf.putAtt(ncid,id,'option_F','cartesian');
id = netcdf.defVar(ncid,'angle','NC_DOUBLE',rho);
netcdf.putAtt(ncid,id,'long_name','angle between xi axis and east');
netcdf.putAtt(ncid,id,'units','radian');
id = netcdf.defVar(ncid,'h','NC_DOUBLE',rho);
netcdf.putAtt(ncid,id,'long_name','Final bathymetry at RHO-points');
netcdf.putAtt(ncid,id,'units','meter');
id = netcdf.defVar(ncid,'hraw','NC_DOUBLE',[rho d_bath]);
netcdf.putAtt(ncid,id,'long_name','Working bathymetry at RHO-points');
netcdf.putAtt(ncid,id,'units','meter');
id = netcdf.defVar(ncid,'alpha','NC_DOUBLE',rho);
netcdf.putAtt(ncid,id,'long_name','Weights between coarse and fine grids at RHO-points');
id = netcdf.defVar(ncid,'f','NC_DOUBLE',rho);
netcdf.putAtt(ncid,id,'long_name','Coriolis parameter at RHO-points');
netcdf.putAtt(ncid,id,'units','second-1');
id = netcdf.defVar(ncid,'pm','NC_DOUBLE',rho);
netcdf.putAtt(ncid,id,'long_name','curvilinear coordinate metric in XI');
netcdf.putAtt(ncid,id,'units','meter-1');
id = netcdf.defVar(ncid,'pn','NC_DOUBLE',rho);
netcdf.putAtt(ncid,id,'long_name','curvilinear coordinate metric in ETA');
netcdf.putAtt(ncid,id,'units','meter-1');
id = netcdf.defVar(ncid,'dndx','NC_DOUBLE',rho);
netcdf.putAtt(ncid,id,'long_name','xi derivative of inverse metric factor pn');
netcdf.putAtt(ncid,id,'units','meter');
id = netcdf.defVar(ncid,'dmde','NC_DOUBLE',rho);
netcdf.putAtt(ncid,id,'long_name','eta derivative of inverse metric factor pm');
netcdf.putAtt(ncid,id,'units','meter');
%
%  Positions (x,y,lon,lat) and masks on the 4 C-grid positions
%
pos   = {'rho','u','v','psi'};
pdims = {rho, u, v, psi};
for k=1:4
  id = netcdf.defVar(ncid,['x_',pos{k}],'NC_DOUBLE',pdims{k});
  netcdf.putAtt(ncid,id,'long_name',['x location of ',upper(pos{k}),'-points']);
  netcdf.putAtt(ncid,id,'units','meter');
end
for k=1:4
  id = netcdf.defVar(ncid,['y_',pos{k}],'NC_DOUBLE',pdims{k});
  netcdf.putAtt(ncid,id,'long_name',['y location of ',upper(pos{k}),'-points']);
  netcdf.putAtt(ncid,id,'units','meter');
end
for k=1:4
  id = netcdf.defVar(ncid,['lon_',pos{k}],'NC_DOUBLE',pdims{k});
  netcdf.putAtt(ncid,id,'long_name',['longitude of ',upper(pos{k}),'-points']);
  netcdf.putAtt(ncid,id,'units','degree_east');
end
for k=1:4
  id = netcdf.defVar(ncid,['lat_',pos{k}],'NC_DOUBLE',pdims{k});
  netcdf.putAtt(ncid,id,'long_name',['latitude of ',upper(pos{k}),'-points']);
  netcdf.putAtt(ncid,id,'units','degree_north');
end
for k=1:4
  id = netcdf.defVar(ncid,['mask_',pos{k}],'NC_DOUBLE',pdims{k});
  netcdf.putAtt(ncid,id,'long_name',['mask on ',upper(pos{k}),'-points']);
  netcdf.putAtt(ncid,id,'option_0','land');
  netcdf.putAtt(ncid,id,'option_1','water');
end
%
%  Global attributes (written while still in define mode)
%
gid = netcdf.getConstant('NC_GLOBAL');
netcdf.putAtt(ncid,gid,'title',title);
netcdf.putAtt(ncid,gid,'date',date);
netcdf.putAtt(ncid,gid,'type','CROCO grid file');
%
%  Leave define mode and close
%
netcdf.endDef(ncid);
netcdf.close(ncid);
return
