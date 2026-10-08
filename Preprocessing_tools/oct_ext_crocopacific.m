function oct_ext_crocopacific(oaname,datafile,dataname,vname,tname,type);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%  pierrick 2003
%
%  Extrpolations in a CROCO climatology file
%  take seasonal data for the upper levels and annual data for the
%  lower levels
%
%  input:
%    
%    oaname      : croco oa file to process (netcdf)
%    datafile    : regular longitude - latitude - z seasonal data
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
ncidclim = netcdf.open(datafile, 'NC_NOWRITE');
x=netcdf.getVar(ncidclim, netcdf.inqVarID(ncidclim, 'LON281_377'));
y=netcdf.getVar(ncidclim, netcdf.inqVarID(ncidclim, 'LAT2_110'));
zclim=-netcdf.getVar(ncidclim, netcdf.inqVarID(ncidclim, 'DEPTH'));
t=netcdf.getVar(ncidclim, netcdf.inqVarID(ncidclim, 'TIME'));
tlen=length(t);
Nzclim=length(zclim);
%
% Open the grid file and get the CROCO positions  
% 
ng_id = netcdf.open(oaname, 'NC_NOWRITE');
if type=='r'
  lon=netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lon_rho'));
  lat=netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lat_rho'));
elseif type=='u'
  lon=netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lon_u'));
  lat=netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lat_u'));
elseif type=='v'
  lon=netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lon_v'));
  lat=netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lat_v'));
else
  error('Bad Type')
end 
lon(lon<0)=lon(lon<0)+360;
netcdf.close(ng_id);
[M,L]=size(lon);
%
% Extract a subgrid of the data set
%
dl=0.5;
minlon=min(min(lon))-dl;
maxlon=max(max(lon))+dl;
minlat=min(min(lat))-dl;
maxlat=max(max(lat))+dl;
imin=max(find(x<=minlon));
imax=min(find(x>=maxlon));
jmin=max(find(y<=minlat));
jmax=min(find(y>=maxlat));
y=y(jmin:jmax);
if isempty(imax)
  dataeast=1;
  imax=(length(x));
  x=x(imin:imax);
  dx=(x(end)-x(1))/(length(x)-1);
  addx=[x(end)+dx:dx:maxlon]';
  x=[x;addx];
  addata=meshgrid(addx,y);
else
  dataeast=0;
  x=x(imin:imax);
end
%
% Open the OA file  
% 
ncid = netcdf.open(oaname, 'NC_WRITE');
Z=-netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Z'));
Nz=length(Z);
if zclim~=Z
 error('Zlevels mismatch between data and OA')
end
%
% interpole the seasonal dataset on the horizontal croco grid
%
disp([' Ext croco pacific: horizontal interpolation of the climatology data'])
%
% loop on time
%
missval=netcdf.getAtt(ncidclim, netcdf.inqVarID(ncidclim, dataname), 'missing_value');
for l=1:tlen
%for l=1:1
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  for k=1:Nzclim
    disp(['vertical index: ',num2str(k),' of total: ',num2str(Nzclim)])
    data=squeeze(netcdf.getVar(ncidclim, netcdf.inqVarID(ncidclim, dataname)));
    if dataeast==1
      data=[data,missval+0*addata];
    end
    data=oct_get_missing_val(x,y,data,missval,ro,default);
    datazgrid(k,:,:)=interp2(x,y,data,lon,lat,'cubic');
  end
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, vname), l,:,:,:-1, 1, datazgrid);  % [conv] 0-based
end
netcdf.close(ncid);
netcdf.close(ncidclim);
return
