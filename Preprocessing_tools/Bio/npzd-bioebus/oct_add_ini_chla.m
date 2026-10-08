function oct_add_ini_chla(inifile,gridfile,seas_datafile,cycle,Roa);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,chla]=oct_add_ini_chla(inifile,gridfile,...
%                                             seas_datafile,...
%                                             cycle);
%
%  pierrick 2001
%
%  Add chlorophyll in a CROCO initial file.
%  take seasonal data for the surface levels and extrapole 
%  using Morel and Berthon (1989) parameterization for the
%  lower levels. warning ! the unit is (micro mole/l) in the
%  dataset.
%  do a temporal interpolation to have values at initial
%  time.
%
%  ref:  Morel and Berthon, Surface pigments, algal biomass
%        profiles, and potential production of the euphotic layer:
%        Relationships reinvestigated in view of remote-sensing 
%        applications. Limnol. Oceanogr., 34, 1989, 1545-1562.
%
%  input:
%    
%    inifile       : croco initial file to process (netcdf)
%    gridfile      : croco grid file (netcdf)
%    seas_datafile : regular longitude - latitude - z seasonal data 
%                    file used for the upper levels  (netcdf)
%    ann_datafile  : regular longitude - latitude - z annual data 
%                    file used for the lower levels  (netcdf)
%    cycle         : time length (days) of climatology cycle (ex:360 for
%                    annual cycle) - 0 if no cycle.
%
%   output:
%
%    [longrd,latgrd,chla] : surface field to plot (as an illustration)
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
%  Updated    August-2006 by Pierrick Penven
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp('Add_ini_chla: creating variable and attribute')
default=NaN;
%
% read in the datafile 
%
ncidseas = netcdf.open(seas_datafile, 'NC_NOWRITE');
x=netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'X'));
y=netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'Y'));
datatime=netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'T'));
datatime=datatime*30;  % !!! if the time in the dataset is in months !!!
tlen=length(datatime);
%
% open the grid file  
% 
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
% open the initial file  
% 
ncid = netcdf.open(inifile, 'NC_WRITE');
theta_s = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_s'));
if isempty(theta_s)
  disp('Restart file')
  theta_s=ncid.theta_s(:);
  theta_b=ncid.theta_b(:);
  hc=ncid.hc(:);
else
  theta_b =  netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_b'));
  hc  =  netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'hc'));
  vtransform = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Vtransform'));
end
[~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
scrum_time = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'scrum_time'));
scrum_time = scrum_time / (24*3600);
tinilen = length(scrum_time);
%redef(nc);
vid_CHLA = netcdf.defVar(ncid, 'CHLA', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'CHLA'), 'long_name', 'Chlorophyll');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'CHLA'), 'units', 'mg C');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'CHLA'), 'fields', 'CHLA, scalar, series');
%
%endef(nc);
%
% Get the missing values
%
missval=netcdf.getAtt(ncidseas, netcdf.inqVarID(ncidseas, 'chlorophyll'), 'missing_value');
%
% loop on time
%
for l=1:tinilen
  disp(['time index: ',num2str(l),' of total: ',num2str(tinilen)])
%
%  get data time indices and weights for temporal interpolation
%
  if cycle~=0
    modeltime=mod(scrum_time(l),cycle);
  else
    modeltime=scrum_time;
  end
  l1=find(modeltime==datatime);
  if isempty(l1)
    disp('temporal interpolation')
    l1=max(find(datatime<modeltime));
    time1=datatime(l1);
    if isempty(l1)
      if cycle~=0
        l1=tlen;
        time1=datatime(l1)-cycle;
      else
        error('No previous time in the dataset')
      end
    end
    l2=min(find(datatime>modeltime));
    time2=datatime(l2);
    if isempty(l2)
      if cycle~=0
        l2=1;
        time2=datatime(l2)+cycle;
      else
        error('No posterious time in the dataset')
      end
    end
    disp(['Initialisation time: ',num2str(modeltime),...
          ' - Time 1: ',num2str(time1),...
          ' - Time 2: ',num2str(time2)])
    cff1=(modeltime-time2)/(time1-time2);
    cff2=(time1-modeltime)/(time1-time2);
  else
    cff1=1;
    l2=l1;
    cff2=0;
  end
%
% interpole the annual dataset on the horizontal croco grid
%
  disp('Add_ini_chla: horizontal extrapolation of surface data')
  surfchla=squeeze(netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'chlorophyll')));
  surfchla=oct_get_missing_val(x,y,surfchla,missval,Roa,default);
  surfchla2=squeeze(netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'chlorophyll')));
  surfchla2=oct_get_missing_val(x,y,surfchla2,missval,Roa,default);
  surfchla=cff1*surfchla + cff2*surfchla2;
  surfchlacroco=interp2(x,y,surfchla,lon,lat);
%
% extrapole the chlorophyll on the vertical
%
  zeta = squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'zeta')));
  zcroco=oct_zlevs(h,zeta,theta_s,theta_b,hc,N,'r',vtransform);
  disp(['Add_ini_chla: vertical ',...
  'extrapolation of chlorophyll'])
  chlacroco=oct_extr_chlo(surfchlacroco,zcroco);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'CHLA'), l,:,:,:-1, 1, chlacroco);  % [conv] 0-based
end
netcdf.close(ncid);
netcdf.close(ncidseas);
return
