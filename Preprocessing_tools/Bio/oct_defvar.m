function vid=oct_defvar(ncid,name,xtype,dimids)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OCT_DEFVAR  netcdf.defVar that can be called again on the same file:
%              if the variable NAME already exists (second run of an
%              oct_make_*_pisces/npzd/bioebus script on its file), its id
%              is returned and its values are overwritten later (error if
%              its dimensions differ). The file must be in define mode.
%
%  vid = oct_defvar(ncid,name,xtype,dimids)
%
%  Octave version (Nov-2026).
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
%  Copyright (c) 2026 by Andres Sepulveda
%  Andres Sepulveda 2026 - Octave adaptations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
try
  vid=netcdf.inqVarID(ncid,name);
catch
  vid=netcdf.defVar(ncid,name,xtype,dimids);
  return
end
[~,~,d0]=netcdf.inqVar(ncid,vid);
if ~isequal(d0(:),dimids(:))
  error(['oct_defvar: variable ',name,' already in the file with other dimensions: ',...
         'make the file again (oct_make_clim/oct_make_bry/oct_make_ini)']);
end
return
