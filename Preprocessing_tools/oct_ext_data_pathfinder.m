function data=oct_ext_data_pathfinder(datafile,dataname,tindex,lon,lat,time)
%
% Read a data file and extrapole 1 horizontal
% slice on a CROCO grid
%
disp(['Getting ',dataname,' for time index ',num2str(tindex)])
%
%
%
ro=1e8;
default=NaN;
%
%
%
dl=1;
lonmin=min(min(lon))-dl;
lonmax=max(max(lon))+dl;
latmin=min(min(lat))-dl;
latmax=max(max(lat))+dl;
%
% Open the data file
%
nciddat = netcdf.open(datafile, 'NC_NOWRITE');

%
% Get attributes
%
missval=netcdf.getAtt(nciddat, netcdf.inqVarID(nciddat, dataname), 'missing_value');
if isempty(missval)
  missval=nan;
end
add_offset=netcdf.getAtt(nciddat, netcdf.inqVarID(nciddat, dataname), 'add_offset');
scale_factor=netcdf.getAtt(nciddat, netcdf.inqVarID(nciddat, dataname), 'scale_factor');
ndims=length(dim(nciddat{dataname}));
%
% Get lon,lat,t
%
X=netcdf.getVar(nciddat, netcdf.inqVarID(nciddat, 'X'));
Y=netcdf.getVar(nciddat, netcdf.inqVarID(nciddat, 'Y'));
T=30*netcdf.getVar(nciddat, netcdf.inqVarID(nciddat, 'T'))-15;
if T~=time
  disp(['Warning incorrect time :',dataname,...
       ' - ',num2str(tindex),...
       ' - ',num2str(T),...
       ' - ',num2str(time)])
end
%
% get a subgrid
%
j=find(Y>=latmin & Y<=latmax);
i1=find(X-360>=lonmin & X-360<=lonmax);
i2=find(X>=lonmin & X<=lonmax);
i3=find(X+360>=lonmin & X+360<=lonmax);
x=cat(1,X(i1)-360,X(i2),X(i3)+360);
y=Y(j);
%
%  Read data
%
if ~isempty(i2)
  if ndims==3
    data=squeeze(netcdf.getVar(nciddat, netcdf.inqVarID(nciddat, dataname)));
  elseif ndims==4
    data=squeeze(netcdf.getVar(nciddat, netcdf.inqVarID(nciddat, dataname)));
  else
    error(['Bad dimension number ',num2str(ndims)])
  end
else
  data=[];
end
if ~isempty(i1)
  if ndims==3
    data=cat(2,squeeze(netcdf.getVar(nciddat, netcdf.inqVarID(nciddat, dataname))),data);
  elseif ndims==4
    data=cat(2,squeeze(netcdf.getVar(nciddat, netcdf.inqVarID(nciddat, dataname))),data);
  else
    error(['Bad dimension number ',num2str(ndims)])
  end
end
if ~isempty(i3)
  if ndims==3
    data=cat(2,data,squeeze(netcdf.getVar(nciddat, netcdf.inqVarID(nciddat, dataname))));
  elseif ndims==4
    data=cat(2,data,squeeze(netcdf.getVar(nciddat, netcdf.inqVarID(nciddat, dataname))));
  else
    error(['Bad dimension number ',num2str(ndims)])
  end
end
netcdf.close(nciddat);
%
% Perform the extrapolation
%
lon
  lat
  x
y
stop

data=oct_get_missing_val(x,y,data,missval,ro,default);
%
% Interpolation on the CROCO grid
%
pcolor(data)

data=interp2(x,y,data,lon,lat,'linear');
%
% Apply offset
%
if ~isempty(add_offset)
  data=add_offset+data*scale_factor;
end
%
return
