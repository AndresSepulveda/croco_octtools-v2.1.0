function a=oct_tc_att(nc,name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OCT_TC_ATT  Global attribute (or scalar variable) of a netcdf file:
%              replaces nc.name(:) of the old Matlab netcdf toolbox
%
%  a = oct_tc_att(nc,name)     [] if it does not exist. If there is no
%                              global attribute NAME but a variable NAME
%                              (e.g. theta_s, hc in recent CROCO files),
%                              the variable is returned.
%
%  Part of the Octave port of the plotting scripts of the CROCO TEST_CASES.
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a=[];
try
  a=netcdf.getAtt(nc.id,netcdf.getConstant('NC_GLOBAL'),name);
  if isnumeric(a), a=double(a); end
catch
  a=oct_tc_var(nc,name);
end
return
