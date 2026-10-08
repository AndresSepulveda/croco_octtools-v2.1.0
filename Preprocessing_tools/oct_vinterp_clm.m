function oct_vinterp_clm(clmname,grdname,oaname,vname,tname,zname,tini,...
                 type,isinitialval);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Vertical interpolation from a Z-grid to a sigma-grid in the
%  case of climatology files.
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
%  Copyright (c) 2003-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% open the grid file  (netcdf.getVar gives (xi,eta): transpose to (eta,xi))
% 
ng_id = netcdf.open(grdname, 'NC_NOWRITE');
h=double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'h'))).';
netcdf.close(ng_id);
[Mp,Lp]=size(h);
%
% open the clim file  
% 
ncid = netcdf.open(clmname, 'NC_WRITE');
theta_s = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_s')));
theta_b = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_b')));
hc      = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'hc')));
[~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
try
  vtransform=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Vtransform')));
catch
  vtransform = 1 ; 
  disp(['No vtransform parameter found'])
  disp(['Use the default value 1 corresponding to the old S vertical coordinate sytem'])
end
%
% open the oa file  
% 
noa_id = netcdf.open(oaname, 'NC_NOWRITE');
z=-double(netcdf.getVar(noa_id, netcdf.inqVarID(noa_id, zname)));
t=double(netcdf.getVar(noa_id, netcdf.inqVarID(noa_id, tname)));
z=z(:); t=t(:);
tlen=length(t);
NZoa=length(z);
%
% Get the sigma depths
%
zcroco=oct_zlevs(h,0.*h,theta_s,theta_b,hc,N,'r',vtransform);
if type=='u'
  zcroco=oct_rho2u_3d(zcroco);
end
if type=='v'
  zcroco=oct_rho2v_3d(zcroco);
end
[~,Mz,Lz]=size(zcroco);   % horizontal size of the variable
zmin=min(min(min(zcroco)));
zmax=max(max(max(zcroco)));
%
% Check if the min z level is below the min sigma level 
%
addsurf=max(z)<zmax;
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
% loop on time
%
% Are we processing initial file ?
isinitial = 0;
if (nargin > 8)
  isinitial = isinitialval;
end
if (isinitial == 1)  % initial file 
  tlen=1;
end
vid_oa=netcdf.inqVarID(noa_id, vname);
vid_out=netcdf.inqVarID(ncid, vname);
for l=1:tlen
  if (isinitial == 0)
    disp([' Time index: ',num2str(l),' of total: ',num2str(tlen)])
    lout=l;
  else
    ll=find(t<=tini);
    if (size(ll,1) ~= 0)
      l=ll(size(ll,1));
    else
      l=1;
    end
    disp([' Time index: ',num2str(l)])
    lout=1;
  end
%
% Read record l of the OA file: file (T,Z,eta,xi) -> getVar (xi,eta,Z)
% -> permute to (Z,eta,xi)
%
  var=permute(double(netcdf.getVar(noa_id,vid_oa,[0 0 0 l-1],[Lz Mz NZoa 1])),[3 2 1]);
  if addsurf
    var=cat(1,var(1,:,:),var);
  end
  if addbot
    var=cat(1,var,var(end,:,:));
  end
  var=var(1:Nz,:,:);
  var=oct_ztosigma(flip(var,1),zcroco,flipud(z));
%
% Write (N,eta,xi) -> (xi,eta,N) record lout
%
  netcdf.putVar(ncid, vid_out, [0 0 0 lout-1], [Lz Mz N 1], permute(var,[3 2 1]));
end
netcdf.close(ncid);
netcdf.close(noa_id);
return
