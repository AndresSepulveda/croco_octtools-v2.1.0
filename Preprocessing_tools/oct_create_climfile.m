function oct_create_climfile(clmname,grdname,title,...
                        theta_s,theta_b,hc,N,...
                        time,cycle,clobber,vtransform, Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% function oct_create_climfile(clmname,grdname,title,...
%                          theta_s,theta_b,hc,N,...
%                          time,cycle,clobber);
%
%   This function create the header of a Netcdf climatology
%   file.
%
%   Input:
%
%   clmname      Netcdf climatology file name (character string).
%   grdname      Netcdf grid file name (character string).
%   theta_s      S-coordinate surface control parameter.(Real)
%   theta_b      S-coordinate bottom control parameter.(Real)
%   hc           Width (m) of surface or bottom boundary layer
%                where higher vertical resolution is required
%                during stretching.(Real)
%   N            Number of vertical levels.(Integer)
%   time        Temperature climatology time.(vector)
%   time        Salinity climatology time.(vector)
%   time        Velocity climatology time.(vector)
%   cycle        Length (days) for cycling the climatology.(Real)
%   clobber      Switch to allow or not writing over an existing
%                file.(character string)
%
%   Output
%
%   nc       Output netcdf object.
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
disp([' Creating the file : ',clmname])
disp(' ')
if nargin < 11
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
    vtransform = 1;
end
disp([' VTRANSFORM = ',num2str(vtransform)])
%
% options for oct_write_time_attributes
insecond = 0;
add_cycle = 1; 
%
% Initialize Yorig if not provided
if ~exist('Yorig', 'var') ,  Yorig = [] ; , end
%
% Get time attributes
[time_unit_att,time_second_unit_att,calendar_att]=...
    oct_get_time_attributes(Yorig);
%
%
%  Read the grid file
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
%  Create the climatology file
%
type = 'CLIMATOLOGY file' ;
history = 'CROCO' ;
if strcmpi(clobber,'clobber')
  ncid = netcdf.create(clmname, 'NC_CLOBBER');
else
  ncid = netcdf.create(clmname, 'NC_NOCLOBBER');
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
%  Create variables
%
vid_spherical = netcdf.defVar(ncid, 'spherical', 'NC_CHAR', did_one);
vid_Vtransform = netcdf.defVar(ncid, 'Vtransform', 'NC_INT', did_one);
vid_Vstretching = netcdf.defVar(ncid, 'Vstretching', 'NC_INT', did_one);
vid_tstart = netcdf.defVar(ncid, 'tstart', 'NC_DOUBLE', did_one);
vid_tend = netcdf.defVar(ncid, 'tend', 'NC_DOUBLE', did_one);
vid_theta_s = netcdf.defVar(ncid, 'theta_s', 'NC_DOUBLE', did_one);
vid_theta_b = netcdf.defVar(ncid, 'theta_b', 'NC_DOUBLE', did_one);
vid_Tcline = netcdf.defVar(ncid, 'Tcline', 'NC_DOUBLE', did_one);
vid_hc = netcdf.defVar(ncid, 'hc', 'NC_DOUBLE', did_one);
vid_s_rho = netcdf.defVar(ncid, 's_rho', 'NC_DOUBLE', did_s_rho);
vid_s_w = netcdf.defVar(ncid, 's_w', 'NC_DOUBLE', did_s_w);
vid_Cs_rho = netcdf.defVar(ncid, 'Cs_rho', 'NC_DOUBLE', did_s_rho);
vid_Cs_w = netcdf.defVar(ncid, 'Cs_w', 'NC_DOUBLE', did_s_w);
vid_tclm_time = netcdf.defVar(ncid, 'tclm_time', 'NC_DOUBLE', did_tclm_time);
vid_temp_time = netcdf.defVar(ncid, 'temp_time', 'NC_DOUBLE', did_temp_time);
vid_sclm_time = netcdf.defVar(ncid, 'sclm_time', 'NC_DOUBLE', did_sclm_time);
vid_salt_time = netcdf.defVar(ncid, 'salt_time', 'NC_DOUBLE', did_salt_time);
vid_uclm_time = netcdf.defVar(ncid, 'uclm_time', 'NC_DOUBLE', did_uclm_time);
vid_vclm_time = netcdf.defVar(ncid, 'vclm_time', 'NC_DOUBLE', did_vclm_time);
vid_v2d_time = netcdf.defVar(ncid, 'v2d_time', 'NC_DOUBLE', did_v2d_time);
vid_v3d_time = netcdf.defVar(ncid, 'v3d_time', 'NC_DOUBLE', did_v3d_time);
vid_ssh_time = netcdf.defVar(ncid, 'ssh_time', 'NC_DOUBLE', did_ssh_time);
vid_zeta_time = netcdf.defVar(ncid, 'zeta_time', 'NC_DOUBLE', did_zeta_time);
vid_temp = netcdf.defVar(ncid, 'temp', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_tclm_time]);
vid_salt = netcdf.defVar(ncid, 'salt', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_sclm_time]);
vid_u = netcdf.defVar(ncid, 'u', 'NC_DOUBLE', [did_xi_u, did_eta_u, did_s_rho, did_uclm_time]);
vid_v = netcdf.defVar(ncid, 'v', 'NC_DOUBLE', [did_xi_v, did_eta_v, did_s_rho, did_vclm_time]);
vid_ubar = netcdf.defVar(ncid, 'ubar', 'NC_DOUBLE', [did_xi_u, did_eta_u, did_uclm_time]);
vid_vbar = netcdf.defVar(ncid, 'vbar', 'NC_DOUBLE', [did_xi_v, did_eta_v, did_vclm_time]);
vid_SSH = netcdf.defVar(ncid, 'SSH', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_ssh_time]);
vid_zeta = netcdf.defVar(ncid, 'zeta', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_zeta_time]);
%
%  Create attributes
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Vtransform'), 'long_name', 'vertical terrain-following transformation equation');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Vstretching'), 'long_name', 'vertical terrain-following stretching function');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'spherical'), 'long_name', 'grid type logical switch');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'spherical'), 'flag_values', 'T, F');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'spherical'), 'flag_meanings', 'spherical Cartesian');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'tstart'), 'long_name', 'start processing day');
oct_write_time_attributes(ncid,'tstart',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,0,0);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'tend'), 'long_name', 'end processing day');
oct_write_time_attributes(ncid,'tend',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,0,0);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'theta_s'), 'long_name', 'S-coordinate surface control parameter');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'theta_s'), 'units', 'nondimensional');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'theta_b'), 'long_name', 'S-coordinate bottom control parameter');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'theta_b'), 'units', 'nondimensional');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Tcline'), 'long_name', 'S-coordinate surface/bottom layer width');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Tcline'), 'units', 'meter');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'hc'), 'long_name', 'S-coordinate parameter, critical depth');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'hc'), 'units', 'meter');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'long_name', 'S-coordinate at RHO-points');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'valid_min', -1.);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'valid_max', 0.);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'positive', 'up');
if (vtransform ==1)
        netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'standard_name', 'ocean_s_coordinate_g1');
elseif (vtransform ==2)
        netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'standard_name', 'ocean_s_coordinate_g2');
end
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 's_rho'), 'formula_terms', 's: s_rho C: Cs_rho eta: zeta depth: h depth_c: hc');
%
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
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_rho'), 'long_name', 'S-coordinate stretching curves at RHO-points');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_rho'), 'units', 'nondimensional');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_rho'), 'valid_min', -1);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_rho'), 'valid_max', 0);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_w'), 'long_name', 'S-coordinate stretching curves at W-points');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_w'), 'units', 'nondimensional');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_w'), 'valid_min', -1);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Cs_w'), 'valid_max', 0);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'tclm_time'), 'long_name', 'time for temperature climatology');
oct_write_time_attributes(ncid,'tclm_time',cycle,time_unit_att,time_second_unit_att,...
                        calendar_att,insecond,add_cycle);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp_time'), 'long_name', 'time for temperature climatology');
oct_write_time_attributes(ncid,'temp_time',cycle,time_unit_att,time_second_unit_att,...
                        calendar_att,insecond,add_cycle);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'sclm_time'), 'long_name', 'time for salinity climatology');
oct_write_time_attributes(ncid,'sclm_time',cycle,time_unit_att,time_second_unit_att,...
                        calendar_att,insecond,add_cycle);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt_time'), 'long_name', 'time for salinity climatology');
oct_write_time_attributes(ncid,'salt_time',cycle,time_unit_att,time_second_unit_att,...
                        calendar_att,insecond,add_cycle);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'uclm_time'), 'long_name', 'time climatological u');
oct_write_time_attributes(ncid,'uclm_time',cycle,time_unit_att,time_second_unit_att,...
                        calendar_att,insecond,add_cycle);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vclm_time'), 'long_name', 'time climatological v');
oct_write_time_attributes(ncid,'vclm_time',cycle,time_unit_att,time_second_unit_att,...
                        calendar_att,insecond,add_cycle);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v2d_time'), 'long_name', 'time for 2D velocity climatology');
oct_write_time_attributes(ncid,'v2d_time',cycle,time_unit_att,time_second_unit_att,...
                        calendar_att,insecond,add_cycle);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v3d_time'), 'long_name', 'time for 3D velocity climatology');
oct_write_time_attributes(ncid,'v3d_time',cycle,time_unit_att,time_second_unit_att,...
                        calendar_att,insecond,add_cycle);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ssh_time'), 'long_name', 'time for sea surface height');
oct_write_time_attributes(ncid,'ssh_time',cycle,time_unit_att,time_second_unit_att,...
                        calendar_att,insecond,add_cycle);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta_time'), 'long_name', 'time for sea surface height');
oct_write_time_attributes(ncid,'zeta_time',cycle,time_unit_att,time_second_unit_att,...
                        calendar_att,insecond,add_cycle);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp'), 'long_name', 'potential temperature');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp'), 'units', 'Celsius');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp'), 'time', 'temp_time');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp'), 'coordinates', 'lon_rho lat_rho s_rho temp_time');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt'), 'long_name', 'salinity');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt'), 'units', 'PSU');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt'), 'time', 'salt_time');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt'), 'coordinates', 'lon_rho lat_rho s_rho salt_time');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u'), 'long_name', 'u-momentum component');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u'), 'units', 'meter second-1');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u'), 'time', 'uclm_time');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u'), 'coordinates', 'lon_u lat_u s_rho u_time');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v'), 'long_name', 'v-momentum component');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v'), 'units', 'meter second-1');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v'), 'time', 'vclm_time');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v'), 'coordinates', 'lon_v lat_v s_rho vclm_time');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar'), 'long_name', 'vertically integrated u-momentum component');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar'), 'units', 'meter second-1');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar'), 'time', 'uclm_time');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar'), 'coordinates', 'lon_u lat_u uclm_time');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar'), 'long_name', 'vertically integrated v-momentum component');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar'), 'units', 'meter second-1');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar'), 'time', 'vclm_time');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar'), 'coordinates', 'lon_v lat_v vclm_time');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'SSH'), 'long_name', 'sea surface height');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'SSH'), 'units', 'meter');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'SSH'), 'time', 'zeta_time');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'SSH'), 'coordinates', 'lon_rho lat_rho zeta_time');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta'), 'long_name', 'sea surface height');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta'), 'units', 'meter');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta'), 'time', 'zeta_time');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta'), 'coordinates', 'lon_rho lat_rho zeta_time');
%
% Create global attributes
%
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'title', title);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'date', date);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'clim_file', clmname);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'grd_file', grdname);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'type', type);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'history', history);
%
% Leave define mode
%
netcdf.endDef(ncid);
%
% Set S-Curves in domain [-1 < sc < 0] at vertical W- and RHO-points.
%
[s_rho,Cs_rho,s_w,Cs_w] = oct_scoordinate(theta_s,theta_b,N,hc,vtransform);
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
%
% Initialize the fields to zero (arrays in Fortran order: xi,eta,s,time)
%
nt=length(time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'u'),    zeros(L,Mp,N,nt));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'v'),    zeros(Lp,M,N,nt));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ubar'), zeros(L,Mp,nt));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'vbar'), zeros(Lp,M,nt));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'SSH'),  zeros(Lp,Mp,nt));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'zeta'), zeros(Lp,Mp,nt));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'temp'), zeros(Lp,Mp,N,nt));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'salt'), zeros(Lp,Mp,N,nt));
netcdf.close(ncid);
return


