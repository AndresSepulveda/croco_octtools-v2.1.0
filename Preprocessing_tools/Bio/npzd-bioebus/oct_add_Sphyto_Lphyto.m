function oct_add_Sphyto_Lphyto(climfile);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function oct_add_phyto(climfile);
%
%  Add phytoplancton (mMol N m-3)  in a CROCO climatology file.
%  take the chlorophyll (mg C) from the climatology file and
%  multiply by the ratio chlorophyll / phytoplancton derived
%  from previous simulations.
%
%  phyto = 0.5 * chla
%
%  input:
%    
%    climfile      : croco climatology file to process (netcdf)
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
%  Updated 14/10/14 Andres Sepulveda (DGEO) Octave compatibility
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% options for oct_write_time_attributes
insecond = 0 ;
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
theta1=0.1;
theta2=0.4;
%
disp('Add_Sphyto_Lphyto: creating variable and attribute')
%
% open the clim file  
% 
ncid = netcdf.open(climfile, 'NC_WRITE');
time= netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'chla_time'));
cycle= netcdf.getAtt(ncid, netcdf.inqVarID(ncid, 'chla_time'), 'cycle_length');
tlen=length(time);
%
%%redef(nc);
%
did_sphyto_time = netcdf.defDim(ncid, 'sphyto_time', tlen);
vid_sphyto_time = netcdf.defVar(ncid, 'sphyto_time', 'NC_DOUBLE', did_sphyto_time);
vid_SPHYTO = netcdf.defVar(ncid, 'SPHYTO', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_sphyto_time]);
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'sphyto_time'), 'long_name', 'time for Small Phytoplankton');
oct_write_time_attributes(ncid,'sphyto_time',cycle,time_unit_att,time_second_unit_att,...
                    calendar_att,insecond,add_cycle);
%
did_lphyto_time = netcdf.defDim(ncid, 'lphyto_time', tlen);
vid_lphyto_time = netcdf.defVar(ncid, 'lphyto_time', 'NC_DOUBLE', did_lphyto_time);
vid_LPHYTO = netcdf.defVar(ncid, 'LPHYTO', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_lphyto_time]);
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lphyto_time'), 'long_name', 'time for Large Phytoplankton');
oct_write_time_attributes(ncid,'lphyto_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'SPHYTO'), 'long_name', 'Small Phytoplankton');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'SPHYTO'), 'units', 'mMol N m-3');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'SPHYTO'), 'fields', 'SPHYTO, scalar, series');
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'LPHYTO'), 'long_name', 'Large Phytoplankton');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'LPHYTO'), 'units', 'mMol N m-3');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'LPHYTO'), 'fields', 'LPHYTO, scalar, series');
%
%%endef(nc);
%
% record the time
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'sphyto_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lphyto_time'), time);
%
% loop on time
%
for l=1:tlen
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'SPHYTO'), l,:,:,:-1, 1, theta1*squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'CHLA'))));  % [conv] 0-based
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'LPHYTO'), l,:,:,:-1, 1, theta2*squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'CHLA'))));  % [conv] 0-based
end
netcdf.close(ncid);
return

