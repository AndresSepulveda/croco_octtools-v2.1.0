function oct_nested_bulk(child_grd,parent_blk,child_blk)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  compute the bulk file of the embedded grid
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
title=['Bulk file for the embedded grid :',child_blk,...
       ' using parent bulk file: ',parent_blk];
oct_nested_file(child_grd,parent_blk,child_blk,title,0,0)
%
% Make a plot
%
disp(' ')
disp(' Make a plot...')
try

figure(1)
oct_plot_nestbulk(child_blk,'tair',[1 6],1)
figure(2)
oct_plot_nestbulk(child_blk,'wspd',[1 6],1)
catch err
  disp(['  plot not done: ',err.message])
end
return
