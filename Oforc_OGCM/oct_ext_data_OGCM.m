function data=oct_ext_data_OGCM(ncid,X,Y,vname,tndx,lon,lat,k,Roa,interp_method)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extrapole one horizontal ECCO (or Data) slice on a CROCO grid
%
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
%  Copyright (c) 2005-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Contributions of P. Marchesiello (IRD) and J. Lefevre (IRD)
%
%  Updated    6-Sep-2006 by Pierrick Penven
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Octave version (Sep-2026): netcdf.* API of the octave-netcdf package.
%  vname is (lat,lon), (time,lat,lon) or (time,depth,lat,lon) in the file,
%  i.e. (lon,lat[,depth][,time]) for netcdf.getVar: hyperslabs are read
%  with 0-based start/count in that order and transposed to (lat,lon).
%  _FillValue / missing_value are replaced by NaN (the Matlab netcdf
%  toolbox did it automatically; netcdf.getVar does not).
%
% extrapolation parameters
%
default=0;
if strcmp(vname,'SAVE') | strcmp(vname,'salt')
  default=34.6;
end
%
% Get the CROCO grid extension + a little margin (~ 2 data grid points)
%
X=X(:); Y=Y(:);
dx=max(abs(gradient(X)));
dy=max(abs(gradient(Y)));
dl=2*max([dx dy]);
%
lonmin=min(min(lon))-dl;
lonmax=max(max(lon))+dl;
latmin=min(min(lat))-dl;
latmax=max(max(lat))+dl;
%
% Extract a data subgrid
%
j=find(Y>=latmin & Y<=latmax);
i1=find(X-360>=lonmin & X-360<=lonmax);
i2=find(X>=lonmin & X<=lonmax);
i3=find(X+360>=lonmin & X+360<=lonmax);
if ~isempty(i2)
  x=X(i2);
else
  x=[];
end
if ~isempty(i1)
  x=cat(1,X(i1)-360,x);
end
if ~isempty(i3)
  x=cat(1,x,X(i3)+360);
end
y=Y(j);
%
%  Get dimensions and missing values
%
varid=netcdf.inqVarID(ncid, vname);
[~,~,dimids]=netcdf.inqVar(ncid, varid);
ndims=length(dimids);
missv=[];
try
  missv=[missv double(netcdf.getAtt(ncid, varid, '_FillValue'))];
end
try
  missv=[missv double(netcdf.getAtt(ncid, varid, 'missing_value'))];
end
%
% Get data (Horizontal 2D matrix)
%
data=[];
ilist={i1,i2,i3};
for n=[2 1 3]
  ii=ilist{n};
  if ~isempty(ii)
    if ndims==2
      start=[ii(1)-1 j(1)-1];            count=[length(ii) length(j)];
    elseif ndims==3
      start=[ii(1)-1 j(1)-1 tndx-1];     count=[length(ii) length(j) 1];
    elseif ndims==4
      start=[ii(1)-1 j(1)-1 k-1 tndx-1]; count=[length(ii) length(j) 1 1];
    else
      error(['Bad dimension number ',num2str(ndims)])
    end
    tmp=double(netcdf.getVar(ncid,varid,start,count)).';
    if n==1
      data=cat(2,tmp,data);
    else
      data=cat(2,data,tmp);
    end
  end
end
for mv=missv
  if ~isnan(mv)
    data(data==mv)=NaN;
  end
end
%
% Perform the extrapolation
%
[data,interp_flag]=oct_get_missing_val(x,y,data,NaN,Roa,default);
%
% Interpolation on the CROCO grid
%
if interp_flag==0
  data=interp2(x,y,data,lon,lat,'nearest');
else
  data=interp2(x,y,data,lon,lat,interp_method);
end
%
return
