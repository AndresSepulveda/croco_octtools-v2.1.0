function oct_interp_ERA5(ATMO_dir,Y,M,Roa,interp_method,...
                     lon1,lat1,lonwave1,latwave1,mask1,maskwave1,maskwave2,tin,...
		                  nc_frc, ncid_blk,lon,lat,angle,tout, add_waves)
%
% Read the local ERA5 files and perform the space interpolations
%
%  Illig, 2010, from oct_interp_NCEP
%  Updated    January 2016 (E. Cadier and S. Illig)
%  Updated    D.Donoso, G. Cambon. P. Penven (Oct 2021) 
%---------------------------------------------------------------------------------
%
%
% Octave version (Sep-2026): netcdf.* API of the octave-netcdf package.
% ERA5 files (from ERA5_convert.py) store VAR(time,lat,lon), i.e.
% (lon,lat,time) for netcdf.getVar: record tin is read with 0-based
% start [0 0 tin-1] and count [nlon nlat 1], then transposed to (lat,lon).
%
[nlat,nlon]=size(lon1);
%
% 1: Air temperature: Convert from Kelvin to Celsius
%
vname='T2M';
ncid = netcdf.open([ATMO_dir,vname,'_Y',num2str(Y),'M',num2str(sprintf('%02d',M)),'.nc'], 'NC_NOWRITE');
tair=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname), [0 0 tin-1], [nlon nlat 1])).';
netcdf.close(ncid);
tair=oct_get_missing_val(lon1,lat1,mask1.*tair,nan,Roa,nan);
tair=tair-273.15;
tair=interp2(lon1,lat1,tair,lon,lat,interp_method);
%
% 2: Relative humidity: Convert from % to fraction
%
% Get Specific Humidity [Kg/Kg]
%
vname='Q';
ncid = netcdf.open([ATMO_dir,vname,'_Y',num2str(Y),'M',num2str(sprintf('%02d',M)),'.nc'], 'NC_NOWRITE');
shum=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname), [0 0 tin-1], [nlon nlat 1])).';
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
ncid = netcdf.open([ATMO_dir,vname,'_Y',num2str(Y),'M',num2str(sprintf('%02d',M)),'.nc'], 'NC_NOWRITE');
prate=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname), [0 0 tin-1], [nlon nlat 1])).';
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
ncid = netcdf.open([ATMO_dir,vname,'_Y',num2str(Y),'M',num2str(sprintf('%02d',M)),'.nc'], 'NC_NOWRITE');
dswrf=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname), [0 0 tin-1], [nlon nlat 1])).';
netcdf.close(ncid);
radsw=oct_get_missing_val(lon1,lat1,mask1.*dswrf,nan,Roa,nan);
radsw=interp2(lon1,lat1,radsw,lon,lat,interp_method);
radsw(radsw<1.e-10)=0;
%
% 5: Longwave flux:  [W/m^2]
%      CROCO convention: positive upward.
%
%  5.2 get the downward longwave flux [W/m^2]
%
vname='STRD';
ncid = netcdf.open([ATMO_dir,vname,'_Y',num2str(Y),'M',num2str(sprintf('%02d',M)),'.nc'], 'NC_NOWRITE');
dlwrf_in=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname), [0 0 tin-1], [nlon nlat 1])).';
netcdf.close(ncid);
radlw_in=oct_get_missing_val(lon1,lat1,mask1.*dlwrf_in,nan,Roa,nan);
radlw_in=interp2(lon1,lat1,radlw_in,lon,lat,interp_method);
%
% 6: Wind  [m/s]
%
vname='U10M';
ncid = netcdf.open([ATMO_dir,vname,'_Y',num2str(Y),'M',num2str(sprintf('%02d',M)),'.nc'], 'NC_NOWRITE');
uwnd=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname), [0 0 tin-1], [nlon nlat 1])).';
netcdf.close(ncid);
uwnd=oct_get_missing_val(lon1,lat1,mask1.*uwnd,nan,Roa,nan);
uwnd=interp2(lon1,lat1,uwnd,lon,lat,interp_method);
%
vname='V10M';
ncid = netcdf.open([ATMO_dir,vname,'_Y',num2str(Y),'M',num2str(sprintf('%02d',M)),'.nc'], 'NC_NOWRITE');
vwnd=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname), [0 0 tin-1], [nlon nlat 1])).';
netcdf.close(ncid);
vwnd=oct_get_missing_val(lon1,lat1,mask1.*vwnd,nan,Roa,nan);
vwnd=interp2(lon1,lat1,vwnd,lon,lat,interp_method);
%
wspd=sqrt(uwnd.^2+vwnd.^2);
%
% Rotations on the CROCO grid
%
cosa=cos(angle);
sina=sin(angle);
%
% uwnd et vwnd sont aux points 'rho'
%
u10=oct_rho2u_2d(uwnd.*cosa+vwnd.*sina);
v10=oct_rho2v_2d(vwnd.*cosa-uwnd.*sina);
%
if add_waves == 1
%
% Waves ...
%
  [nlat,nlon]=size(lonwave1);
%
% 8: Surface wave amplitude: convert from SWH to Amp
%
vname='SWH';
ncid = netcdf.open([ATMO_dir,vname,'_Y',num2str(Y),'M',num2str(sprintf('%02d',M)),'.nc'], 'NC_NOWRITE');
awave=1/(2*sqrt(2))*double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname), [0 0 tin-1], [nlon nlat 1])).';
netcdf.close(ncid);
  awave=oct_get_missing_val(lonwave1,latwave1,maskwave1.*awave,nan,Roa,nan);
  awave=interp2(lonwave1,latwave1,awave,lon,lat,interp_method);
%
% 9: Surface wave direction
%
vname='MWD';
ncid = netcdf.open([ATMO_dir,vname,'_Y',num2str(Y),'M',num2str(sprintf('%02d',M)),'.nc'], 'NC_NOWRITE');
dwave=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname), [0 0 tin-1], [nlon nlat 1])).';
netcdf.close(ncid);
  dwave=oct_get_missing_val(lonwave1,latwave1,maskwave1.*dwave,nan,Roa,nan);
  dwave=interp2(lonwave1,latwave1,dwave,lon,lat,interp_method);
%
% 10: Surface wave peak period
%
vname='PP1D';
ncid = netcdf.open([ATMO_dir,vname,'_Y',num2str(Y),'M',num2str(sprintf('%02d',M)),'.nc'], 'NC_NOWRITE');
pwave=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname), [0 0 tin-1], [nlon nlat 1])).';
netcdf.close(ncid);
  pwave=oct_get_missing_val(lonwave1,latwave1,maskwave2.*pwave,nan,Roa,nan);
  pwave=interp2(lonwave1,latwave1,pwave,lon,lat,interp_method);
end
%
% Fill the CROCO files: record tout, 0-based start and count in Fortran
% order [xi eta time]; (eta,xi) fields are transposed with .'
%
[Mp,Lp]=size(lon);
if ~isempty(nc_frc)
  if add_waves == 1
    netcdf.putVar(nc_frc, netcdf.inqVarID(nc_frc, 'Awave'), [0 0 tout-1], [Lp Mp 1], awave.');
    netcdf.putVar(nc_frc, netcdf.inqVarID(nc_frc, 'Dwave'), [0 0 tout-1], [Lp Mp 1], dwave.');
    netcdf.putVar(nc_frc, netcdf.inqVarID(nc_frc, 'Pwave'), [0 0 tout-1], [Lp Mp 1], pwave.');
  end
end
if ~isempty(ncid_blk)
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'tair'),     [0 0 tout-1], [Lp Mp 1],   tair.');
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'rhum'),     [0 0 tout-1], [Lp Mp 1],   rhum.');
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'prate'),    [0 0 tout-1], [Lp Mp 1],   prate.');
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'wspd'),     [0 0 tout-1], [Lp Mp 1],   wspd.');
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'radlw_in'), [0 0 tout-1], [Lp Mp 1],   radlw_in.');
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'radsw'),    [0 0 tout-1], [Lp Mp 1],   radsw.');
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'uwnd'),     [0 0 tout-1], [Lp-1 Mp 1], u10.');
  netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'vwnd'),     [0 0 tout-1], [Lp Mp-1 1], v10.');
end
%
end
