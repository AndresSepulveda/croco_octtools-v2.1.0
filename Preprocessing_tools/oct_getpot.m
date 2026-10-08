function oct_getpot(clmname,grdname);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get potential temperature of seawater from insitu
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
%  Copyright (c) 2004-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%		
%
% open the grid file  
% 
%
% Read the grid (netcdf.getVar gives (xi,eta): transpose to (eta,xi))
%
ncid = netcdf.open(grdname, 'NC_NOWRITE');
h=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'))).';
netcdf.close(ncid);
[Mp,Lp]=size(h);
%
ncid = netcdf.open(clmname, 'NC_WRITE');
theta_s = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_s')));
theta_b = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_b')));
hc      = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'hc')));
[~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
%
% Number of records: tclm_time for clim files, time for ini files
%
try
  [~,tlen]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'tclm_time'));
catch
  try
    [~,tlen]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'time'));
  catch
    tlen=1;
  end
end
try
  vtransform=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Vtransform')));
catch
  vtransform=1; %Old Vtransform
  disp([' NO VTRANSFORM parameter found'])
  disp([' USE TRANSFORM default value vtransform = 1'])
end
if tlen==0
  tlen=1;
end
P=-1e-4*1025*9.81*oct_zlevs(h,0.*h,theta_s,theta_b,hc,N,'r',vtransform);
vid_t=netcdf.inqVarID(ncid, 'temp');
vid_s=netcdf.inqVarID(ncid, 'salt');
for l=1:tlen
  disp(['   getpot: Time index: ',num2str(l),' of total: ',num2str(tlen)])
  T=permute(double(netcdf.getVar(ncid,vid_t,[0 0 0 l-1],[Lp Mp N 1])),[3 2 1]);
  S=permute(double(netcdf.getVar(ncid,vid_s,[0 0 0 l-1],[Lp Mp N 1])),[3 2 1]);
  netcdf.putVar(ncid, vid_t, [0 0 0 l-1], [Lp Mp N 1], permute(oct_theta(S,T,P),[3 2 1]));
end
netcdf.close(ncid);
return
