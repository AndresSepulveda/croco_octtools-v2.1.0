function handles=oct_get_childgrdname(h,handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Get the name of the child grid file from the GUI
%
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
[filename, pathname] = uigetfile({'*.nc*', 'All netcdf-Files (*.nc*)'; ...
		'*.*','All Files (*.*)'},'CHILD GRID');
if isequal([filename,pathname],[0,0])
  return
end
handles.childgrid=fullfile(pathname,filename);
try
  ncid = netcdf.open(handles.childgrid, 'NC_NOWRITE');
catch
  disp('Warning : this is not a netcdf file')
  handles.childgrid=[];
  return
end
try
  grdpos=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'grd_pos')));
  parent=netcdf.getAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'parent_grid');
catch
  grdpos=[];
  parent='';
end
netcdf.close(ncid);
if isempty(grdpos)
  disp('Warning : this is not a child grid file')
  handles.childgrid=[];
  return
end
if ~strcmp(parent,handles.parentgrid)
  Answer=questdlg(['Warning : Are you sure that ',handles.childgrid,...
                   ' is a child of ',handles.parentgrid,' ?'],'',...
                   'Yes','No','Yes');
  if strcmp(Answer,'No')
    handles.childgrid=[];
    return
  end
end
handles.imin=grdpos(1);
handles.imax=grdpos(2);
handles.jmin=grdpos(3);
handles.jmax=grdpos(4);
handles=oct_update_plot(h,handles);
return
