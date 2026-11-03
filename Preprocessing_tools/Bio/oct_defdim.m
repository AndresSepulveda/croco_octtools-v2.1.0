function did=oct_defdim(ncid,name,len)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OCT_DEFDIM  netcdf.defDim that can be called again on the same file:
%              if the dimension NAME already exists (second run of an
%              oct_make_*_pisces/npzd/bioebus script on its file), its id
%              is returned (error if its length differs, unless it is the
%              unlimited dimension). The file must be in define mode.
%
%  did = oct_defdim(ncid,name,len)
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
  did=netcdf.inqDimID(ncid,name);
catch
  did=netcdf.defDim(ncid,name,len);
  return
end
[~,n0]=netcdf.inqDim(ncid,did);
[~,~,~,unlim]=netcdf.inq(ncid);
if did~=unlim && len~=netcdf.getConstant('NC_UNLIMITED') && n0~=len
  error(['oct_defdim: dimension ',name,' already in the file with ',num2str(n0),...
         ' values (',num2str(len),' now): make the file again (oct_make_clim/oct_make_bry/oct_make_ini)']);
end
return
