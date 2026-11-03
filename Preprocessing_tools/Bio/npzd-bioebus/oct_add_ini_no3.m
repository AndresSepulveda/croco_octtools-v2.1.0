function oct_add_ini_no3(ininame,grdname,oaname,cycle,NO3min);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,no3]=add_ini_no3(ininame,grdname,...
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
%  Updated    Oct-2026 : Octave version (octave-netcdf, netcdf.* API)
%  Andres Sepulveda 2026 - Octave adaptations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
disp('Add_ini_no3: creating variable and attribute')
%
% open the grid file  
% 
ncid=netcdf.open(grdname,'NC_NOWRITE');
h=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'h'))).';
netcdf.close(ncid);
[M,L]=size(h);
%
% open the initial file  
% 
ncid=netcdf.open(ininame,'NC_WRITE');
try
  theta_s = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'theta_s')));
catch
  theta_s = [];
end
if isempty(theta_s)
  disp('Restart file')
  gid=netcdf.getConstant('NC_GLOBAL');
  theta_s=double(netcdf.getAtt(ncid,gid,'theta_s'));
  theta_b=double(netcdf.getAtt(ncid,gid,'theta_b'));
  hc=double(netcdf.getAtt(ncid,gid,'hc'));
else
  theta_b = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'theta_b')));
  hc      = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'hc')));
  try
    vtransform = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'Vtransform')));
  catch
    vtransform=1; %Old Vtransform
    disp([' NO VTRANSFORM parameter found'])
    disp([' USE TRANSFORM default value vtransform = 1'])
  end
end
[~,N]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'s_rho'));
%
% open the oa file  
% 
noa=netcdf.open(oaname,'NC_NOWRITE');
z=-double(netcdf.getVar(noa,netcdf.inqVarID(noa,'Zno3')));
oatime=double(netcdf.getVar(noa,netcdf.inqVarID(noa,'no3_time')));
z=z(:); oatime=oatime(:);
tlen=length(oatime);
NZoa=length(z);
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
scrum_time = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'scrum_time')));
scrum_time = scrum_time(:) / (24*3600);
tinilen = length(scrum_time);
netcdf.reDef(ncid);
vid_v=oct_defvar(ncid,'NO3','double',...
      [netcdf.inqDimID(ncid,'xi_rho') netcdf.inqDimID(ncid,'eta_rho') ...
       netcdf.inqDimID(ncid,'s_rho') netcdf.inqDimID(ncid,'time')]);
netcdf.putAtt(ncid,vid_v,'long_name','Nitrate');
netcdf.putAtt(ncid,vid_v,'units','mMol N m-3');
netcdf.putAtt(ncid,vid_v,'fields','NO3, scalar, series');
netcdf.endDef(ncid);
vid_oa=netcdf.inqVarID(noa,'NO3');
vid_zeta=netcdf.inqVarID(ncid,'zeta');
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
  % noa{'NO3'}(l1,:,:,:) -> (Z,eta,xi)
  var=permute(double(netcdf.getVar(noa,vid_oa,[0 0 0 l1-1],[L M NZoa 1])),[3 2 1]);
  if addsurf
    var=cat(1,var(1,:,:),var);
  end
  if addbot
    var=cat(1,var,var(end,:,:));
  end
  var2=permute(double(netcdf.getVar(noa,vid_oa,[0 0 0 l2-1],[L M NZoa 1])),[3 2 1]);
  if addsurf
    var2=cat(1,var2(1,:,:),var2);
  end
  if addbot
    var2=cat(1,var2,var2(end,:,:));
  end
  var=cff1*var + cff2*var2;
  var=var(1:Nz,:,:);   % keep the levels consistent with z(1:Nz) (needed by oct_ztosigma)
  zeta = double(netcdf.getVar(ncid,vid_zeta,[0 0 l-1],[L M 1])).';
  zcroco=oct_zlevs(h,zeta,theta_s,theta_b,hc,N,'r',vtransform);
  % nc{'NO3'}(l,:,:,:)=... (N,M,L) -> Fortran [L M N 1]
  netcdf.putVar(ncid,vid_v,[0 0 0 l-1],[L M N 1],...
                permute(oct_ztosigma(flip(var,1),zcroco,flipud(z)),[3 2 1]));
end
netcdf.close(noa);
%
% Remove low values for oligotrophic areas
%
for l=1:tinilen
  NO3=double(netcdf.getVar(ncid,vid_v,[0 0 0 l-1],[L M N 1]));
  NO3(NO3<NO3min)=0;
  netcdf.putVar(ncid,vid_v,[0 0 0 l-1],[L M N 1],NO3);
end
netcdf.close(ncid);
return
