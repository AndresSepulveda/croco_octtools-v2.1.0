function oct_plot_nestdust(child_dust,thefield,thetime,skip)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Test the embedded dust forcing file.
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
%  Plots a 2D field of the child dust file (top) and of its parent file
%  (bottom) for the records given in thetime (skip is not used).
%
ncid = netcdf.open(child_dust, 'NC_NOWRITE');
gid = netcdf.getConstant('NC_GLOBAL');
parent_file = netcdf.getAtt(ncid, gid, 'parent_file');
child_grd   = netcdf.getAtt(ncid, gid, 'grd_file');
netcdf.close(ncid);
ncid = netcdf.open(child_grd, 'NC_NOWRITE');
parent_grd = netcdf.getAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'parent_grid');
netcdf.close(ncid);
files = {child_dust, parent_file};
grids = {child_grd, parent_grd};
nt=length(thetime);
for i=1:nt
  time=thetime(i);
  for n=1:2
    subplot(2,nt,i+(n-1)*nt)
    ncid = netcdf.open(grids{n}, 'NC_NOWRITE');
    lon =double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'))).';
    lat =double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'))).';
    mask=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'))).';
    netcdf.close(ncid);
    [M,L]=size(lon);
    mask(mask==0)=NaN;
    ncid = netcdf.open(files{n}, 'NC_NOWRITE');
    vid=netcdf.inqVarID(ncid, thefield);
    field=double(netcdf.getVar(ncid, vid, [0 0 time-1], [L M 1])).';
    try
      fieldname=netcdf.getAtt(ncid, vid, 'long_name');
    catch
      fieldname=thefield;
    end
    netcdf.close(ncid);
    if n==1
      lonc=lon; latc=lat; cax=[min(field(:)) max(field(:))];
      if cax(1)==cax(2), cax=cax+[-1 1]; end
    end
    pcolor(lon,lat,mask.*field)
    shading flat
    axis image
    caxis(cax)
    colorbar
    axis([min(lonc(:)) max(lonc(:)) min(latc(:)) max(latc(:))])
    if n==1
      title(['child: ',fieldname,' - ',num2str(time)])
    else
      title(['parent: ',fieldname,' - ',num2str(time)])
    end
  end
end
return
