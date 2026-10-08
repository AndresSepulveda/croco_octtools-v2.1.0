function [x,y,data]=oct_read_data_tpxo(datafile,dataname,itide,lon,lat,type,dl)
%
%  Read in a tide TPXO file
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
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Octave version (Sep-2026): netcdf.* API of the octave-netcdf package.
%  dataname is (lat,lon) or (tide,lat,lon) in the file, i.e. (lon,lat[,tide])
%  for netcdf.getVar: hyperslabs are read with 0-based start/count in that
%  order and transposed to (lat,lon).
%
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
  add_offset=double(netcdf.getAtt(nciddat, varid, 'add_offset'));
catch
  add_offset=[];
end
try
  scale_factor=double(netcdf.getAtt(nciddat, varid, 'scale_factor'));
catch
  scale_factor=1;
end
%
% Get lon,lat
%
%  The coordinates of the variable are searched in this order:
%   1 - coordinate variables named as the dimensions of dataname,
%   2 - lon_<type> / lat_<type>,
%   3 - lon_r / lat_r. On the Arakawa C grid of TPXO, lat_u=lat_r and
%       lon_v=lon_r (some TPXO files do not store them). If lon_u or
%       lat_v is missing, it is rebuilt with a half grid shift.
%
dnames=cell(1,ndims);
for k=1:ndims
  dnames{k}=netcdf.inqDim(nciddat, dimids(k));
end
X=get_tpxo_coord(nciddat,'lon',type,dnames);
Y=get_tpxo_coord(nciddat,'lat',type,dnames);
X=X(:); Y=Y(:);
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
if ndims<2 || ndims>3
  netcdf.close(nciddat);
  error(['Bad dimension number ',num2str(ndims)])
end
data=[];
ilist={i1,i2,i3};
for n=[2 1 3]
  ii=ilist{n};
  if ~isempty(ii)
    if ndims==2
      start=[ii(1)-1 j(1)-1];         count=[length(ii) length(j)];
    else
      start=[ii(1)-1 j(1)-1 itide-1]; count=[length(ii) length(j) 1];
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
% Apply offset
%
if ~isempty(add_offset)
  data=add_offset+data*scale_factor;
elseif scale_factor~=1
  data=data*scale_factor;
end
%
% Make a grid
%
[x,y]=meshgrid(x,y);
%
return
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function C=get_tpxo_coord(ncid,cname,type,dnames)
%
% Read the lon or lat coordinate of a TPXO variable (see above)
%
cand={};
for k=1:numel(dnames)
  if strncmp(dnames{k},cname,3)
    cand{end+1}=dnames{k};
  end
end
cand{end+1}=[cname,'_',type];
for k=1:numel(cand)
  try
    C=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, cand{k})));
    return
  end
end
%
% Not found: use the rho coordinate
%
try
  C=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, [cname,'_r'])));
catch
  C=[];
  try
    C=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, [cname,'_z'])));
  end
  if isempty(C)
    netcdf.close(ncid);
    error(['No ',cname,'_',type,' nor ',cname,'_r coordinate in the TPXO file'])
  end
end
C=C(:);
if (strcmp(cname,'lon') && type=='u') || (strcmp(cname,'lat') && type=='v')
  if numel(C)>1
    C=C-0.5*(C(2)-C(1));          % u (v) points: half cell west (south)
  end
  disp(['  ',cname,'_',type,' not in the TPXO file: built from ',cname,...
        '_r with a half grid shift'])
end
return

