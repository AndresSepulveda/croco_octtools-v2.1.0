function oct_interp_CFSR(NCEP_dir,Y,M,Roa,interp_method,...
                     lon1,lat1,mask1,tin,...
		     nc_frc,ncid_blk,lon,lat,angle,tout)

%
% Read the local NCEP files and perform the interpolations
%
%
% 1: Air temperature: Convert from Kelvin to Celsius
%
vname='Temperature_height_above_ground';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
tair=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
tair=oct_get_missing_val(lon1,lat1,mask1.*tair,nan,Roa,nan);
tair=tair-273.15;
tair=interp2(lon1,lat1,tair,lon,lat,interp_method);
%
% 2: Relative humidity: Convert from % to fraction
%
% Get Specific Humidity [Kg/Kg]
%
vname='Specific_humidity';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
shum=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
shum=oct_get_missing_val(lon1,lat1,mask1.*shum,nan,Roa,nan);
shum=interp2(lon1,lat1,shum,lon,lat,interp_method);
%
% computes specific humidity at saturation (Tetens  formula)
% (see air_sea tools, fonction qsat)
%
rhum=shum./qsat(tair);
%
% 3: Precipitation rate: Convert from [kg/m^2/s] to cm/day
%
vname='Precipitation_rate';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
prate=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
prate=oct_get_missing_val(lon1,lat1,mask1.*prate,nan,Roa,nan);
prate=prate*0.1*(24.*60.*60.0);
prate=interp2(lon1,lat1,prate,lon,lat,interp_method);
prate(abs(prate)<1.e-4)=0;
%
% 4: Net shortwave flux: [W/m^2]
%      CROCO convention: downward = positive
%
% Downward solar shortwave
%
vname='Downward_Short-Wave_Rad_Flux_surface';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
dswrf=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
dswrf=oct_get_missing_val(lon1,lat1,mask1.*dswrf,nan,Roa,nan);
%  
% Upward solar shortwave
% 
vname='Upward_Short-Wave_Rad_Flux_surface';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
uswrf=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
uswrf=oct_get_missing_val(lon1,lat1,mask1.*uswrf,nan,Roa,nan);
%  
%  Net solar shortwave radiation  
%
radsw=dswrf - uswrf;
%----------------------------------------------------  
% GC le 31 03 2009
%  radsw is NET solar shortwave radiation
%  no more downward only solar radiation
% GC  bug fix by F. Marin IRD/LEGOS
%-----------------------------------------------------
radsw=interp2(lon1,lat1,radsw,lon,lat,interp_method);
radsw(radsw<1.e-10)=0;
%
% 5: Net outgoing Longwave flux:  [W/m^2]
%      CROCO convention: positive upward (opposite to nswrf !!!!)
%
% Get the net longwave flux [W/m^2]
%
%  5.1 get the downward longwave flux [W/m^2]
%
vname='Downward_Long-Wave_Rad_Flux';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
dlwrf=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
dlwrf=oct_get_missing_val(lon1,lat1,mask1.*dlwrf,nan,Roa,nan);
%
%  5.2 get the upward longwave flux [W/m^2]
%
vname='Upward_Long-Wave_Rad_Flux_surface';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
ulwrf=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
ulwrf=oct_get_missing_val(lon1,lat1,mask1.*ulwrf,nan,Roa,nan);
%  
%  Net longwave flux 
%
radlw=interp2(lon1,lat1,ulwrf-dlwrf,lon,lat,interp_method);
%
% get the  downward longwave heat flux  
%
radlw_in=interp2(lon1,lat1,dlwrf,lon,lat,interp_method);
%
% 6: Wind & Wind stress [m/s]
%
vname='U-component_of_wind';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
uwnd=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
uwnd=oct_get_missing_val(lon1,lat1,mask1.*uwnd,nan,Roa,nan);
uwnd=interp2(lon1,lat1,uwnd,lon,lat,interp_method);
%
vname='V-component_of_wind';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
vwnd=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
vwnd=oct_get_missing_val(lon1,lat1,mask1.*vwnd,nan,Roa,nan);
vwnd=interp2(lon1,lat1,vwnd,lon,lat,interp_method);
%
% Compute the stress
%
wspd=sqrt(uwnd.^2+vwnd.^2);
[Cd,uu]=cdnlp(wspd,10.);
rhoa=air_dens(tair,rhum*100);
tx=Cd.*rhoa.*uwnd.*wspd;
ty=Cd.*rhoa.*vwnd.*wspd;
%
% Rotations on the CROCO grid
%
cosa=cos(angle);
sina=sin(angle);
%
sustr=oct_rho2u_2d(tx.*cosa+ty.*sina);
svstr=oct_rho2v_2d(ty.*cosa-tx.*sina);
%
% uwnd et vwnd sont aux points 'rho'
%
u10=oct_rho2u_2d(uwnd.*cosa+vwnd.*sina);
v10=oct_rho2v_2d(vwnd.*cosa-uwnd.*sina);
%
% Fill the CROCO files
%
if ~isempty(nc_frc)
  nc_frc{'sustr'}(tout,:,:)=sustr;
  nc_frc{'svstr'}(tout,:,:)=svstr;
end
if ~isempty(ncid_blk)
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'tair'), tout,:,:-1, 1, tair);  % [conv] 0-based
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'rhum'), tout,:,:-1, 1, rhum);  % [conv] 0-based
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'prate'), tout,:,:-1, 1, prate);  % [conv] 0-based
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'wspd'), tout,:,:-1, 1, wspd);  % [conv] 0-based
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'radlw'), tout,:,:-1, 1, radlw);  % [conv] 0-based
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'radlw_in'), tout,:,:-1, 1, radlw_in);  % [conv] 0-based
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'radsw'), tout,:,:-1, 1, radsw);  % [conv] 0-based
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'uwnd'), tout,:,:-1, 1, u10);  % [conv] 0-based
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'vwnd'), tout,:,:-1, 1, v10);  % [conv] 0-based
%  nc_blk{'sustr'}(tout,:,:)=sustr;
%  nc_blk{'svstr'}(tout,:,:)=svstr;
end


