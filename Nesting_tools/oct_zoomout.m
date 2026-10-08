function handles=oct_zoomout(h,handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Zoom to fit the parent domain
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
  disp('Warning : please open a netcdf file !!!')
  return
end
ncid = netcdf.open(handles.parentgrid, 'NC_NOWRITE');
lon=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho')));
lat=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho')));
netcdf.close(ncid);
handles.lonmin=min(lon(:));
handles.lonmax=max(lon(:));
handles.latmin=min(lat(:));
handles.latmax=max(lat(:));
oct_plot_nestgrid(h,handles)
return
