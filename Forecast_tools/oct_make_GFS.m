%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Create and fill frc and bulk files with GFS data.
% for a forecast run
%
% Description  : 3 hourly forecasts / 0.25 deg (00z/06z/12z/18z) 
%
% The on-line reference to GFS is at
% http://nomad3.ncep.noaa.gov/
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
%  Copyright (c) 2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    9-Sep-2006 by Pierrick Penven
%  Updated    20-Aug-2008 by Matthieu Caillaud & P. Marchesiello
%  Updated    12-Feb-2016 by P. Marchesiello
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Common parameters
%
tic
crocotools_param
%
makeplot = 0;
it=2;
%
frc_prefix=[frc_prefix,'_GFS_'];
blk_prefix=[blk_prefix,'_GFS_'];
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end of user input  parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% time (in matlab time)
%
today=floor(now);
%
% date in 'Yorig' time
%
rundate=datenum(today)-datenum(Yorig,1,1);
%
% GFS data name
%
gfs_name=[FRCST_dir,'GFS_',num2str(rundate),'.nc'];
%
%
if level==0
  nc_suffix='.nc';
else
  nc_suffix=['.nc.',num2str(level)];
  grdname=[grdname,'.',num2str(level)];
end
%
% Get the model grid
%
ncid = netcdf.open(grdname, 'NC_NOWRITE');
lon=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'));
lat=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'));
angle=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'));
h=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'));
netcdf.close(ncid);
cosa=cos(angle);
sina=sin(angle);
%
% Extract data over the internet
%
if Download_data==1
%
% Get the model limits
%
  lonmin=min(min(lon));
  lonmax=max(max(lon));
  latmin=min(min(lat));
  latmax=max(max(lat));
%
% Download data with DODS (the download matlab routine depends on the OGCM)
% 
  disp('Download data...')
  disp('--> NB: if you receive this message during download : ')
  disp('  " syntax error, unexpected WORD_WORD, expecting SCAN_ATTR or SCAN_DATASET or SCAN_ERROR ..."')
  disp('  " you maybe reach the rate limit authorized, there is a ban on your IP due to an “Over Rate Limit” violation, try to wait more than 10 minutes before to do it again')  
  disp([' '])
  oct_download_GFS(today,lonmin,lonmax,latmin,latmax,FRCST_dir,Yorig,it)
%
end
%
% Get the GFS grid 
% 
ncid=netcdf.open(gfs_name,'NC_NOWRITE');
lon1=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon'));
lat1=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat'));
time=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time'));
mask=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask'));
tlen=length(time);
%
% bulk and forcing files
%
blkname=[blk_prefix,num2str(rundate),nc_suffix];
disp(['Create a new bulk file: ' blkname])
oct_create_bulk(blkname,grdname,CROCO_title,time,0);
ncid_blk = netcdf.open(blkname, 'NC_WRITE');
frcname=[frc_prefix,num2str(rundate),nc_suffix];
disp(['Create a new forcing file: ' frcname])
oct_create_forcing(frcname,grdname,CROCO_title,...
                       time,0,0,...
                       0,0,0,...
  	               0,0,0,0,0,0)
ncid_frc = netcdf.open(frcname, 'NC_WRITE');
%
% Loop on time
%
missval=nan;
default=nan;
for l=1:tlen
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'tair')));
  if mean(mean(isnan(var)~=1))
    var=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'tair'), l,:,:-1, 1, interp2(lon1,lat1,var,lon,lat,interp_method));  % [conv] 0-based
  else
    var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'tair'))); 
    var=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'tair'), l,:,:-1, 1, interp2(lon1,lat1,var,lon,lat,interp_method));  % [conv] 0-based
  end

  var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'rhum')));
  if mean(mean(isnan(var)~=1))
    var=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'rhum'), l,:,:-1, 1, interp2(lon1,lat1,var,lon,lat,interp_method));  % [conv] 0-based
  else
    var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'rhum')));
    var=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'rhum'), l,:,:-1, 1, interp2(lon1,lat1,var,lon,lat,interp_method));  % [conv] 0-based
  end
  
  var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'prate')));
  if mean(mean(isnan(var)~=1))
    var=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'prate'), l,:,:-1, 1, interp2(lon1,lat1,var,lon,lat,interp_method));  % [conv] 0-based
  else
    var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'prate')));
    var=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'prate'), l,:,:-1, 1, interp2(lon1,lat1,var,lon,lat,interp_method));  % [conv] 0-based
  end
  
  var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'wspd')));
  if mean(mean(isnan(var)~=1))
    var=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'wspd'), l,:,:-1, 1, interp2(lon1,lat1,var,lon,lat,interp_method));  % [conv] 0-based
  else
    var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'wspd')));
    var=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'wspd'), l,:,:-1, 1, interp2(lon1,lat1,var,lon,lat,interp_method));  % [conv] 0-based
  end
  
  %Zonal wind speed
  var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'uwnd')));
  if mean(mean(isnan(var)~=1))
    uwnd=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    uwnd=interp2(lon1,lat1,uwnd,lon,lat,interp_method);
  else
    var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'uwnd')));
    uwnd=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    uwnd=interp2(lon1,lat1,uwnd,lon,lat,interp_method);
  end
  
  %Meridian wind speed
  var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'vwnd')));
  if mean(mean(isnan(var)~=1))
    vwnd=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    vwnd=interp2(lon1,lat1,vwnd,lon,lat,interp_method);
  else
    var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'vwnd')));
    vwnd=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    vwnd=interp2(lon1,lat1,vwnd,lon,lat,interp_method);
  end
  
  netcdf.putVar(ncid_frc, netcdf.inqVarID(ncid_frc, 'uwnd'), l,:,:-1, 1, oct_rho2u_2d(uwnd.*cosa+vwnd.*sina));  % [conv] 0-based
  netcdf.putVar(ncid_frc, netcdf.inqVarID(ncid_frc, 'vwnd'), l,:,:-1, 1, oct_rho2v_2d(vwnd.*cosa-uwnd.*sina));  % [conv] 0-based
  
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'uwnd'), l,:,:-1, 1, oct_rho2u_2d(uwnd.*cosa+vwnd.*sina));  % [conv] 0-based
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'vwnd'), l,:,:-1, 1, oct_rho2v_2d(vwnd.*cosa-uwnd.*sina));  % [conv] 0-based
  
  %Net longwave flux
  var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'radlw')));
  if mean(mean(isnan(var)~=1))
    var=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'radlw'), l,:,:-1, 1, interp2(lon1,lat1,var,lon,lat,interp_method));  % [conv] 0-based
  else
    var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'radlw')));
    var=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'radlw'), l,:,:-1, 1, interp2(lon1,lat1,var,lon,lat,interp_method));  % [conv] 0-based
  end
  
  %Downward longwave flux
  var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'radlw_in')));
  if mean(mean(isnan(var)~=1))
    var=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'radlw_in'), l,:,:-1, 1, interp2(lon1,lat1,var,lon,lat,interp_method));  % [conv] 0-based
  else
    var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'radlw_in')));
    var=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'radlw_in'), l,:,:-1, 1, interp2(lon1,lat1,var,lon,lat,interp_method));  % [conv] 0-based
  end
   
  %Net solar short wave radiation
  var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'radsw')));
  if mean(mean(isnan(var)~=1))
    var=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'radsw'), l,:,:-1, 1, interp2(lon1,lat1,var,lon,lat,interp_method));  % [conv] 0-based
  else
    var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'radsw')));
    var=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'radsw'), l,:,:-1, 1, interp2(lon1,lat1,var,lon,lat,interp_method));  % [conv] 0-based
  end
  
  var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'tx')));
  if mean(mean(isnan(var)~=1))
    tx=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    tx=interp2(lon1,lat1,tx,lon,lat,interp_method);
  else
    var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'tx')));
    tx=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    tx=interp2(lon1,lat1,tx,lon,lat,interp_method);
  end
  
  var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'ty')));
  if mean(mean(isnan(var)~=1))
    ty=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    ty=interp2(lon1,lat1,ty,lon,lat,interp_method);
  else
    var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'ty')));
    ty=oct_get_missing_val(lon1,lat1,var,missval,Roa,default);
    ty=interp2(lon1,lat1,ty,lon,lat,interp_method);
  end
  
  netcdf.putVar(ncid_frc, netcdf.inqVarID(ncid_frc, 'sustr'), l,:,:-1, 1, oct_rho2u_2d(tx.*cosa+ty.*sina));  % [conv] 0-based
  netcdf.putVar(ncid_frc, netcdf.inqVarID(ncid_frc, 'svstr'), l,:,:-1, 1, oct_rho2v_2d(ty.*cosa-tx.*sina));  % [conv] 0-based
  
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'sustr'), l,:,:-1, 1, oct_rho2u_2d(tx.*cosa+ty.*sina));  % [conv] 0-based
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'svstr'), l,:,:-1, 1, oct_rho2v_2d(ty.*cosa-tx.*sina));  % [conv] 0-based
end
% 
netcdf.close(ncid_frc);
netcdf.close(ncid_blk);
netcdf.close(ncid);
%---------------------------------------------------------------
% Make a few plots
%---------------------------------------------------------------
if makeplot==1
  disp(' ')
  disp(' Make a few plots...')
  slides=[10 12 14 16]; 
  oct_test_forcing(blkname,grdname,'tair',slides,3,coastfileplot)
  figure
  oct_test_forcing(blkname,grdname,'rhum',slides,3,coastfileplot)
  figure
  oct_test_forcing(blkname,grdname,'prate',slides,3,coastfileplot)
  figure
  oct_test_forcing(blkname,grdname,'wspd',slides,3,coastfileplot)
  figure
  oct_test_forcing(blkname,grdname,'radlw',slides,3,coastfileplot)
  figure
  oct_test_forcing(blkname,grdname,'radlw_in',slides,3,coastfileplot)
  figure
  oct_test_forcing(blkname,grdname,'sustr',slides,3,coastfileplot)
  figure
  oct_test_forcing(blkname,grdname,'svstr',slides,3,coastfileplot)
  figure
  oct_test_forcing(blkname,grdname,'radsw',slides,3,coastfileplot)
end

toc

