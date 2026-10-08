function oct_add_ini_zoo(inifile);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function oct_add_ini_zoo(inifile);
%
%  Add zooplancton (mMol N m-3) in a CROCO climatology file.
%  take the chlorophyll (mg C) from the initial file and
%  multiply by the ratio chlorophyll / phytoplancton derived
%  from previous simulations (Gruber et al., 2005)
%
%  zoo = 0.2 * chla

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
%  Updated in 2005 by Patrick Marchesiello
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
oct_theta=0.2;
%
disp('Add_ini_zoo: creating variable and attribute')
%
% open the initial file  
% 
ncid = netcdf.open(inifile, 'NC_WRITE');
time= netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'scrum_time'));
tlen=length(time);
%%redef(nc);
vid_ZOO = netcdf.defVar(ncid, 'ZOO', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ZOO'), 'long_name', 'Zooplankton');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ZOO'), 'units', 'mMol N m-3');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ZOO'), 'fields', 'ZOO, scalar, series');
%%endef(nc);
%
% loop on time
%
for l=1:tlen
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ZOO'), l,:,:,:-1, 1, oct_theta*squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'CHLA'))));  % [conv] 0-based
end
netcdf.close(ncid);
return
