function oct_add_zoo(climfile);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function oct_add_zoo(climfile);
%
%  Add zooplancton (mMol N m-3) in a CROCO climatology file.
%  take the chlorophyll (mg C) from the climatology file and
%  multiply by the ratio chlorophyll / phytoplancton derived
%  from previous simulations (Gruber et al., 2005)
%
%  zoo = 0.2 * chla
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
%  Updated    2005 by Patrick Marchesiello (IRD)
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
%
oct_theta=0.2;
%
disp('Add_zoo: creating variable and attribute')
%
% open the clim file  
% 
ncid = netcdf.open(climfile, 'NC_WRITE');
time= netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'chla_time'));
cycle= netcdf.getAtt(ncid, netcdf.inqVarID(ncid, 'chla_time'), 'cycle_length');
tlen=length(time);
%%redef(nc);
did_zoo_time = netcdf.defDim(ncid, 'zoo_time', tlen);
vid_zoo_time = netcdf.defVar(ncid, 'zoo_time', 'NC_DOUBLE', did_zoo_time);
vid_ZOO = netcdf.defVar(ncid, 'ZOO', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_zoo_time]);
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'zoo_time'), 'long_name', 'time for zooplankton');
oct_write_time_attributes(ncid,'zoo_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ZOO'), 'long_name', 'Zooplankton');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ZOO'), 'units', 'mMol N m-3');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ZOO'), 'fields', 'ZOO, scalar, series');
%
%%endef(nc);
%
% record the time
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'zoo_time'), time);
%
% loop on time
%
for l=1:tlen
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ZOO'), l,:,:,:-1, 1, oct_theta*squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'CHLA'))));  % [conv] 0-based
end
netcdf.close(ncid);
return
