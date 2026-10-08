function ncidrst=oct_create_nestedrestart(rstfile,gridfile,parentfile,title,clobber,...
				    biol,pisces,namebiol,namepisces,unitbiol,unitpisces,hc,vtransform)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function ncrst=oct_create_nestedrestart(rstfile,gridfile,parentfile,...
%                                      title,clobber)
%
%   This function create the header of a Netcdf initial 
%   file.
%
%   Input: 
%
%   rstfile     Netcdf restart file name (character string)
%   gridfile    Netcdf grid file name (character string).
%   parentfile  Netcdf parent restart file name (character string).
%   clobber      Switch to allow or not writing over an existing
%                file.(character string)
%
%   Output
%
%   ncrst       Output netcdf object.
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Octave version (Sep-2026): kept for compatibility. The file is now
%  created with the structure of the parent file by oct_create_nestedfile
%  (the previous automatic conversion had broken the variable
%  definitions and lost many attributes). The nesting routines call
%  oct_nested_file directly.
%
oct_create_nestedfile(parentfile,rstfile,gridfile,title)
ncidrst = netcdf.open(rstfile, 'NC_WRITE');
return
