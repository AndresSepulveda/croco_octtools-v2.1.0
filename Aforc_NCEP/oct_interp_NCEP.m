function oct_interp_NCEP(NCEP_dir,Y,M,Roa,interp_method,...
                     lon1,lat1,mask1,tin,...
		     nc_frc,ncid_blk,lon,lat,angle,tout,Get_My_Data)

%
% Read the local NCEP files and perform the interpolations
%
% Pierrick 2005
% Menkes 2007
% Update, Feb-2008, J. Lefevre to use Nomads3 server
% Update, March-2009, G. Cambon & F. Marin Compute net solar short wave
% Update, October 2009, G.Cambon
%---------------------------------------------------------------------------------
%
% 1: Air temperature: Convert from Kelvin to Celsius
%
if Get_My_Data ~=1
  vname='tmp2m';
else
  vname='air';
end
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
if Get_My_Data ~=1
  vname='spfh2m';
else
  vname='shum';
end
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
if Get_My_Data ~=1
  vname='pratesfc';
else
  vname='prate';
end
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
if Get_My_Data ~=1
  vname='dswrfsfc';
else
  vname='dswrf';
end
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
dswrf=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
dswrf=oct_get_missing_val(lon1,lat1,mask1.*dswrf,nan,Roa,nan);
%  
% Upward solar shortwave
% 
if Get_My_Data ~=1
  vname='uswrfsfc';
else
  vname='uswrf';
end
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
if Get_My_Data ~=1
  vname='dlwrfsfc';
else
  vname='dlwrf';
end
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
dlwrf=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
dlwrf=oct_get_missing_val(lon1,lat1,mask1.*dlwrf,nan,Roa,nan);
%
%  5.2 get the upward longwave flux [W/m^2]
%
if Get_My_Data ~=1
  vname='ulwrfsfc';
else
  vname='ulwrf';
end
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
if Get_My_Data ~=1
  vname='ugrd10m';
else
  vname='uwnd';
end
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
uwnd=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
uwnd=oct_get_missing_val(lon1,lat1,mask1.*uwnd,nan,Roa,nan);
uwnd=interp2(lon1,lat1,uwnd,lon,lat,interp_method);
%
if Get_My_Data ~=1
  vname='vgrd10m';
else
  vname='vwnd';
end
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


