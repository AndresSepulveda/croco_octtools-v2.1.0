function data=oct_ext_data(datafile,dataname,tindex,lon,lat,time,Roa,savefile)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  data=oct_ext_data(datafile,dataname,tindex,lon,lat,time,Roa,savefile)
%
%  Read a 2D field (time index tindex) from a regular lon/lat
%  dataset (COADS-like: dataname(T,Y,X) or dataname(T,Z,Y,X)),
%  extrapolate over missing values and interpolate it on the
%  CROCO grid (lon,lat) given as (eta,xi) matrices.
%
%  Octave version: uses the netcdf.* API of the octave-netcdf
%  package. Hyperslabs are read with 0-based start/count given in
%  Fortran order (X,Y,[Z],T) and transposed back to (Y,X).
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
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    Sep-2026 : octave-netcdf (netcdf.* API)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin < 8 
  savefile=2;
end

disp(['Getting ',dataname,' for time index ',num2str(tindex)])
%
default=NaN;
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
varid = netcdf.inqVarID(nciddat, dataname);
[~,~,dimids] = netcdf.inqVar(nciddat, varid);
ndims = length(dimids);
%
% Get attributes (empty if absent)
%
try
  missval = double(netcdf.getAtt(nciddat, varid, 'missing_value'));
catch
  try
    missval = double(netcdf.getAtt(nciddat, varid, '_FillValue'));
  catch
    missval = [];
  end
end
if isempty(missval)
  missval=nan;
end
try
  add_offset = double(netcdf.getAtt(nciddat, varid, 'add_offset'));
catch
  add_offset = [];
end
try
  scale_factor = double(netcdf.getAtt(nciddat, varid, 'scale_factor'));
catch
  scale_factor = 1;
end
%
% Get lon,lat (X/lon/longitude and Y/lat/latitude)
%
X=[];
for vn={'X','lon','longitude'}
  try
    X = double(netcdf.getVar(nciddat, netcdf.inqVarID(nciddat, vn{1})));
    break
  end
end
if isempty(X)
  error(['Empty longitude in ',datafile])
end
Y=[];
for vn={'Y','lat','latitude'}
  try
    Y = double(netcdf.getVar(nciddat, netcdf.inqVarID(nciddat, vn{1})));
    break
  end
end
if isempty(Y)
  error(['Empty latitude in ',datafile])
end
X=X(:);
Y=Y(:);
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
%  Read data: ncdump order (T,[Z],Y,X) <-> netcdf.getVar order (X,Y,[Z],T).
%  For 4D variables the first level (surface) is read.
%
if ndims~=3 && ndims~=4
  netcdf.close(nciddat);
  error(['Bad dimension number ',num2str(ndims)])
end
data=[];
ilist={i1,i2,i3};
for n=[2 1 3]
  ii=ilist{n};
  if ~isempty(ii)
    if ndims==3
      start=[ii(1)-1 j(1)-1 tindex-1];
      count=[length(ii) length(j) 1];
    else
      start=[ii(1)-1 j(1)-1 0 tindex-1];
      count=[length(ii) length(j) 1 1];
    end
    tmp=double(netcdf.getVar(nciddat,varid,start,count)).';
    if n==1
      data=cat(2,tmp,data);
    else
      data=cat(2,data,tmp);
    end
  end
end
netcdf.close(nciddat);
%
% Perform the extrapolation
%
if savefile==2
  data=oct_get_missing_val(x,y,data,missval,Roa,default,2);
else
  if tindex==1
    data=oct_get_missing_val(x,y,data,missval,Roa,default,1);
  else
    data=oct_get_missing_val(x,y,data,missval,Roa,default,0);
  end
end
%
% Interpolation on the CROCO grid
%
%data=interp2(x,y,data,lon,lat,'linear');
data=interp2(x,y,data,lon,lat,'cubic');
%
% Apply offset
%
if ~isempty(add_offset)
  data=add_offset+data*scale_factor;
elseif scale_factor~=1
  data=data*scale_factor;
end
%
% Test for salinity (no negative salinity !)
%
if strcmp(dataname,'salinity')
  disp('salinity test')
  data(data<2)=2;
end
%
return
