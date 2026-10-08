function oct_nested_ndepo(child_grd,parent_ndepo,child_ndepo)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  compute the ndepo file (PISCES biogeochemical model) 
%  of the embedded grid
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
%  Update : Gildas Cambon: 13 Nov 2009
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Octave version (Sep-2026): the child file is created with the
%  structure of the parent file and every horizontal field is
%  interpolated by the generic routine oct_nested_file (netcdf.* API
%  of the octave-netcdf package).
%
%  The dust and nitrogen deposition fields are in the same frcbio file:
%  oct_nested_dust already interpolates all its variables. This routine
%  only does it when the child file does not exist yet.
%
if exist(child_ndepo,'file')
  disp([' ',child_ndepo,' already created (dust + ndepo)'])
  return
end
title=['Nitrogen deposition file for the embedded grid :',child_ndepo,...
       ' using parent file: ',parent_ndepo];
oct_nested_file(child_grd,parent_ndepo,child_ndepo,title,0,0)
return
