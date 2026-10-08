function handles=oct_set_parentgrid(h,handles,grdname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  handles=oct_set_parentgrid(h,handles,grdname)
%
%  Load the parent grid grdname in the nesting GUI (oct_nestgui):
%  grid size, domain limits, minimum depth, default child position,
%  and plot. Used by oct_get_parentgrdname (file dialog) and by
%  oct_nestgui('parent_grid.nc') to open a grid directly.
%
%  Octave version (Sep-2026): netcdf.* API of the octave-netcdf package.
%  This file is part of CROCOTOOLS (GNU General Public License).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
  ncid = netcdf.open(grdname, 'NC_NOWRITE');
catch
  disp(['Warning : ',grdname,' is not a netcdf file !!!'])
  handles.parentgrid=[];
  return
end
handles.parentgrid=grdname;
% netcdf.getVar returns (xi,eta): transpose to (eta,xi)
lon=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'))).';
lat=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'))).';
hh=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'))).';
netcdf.close(ncid);
[handles.Mparent,handles.Lparent]=size(lon);
handles.lonmin=min(min(lon));
handles.lonmax=max(max(lon));
handles.latmin=min(min(lat));
handles.latmax=max(max(lat));
handles.hmin=min(min(hh));
set(handles.edithmin,'String',num2str(handles.hmin));
handles.imin=2;
handles.imax=handles.Lparent-2;
handles.jmin=2;
handles.jmax=handles.Mparent-2;
set(handles.figure1,'Name',['NESTGUI (Octave) - parent grid: ',grdname]);
handles=oct_update_plot(h,handles);
return
