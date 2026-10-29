function nc=oct_tc_open(fname,mode)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OCT_TC_OPEN  Open a netcdf file for reading (replaces nc=netcdf(fname)
%               of the old Matlab netcdf toolbox in the TEST_CASES plots)
%
%  nc = oct_tc_open(fname)       nc: structure (file name, id); read the
%                                variables with oct_tc_var, the global
%                                attributes with oct_tc_att, the
%                                dimensions with oct_tc_dim; close it
%                                with oct_tc_close
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
if nargin>1 && ~any(strcmpi(mode,{'r','nowrite','NC_NOWRITE'}))
  warning('oct_tc_open: only read mode is supported, file opened read-only');
end
if exist('netcdf')~=2 && isempty(which('netcdf.open'))
  pkg load netcdf
end
if ~exist(fname,'file')
  error(['oct_tc_open: file not found: ',fname]);
end
nc.file=fname;
nc.id=netcdf.open(fname,'NC_NOWRITE');
return
