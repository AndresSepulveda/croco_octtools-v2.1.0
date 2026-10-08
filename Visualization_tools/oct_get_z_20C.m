function [lat,lon,mask,h]=oct_get_z_20C(hisfile,gridfile,tindex,coef)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Get the depth of 20C isotherm
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
%  Copyright (c) 2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated 15 Nov 2006 by P. Penven - remove vlevel
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[lat,lon,mask]=oct_read_latlonmask(gridfile,'r');
zr=oct_get_depths(hisfile,gridfile,tindex,'r');
ncid = netcdf.open(hisfile, 'NC_NOWRITE');
temp=read3d(ncid,'temp',tindex);
netcdf.close(ncid);
h=coef.*mask.*oct_get_depth_var(temp,zr,20);

%
%----------------------------------------------------------------------
%
function var=read3d(ncid,vname,tindex)
%
% Read the record tindex of a (time,s,eta,xi) variable with the
% octave-netcdf API and return it as (s,eta,xi)
%
vid=netcdf.inqVarID(ncid,vname);
[~,~,dd]=netcdf.inqVar(ncid,vid);
cnt=zeros(1,numel(dd));
for k=1:numel(dd)
  [~,cnt(k)]=netcdf.inqDim(ncid,dd(k));
end
start=zeros(1,numel(dd));
if numel(dd)==4
  start(4)=tindex-1; cnt(4)=1;
end
var=permute(double(netcdf.getVar(ncid,vid,start,cnt)),[3 2 1]);
return
