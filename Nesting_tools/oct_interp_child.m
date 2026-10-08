function handles=oct_interp_child(h,handles);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Get everything in order to compute the child grid
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
% Get the parent grid name
%
if isempty(handles.parentgrid)
  handles=oct_get_parentgrdname(h,handles);
end
%
% Get the sub domain
%
if isempty(handles.imin)
  handles=oct_get_findgridpos(h,handles);
end
%
% Get the child grid name
%
lev=str2num(handles.parentgrid(end));
if isempty(lev) 
  childname=[handles.parentgrid,'.1'];
else
  childname=[handles.parentgrid(1:end-1),num2str(lev+1)];
end
Answer=questdlg(['Child grid name: ',childname,' OK ?'],'','Yes','Cancel','Yes');
switch Answer
case {'Cancel'}
  return
case 'Yes'
  handles.childgrid=childname;
end
%
% Get the topo Name
%
if handles.newtopo==1
  if isempty(handles.toponame)
    handles=oct_get_topofile(h,handles);
  end
end
%
% Get the rfactor and the width of the connection band
%
handles=oct_get_rfactor(h,handles);
handles=oct_get_nband(h,handles);
%
% Perform the interpolations
%
[imin_new,imax_new,jmin_new,jmax_new]=oct_nested_grid(handles.parentgrid,handles.childgrid,...
            handles.imin,handles.imax,handles.jmin,handles.jmax,...
            handles.rcoeff,handles.toponame,handles.newtopo,handles.rfactor,...
            handles.nband,handles.hmin,handles.matchvolume,...
	    handles.hmax_coast,handles.n_filter_deep,...
	    handles.n_filter_final);
%
% Update the imin,imax, jmin, jmax limits
%
handles.imin=imin_new;
handles.imax=imax_new;
handles.jmin=jmin_new;
handles.jmax=jmax_new;

handles=oct_update_limits(h,handles);

%
%
%
% Plot the river
%	    
if (~isempty(handles.Isrcparent)) & ~(isempty(handles.Jsrcparent))
 try
  disp('   Plot the river')
  ncid = netcdf.open(handles.parentgrid, 'NC_NOWRITE');
  lon=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'))).';
  lat=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'))).';
  netcdf.close(ncid);
  lon_src=lon(handles.Jsrcparent+1,handles.Isrcparent+1);
  lat_src=lat(handles.Jsrcparent+1,handles.Isrcparent+1);
  hold on
  plot(lon_src,lat_src,'s','LineWidth',1.5,'MarkerEdgeColor','k',...
       'MarkerFaceColor','b','MarkerSize',10);
  ncid = netcdf.open(handles.childgrid, 'NC_NOWRITE');
  lon=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'))).';
  lat=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'))).';
  netcdf.close(ncid);
  lon_src=lon(handles.Jsrcchild+1,handles.Isrcchild+1);
  lat_src=lat(handles.Jsrcchild+1,handles.Isrcchild+1);
  plot(lon_src,lat_src,'o','LineWidth',1.5,'MarkerEdgeColor','k',...
       'MarkerFaceColor','m','MarkerSize',7);
  hold off
 catch
  disp('   The river is outside the child domain')
 end
end
return
