function oct_bry_interp_bgc_chloro(zbryname,grdfile,clmfile,lon,lat,seas_datafile,ann_datafile,...
                    dataname,vname,obcndx,coef,Roa);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%  function oct_bry_interp_bgc_chloro(zbryname,lon,lat,seas_datafile,ann_datafile,...
%                      dataname,vname,obcndx,Roa);
% 
%  Interpole data for the lateral boundaries (bry_file) along 
%  horizontal z levels.
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
%  Updated    5-Oct-2006 by Pierrick Penven (test for negative salinity)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[M,L]=size(lon);
%
disp(['Add ',dataname,': creating variable and attribute'])
% set the default value if no data
default=NaN;
Roa=0;
%
% read in the datafile 
%
ncidseas = netcdf.open(seas_datafile, 'NC_NOWRITE');
x=netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'X'));
y=netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'Y'));
t=netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'T'));
tlen=length(t);
missval=netcdf.getAtt(ncidseas, netcdf.inqVarID(ncidseas, 'chlorophyll'), 'missing_value');
%
% open the grid file  
% 
ng_id = netcdf.open(grdfile, 'NC_NOWRITE');
lon=netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lon_rho'));
%lon(lon<0)=lon(lon<0)+360;
lat=netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lat_rho'));
h=netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'h'));
netcdf.close(ng_id);
[M,L]=size(lon);
dl=2.;
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
% open the clim file  
% 
ncid = netcdf.open(clmfile, 'NC_NOWRITE');
theta_s = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_s'));
theta_b =  netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_b'));
Tcline  =  netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Tcline'));
[~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
vtransform=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Vtransform'));
if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
end
netcdf.close(ncid);
%
% loop on time
%
chlacroco=zeros(tlen,N,M,L);
for l=1:tlen
disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
%
% extrapole the annual dataset on the horizontal croco grid
%
  disp([dataname,' : horizontal interpolation of surface data'])
  surfchla=squeeze(netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'chlorophyll')));
  surfchla=oct_get_missing_val(x,y,surfchla,missval,Roa,default);
  surfchlacroco=interp2(x,y,surfchla,lon,lat);
%
% extrapole the chlorophyll on the vertical
%
  zcroco=oct_zlevs(h,0.*h,theta_s,theta_b,Tcline,N,'r',vtransform);
  disp(['      ==> then vertical extrapolation'])
  chlacroco(l,:,:,:)=oct_extr_chlo(surfchlacroco,zcroco);
end
netcdf.close(ncidseas);
%
% get the boundary position
%
if obcndx==1
%
% Southern boundary
% 
  icroco=(1:L);
  jcroco=1;
elseif obcndx==2
%
% Eastern boundary
% 
  icroco=L;
  jcroco=(1:M);
elseif obcndx==3
%
% Northern boundary
% 
  icroco=(1:L);
  jcroco=M;
elseif obcndx==4
%
% Western boundary
% 
  icroco=1;
  jcroco=(1:M);
end
%
lon=lon(jcroco,icroco);
lat=lat(jcroco,icroco);
%
% Open the boundary file
%
ncid = netcdf.open(zbryname, 'NC_WRITE');
%
% loop on time
% 
dims=size(lon);
for l=1:tlen
%for l=1:1
  disp(['writing time index: ',num2str(l),' of total: ',num2str(tlen)])
  datazgrid=squeeze(chlacroco(l,:,jcroco,icroco));
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, vname), l,:,:-1, 1, coef.*datazgrid);  % [conv] 0-based
end
netcdf.close(ncid);
return

