function oct_add_Szoo_Lzoo(climfile);
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
theta1=0.2;
theta2=0.3;
%
disp('Add_Szoo_Lzoo: creating variable and attribute')
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
did_szoo_time = netcdf.defDim(ncid, 'szoo_time', tlen);
vid_szoo_time = netcdf.defVar(ncid, 'szoo_time', 'NC_DOUBLE', did_szoo_time);
vid_SZOO = netcdf.defVar(ncid, 'SZOO', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_szoo_time]);
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'szoo_time'), 'long_name', 'time for Small Zooplankton');
oct_write_time_attributes(ncid,'szoo_time',cycle,time_unit_att,time_second_unit_att,...
                       calendar_att,insecond,add_cycle);
%
did_lzoo_time = netcdf.defDim(ncid, 'lzoo_time', tlen);
vid_lzoo_time = netcdf.defVar(ncid, 'lzoo_time', 'NC_DOUBLE', did_lzoo_time);
vid_LZOO = netcdf.defVar(ncid, 'LZOO', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_lzoo_time]);
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lzoo_time'), 'long_name', 'time for Large Zooplankton');
oct_write_time_attributes(ncid,'lzoo_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'SZOO'), 'long_name', 'Small Zooplankton');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'SZOO'), 'units', 'mMol N m-3');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'SZOO'), 'fields', 'SZOO, scalar, series');
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'LZOO'), 'long_name', 'Large Zooplankton');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'LZOO'), 'units', 'mMol N m-3');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'LZOO'), 'fields', 'LZOO, scalar, series');
%
%%endef(nc);
%
% record the time
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'szoo_time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lzoo_time'), time);
%
% loop on time
%
for l=1:tlen
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'SZOO'), l,:,:,:-1, 1, theta1*squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'CHLA'))));  % [conv] 0-based
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'LZOO'), l,:,:,:-1, 1, theta2*squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'CHLA'))));  % [conv] 0-based
end
netcdf.close(ncid);
return

