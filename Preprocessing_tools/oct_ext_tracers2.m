function oct_ext_tracers2(oaname,month_datafile,seas_datafile,...
                      dataname,vname,tname);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%  pierrick 2002
%
%  Ext tracers in a CROCO climatology file
%  take monthly data for the upper levels and 
%  seasonnal data for the
%  lower levels
%
%  input:
%    
%    oaname      : croco oa file to process (netcdf)
%    month_datafile : regular longitude - latitude - z seasonal data 
%                    file used for the upper levels  (netcdf)
%    seas_datafile  : regular longitude - latitude - z annual data 
%                    file used for the lower levels  (netcdf)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
%
% set the value of ro (oa decorrelation scale [m]) 
% and default (value if no data)
%
ro=1e8;
default=NaN;
disp([' Ext tracers: ro = ',num2str(ro/1000),...
      ' km - default value = ',num2str(default)])
%
% Read in the datafile 
%
ncidmonth = netcdf.open(month_datafile, 'NC_NOWRITE');
x=netcdf.getVar(ncidmonth, netcdf.inqVarID(ncidmonth, 'X'));
y=netcdf.getVar(ncidmonth, netcdf.inqVarID(ncidmonth, 'Y'));
zmonth=-netcdf.getVar(ncidmonth, netcdf.inqVarID(ncidmonth, 'Z'));
t=netcdf.getVar(ncidmonth, netcdf.inqVarID(ncidmonth, 'T'));
tlen=length(t);
Nzmonth=length(zmonth);
%
% Open the grid file  
% 
ng_id = netcdf.open(oaname, 'NC_NOWRITE');
lon=netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lon_rho'));
lon(lon<0)=lon(lon<0)+360;
lat=netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lat_rho'));
netcdf.close(ng_id);
[M,L]=size(lon);
dl=0.5;
minlon=min(min(lon))-dl;
maxlon=max(max(lon))+dl;
minlat=min(min(lat))-dl;
maxlat=max(max(lat))+dl;
imin=max(find(x<=minlon));
imax=min(find(x>=maxlon));
jmin=max(find(y<=minlat));
jmax=min(find(y>=maxlat));
x=x(imin:imax);
y=y(jmin:jmax);
%
% Open the OA file  
% 
ncid = netcdf.open(oaname, 'NC_WRITE');
Z=-netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Z'));
Nz=length(Z);
%
% Check the time
%
tclim=netcdf.getVar(ncid, netcdf.inqVarID(ncid, tname)); 
t=t*30; % if time in month in the dataset !!!
if (tclim~=t)
  disp('Warning !! time mismatch')
  disp('  tclim = ')
  tclim
  disp('  t = ')
  t
end
%
% Read the seasonal dataset
%
if Nz > Nzmonth
  ncidseas = netcdf.open(seas_datafile, 'NC_NOWRITE');
  zseas=-netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'Z'));
  if (Z~=zseas)
    error('Vertical levels mismatch')
  end
%
% Interpole the seasonal dataset on the horizontal CROCO grid
%
  disp(' Ext tracers: horizontal interpolation of the annual data')
  if zmonth~=zseas(1:length(zmonth)) 
    error('vertical levels dont match')
  end
  datazgrid=zeros(Nz,M,L);
  missval=netcdf.getAtt(ncidseas, netcdf.inqVarID(ncidseas, dataname), 'missing_value');
  for k=Nzmonth+1:Nz
    data=squeeze(netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, dataname)));
    data=oct_get_missing_val(x,y,data,missval,ro,default);
    datazgrid(k,:,:)=interp2(x,y,data,lon,lat,'cubic');
  end
  netcdf.close(ncidseas);
end
%
% interpole the seasonal dataset on the horizontal croco grid
%
disp([' Ext tracers: horizontal interpolation of the seasonal data'])
%
% loop on time
%
missval=netcdf.getAtt(ncidmonth, netcdf.inqVarID(ncidmonth, dataname), 'missing_value');
for l=1:tlen
%for l=1:1
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  if Nz <= Nzmonth
    datazgrid=zeros(Nz,M,L);
  end
  for k=1:min([Nz Nzmonth])
    data=squeeze(netcdf.getVar(ncidmonth, netcdf.inqVarID(ncidmonth, dataname)));
    data=oct_get_missing_val(x,y,data,missval,ro,default);
    datazgrid(k,:,:)=interp2(x,y,data,lon,lat,'cubic');
  end
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, vname), l,:,:,:-1, 1, datazgrid);  % [conv] 0-based
end
netcdf.close(ncid);
netcdf.close(ncidmonth);
return
