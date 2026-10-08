function oct_add_ini_Sphyto_Lphyto(inifile);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function oct_add_ini_phyto(inifile);
%
%  Add phytoplancton (mMol N m-3)  in a CROCO initial file.
%  take the chlorophyll (mg C) from the initial file and
%  multiply by the ratio chlorophyll / phytoplancton derived
%  from previous simulations.
%
%  phyto = theta * chla
%
%  input:
%    
%    inifile      : croco initial file to process (netcdf)
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
%
theta1=0.1;
theta2=0.4;
%
disp('Add_ini_Sphyto_Lphyto: creating variable and attribute')
%
% open the initial file  
% 
ncid = netcdf.open(inifile, 'NC_WRITE');
time= netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'scrum_time'));
tlen=length(time);
%
%redef(nc);
%
vid_SPHYTO = netcdf.defVar(ncid, 'SPHYTO', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'SPHYTO'), 'long_name', 'Small Phytoplankton');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'SPHYTO'), 'units', 'mMol N m-3');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'SPHYTO'), 'fields', 'SPHYTO, scalar, series');
%
vid_LPHYTO = netcdf.defVar(ncid, 'LPHYTO', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'LPHYTO'), 'long_name', 'Large Phytoplankton');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'LPHYTO'), 'units', 'mMol N m-3');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'LPHYTO'), 'fields', 'LPHYTO, scalar, series');
%
%endef(nc);
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

