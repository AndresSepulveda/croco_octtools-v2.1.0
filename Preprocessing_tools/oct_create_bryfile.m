function oct_create_bryfile(bryname,grdname,title,obc,...
                        theta_s,theta_b,hc,N,...
                        time,cycle,clobber,vtransform,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function oct_create_bryfile(bryname,grdname,title,obc...
%                          theta_s,theta_b,hc,N,...
%                          time,cycle,clobber);
%
%   This function create the header of a Netcdf climatology 
%   file.
%
%   Input:
%
%   bryname      Netcdf climatology file name (character string).
%   grdname      Netcdf grid file name (character string).
%   obc          open boundaries flag (1=open , [S E N W]).
%   theta_s      S-coordinate surface control parameter.(Real)
%   theta_b      S-coordinate bottom control parameter.(Real)
%   hc           Width (m) of surface or bottom boundary layer 
%                where higher vertical resolution is required 
%                during stretching.(Real)
%   N            Number of vertical levels.(Integer)
%   time         time.(vector)
%   cycle        Length (days) for cycling the climatology.(Real)
%   clobber      Switch to allow or not writing over an existing
%                file.(character string)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp([' Creating the file : ',bryname])
disp(' ')
if nargin < 12
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
    vtransform = 1; 
end
disp([' VTRANSFORM = ',num2str(vtransform)])
%
% options for oct_write_time_attributes
insecond = 0;
add_cycle = 1 ; 
%
%
% Initialize Yorig if not provided
if ~exist('Yorig', 'var') ,  Yorig = [] ; , end
%
% Get time attributes
[time_unit_att,time_second_unit_att,calendar_att]=...
                    oct_get_time_attributes(Yorig);
%
%
%  Read the grid file and check the topography
%
ncid = netcdf.open(grdname, 'NC_NOWRITE');
h=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'))).';
maskr=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'))).';
[~,Lp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_rho'));
[~,Mp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_rho'));
netcdf.close(ncid);
hmin=min(min(h(maskr==1)));
if vtransform ==1;
  if hc > hmin
    error([' hc (',num2str(hc),' m) > hmin (',num2str(hmin),' m)'])
  end
end
L=Lp-1;
M=Mp-1;
Np=N+1;
%
%  Create the boundary file
%
type = 'BOUNDARY file' ; 
history = 'CROCO' ;
if strcmpi(clobber,'clobber')
  ncid = netcdf.create(bryname, 'NC_CLOBBER');
else
  ncid = netcdf.create(bryname, 'NC_NOCLOBBER');
end
%
%  Create dimensions
%
did_xi_u = netcdf.defDim(ncid, 'xi_u', L);
did_xi_v = netcdf.defDim(ncid, 'xi_v', Lp);
did_xi_rho = netcdf.defDim(ncid, 'xi_rho', Lp);
did_eta_u = netcdf.defDim(ncid, 'eta_u', Mp);
did_eta_v = netcdf.defDim(ncid, 'eta_v', M);
did_eta_rho = netcdf.defDim(ncid, 'eta_rho', Mp);
did_s_rho = netcdf.defDim(ncid, 's_rho', N);
did_s_w = netcdf.defDim(ncid, 's_w', Np);
did_tracer = netcdf.defDim(ncid, 'tracer', 2);
did_bry_time = netcdf.defDim(ncid, 'bry_time', length(time));
did_tclm_time = netcdf.defDim(ncid, 'tclm_time', length(time));
did_temp_time = netcdf.defDim(ncid, 'temp_time', length(time));
did_sclm_time = netcdf.defDim(ncid, 'sclm_time', length(time));
did_salt_time = netcdf.defDim(ncid, 'salt_time', length(time));
did_uclm_time = netcdf.defDim(ncid, 'uclm_time', length(time));
did_vclm_time = netcdf.defDim(ncid, 'vclm_time', length(time));
did_v2d_time = netcdf.defDim(ncid, 'v2d_time', length(time));
did_v3d_time = netcdf.defDim(ncid, 'v3d_time', length(time));
did_ssh_time = netcdf.defDim(ncid, 'ssh_time', length(time));
did_zeta_time = netcdf.defDim(ncid, 'zeta_time', length(time));
did_one = netcdf.defDim(ncid, 'one', 1);
%
%  Create variables and attributes
%
vid_spherical = netcdf.defVar(ncid, 'spherical', 'NC_CHAR', did_one);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'spherical'), 'long_name', 'grid type logical switch');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'spherical'), 'flag_values', 'T, F');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'spherical'), 'flag_meanings', 'spherical Cartesian');
%
vid_Vtransform = netcdf.defVar(ncid, 'Vtransform', 'NC_INT', did_one);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Vtransform'), 'long_name', 'vertical terrain-following transformation equation');
%
vid_Vstretching = netcdf.defVar(ncid, 'Vstretching', 'NC_INT', did_one);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Vstretching'), 'long_name', 'vertical terrain-following stretching function');
%
vid_tstart = netcdf.defVar(ncid, 'tstart', 'NC_DOUBLE', did_one);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'tstart'), 'long_name', 'start processing day');
oct_write_time_attributes(ncid,'tstart','',time_unit_att,time_second_unit_att,...
                      calendar_att,0,0);
%
vid_tend = netcdf.defVar(ncid, 'tend', 'NC_DOUBLE', did_one);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'tend'), 'long_name', 'end processing day');
oct_write_time_attributes(ncid,'tend','',time_unit_att,time_second_unit_att,...
                      calendar_att,0,0);
%
vid_theta_s = netcdf.defVar(ncid, 'theta_s', 'NC_DOUBLE', did_one);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'theta_s'), 'long_name', 'S-coordinate surface control parameter');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'theta_s'), 'units', 'nondimensional');
%
vid_theta_b = netcdf.defVar(ncid, 'theta_b', 'NC_DOUBLE', did_one);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'theta_b'), 'long_name', 'S-coordinate bottom control parameter');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'theta_b'), 'units', 'nondimensional');
%
vid_Tcline = netcdf.defVar(ncid, 'Tcline', 'NC_DOUBLE', did_one);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Tcline'), 'long_name', 'S-coordinate surface/bottom layer width');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Tcline'), 'units', 'meter');
%
vid_hc = netcdf.defVar(ncid, 'hc', 'NC_DOUBLE', did_one);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'hc'), 'long_name', 'S-coordinate parameter, critical depth');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'hc'), 'units', 'meter');
%
vid_s_rho = netcdf.defVar(ncid, 's_rho', 'NC_DOUBLE', did_s_rho);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'long_name', 'S-coordinate at RHO-points');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'valid_min', -1.);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'valid_max', 0.);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'positive', 'up');
if (vtransform == 1)
        netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'standard_name', 'ocean_s_coordinate_g1');
elseif (vtransform == 2)
        netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'standard_name', 'ocean_s_coordinate_g2');
end
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'formula_terms', 's: s_rho C: Cs_rho eta: zeta depth: h depth_c: hc');
%
vid_s_w = netcdf.defVar(ncid, 's_w', 'NC_DOUBLE', did_s_w);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_w'), 'long_name', 'S-coordinate at W-points');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_w'), 'valid_min', -1.);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_w'), 'valid_max', 0.);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_w'), 'positive', 'up');
if (vtransform == 1)
        netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_w'), 'standard_name', 'ocean_s_coordinate_g1');
elseif (vtransform == 2)
        netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_w'), 'standard_name', 'ocean_s_coordinate_g2');
end
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_w'), 'formula_terms', 's: s_w C: Cs_w eta: zeta depth: h depth_c: hc');
%
vid_Cs_rho = netcdf.defVar(ncid, 'Cs_rho', 'NC_DOUBLE', did_s_rho);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_rho'), 'long_name', 'S-coordinate stretching curves at RHO-points');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_rho'), 'units', 'nondimensional');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_rho'), 'valid_min', -1);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_rho'), 'valid_max', 0);
%
vid_Cs_w = netcdf.defVar(ncid, 'Cs_w', 'NC_DOUBLE', did_s_w);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_w'), 'long_name', 'S-coordinate stretching curves at W-points');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_w'), 'units', 'nondimensional');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_w'), 'valid_min', -1);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_w'), 'valid_max', 0);
%
vid_bry_time = netcdf.defVar(ncid, 'bry_time', 'NC_DOUBLE', did_bry_time);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'bry_time'), 'long_name', 'time for boundary');
oct_write_time_attributes(ncid,'bry_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);
%
vid_tclm_time = netcdf.defVar(ncid, 'tclm_time', 'NC_DOUBLE', did_tclm_time);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'tclm_time'), 'long_name', 'time for temperature climatology');
oct_write_time_attributes(ncid,'tclm_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);
%
vid_temp_time = netcdf.defVar(ncid, 'temp_time', 'NC_DOUBLE', did_temp_time);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_time'), 'long_name', 'time for temperature climatology');
oct_write_time_attributes(ncid,'temp_time',cycle,time_unit_att,time_second_unit_att,...
                           calendar_att,insecond,add_cycle);
%
vid_sclm_time = netcdf.defVar(ncid, 'sclm_time', 'NC_DOUBLE', did_sclm_time);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'sclm_time'), 'long_name', 'time for salinity climatology');
oct_write_time_attributes(ncid,'sclm_time',cycle,time_unit_att,time_second_unit_att,...
                           calendar_att,insecond,add_cycle);
%
vid_salt_time = netcdf.defVar(ncid, 'salt_time', 'NC_DOUBLE', did_salt_time);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_time'), 'long_name', 'time for salinity climatology');
oct_write_time_attributes(ncid,'salt_time',cycle,time_unit_att,time_second_unit_att,...
                           calendar_att,insecond,add_cycle);
%
vid_uclm_time = netcdf.defVar(ncid, 'uclm_time', 'NC_DOUBLE', did_uclm_time);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'uclm_time'), 'long_name', 'time climatological u');
oct_write_time_attributes(ncid,'uclm_time',cycle,time_unit_att,time_second_unit_att,...
                           calendar_att,insecond,add_cycle);
%
vid_vclm_time = netcdf.defVar(ncid, 'vclm_time', 'NC_DOUBLE', did_vclm_time);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vclm_time'), 'long_name', 'time climatological v');
oct_write_time_attributes(ncid,'vclm_time',cycle,time_unit_att,time_second_unit_att,...
                           calendar_att,insecond,add_cycle);
%
vid_v2d_time = netcdf.defVar(ncid, 'v2d_time', 'NC_DOUBLE', did_v2d_time);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v2d_time'), 'long_name', 'time for 2D velocity climatology');
oct_write_time_attributes(ncid,'v2d_time',cycle,time_unit_att,time_second_unit_att,...
                           calendar_att,insecond,add_cycle);
%
vid_v3d_time = netcdf.defVar(ncid, 'v3d_time', 'NC_DOUBLE', did_v3d_time);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v3d_time'), 'long_name', 'time for 3D velocity climatology');
oct_write_time_attributes(ncid,'v3d_time',cycle,time_unit_att,time_second_unit_att,...
                           calendar_att,insecond,add_cycle);
%
vid_ssh_time = netcdf.defVar(ncid, 'ssh_time', 'NC_DOUBLE', did_ssh_time);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ssh_time'), 'long_name', 'time for sea surface height');
oct_write_time_attributes(ncid,'ssh_time',cycle,time_unit_att,time_second_unit_att,...
                           calendar_att,insecond,add_cycle);
%
vid_zeta_time = netcdf.defVar(ncid, 'zeta_time', 'NC_DOUBLE', did_zeta_time);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta_time'), 'long_name', 'time for sea surface height');
oct_write_time_attributes(ncid,'zeta_time',cycle,time_unit_att,time_second_unit_att,...
                           calendar_att,insecond,add_cycle);
%
if obc(1)==1
%
%   Southern boundary
%
  vid_temp_south = netcdf.defVar(ncid, 'temp_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_temp_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_south'), 'long_name', 'southern boundary potential temperature');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_south'), 'units', 'Celsius');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_south'), 'coordinates', 'lon_rho s_rho temp_time');
%
  vid_salt_south = netcdf.defVar(ncid, 'salt_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_salt_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_south'), 'long_name', 'southern boundary salinity');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_south'), 'units', 'PSU');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_south'), 'coordinates', 'lon_rho s_rho salt_time');
%
  vid_u_south = netcdf.defVar(ncid, 'u_south', 'NC_DOUBLE', [did_xi_u, did_s_rho, did_v3d_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u_south'), 'long_name', 'southern boundary u-momentum component');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u_south'), 'units', 'meter second-1');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u_south'), 'coordinates', 'lon_u s_rho u_time');
%
  vid_v_south = netcdf.defVar(ncid, 'v_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_v3d_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v_south'), 'long_name', 'southern boundary v-momentum component');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v_south'), 'units', 'meter second-1');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v_south'), 'coordinates', 'lon_v s_rho vclm_time');
%
  vid_ubar_south = netcdf.defVar(ncid, 'ubar_south', 'NC_DOUBLE', [did_xi_u, did_v2d_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar_south'), 'long_name', 'southern boundary vertically integrated u-momentum component');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar_south'), 'units', 'meter second-1');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar_south'), 'coordinates', 'lon_u uclm_time');
%
  vid_vbar_south = netcdf.defVar(ncid, 'vbar_south', 'NC_DOUBLE', [did_xi_rho, did_v2d_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar_south'), 'long_name', 'southern boundary vertically integrated v-momentum component');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar_south'), 'units', 'meter second-1');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar_south'), 'coordinates', 'lon_v vclm_time');
%
  vid_zeta_south = netcdf.defVar(ncid, 'zeta_south', 'NC_DOUBLE', [did_xi_rho, did_zeta_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta_south'), 'long_name', 'southern boundary sea surface height');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta_south'), 'units', 'meter');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta_south'), 'coordinates', 'lon_rho zeta_time');
%
end
%
if obc(2)==1
%
%   Eastern boundary
%
  vid_temp_east = netcdf.defVar(ncid, 'temp_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_temp_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_east'), 'long_name', 'eastern boundary potential temperature');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_east'), 'units', 'Celsius');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_east'), 'coordinates', 'lat_rho s_rho temp_time');
%
  vid_salt_east = netcdf.defVar(ncid, 'salt_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_salt_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_east'), 'long_name', 'eastern boundary salinity');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_east'), 'units', 'PSU');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_east'), 'coordinates', 'lat_rho s_rho salt_time');
%
  vid_u_east = netcdf.defVar(ncid, 'u_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_v3d_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u_east'), 'long_name', 'eastern boundary u-momentum component');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u_east'), 'units', 'meter second-1');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u_east'), 'coordinates', 'lat_u s_rho u_time');
%
  vid_v_east = netcdf.defVar(ncid, 'v_east', 'NC_DOUBLE', [did_eta_v, did_s_rho, did_v3d_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v_east'), 'long_name', 'eastern boundary v-momentum component');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v_east'), 'units', 'meter second-1');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v_east'), 'coordinates', 'lat_v s_rho vclm_time');
%
  vid_ubar_east = netcdf.defVar(ncid, 'ubar_east', 'NC_DOUBLE', [did_eta_rho, did_v2d_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar_east'), 'long_name', 'eastern boundary vertically integrated u-momentum component');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar_east'), 'units', 'meter second-1');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar_east'), 'coordinates', 'lat_u uclm_time');
%
  vid_vbar_east = netcdf.defVar(ncid, 'vbar_east', 'NC_DOUBLE', [did_eta_v, did_v2d_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar_east'), 'long_name', 'eastern boundary vertically integrated v-momentum component');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar_east'), 'units', 'meter second-1');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar_east'), 'coordinates', 'lat_v vclm_time');
%
  vid_zeta_east = netcdf.defVar(ncid, 'zeta_east', 'NC_DOUBLE', [did_eta_rho, did_zeta_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta_east'), 'long_name', 'eastern boundary sea surface height');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta_east'), 'units', 'meter');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta_east'), 'coordinates', 'lat_rho zeta_time');
%
end
%
if obc(3)==1
%
%   Northern boundary
%
  vid_temp_north = netcdf.defVar(ncid, 'temp_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_temp_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_north'), 'long_name', 'northern boundary potential temperature');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_north'), 'units', 'Celsius');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_north'), 'coordinates', 'lon_rho s_rho temp_time');
%
  vid_salt_north = netcdf.defVar(ncid, 'salt_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_salt_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_north'), 'long_name', 'northern boundary salinity');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_north'), 'units', 'PSU');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_north'), 'coordinates', 'lon_rho s_rho salt_time');
%
  vid_u_north = netcdf.defVar(ncid, 'u_north', 'NC_DOUBLE', [did_xi_u, did_s_rho, did_v3d_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u_north'), 'long_name', 'northern boundary u-momentum component');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u_north'), 'units', 'meter second-1');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u_north'), 'coordinates', 'lon_u s_rho u_time');
%
  vid_v_north = netcdf.defVar(ncid, 'v_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_v3d_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v_north'), 'long_name', 'northern boundary v-momentum component');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v_north'), 'units', 'meter second-1');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v_north'), 'coordinates', 'lon_v s_rho vclm_time');
%
  vid_ubar_north = netcdf.defVar(ncid, 'ubar_north', 'NC_DOUBLE', [did_xi_u, did_v2d_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar_north'), 'long_name', 'northern boundary vertically integrated u-momentum component');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar_north'), 'units', 'meter second-1');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar_north'), 'coordinates', 'lon_u uclm_time');
%
  vid_vbar_north = netcdf.defVar(ncid, 'vbar_north', 'NC_DOUBLE', [did_xi_rho, did_v2d_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar_north'), 'long_name', 'northern boundary vertically integrated v-momentum component');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar_north'), 'units', 'meter second-1');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar_north'), 'coordinates', 'lon_v vclm_time');

  vid_zeta_north = netcdf.defVar(ncid, 'zeta_north', 'NC_DOUBLE', [did_xi_rho, did_zeta_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta_north'), 'long_name', 'northern boundary sea surface height');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta_north'), 'units', 'meter');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta_north'), 'coordinates', 'lon_rho zeta_time');
%
end
%
if obc(4)==1
%
%   Western boundary
%
  vid_temp_west = netcdf.defVar(ncid, 'temp_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_temp_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_west'), 'long_name', 'western boundary potential temperature');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_west'), 'units', 'Celsius');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_west'), 'coordinates', 'lat_rho s_rho temp_time');
%
  vid_salt_west = netcdf.defVar(ncid, 'salt_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_salt_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_west'), 'long_name', 'western boundary salinity');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_west'), 'units', 'PSU');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_west'), 'coordinates', 'lat_rho s_rho salt_time');
%
  vid_u_west = netcdf.defVar(ncid, 'u_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_v3d_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u_west'), 'long_name', 'western boundary u-momentum component');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u_west'), 'units', 'meter second-1');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u_west'), 'coordinates', 'lat_u s_rho u_time');
%
  vid_v_west = netcdf.defVar(ncid, 'v_west', 'NC_DOUBLE', [did_eta_v, did_s_rho, did_v3d_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v_west'), 'long_name', 'western boundary v-momentum component');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v_west'), 'units', 'meter second-1');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v_west'), 'coordinates', 'lat_v s_rho vclm_time');
%
  vid_ubar_west = netcdf.defVar(ncid, 'ubar_west', 'NC_DOUBLE', [did_eta_rho, did_v2d_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar_west'), 'long_name', 'western boundary vertically integrated u-momentum component');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar_west'), 'units', 'meter second-1');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar_west'), 'coordinates', 'lat_u uclm_time');
%
  vid_vbar_west = netcdf.defVar(ncid, 'vbar_west', 'NC_DOUBLE', [did_eta_v, did_v2d_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar_west'), 'long_name', 'western boundary vertically integrated v-momentum component');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar_west'), 'units', 'meter second-1');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar_west'), 'coordinates', 'lat_v vclm_time');
%
  vid_zeta_west = netcdf.defVar(ncid, 'zeta_west', 'NC_DOUBLE', [did_eta_rho, did_zeta_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta_west'), 'long_name', 'western boundary sea surface height');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta_west'), 'units', 'meter');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta_west'), 'coordinates', 'lat_rho zeta_time');
%
end
%
%
% Create global attributes
%
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'title', title);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'date', date);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'clim_file', bryname);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'grd_file', grdname);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'type', type);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'history', history);
%
% Leave define mode
%
netcdf.endDef(ncid);
%
% Compute S coordinates
%
[s_rho,Cs_rho,s_w,Cs_w] = oct_scoordinate(theta_s,theta_b,N,hc,vtransform);
%disp(['vtransform=',num2str(vtransform)])
%
% Write variables
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'spherical'), 'T');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Vtransform'), int32(vtransform));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Vstretching'), int32(1));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'tstart'), min([min(time) min(time) min(time)]));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'tend'), max([max(time) max(time) max(time)]));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'theta_s'), theta_s);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'theta_b'), theta_b);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Tcline'), hc);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'hc'), hc);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 's_rho'), s_rho);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 's_w'), s_w);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Cs_rho'), Cs_rho);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Cs_w'), Cs_w);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'tclm_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'temp_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'sclm_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'salt_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'uclm_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'vclm_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'v2d_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'v3d_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ssh_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'zeta_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'bry_time'), time);
%
% Initialize the boundary arrays to zero. The array size is taken from the
% variable dimensions (netcdf.inqVar returns them in Fortran order).
%
bnames={'south','east','north','west'};
for ob=1:4
  if obc(ob)==1
    for vn={'u','v','ubar','vbar','zeta','temp','salt'}
      vid=netcdf.inqVarID(ncid,[vn{1},'_',bnames{ob}]);
      [~,~,dids]=netcdf.inqVar(ncid,vid);
      sz=ones(1,max(2,numel(dids)));
      for k=1:numel(dids)
        [~,sz(k)]=netcdf.inqDim(ncid,dids(k));
      end
      netcdf.putVar(ncid,vid,zeros(sz));
    end
  end
end
netcdf.close(ncid);
return


