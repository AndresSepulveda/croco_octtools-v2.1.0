function oct_add_Sphyto_Lphyto(climfile);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function add_phyto(climfile);
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
%  Updated    Oct-2026 : Octave version (octave-netcdf, netcdf.* API)
%  Andres Sepulveda 2026 - Octave adaptations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% options for write_time_attributes
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
ncid=netcdf.open(climfile,'NC_WRITE');
vid=netcdf.inqVarID(ncid,'chla_time');
time=double(netcdf.getVar(ncid,vid));
time=time(:);
cycle=double(netcdf.getAtt(ncid,vid,'cycle_length'));
tlen=length(time);
[~,N]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'s_rho'));
[~,Mp]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'eta_rho'));
[~,Lp]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'xi_rho'));
did_s=netcdf.inqDimID(ncid,'s_rho');
did_eta=netcdf.inqDimID(ncid,'eta_rho');
did_xi=netcdf.inqDimID(ncid,'xi_rho');
%
netcdf.reDef(ncid);
%
did_t=oct_defdim(ncid,'sphyto_time',tlen);
vid_t=oct_defvar(ncid,'sphyto_time','double',did_t);
vid_v=oct_defvar(ncid,'SPHYTO','double',[did_xi did_eta did_s did_t]);
%
netcdf.putAtt(ncid,vid_t,'long_name','time for Small Phytoplankton');
oct_write_time_attributes(ncid,'sphyto_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);
%
did_t=oct_defdim(ncid,'lphyto_time',tlen);
vid_t=oct_defvar(ncid,'lphyto_time','double',did_t);
vid_v=oct_defvar(ncid,'LPHYTO','double',[did_xi did_eta did_s did_t]);
%
netcdf.putAtt(ncid,vid_t,'long_name','time for Large Phytoplankton');
oct_write_time_attributes(ncid,'lphyto_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);
%
vid_v=netcdf.inqVarID(ncid,'SPHYTO');
netcdf.putAtt(ncid,vid_v,'long_name','Small Phytoplankton');
netcdf.putAtt(ncid,vid_v,'units','mMol N m-3');
netcdf.putAtt(ncid,vid_v,'fields','SPHYTO, scalar, series');
%
vid_v=netcdf.inqVarID(ncid,'LPHYTO');
netcdf.putAtt(ncid,vid_v,'long_name','Large Phytoplankton');
netcdf.putAtt(ncid,vid_v,'units','mMol N m-3');
netcdf.putAtt(ncid,vid_v,'fields','LPHYTO, scalar, series');
%
netcdf.endDef(ncid);
%
% record the time
%
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'sphyto_time'),0,tlen,time);
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lphyto_time'),0,tlen,time);
%
% loop on time
%
vid_chla=netcdf.inqVarID(ncid,'CHLA');
for l=1:tlen
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  % CHLA(l,:,:,:) in Fortran order [xi eta s time] (no permutation needed: copy)
  chla=double(netcdf.getVar(ncid,vid_chla,[0 0 0 l-1],[Lp Mp N 1]));
  netcdf.putVar(ncid,netcdf.inqVarID(ncid,'SPHYTO'),[0 0 0 l-1],[Lp Mp N 1],theta1*chla);
  netcdf.putVar(ncid,netcdf.inqVarID(ncid,'LPHYTO'),[0 0 0 l-1],[Lp Mp N 1],theta2*chla);
end
netcdf.close(ncid);
return
