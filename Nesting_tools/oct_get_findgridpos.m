function handles=oct_get_findgridpos(h,handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Get imin,imax,jmin,jmax (the child grid positions)
% from the mouse.
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
%  Copyright (c) 2004-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Octave version (Sep-2026): netcdf.* API of the octave-netcdf package.
%
%  rbbox does not exist in Octave: the two corners of the child domain
%  are selected with two mouse clicks (ginput).
%
if isempty(handles.parentgrid)
  disp('Please open a parent grid file !!!')
  handles=oct_get_parentgrdname(h,handles);
  return
end
ncid = netcdf.open(handles.parentgrid, 'NC_NOWRITE');
plon=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_psi'))).';
plat=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_psi'))).';
netcdf.close(ncid);
set(handles.figure1,'CurrentAxes',handles.axes1);
disp('Click on two opposite corners of the child domain')
[x,y]=ginput(2);
if numel(x)<2
  return
end
[lon1,lat1]=m_xy2ll(x(1),y(1));
[lon2,lat2]=m_xy2ll(x(2),y(2));
if lon1==lon2 | lat1==lat2
  return
end
dist=oct_spheric_dist(plat,lat1,plon,lon1);
[j1,i1]=find(dist==min(min(dist)));
dist=oct_spheric_dist(plat,lat2,plon,lon2);
[j2,i2]=find(dist==min(min(dist)));
handles.imin=min([i1(1) i2(1)]);
handles.imax=max([i1(1) i2(1)]);
handles.jmin=min([j1(1) j2(1)]);
handles.jmax=max([j1(1) j2(1)]);
handles=oct_update_plot(h,handles);
return
