function oct_add_ini_no3(ininame,grdname,oaname,cycle,NO3min);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,no3]=oct_add_ini_no3(ininame,grdname,...
%                                           seas_datafile,ann_datafile,...
%                                           cycle);
%
%  Add nitrate (mMol N m-3) in a CROCO initial file.
%  take seasonal data for the upper levels and annual data for the
%  lower levels.
%  do a temporal interpolation to have values at initial
%  time.
%
%  input:
%    
%    ininame       : croco initial file to process (netcdf)
%    grdname      : croco grid file (netcdf)
%    seas_datafile : regular longitude - latitude - z seasonal data 
%                    file used for the upper levels  (netcdf)
%    ann_datafile  : regular longitude - latitude - z annual data 
%                    file used for the lower levels  (netcdf)
%    cycle         : time length (days) of climatology cycle (ex:360 for
%                    annual cycle) - 0 if no cycle.
%
%   output:
%
%    [longrd,latgrd,no3] : surface field to plot (as an illustration)
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
disp('Add_ini_no3: creating variable and attribute')
%
% open the grid file  
% 
ncid = netcdf.open(grdname, 'NC_NOWRITE');
h=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'));
netcdf.close(ncid);
%
% open the initial file  
% 
ncid = netcdf.open(ininame, 'NC_WRITE');
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
  if  ~exist('vtransform')
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
  end
end
[~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
%
% open the oa file  
% 
noa_id = netcdf.open(oaname, 'NC_NOWRITE');
z=-netcdf.getVar(noa_id, netcdf.inqVarID(noa_id, 'Zno3'));
oatime=netcdf.getVar(noa_id, netcdf.inqVarID(noa_id, 'no3_time'));
tlen=length(oatime);
%
% Get the sigma depths
%
zcroco=oct_zlevs(h,0.*h,theta_s,theta_b,hc,N,'r',vtransform);
zmin=min(min(min(zcroco)));
zmax=max(max(max(zcroco)));
%
% Check if the min z level is below the min sigma level 
%    (if not add a deep layer)
%
%addsurf=max(z)<zmax;
addsurf=1;
addbot=min(z)>zmin;
if addsurf
 z=[100;z];
end
if addbot
 z=[z;-100000];
end
Nz=min(find(z<zmin));
z=z(1:Nz);
%
% read in the initial file  
% 
scrum_time = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'scrum_time'));
scrum_time = scrum_time / (24*3600);
tinilen = length(scrum_time);
%redef(nc);
vid_NO3 = netcdf.defVar(ncid, 'NO3', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3'), 'long_name', 'Nitrate');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3'), 'units', 'mMol N m-3');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3'), 'fields', 'NO3, scalar, series');
%endef(nc);
%
%  loop on initial time
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
  l1=find(modeltime==oatime);
  if isempty(l1)
    disp('temporal interpolation')
    l1=max(find(oatime<modeltime));
    time1=oatime(l1);
    if isempty(l1)
      if cycle~=0
        l1=tlen;
        time1=oatime(l1)-cycle;
      else
        error('No previous time in the dataset')
      end
    end
    l2=min(find(oatime>modeltime));
    time2=oatime(l2);
    if isempty(l2)
      if cycle~=0
        l2=1;
        time2=oatime(l2)+cycle;
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
% interpole the seasonal dataset on the horizontal croco grid
%
  disp(['Add_ini_no3: vertical interpolation'])
  var=squeeze(netcdf.getVar(noa_id, netcdf.inqVarID(noa_id, 'NO3')));
  if addsurf
    var=cat(1,var(1,:,:),var);
  end
  if addbot
    var=cat(1,var,var(end,:,:));
  end
  var2=squeeze(netcdf.getVar(noa_id, netcdf.inqVarID(noa_id, 'NO3')));
  if addsurf
    var2=cat(1,var2(1,:,:),var2);
  end
  if addbot
    var2=cat(1,var2,var2(end,:,:));
  end
  var=cff1*var + cff2*var2;
  zeta = squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'zeta')));
  zcroco=oct_zlevs(h,zeta,theta_s,theta_b,hc,N,'r',vtransform);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'NO3'), l,:,:,:-1, 1, oct_ztosigma(flip(var,1),zcroco,flipud(z)));  % [conv] 0-based
end
netcdf.close(noa_id);
%
% Remove low values for oligotrophic areas
%
for l=1:tinilen
  NO3=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'NO3'));
  NO3(NO3<NO3min)=0;
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'NO3'), l,:,:,:-1, 1, NO3);  % [conv] 0-based
end
netcdf.close(ncid);
return
