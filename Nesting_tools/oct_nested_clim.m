function oct_nested_clim(child_grd,parent_clim,child_clim,...
  vertical_correc,extrapmask,biol,bioebus,pisces)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  compute the climatology of the embedded grid
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
%  Octave version (Sep-2026): the child file is created with the
%  structure of the parent file and every horizontal field is
%  interpolated by the generic routine oct_nested_file (netcdf.* API
%  of the octave-netcdf package).
%
if pisces & biol
  error(['Both Biol NPZD and Pisces are ON, not possible yet... !'])
end
if extrapmask==1
  disp('Extrapolation under mask is on')
end
if vertical_correc==1
  disp('Vertical correction is on')
end
if biol==1 | pisces==1 | bioebus==1
  disp('Biogeochemical variables of the parent file are interpolated too')
end
title=['Climatology file for the embedded grid :',child_clim,...
       ' using parent climatology file: ',parent_clim];
oct_nested_file(child_grd,parent_clim,child_clim,title,extrapmask,vertical_correc)
%
% Make a plot
%
disp(' ')
disp(' Make a plot...')
try

figure(1)
oct_plot_nestclim(child_clim,child_grd,'temp',1)
catch err
  disp(['  plot not done: ',err.message])
end
return
