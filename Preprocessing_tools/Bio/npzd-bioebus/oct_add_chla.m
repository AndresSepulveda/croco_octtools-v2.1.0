function oct_add_chla(climfile,gridfile,seas_datafile,cycle,Roa);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function add_chla(climfile,gridfile,seas_datafile,cycle);
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
%  Updated    Oct-2026 : Octave version (octave-netcdf, netcdf.* API)
%  Andres Sepulveda 2026 - Octave adaptations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
disp('Add_chla: creating variable and attribute')
default=NaN;
%
% read in the datafile 
%
ncidseas=netcdf.open(seas_datafile,'NC_NOWRITE');
x=double(netcdf.getVar(ncidseas,netcdf.inqVarID(ncidseas,'X')));
y=double(netcdf.getVar(ncidseas,netcdf.inqVarID(ncidseas,'Y')));
t=double(netcdf.getVar(ncidseas,netcdf.inqVarID(ncidseas,'T')));
x=x(:); y=y(:); t=t(:);
tlen=length(t);
%
% open the grid file  
% 
ng=netcdf.open(gridfile,'NC_NOWRITE');
lon=double(netcdf.getVar(ng,netcdf.inqVarID(ng,'lon_rho'))).';
%lon(lon<0)=lon(lon<0)+360;
lat=double(netcdf.getVar(ng,netcdf.inqVarID(ng,'lat_rho'))).';
h=double(netcdf.getVar(ng,netcdf.inqVarID(ng,'h'))).';
netcdf.close(ng);
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
ncid=netcdf.open(climfile,'NC_WRITE');
theta_s = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'theta_s')));
theta_b = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'theta_b')));
Tcline  = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'Tcline')));
try
  vtransform=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'Vtransform')));
catch
  vtransform=1; %Old Vtransform
  disp([' NO VTRANSFORM parameter found'])
end
[~,N]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'s_rho'));

netcdf.reDef(ncid);
did_t=oct_defdim(ncid,'chla_time',tlen);
vid_t=oct_defvar(ncid,'chla_time','double',did_t);
vid_chla=oct_defvar(ncid,'CHLA','double',...
         [netcdf.inqDimID(ncid,'xi_rho') netcdf.inqDimID(ncid,'eta_rho') ...
          netcdf.inqDimID(ncid,'s_rho') did_t]);
%
netcdf.putAtt(ncid,vid_t,'long_name','time for chlorophyll');
netcdf.putAtt(ncid,vid_t,'units','day');
if cycle~=0
  netcdf.putAtt(ncid,vid_t,'cycle_length',cycle);
end
%
netcdf.putAtt(ncid,vid_chla,'long_name','Chlorophyll');
netcdf.putAtt(ncid,vid_chla,'units','mg C');
netcdf.putAtt(ncid,vid_chla,'fields','CHLA, scalar, series');
%
netcdf.endDef(ncid);
%
% Record the time
%
netcdf.putVar(ncid,vid_t,0,tlen,t*30); % if time in month in the dataset !!!
%
% Get the missing values
%
vid_seas=netcdf.inqVarID(ncidseas,'chlorophyll');
missval=double(netcdf.getAtt(ncidseas,vid_seas,'missing_value'));
%
% loop on time
%
for l=1:tlen
disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
%
% extrapole the annual dataset on the horizontal croco grid
%
  disp('Add_chla: horizontal interpolation of surface data')
  % chlorophyll(l,jmin:jmax,imin:imax) -> start/count [X Y T]
  surfchla=double(netcdf.getVar(ncidseas,vid_seas,[imin-1 jmin-1 l-1],...
                  [imax-imin+1 jmax-jmin+1 1])).';
  surfchla=oct_get_missing_val(x,y,surfchla,missval,Roa,default);
  surfchlacroco=interp2(x,y,surfchla,lon,lat);
%
% extrapole the chlorophyll on the vertical
%
  zcroco=oct_zlevs(h,0.*h,theta_s,theta_b,Tcline,N,'r',vtransform);
  disp(['Add_chla: vertical ',...
  'extrapolation of chlorophyll'])
  chlacroco=oct_extr_chlo(surfchlacroco,zcroco);
  % nc{'CHLA'}(l,:,:,:)=chlacroco (N,M,L) -> Fortran [L M N 1]
  netcdf.putVar(ncid,vid_chla,[0 0 0 l-1],[L M N 1],permute(chlacroco,[3 2 1]));
end
netcdf.close(ncid);
netcdf.close(ncidseas);
chla=squeeze(chlacroco(N,:,:));
return
