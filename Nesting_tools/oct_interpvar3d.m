function oct_interpvar3d(np_id,ncid,igrid_par,jgrid_par,...
                   igrid_child,jgrid_child,...
                   varname,mask,tindex)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Interpole a 3D variable on a nested grid
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
%  Parent record tindex of varname(time,eta,xi), sub-domain jmin:jmax,
%  imin:imax, is read with 0-based start/count in Fortran order
%  [xi eta time], transposed to (eta,xi), interpolated on the child grid
%  and written as record tindex of the child file.
%
imin=min(min(igrid_par));
imax=max(max(igrid_par));
jmin=min(min(jgrid_par));
jmax=max(max(jgrid_par));
%
% Get the mask
%
if ~isempty(mask)
  [I,J]=meshgrid(imin:imax,jmin:jmax);
  % rho mask -> u/v/psi mask according to the size of the parent grid
  if size(mask,2)==imax+1
    mask=mask(:,1:end-1).*mask(:,2:end);
  end
  if size(mask,1)==jmax+1
    mask=mask(1:end-1,:).*mask(2:end,:);
  end
  mask=mask(jmin:jmax,imin:imax);
end
%
% Read the parent variable
%
vid_p=netcdf.inqVarID(np_id, varname);
var_par=double(netcdf.getVar(np_id, vid_p, [imin-1 jmin-1 tindex-1],...
                             [imax-imin+1 jmax-jmin+1 1])).';
%
% Extrapole values on land
%
if ~isempty(mask)
  var_par(mask==0)=griddata(I(mask==1),J(mask==1),var_par(mask==1),...
                            I(mask==0),J(mask==0),'nearest');
end
%
% Perform the interpolation and write record tindex
%
var_child=interp2(igrid_par,jgrid_par,var_par,igrid_child,jgrid_child,'cubic');
[Mc,Lc]=size(var_child);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, varname), [0 0 tindex-1], [Lc Mc 1], var_child.');
%
return
