function  oct_create_nestedgrid(L,M,grdname,oct_parent,title)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%  Copyright (c) 2004-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Lp=L+1;
Mp=M+1;
%
nw_id = netcdf.create(grdname, 'NC_CLOBBER');
%redef(nw);
%
%  Create dimensions
%
did_xi_u = netcdf.defDim(nw_id, 'xi_u', L);
did_eta_u = netcdf.defDim(nw_id, 'eta_u', Mp);
did_xi_v = netcdf.defDim(nw_id, 'xi_v', Lp);
did_eta_v = netcdf.defDim(nw_id, 'eta_v', M);
did_xi_rho = netcdf.defDim(nw_id, 'xi_rho', Lp);
did_eta_rho = netcdf.defDim(nw_id, 'eta_rho', Mp);
did_xi_psi = netcdf.defDim(nw_id, 'xi_psi', L);
did_eta_psi = netcdf.defDim(nw_id, 'eta_psi', M);
did_one = netcdf.defDim(nw_id, 'one', 1);
did_two = netcdf.defDim(nw_id, 'two', 2);
did_four = netcdf.defDim(nw_id, 'four', 4);
did_bath = netcdf.defDim(nw_id, 'bath', netcdf.getConstant('NC_UNLIMITED'));

%
%  Create variables and attributes
%

vid_xl = netcdf.defVar(nw_id, 'xl', 'NC_DOUBLE', did_one);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'xl'), 'long_name', 'domain length in the XI-direction');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'xl'), 'units', 'meter');

vid_el = netcdf.defVar(nw_id, 'el', 'NC_DOUBLE', did_one);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'el'), 'long_name', 'domain length in the ETA-direction');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'el'), 'units', 'meter');

vid_depthmin = netcdf.defVar(nw_id, 'depthmin', 'NC_DOUBLE', did_one);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'depthmin'), 'long_name', 'Shallow bathymetry clipping depth');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'depthmin'), 'units', 'meter');

vid_depthmax = netcdf.defVar(nw_id, 'depthmax', 'NC_DOUBLE', did_one);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'depthmax'), 'long_name', 'Deep bathymetry clipping depth');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'depthmax'), 'units', 'meter');

vid_spherical = netcdf.defVar(nw_id, 'spherical', 'NC_CHAR', did_one);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'spherical'), 'long_name', 'Grid type logical switch');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'spherical'), 'option_T', 'spherical');

vid_refine_coef = netcdf.defVar(nw_id, 'refine_coef', 'NC_INT', did_one);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'refine_coef'), 'long_name', 'Grid refinment coefficient');

vid_grd_pos = netcdf.defVar(nw_id, 'grd_pos', 'NC_INT', did_four);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'grd_pos'), 'long_name', 'Subgrid location in the parent grid: psi corner points (imin imax jmin jmax)');

vid_angle = netcdf.defVar(nw_id, 'angle', 'NC_DOUBLE', [did_xi_rho, did_eta_rho]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'angle'), 'long_name', 'angle between xi axis and east');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'angle'), 'units', 'degree');

vid_h = netcdf.defVar(nw_id, 'h', 'NC_DOUBLE', [did_xi_rho, did_eta_rho]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'h'), 'long_name', 'Final bathymetry at RHO-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'h'), 'units', 'meter');

vid_hraw = netcdf.defVar(nw_id, 'hraw', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_bath]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'hraw'), 'long_name', 'Working bathymetry at RHO-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'hraw'), 'units', 'meter');

vid_alpha = netcdf.defVar(nw_id, 'alpha', 'NC_DOUBLE', [did_xi_rho, did_eta_rho]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'alpha'), 'long_name', 'Weights between coarse and fine grids at RHO-points');

vid_f = netcdf.defVar(nw_id, 'f', 'NC_DOUBLE', [did_xi_rho, did_eta_rho]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'f'), 'long_name', 'Coriolis parameter at RHO-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'f'), 'units', 'second-1');

vid_pm = netcdf.defVar(nw_id, 'pm', 'NC_DOUBLE', [did_xi_rho, did_eta_rho]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'pm'), 'long_name', 'curvilinear coordinate metric in XI');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'pm'), 'units', 'meter-1');

vid_pn = netcdf.defVar(nw_id, 'pn', 'NC_DOUBLE', [did_xi_rho, did_eta_rho]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'pn'), 'long_name', 'curvilinear coordinate metric in ETA');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'pn'), 'units', 'meter-1');

vid_dndx = netcdf.defVar(nw_id, 'dndx', 'NC_DOUBLE', [did_xi_rho, did_eta_rho]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'dndx'), 'long_name', 'xi derivative of inverse metric factor pn');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'dndx'), 'units', 'meter');

vid_dmde = netcdf.defVar(nw_id, 'dmde', 'NC_DOUBLE', [did_xi_rho, did_eta_rho]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'dmde'), 'long_name', 'eta derivative of inverse metric factor pm');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'dmde'), 'units', 'meter');

vid_x_rho = netcdf.defVar(nw_id, 'x_rho', 'NC_DOUBLE', [did_xi_rho, did_eta_rho]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'x_rho'), 'long_name', 'x location of RHO-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'x_rho'), 'units', 'meter');

vid_x_u = netcdf.defVar(nw_id, 'x_u', 'NC_DOUBLE', [did_xi_u, did_eta_u]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'x_u'), 'long_name', 'x location of U-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'x_u'), 'units', 'meter');

vid_x_v = netcdf.defVar(nw_id, 'x_v', 'NC_DOUBLE', [did_xi_v, did_eta_v]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'x_v'), 'long_name', 'x location of V-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'x_v'), 'units', 'meter');

vid_x_psi = netcdf.defVar(nw_id, 'x_psi', 'NC_DOUBLE', [did_xi_psi, did_eta_psi]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'x_psi'), 'long_name', 'x location of PSI-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'x_psi'), 'units', 'meter');

vid_y_rho = netcdf.defVar(nw_id, 'y_rho', 'NC_DOUBLE', [did_xi_rho, did_eta_rho]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'y_rho'), 'long_name', 'y location of RHO-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'y_rho'), 'units', 'meter');

vid_y_u = netcdf.defVar(nw_id, 'y_u', 'NC_DOUBLE', [did_xi_u, did_eta_u]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'y_u'), 'long_name', 'y location of U-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'y_u'), 'units', 'meter');

vid_y_v = netcdf.defVar(nw_id, 'y_v', 'NC_DOUBLE', [did_xi_v, did_eta_v]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'y_v'), 'long_name', 'y location of V-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'y_v'), 'units', 'meter');

vid_y_psi = netcdf.defVar(nw_id, 'y_psi', 'NC_DOUBLE', [did_xi_psi, did_eta_psi]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'y_psi'), 'long_name', 'y location of PSI-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'y_psi'), 'units', 'meter');

vid_lon_rho = netcdf.defVar(nw_id, 'lon_rho', 'NC_DOUBLE', [did_xi_rho, did_eta_rho]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon_rho'), 'long_name', 'longitude of RHO-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon_rho'), 'units', 'degree_east');

vid_lon_u = netcdf.defVar(nw_id, 'lon_u', 'NC_DOUBLE', [did_xi_u, did_eta_u]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon_u'), 'long_name', 'longitude of U-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon_u'), 'units', 'degree_east');

vid_lon_v = netcdf.defVar(nw_id, 'lon_v', 'NC_DOUBLE', [did_xi_v, did_eta_v]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon_v'), 'long_name', 'longitude of V-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon_v'), 'units', 'degree_east');

vid_lon_psi = netcdf.defVar(nw_id, 'lon_psi', 'NC_DOUBLE', [did_xi_psi, did_eta_psi]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon_psi'), 'long_name', 'longitude of PSI-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon_psi'), 'units', 'degree_east');

vid_lat_rho = netcdf.defVar(nw_id, 'lat_rho', 'NC_DOUBLE', [did_xi_rho, did_eta_rho]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat_rho'), 'long_name', 'latitude of RHO-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat_rho'), 'units', 'degree_north');

vid_lat_u = netcdf.defVar(nw_id, 'lat_u', 'NC_DOUBLE', [did_xi_u, did_eta_u]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat_u'), 'long_name', 'latitude of U-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat_u'), 'units', 'degree_north');

vid_lat_v = netcdf.defVar(nw_id, 'lat_v', 'NC_DOUBLE', [did_xi_v, did_eta_v]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat_v'), 'long_name', 'latitude of V-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat_v'), 'units', 'degree_north');

vid_lat_psi = netcdf.defVar(nw_id, 'lat_psi', 'NC_DOUBLE', [did_xi_psi, did_eta_psi]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat_psi'), 'long_name', 'latitude of PSI-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat_psi'), 'units', 'degree_north');

vid_mask_rho = netcdf.defVar(nw_id, 'mask_rho', 'NC_DOUBLE', [did_xi_rho, did_eta_rho]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'mask_rho'), 'long_name', 'mask on RHO-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'mask_rho'), 'option_0', 'land');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'mask_rho'), 'option_1', 'water');

vid_mask_u = netcdf.defVar(nw_id, 'mask_u', 'NC_DOUBLE', [did_xi_u, did_eta_u]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'mask_u'), 'long_name', 'mask on U-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'mask_u'), 'option_0', 'land');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'mask_u'), 'option_1', 'water');

vid_mask_v = netcdf.defVar(nw_id, 'mask_v', 'NC_DOUBLE', [did_xi_v, did_eta_v]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'mask_v'), 'long_name', 'mask on V-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'mask_v'), 'option_0', 'land');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'mask_v'), 'option_1', 'water');

vid_mask_psi = netcdf.defVar(nw_id, 'mask_psi', 'NC_DOUBLE', [did_xi_psi, did_eta_psi]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'mask_psi'), 'long_name', 'mask on PSI-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'mask_psi'), 'option_0', 'land');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'mask_psi'), 'option_1', 'water');

%endef(nw);

%
% Create global attributes
%

% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'title', title);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'date', date);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'parent_grid', oct_parent);

netcdf.close(nw_id);
return
