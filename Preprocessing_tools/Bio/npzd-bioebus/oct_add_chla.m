function oct_add_chla(climfile,gridfile,seas_datafile,cycle,Roa);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function oct_add_chla(climfile,gridfile,seas_datafile,cycle);
%
%  Add chlorophyll (mg C) in a CROCO climatology file.
%  take seasonal data for the surface levels and extrapole 
%  using Morel and Berthon (1989) parameterization for the
%  lower levels. warning ! the unit is (micro mole/l) in the
%  dataset.
%  ref:  Morel and Berthon, Surface pigments, algal biomass
%        profiles, and potential production of the euphotic layer:
%        Relationships reinvestigated in view of remote-sensing 
%        applications. Limnol. Oceanogr., 34, 1989, 1545-1562.
%
%  input:
%    
%    climfile      : croco climatology file to process (netcdf)
%    gridfile      : croco grid file (netcdf)
%    seas_datafile : regular longitude - latitude - z seasonal data 
%                    file used for the upper levels  (netcdf)
%    ann_datafile  : regular longitude - latitude - z annual data 
%                    file used for the lower levels  (netcdf)
%    cycle         : time length (days) of climatology cycle (ex:360 for
%                    annual cycle) - 0 if no cycle.
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
disp('Add_chla: creating variable and attribute')
default=NaN;
%
% read in the datafile 
%
ncidseas = netcdf.open(seas_datafile, 'NC_NOWRITE');
x=netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'X'));
y=netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'Y'));
t=netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'T'));
tlen=length(t);
%
% open the grid file  
% 
ng_id = netcdf.open(gridfile, 'NC_NOWRITE');
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
ncid = netcdf.open(climfile, 'NC_WRITE');
theta_s = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_s'));
theta_b =  netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_b'));
Tcline  =  netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Tcline'));
vtransform=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Vtransform'));
if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
end
[~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));

%redef(nc);
did_chla_time = netcdf.defDim(ncid, 'chla_time', tlen);
vid_chla_time = netcdf.defVar(ncid, 'chla_time', 'NC_DOUBLE', did_chla_time);
vid_CHLA = netcdf.defVar(ncid, 'CHLA', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_chla_time]);
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'chla_time'), 'long_name', 'time for chlorophyll');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'chla_time'), 'units', 'day');
if cycle~=0
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'chla_time'), 'cycle_length', cycle);
end
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'CHLA'), 'long_name', 'Chlorophyll');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'CHLA'), 'units', 'mg C');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'CHLA'), 'fields', 'CHLA, scalar, series');
%
%endef(nc);
%
% Record the time
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'chla_time'), t*30);  % if time in month in the dataset !!!
%
% Get the missing values
%
missval=netcdf.getAtt(ncidseas, netcdf.inqVarID(ncidseas, 'chlorophyll'), 'missing_value');
%
% loop on time
%
for l=1:tlen
disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
%
% extrapole the annual dataset on the horizontal croco grid
%
  disp('Add_chla: horizontal interpolation of surface data')
  surfchla=squeeze(netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'chlorophyll')));
  surfchla=oct_get_missing_val(x,y,surfchla,missval,Roa,default);
  surfchlacroco=interp2(x,y,surfchla,lon,lat);
%
% extrapole the chlorophyll on the vertical
%
  zcroco=oct_zlevs(h,0.*h,theta_s,theta_b,Tcline,N,'r',vtransform);
  disp(['Add_chla: vertical ',...
  'extrapolation of chlorophyll'])
  chlacroco=oct_extr_chlo(surfchlacroco,zcroco);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'CHLA'), l,:,:,:-1, 1, chlacroco);  % [conv] 0-based
end
netcdf.close(ncid);
netcdf.close(ncidseas);
chla=squeeze(chlacroco(N,:,:));
return
