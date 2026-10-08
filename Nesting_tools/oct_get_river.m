function handles=oct_get_river(h,handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Get the river position
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
if isempty(handles.parentgrid)
  disp('Please open a netcdf file !!!')
  return
end
ncid = netcdf.open(handles.parentgrid, 'NC_NOWRITE');
lon=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'))).';
lat=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'))).';
netcdf.close(ncid);
set(handles.figure1,'CurrentAxes',handles.axes1);
disp('Click on the river position')
[x,y] = ginput(1);
if isempty(x)
  return
end
[lon1,lat1]=m_xy2ll(x,y);
dist=oct_spheric_dist(lat,lat1,lon,lon1);
[j1,i1]=find(dist==min(min(dist)));
handles.Isrcparent=i1(1)-1;
handles.Jsrcparent=j1(1)-1;
handles=oct_update_plot(h,handles);
return
