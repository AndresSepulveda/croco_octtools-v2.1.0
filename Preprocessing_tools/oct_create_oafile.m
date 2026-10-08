function oct_create_oafile(oaname,grdname,title,Z,...
                       time,cycle,clobber,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function nc=oct_create_oafile(oaname,grdname,title,Z,...
%                       time,cycle,clobber);
%
%   This function create the header of a Netcdf OA
%   file. ie an intermediate file on a Z-grid.
%
%   Input: 
% 
%   oaname       Netcdf OA file name (character string).
%   grdname      Netcdf grid file name (character string).
%   Z            Vertical levels.(Vector)  
%   time         OA time.(Vector) 
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
disp([' Creating the file : ',oaname])
disp(' ')
%
% options for oct_write_time_attributes
insecond = 0;
add_cycle = 1 ; 
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
lonr=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'))).';
latr=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'))).';
lonu=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_u'))).';
latu=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_u'))).';
lonv=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_v'))).';
latv=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_v'))).';
netcdf.close(ncid);
[Mp,Lp]=size(lonr);
L=Lp-1;
M=Mp-1;
%
%  Create the climatology file
%
type = 'OA file' ; 
history = 'CROCO' ;
if strcmpi(clobber,'clobber')
  ncid = netcdf.create(oaname, 'NC_CLOBBER');
else
  ncid = netcdf.create(oaname, 'NC_NOCLOBBER');
end
%
%  Create dimensions
%
did_xi_rho = netcdf.defDim(ncid, 'xi_rho', Lp);
did_eta_rho = netcdf.defDim(ncid, 'eta_rho', Mp);
did_xi_u = netcdf.defDim(ncid, 'xi_u', L);
did_eta_v = netcdf.defDim(ncid, 'eta_v', M);
did_Z = netcdf.defDim(ncid, 'Z', length(Z));
did_tracer = netcdf.defDim(ncid, 'tracer', 2);
did_tclm_time = netcdf.defDim(ncid, 'tclm_time', length(time));
did_sclm_time = netcdf.defDim(ncid, 'sclm_time', length(time));
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
vid_lon_rho = netcdf.defVar(ncid, 'lon_rho', 'NC_DOUBLE', [did_xi_rho, did_eta_rho]);
vid_lat_rho = netcdf.defVar(ncid, 'lat_rho', 'NC_DOUBLE', [did_xi_rho, did_eta_rho]);
vid_lon_u = netcdf.defVar(ncid, 'lon_u', 'NC_DOUBLE', [did_xi_u, did_eta_rho]);
vid_lat_u = netcdf.defVar(ncid, 'lat_u', 'NC_DOUBLE', [did_xi_u, did_eta_rho]);
vid_lon_v = netcdf.defVar(ncid, 'lon_v', 'NC_DOUBLE', [did_xi_rho, did_eta_v]);
vid_lat_v = netcdf.defVar(ncid, 'lat_v', 'NC_DOUBLE', [did_xi_rho, did_eta_v]);
vid_Z = netcdf.defVar(ncid, 'Z', 'NC_DOUBLE', did_Z);
vid_tclm_time = netcdf.defVar(ncid, 'tclm_time', 'NC_DOUBLE', did_tclm_time);
vid_sclm_time = netcdf.defVar(ncid, 'sclm_time', 'NC_DOUBLE', did_sclm_time);
vid_uclm_time = netcdf.defVar(ncid, 'uclm_time', 'NC_DOUBLE', did_uclm_time);
vid_vclm_time = netcdf.defVar(ncid, 'vclm_time', 'NC_DOUBLE', did_vclm_time);
vid_v2d_time = netcdf.defVar(ncid, 'v2d_time', 'NC_DOUBLE', did_v2d_time);
vid_v3d_time = netcdf.defVar(ncid, 'v3d_time', 'NC_DOUBLE', did_v3d_time);
vid_ssh_time = netcdf.defVar(ncid, 'ssh_time', 'NC_DOUBLE', did_ssh_time);
vid_zeta_time = netcdf.defVar(ncid, 'zeta_time', 'NC_DOUBLE', did_zeta_time);
vid_temp = netcdf.defVar(ncid, 'temp', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_Z, did_tclm_time]);
vid_salt = netcdf.defVar(ncid, 'salt', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_Z, did_sclm_time]);
vid_u = netcdf.defVar(ncid, 'u', 'NC_DOUBLE', [did_xi_u, did_eta_rho, did_Z, did_uclm_time]);
vid_v = netcdf.defVar(ncid, 'v', 'NC_DOUBLE', [did_xi_rho, did_eta_v, did_Z, did_vclm_time]);
vid_ubar = netcdf.defVar(ncid, 'ubar', 'NC_DOUBLE', [did_xi_u, did_eta_rho, did_uclm_time]);
vid_vbar = netcdf.defVar(ncid, 'vbar', 'NC_DOUBLE', [did_xi_rho, did_eta_v, did_vclm_time]);
vid_SSH = netcdf.defVar(ncid, 'SSH', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_ssh_time]);
vid_zeta = netcdf.defVar(ncid, 'zeta', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_zeta_time]);
%
%  Create attributes
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lon_rho'), 'long_name', 'longitude of RHO-points');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lon_rho'), 'units', 'degree_east');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lat_rho'), 'latg_name', 'latitude of RHO-points');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lat_rho'), 'units', 'degree_north');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lon_u'), 'long_name', 'longitude of U-points');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lon_u'), 'units', 'degree_east');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lat_u'), 'latg_name', 'latitude of U-points');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lat_u'), 'units', 'degree_north');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lon_v'), 'long_name', 'longitude of V-points');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lon_v'), 'units', 'degree_east');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lat_v'), 'latg_name', 'latitude of V-points');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lat_v'), 'units', 'degree_north');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Z'), 'long_name', 'Depth');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Z'), 'units', 'm');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'tclm_time'), 'long_name', 'time for temperature climatology');
oct_write_time_attributes(ncid,'tclm_time',cycle,time_unit_att,time_second_unit_att,...
                    calendar_att,insecond,add_cycle);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'sclm_time'), 'long_name', 'time for salinity climatology');
oct_write_time_attributes(ncid,'sclm_time',cycle,time_unit_att,time_second_unit_att,...
                        calendar_att,insecond,add_cycle);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'uclm_time'), 'long_name', 'time for u climatology');
oct_write_time_attributes(ncid,'uclm_time',cycle,time_unit_att,time_second_unit_att,...
                    calendar_att,insecond,add_cycle);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vclm_time'), 'long_name', 'time for v climatology');
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
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta_time'), 'long_name', 'time for zeta climatology');
oct_write_time_attributes(ncid,'zeta_time',cycle,time_unit_att,time_second_unit_att,...
                        calendar_att,insecond,add_cycle);
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp'), 'long_name', 'potential temperature');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'temp'), 'units', 'Celsius');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt'), 'long_name', 'salinity');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'salt'), 'units', 'PSU');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u'), 'long_name', 'u-momentum component');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'u'), 'units', 'meter second-1');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v'), 'long_name', 'v-momentum component');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'v'), 'units', 'meter second-1');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar'), 'long_name', 'vertically integrated u-momentum component');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ubar'), 'units', 'meter second-1');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar'), 'long_name', 'vertically integrated v-momentum component');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'vbar'), 'units', 'meter second-1');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'SSH'), 'long_name', 'sea surface height');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'SSH'), 'units', 'meter');
%
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta'), 'long_name', 'sea surface height');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zeta'), 'units', 'meter');
%
% Create global attributes
%
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'title', title);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'date', date);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'grd_file', grdname);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'type', type);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'history', history);
%
% Leave define mode
%
netcdf.endDef(ncid);
%
% Write variables
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Z'), Z);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'), lonr.');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'), latr.');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon_u'), lonu.');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat_u'), latu.');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon_v'), lonv.');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat_v'), latv.');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'tclm_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'sclm_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'uclm_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'vclm_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'v2d_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'v3d_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ssh_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'zeta_time'), time);
nt=length(time); NZ=length(Z);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'u'),    zeros(L,Mp,NZ,nt));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'v'),    zeros(Lp,M,NZ,nt));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ubar'), zeros(L,Mp,nt));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'vbar'), zeros(Lp,M,nt));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'SSH'),  zeros(Lp,Mp,nt));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'zeta'), zeros(Lp,Mp,nt));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'temp'), zeros(Lp,Mp,NZ,nt));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'salt'), zeros(Lp,Mp,NZ,nt));
netcdf.close(ncid);
return


