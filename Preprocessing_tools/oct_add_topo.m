function h=oct_add_topo(grdname,toponame)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% add a topography (here etopo2) to a CROCO grid
%
% the topogaphy matrix is coarsened prior
% to the interpolation on the CROCO grid tp
% prevent the generation of noise due to 
% subsampling. this procedure ensure a better
% general volume conservation.
%
% Last update Pierrick Penven 8/2006.
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
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr 
%
%  Updated    Aug-2006 by Pierrick Penven
%  Updated    2006/10/05 by Pierrick Penven (dl depend of model
%                                           resolution at low resolution)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  read croco grid (netcdf.getVar gives (xi,eta): transpose to (eta,xi))
ncid = netcdf.open(grdname,'NC_NOWRITE');
lon = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lon_rho'))).';
lat = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lat_rho'))).';
pm  = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'pm'))).';
pn  = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'pn'))).';
netcdf.close(ncid);
%
% Get CROCO averaged resolution
%
dx=mean(mean(1./pm));
dy=mean(mean(1./pn));
dx_croco=mean([dx dy]);
disp(['   CROCO resolution : ',num2str(dx_croco/1000,3),' km'])
%
dl=max([1 2*(dx_croco/(60*1852))]);
lonmin=min(min(lon))-dl;
lonmax=max(max(lon))+dl;
latmin=min(min(lat))-dl;
latmax=max(max(lat))+dl;
%
%  open the topo file
%
ncid = netcdf.open(toponame,'NC_NOWRITE');
tlon = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lon')));
tlat = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lat')));
tlon = tlon(:); tlat = tlat(:);
%
%  get a subgrid
%
j=find(tlat>=latmin & tlat<=latmax);
i1=find(tlon-360>=lonmin & tlon-360<=lonmax);
i2=find(tlon>=lonmin & tlon<=lonmax);
i3=find(tlon+360>=lonmin & tlon+360<=lonmax);
x=cat(1,tlon(i1)-360,tlon(i2),tlon(i3)+360);
y=tlat(j);
%
%  Read data: topo(lat,lon) in the file -> netcdf.getVar gives (lon,lat).
%  Hyperslab: start is 0-based and in Fortran order [lon lat].
%
vid = netcdf.inqVarID(ncid,'topo');
if ~isempty(i2)
  topo=-double(netcdf.getVar(ncid,vid,[i2(1)-1 j(1)-1],[length(i2) length(j)])).';
else
  topo=[];
end
if ~isempty(i1)
  topo=cat(2,-double(netcdf.getVar(ncid,vid,[i1(1)-1 j(1)-1],[length(i1) length(j)])).',topo);
end
if ~isempty(i3)
  topo=cat(2,topo,-double(netcdf.getVar(ncid,vid,[i3(1)-1 j(1)-1],[length(i3) length(j)])).');
end
netcdf.close(ncid);
%
% Get TOPO averaged resolution
%
R=6367442.76;
deg2rad=pi/180;
dg=mean(x(2:end)-x(1:end-1));
dphi=y(2:end)-y(1:end-1);
dy=R*deg2rad*dphi;
dx=R*deg2rad*dg*cos(deg2rad*y);
dx_topo=mean([dx ;dy]);
disp(['   Topography data resolution : ',num2str(dx_topo/1000,3),' km'])
%
% Degrade TOPO resolution
%
n=0;
while dx_croco>(dx_topo)
  n=n+1;
%  
  x=0.5*(x(2:end)+x(1:end-1));
  x=x(1:2:end);
  y=0.5*(y(2:end)+y(1:end-1));
  y=y(1:2:end);
%
  topo=0.25*(topo(2:end,1:end-1)  +topo(2:end,2:end)+...
             topo(1:end-1,1:end-1)+topo(1:end-1,2:end));
  topo=topo(1:2:end,1:2:end);   
%  
  dg=mean(x(2:end)-x(1:end-1));
  dphi=y(2:end)-y(1:end-1);
  dy=R*deg2rad*dphi;
  dx=R*deg2rad*dg*cos(deg2rad*y);
  dx_topo=mean([dx ;dy]);
end
disp(['   Topography resolution halved ',num2str(n),' times'])
disp(['   New topography resolution : ',num2str(dx_topo/1000,3),' km'])
%
%  interpolate the topo
%
h=interp2(x,y,topo,lon,lat,'cubic');
%
return
