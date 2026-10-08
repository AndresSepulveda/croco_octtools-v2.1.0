function oct_plot_nestforcing(child_frc,thefield,thetime,skip)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Test the embedded forcing file.
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
%  Plots a 2D field of a child forcing (or bulk) file (top) and of its
%  parent file (bottom) for the records given in thetime. thefield='spd'
%  plots the wind stress (forcing file) or the wind speed (bulk file).
%
npts=[0 0 0 0];
nt=length(thetime);
%
% Child file / grid, parent file / grid
%
ncid = netcdf.open(child_frc, 'NC_NOWRITE');
gid = netcdf.getConstant('NC_GLOBAL');
parent_frc = netcdf.getAtt(ncid, gid, 'parent_file');
child_grd  = netcdf.getAtt(ncid, gid, 'grd_file');
try
  netcdf.inqVarID(ncid, 'sustr'); uname='sustr'; vname='svstr';
catch
  uname='uwnd'; vname='vwnd';
end
netcdf.close(ncid);
ncid = netcdf.open(child_grd, 'NC_NOWRITE');
parent_grd = netcdf.getAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'parent_grid');
refinecoeff = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'refine_coef')));
netcdf.close(ncid);
files = {child_frc, parent_frc};
grids = {child_grd, parent_grd};
skips = [skip*refinecoeff skip];
for i=1:nt
  time=thetime(i);
  for n=1:2
    subplot(2,nt,i+(n-1)*nt)
%
%   Grid (transposed to (eta,xi))
%
    ncid = netcdf.open(grids{n}, 'NC_NOWRITE');
    lon  =double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'))).';
    lat  =double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'))).';
    mask =double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'))).';
    angle=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'))).';
    netcdf.close(ncid);
    [M,L]=size(lon);
    mask(mask==0)=NaN;
%
%   Record 'time' of the fields
%
    ncid = netcdf.open(files{n}, 'NC_NOWRITE');
    u=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, uname), [0 0 time-1], [L-1 M 1])).';
    v=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, vname), [0 0 time-1], [L M-1 1])).';
    if strcmp(thefield(1:min(3,end)),'spd')
      field=sqrt((oct_u2rho_2d(u)).^2+(oct_v2rho_2d(v)).^2);
      fieldname='wind';
    else
      vid=netcdf.inqVarID(ncid, thefield);
      field=double(netcdf.getVar(ncid, vid, [0 0 time-1], [L M 1])).';
      fieldname=netcdf.getAtt(ncid, vid, 'long_name');
    end
    netcdf.close(ncid);
    if n==1
      lonc=lon; latc=lat; cax=[min(field(:)) max(field(:))];
      if cax(1)==cax(2), cax=cax+[-1 1]; end
    end
    [ured,vred,lonred,latred]=oct_uv_vec2rho(u,v,lon,lat,angle,mask,skips(n),npts);
    pcolor(lon,lat,mask.*field)
    shading flat
    axis image
    caxis(cax)
    colorbar
    hold on
    quiver(lonred,latred,ured,vred,'k')
    hold off
    axis([min(lonc(:)) max(lonc(:)) min(latc(:)) max(latc(:))])
    if n==1
      title(['child: ',fieldname,' - ',num2str(time)])
    else
      title(['parent: ',fieldname,' - ',num2str(time)])
    end
  end
end
return
