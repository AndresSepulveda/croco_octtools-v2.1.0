function oct_add_ini_Sphyto_Lphyto(inifile);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function add_ini_phyto(inifile);
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
%  Updated    Oct-2026 : Octave version (octave-netcdf, netcdf.* API)
%  Andres Sepulveda 2026 - Octave adaptations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
theta1=0.1;
theta2=0.4;
%
disp('Add_ini_Sphyto_Lphyto: creating variable and attribute')
%
% open the initial file  
% 
ncid=netcdf.open(inifile,'NC_WRITE');
time=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'scrum_time')));
tlen=length(time);
[~,N]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'s_rho'));
[~,Mp]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'eta_rho'));
[~,Lp]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'xi_rho'));
dims4 = [netcdf.inqDimID(ncid,'xi_rho') netcdf.inqDimID(ncid,'eta_rho') ...
         netcdf.inqDimID(ncid,'s_rho') netcdf.inqDimID(ncid,'time')];
%
netcdf.reDef(ncid);
%
vid=oct_defvar(ncid,'SPHYTO','double',dims4);
netcdf.putAtt(ncid,vid,'long_name','Small Phytoplankton');
netcdf.putAtt(ncid,vid,'units','mMol N m-3');
netcdf.putAtt(ncid,vid,'fields','SPHYTO, scalar, series');
%
vid=oct_defvar(ncid,'LPHYTO','double',dims4);
netcdf.putAtt(ncid,vid,'long_name','Large Phytoplankton');
netcdf.putAtt(ncid,vid,'units','mMol N m-3');
netcdf.putAtt(ncid,vid,'fields','LPHYTO, scalar, series');
%
netcdf.endDef(ncid);
%
% loop on time
%
vid_chla=netcdf.inqVarID(ncid,'CHLA');
for l=1:tlen
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  % CHLA(l,:,:,:) in Fortran order [xi eta s time] (elementwise: no permutation)
  chla=double(netcdf.getVar(ncid,vid_chla,[0 0 0 l-1],[Lp Mp N 1]));
  netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SPHYTO'),[0 0 0 l-1],[Lp Mp N 1],theta1*chla);
  netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LPHYTO'),[0 0 0 l-1],[Lp Mp N 1],theta2*chla);
end
netcdf.close(ncid);
return
