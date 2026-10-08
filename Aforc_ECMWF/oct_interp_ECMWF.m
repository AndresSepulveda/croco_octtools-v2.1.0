function oct_interp_ECMWF(NCEP_dir,Y,M,Roa,interp_method,...
                     lon1,lat1,mask1,tin,...
		     nc_frc,ncid_blk,lon,lat,angle,tout)
%
% Read the local ECMWF files and perform the space interpolations
%
%  Illig, 2010, from oct_interp_NCEP
%  Updated    January 2016 (E. Cadier and S. Illig)
%---------------------------------------------------------------------------------
%
% 1: Air temperature: Convert from Kelvin to Celsius
%
vname='T2M';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
tair=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
tair=oct_get_missing_val(lon1,lat1,mask1.*tair,nan,Roa,nan);
tair=tair-273.15;
tair=interp2(lon1,lat1,tair,lon,lat,interp_method);
%
%
% 2: Relative humidity: Convert from % to fraction
%
% Get Specific Humidity [Kg/Kg]
%
vname='Q';
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
vname='TP';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
prate=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
prate=oct_get_missing_val(lon1,lat1,mask1.*prate,nan,Roa,nan);
prate=prate*0.1*(24.*60.*60.0);
prate=interp2(lon1,lat1,prate,lon,lat,interp_method);
prate(prate<1.e-4)=0;
%
% 4: Shortwave flux: [W/m^2]
%      CROCO convention: downward = positive
%
%  Solar shortwave
%
vname='SSR';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
dswrf=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
radsw=oct_get_missing_val(lon1,lat1,mask1.*dswrf,nan,Roa,nan);
radsw=interp2(lon1,lat1,radsw,lon,lat,interp_method);
radsw(radsw<1.e-10)=0;
%
%
% 5: Longwave flux:  [W/m^2]
%      CROCO convention: positive upward.
%
%  5.1 Get the net longwave flux [W/m^2]
%
vname='STR';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
dlwrf=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
radlw=oct_get_missing_val(lon1,lat1,mask1.*dlwrf,nan,Roa,nan);
radlw=interp2(lon1,lat1,radlw,lon,lat,interp_method);
%
%  5.2 get the downwrad longwave flux [W/m^2]
%
vname='STRD';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
dlwrf_in=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
radlw_in=oct_get_missing_val(lon1,lat1,mask1.*dlwrf_in,nan,Roa,nan);
radlw_in=interp2(lon1,lat1,radlw_in,lon,lat,interp_method);
%
%
% 6: Wind  [m/s]
%
vname='U10M';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
uwnd=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
uwnd=oct_get_missing_val(lon1,lat1,mask1.*uwnd,nan,Roa,nan);
uwnd=interp2(lon1,lat1,uwnd,lon,lat,interp_method);
%
%
vname='V10M';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
vwnd=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
vwnd=oct_get_missing_val(lon1,lat1,mask1.*vwnd,nan,Roa,nan);
vwnd=interp2(lon1,lat1,vwnd,lon,lat,interp_method);
%
wspd=sqrt(uwnd.^2+vwnd.^2);
%
%
% 7: Wind & Wind stress [m/s]
%
vname='EWSS';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
tx=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
tx=oct_get_missing_val(lon1,lat1,mask1.*tx,nan,0,nan);
tx=interp2(lon1,lat1,tx,lon,lat,interp_method);
%
vname='NSSS';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
ty=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
ty=oct_get_missing_val(lon1,lat1,mask1.*ty,nan,0,nan);
ty=interp2(lon1,lat1,ty,lon,lat,interp_method);
%
% Compute the stress
%
%[Cd,uu]=cdnlp(wspd,10.);
%rhoa=air_dens(tair,rhum*100);
%tx2=Cd.*rhoa.*uwnd.*wspd;
%ty2=Cd.*rhoa.*vwnd.*wspd;

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
% 8: Surface wave amplitude: convert from SWH to Amp
%
vname='SWH';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
awave=1/(2*sqrt(2))*squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
awave=oct_get_missing_val(lon1,lat1,mask1.*awave,nan,Roa,nan);
awave=interp2(lon1,lat1,awave,lon,lat,interp_method);
%
% 9: Surface wave direction
%
vname='MWD';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
dwave=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
dwave=oct_get_missing_val(lon1,lat1,mask1.*dwave,nan,Roa,nan);
dwave=interp2(lon1,lat1,dwave,lon,lat,interp_method);
%
% 10: Surface wave peak period
%
vname='PP1D';
ncid = netcdf.open([NCEP_dir,vname,'_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
pwave=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname)));
netcdf.close(ncid);
pwave=oct_get_missing_val(lon1,lat1,mask1.*pwave,nan,Roa,nan);
pwave=interp2(lon1,lat1,pwave,lon,lat,interp_method);

%
% Fill the CROCO files
%
if ~isempty(nc_frc)
  nc_frc{'sustr'}(tout,:,:)=sustr;
  nc_frc{'svstr'}(tout,:,:)=svstr;
  nc_frc{'Awave'}(tout,:,:)=awave;
  nc_frc{'Dwave'}(tout,:,:)=dwave;
  nc_frc{'Pwave'}(tout,:,:)=pwave;
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
  %nc_blk{'sustr'}(tout,:,:)=sustr;
  %nc_blk{'svstr'}(tout,:,:)=svstr;
end


