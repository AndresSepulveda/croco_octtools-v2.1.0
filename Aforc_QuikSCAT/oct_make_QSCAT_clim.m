%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  make_QSCATclm.m
%
%  Interpolate QuikSCAT monthly climdatology data on a CROCO grid 
%  and write into a CROCO netcdf forcing file
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
%  Copyright (c) 2002-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    21-Dec-2006 by Pierrick Penven (new climatology file)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
crocotools_param
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Read in the grid
%
disp(' ')
disp(' Read in the grid...')
ncid = netcdf.open(grdname, 'NC_NOWRITE');
[~,Lp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_rho'));
[~,Mp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_rho'));
lon=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'));
lat=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'));
angle=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'));
result=close(ncid);
cosa = cos(angle);
sina = sin(angle);
%
% Loop on time
%
ncid = netcdf.open(frcname, 'NC_WRITE');
for tindex=1:12
  time=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'sms_time'));
  u=oct_ext_data(QSCAT_clim_file,'taux',tindex,...
             lon,lat,time,Roa,2);
  v=oct_ext_data(QSCAT_clim_file,'tauy',tindex,...
             lon,lat,time,Roa,2);
%
%  Rotation (if not rectangular lon/lat grid)
%
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'sustr'), tindex,:,:-1, 1, oct_rho2u_2d(u.*cosa + v.*sina));  % [conv] 0-based
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'svstr'), tindex,:,:-1, 1, oct_rho2v_2d(v.*cosa - u.*sina));  % [conv] 0-based
end
netcdf.close(ncid);
%
% Make a few plots
%
if makeplot
    disp(' ')
    disp(' Make a few plots...')
    oct_test_forcing(frcname,grdname,'spd',[1 4 7 10],3,coastfileplot)
end
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
