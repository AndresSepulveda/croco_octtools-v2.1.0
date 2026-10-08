%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO bulk file
%
%  Extrapole and interpole surface data to get surface boundary
%  conditions for CROCO (forcing netcdf file)
%
%  Data input format (netcdf):
%     taux(T, Y, X)
%     T : time [Months]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%  Data source : IRI/LDEO Climate Data Library 
%                (Atlas of Surface Marine Data 1994)
%
%    http://ingrid.ldgo.columbia.edu/
%    http://iridl.ldeo.columbia.edu/SOURCES/.DASILVA/
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
%  Copyright (c) 2005 by Patrick Marchesiello and Pierrick Penven
%  e-mail:Patrick.Marchesiello@ird.fr  
%
%  Updated    2006/09/29 by Pierrick Penven (add a test for the plots)
%  Updated    2006/10/02 by Pierrick Penven (add the 'tmp file' for 
%                                            oct_ext_data)
%  Updated    2006/10/05 by Pierrick Penven (add coads_dir)
%  Updated    25-Oct-2006 by Pierrick Penven (uwnd and vwnd)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
crocotools_param
%
%  Load air-sea parameters
%
as_consts
%
%    sat      : Surface atmospheric temperature
%    airdens  : Surface atmospheric density
%    w3       : Wind speed at 10 meters
%    qsea     : Sea level specific humidity
%    rh       : relative humidity
%    precip   : precipitation rate
%    shortrad : Short wave radiation 
%    longrade : Outgoing long wave radiation
%
sat_file     =[coads_dir,'sat.cdf'];
sat_name     ='sat';
sst_file     =[coads_dir,'sst.cdf'];
sst_name     ='sst';
airdens_file =[coads_dir,'airdens.cdf'];
airdens_name ='airdens';
u3_file      =[coads_dir,'u3.cdf'];
u3_name      ='u3';
v3_file      =[coads_dir,'v3.cdf'];
v3_name      ='v3';
w3_file      =[coads_dir,'w3.cdf'];
w3_name      ='w3';
qsea_file    =[coads_dir,'qsea.cdf'];
qsea_name    ='qsea';
rh_file      =[coads_dir,'rh.cdf'];
rh_name      ='rh';
precip_file  =[coads_dir,'precip.cdf'];
precip_name  ='precip';
srf_file     =[coads_dir,'shortrad.cdf'];
srf_name     ='shortrad';
lrf_file     =[coads_dir,'longrad.cdf'];
lrf_name     ='longrad';
taux_file      =[coads_dir,'taux.cdf'];
taux_name      ='taux';
tauy_file      =[coads_dir,'tauy.cdf'];
tauy_name      ='tauy';

%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Title
%
disp(' ')
disp(CROCO_title)
%
% Read in the grid
%
disp(' ')
disp(' Read in the grid...')
ncid = netcdf.open(grdname, 'NC_NOWRITE');
[~,Lp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_rho'));
[~,Mp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_rho'));
% netcdf.getVar returns (xi,eta): transpose to the CROCO (eta,xi) layout
lon=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'))).';
lat=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'))).';
lonu=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_u'))).';
latu=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_u'))).';
lonv=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_v'))).';
latv=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_v'))).';
angle=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'))).';
netcdf.close(ncid);
cosa=cos(angle);
sina=sin(angle);
%
% Create the forcing file
%
disp(' ')
disp(' Create the bulk forcing file...')
oct_create_bulk(blkname,grdname,CROCO_title,coads_time,coads_cycle);
%
% Loop on time
%
%
% Records: netcdf.putVar(ncid,varid,start,count,data) with 0-based start
% and count in Fortran order [xi eta time]; (eta,xi) fields transposed.
%
ncid = netcdf.open(blkname, 'NC_WRITE');
t_all=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'bulk_time')));
rr=[Lp Mp 1];    % count for rho-point records
ru=[Lp-1 Mp 1];  % count for u-point records
rv=[Lp Mp-1 1];  % count for v-point records
for tindex=1:length(coads_time)
  time=t_all(tindex);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'tair'), [0 0 tindex-1], rr, ...
                oct_ext_data(sat_file,sat_name,tindex,lon,lat,time,Roa,1).');
end
for tindex=1:length(coads_time)
  time=t_all(tindex);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'rhum'), [0 0 tindex-1], rr, ...
                0.01*oct_ext_data(rh_file,rh_name,tindex,lon,lat,time,Roa,1).');
end
for tindex=1:length(coads_time)
  time=t_all(tindex);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'prate'), [0 0 tindex-1], rr, ...
                0.8*oct_ext_data(precip_file,precip_name,tindex,lon,lat,time,Roa,1).');
end
for tindex=1:length(coads_time)
  time=t_all(tindex);
  radlw=oct_ext_data(lrf_file,lrf_name,tindex,lon,lat,time,Roa,1);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'radlw'), [0 0 tindex-1], rr, radlw.');
  sst= oct_ext_data(sst_file,sst_name,tindex,lon,lat,time,Roa,1);
  lwup=emiss_lw.*sigmaSB.*((sst+CtoK).^4);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'radlw_in'), [0 0 tindex-1], rr, -(radlw-lwup).');
end
for tindex=1:length(coads_time)
  time=t_all(tindex);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'radsw'), [0 0 tindex-1], rr, ...
                oct_ext_data(srf_file,srf_name,tindex,lon,lat,time,Roa,1).');
end
for tindex=1:length(coads_time)
  time=t_all(tindex);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'wspd'), [0 0 tindex-1], rr, ...
                oct_ext_data(w3_file,w3_name,tindex,lon,lat,time,Roa,1).');
end
for tindex=1:length(coads_time)
  time=t_all(tindex);
  uwnd = oct_ext_data(u3_file,u3_name,tindex,lon,lat,time,Roa,1);
  vwnd = oct_ext_data(v3_file,v3_name,tindex,lon,lat,time,Roa,1);
  u10=oct_rho2u_2d(uwnd.*cosa+vwnd.*sina);
  v10=oct_rho2v_2d(vwnd.*cosa-uwnd.*sina);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'uwnd'), [0 0 tindex-1], ru, u10.');
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'vwnd'), [0 0 tindex-1], rv, v10.');
end
for tindex=1:length(coads_time)
  time=t_all(tindex);
  tx=oct_ext_data(taux_file,taux_name,tindex,lon,lat,time,Roa,2);
  ty=oct_ext_data(tauy_file,tauy_name,tindex,lon,lat,time,Roa,2);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'sustr'), [0 0 tindex-1], ru, ...
                oct_rho2u_2d(tx.*cosa + ty.*sina).');
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'svstr'), [0 0 tindex-1], rv, ...
                oct_rho2v_2d(ty.*cosa - tx.*sina).');
end
netcdf.close(ncid);
%
% Make a few plots
%
if makeplot==1
  disp(' ')
  disp(' Make a few plots...')
  oct_test_forcing(blkname,grdname,'tair',[1 4 7 10],3,coastfileplot)
  figure
  oct_test_forcing(blkname,grdname,'rhum',[1 4 7 10],3,coastfileplot)
  figure
  oct_test_forcing(blkname,grdname,'prate',[1 4 7 10],3,coastfileplot)
  figure
  oct_test_forcing(blkname,grdname,'uwnd',[1 4 7 10],3,coastfileplot)
  figure
  oct_test_forcing(blkname,grdname,'vwnd',[1 4 7 10],3,coastfileplot)
  figure
  oct_test_forcing(blkname,grdname,'wspd',[1 4 7 10],3,coastfileplot)
  figure
  oct_test_forcing(blkname,grdname,'radlw',[1 4 7 10],3,coastfileplot)
  figure
  oct_test_forcing(blkname,grdname,'radlw_in',[1 4 7 10],3,coastfileplot)
  figure
  oct_test_forcing(blkname,grdname,'radsw',[1 4 7 10],3,coastfileplot)
end
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
