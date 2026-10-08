function oct_nc_add_tides(fname,Ntides,start_tide_mjd,components)
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
%  Copyright (c) 2001-2006 by Patrick Marchesiello
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Octave version (Sep-2026): netcdf.* API of the octave-netcdf package.
%  The existing forcing file is put back in define mode (netcdf.reDef),
%  the xi_rho/eta_rho dimension ids are taken from the file and the new
%  variables are defined with dimensions in Fortran order
%  (xi_rho,eta_rho,tide_period) -> tide_Eamp(tide_period,eta_rho,xi_rho).
%
if ~exist(fname,'file')
  error(['NC_ADD_TIDES: forcing file not found: ',fname])
end
ncid = netcdf.open(fname, 'NC_WRITE');
%
% Tides already in the file (make_tides run twice): reuse the variables
% if the number of constituents is the same.
%
try
  [~,nold]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'tide_period'));
catch
  nold=-1;
end
if nold==Ntides
  disp(['NC_ADD_TIDES: tidal variables already in ',fname,': they will be overwritten'])
  netcdf.reDef(ncid);
  gid = netcdf.getConstant('NC_GLOBAL');
  netcdf.putAtt(ncid, gid, 'date', date);
  netcdf.putAtt(ncid, gid, 'start_tide_mjd', start_tide_mjd);
  netcdf.putAtt(ncid, gid, 'components', components);
  netcdf.endDef(ncid);
  netcdf.close(ncid);
  return
elseif nold>0
  netcdf.close(ncid);
  error(['NC_ADD_TIDES: ',fname,' already contains ',num2str(nold),...
         ' tidal constituents (Ntides=',num2str(Ntides),...
         '). Re-create the forcing file (oct_make_forcing) or delete it.'])
end
netcdf.reDef(ncid);
%
did_xi_rho  = netcdf.inqDimID(ncid, 'xi_rho');
did_eta_rho = netcdf.inqDimID(ncid, 'eta_rho');
did_tide_period = netcdf.defDim(ncid, 'tide_period', Ntides);
%
id = netcdf.defVar(ncid, 'tide_period', 'NC_DOUBLE', did_tide_period);
netcdf.putAtt(ncid, id, 'long_name', 'Tide angular period');
netcdf.putAtt(ncid, id, 'units', 'Hours');
%
d3 = [did_xi_rho, did_eta_rho, did_tide_period];
vars = {'tide_Ephase', 'Tidal elevation phase angle',               'Degrees'
        'tide_Eamp',   'Tidal elevation amplitude',                 'Meter'
        'tide_Cmin',   'Tidal current ellipse semi-minor axis',     'Meter second-1'
        'tide_Cmax',   'Tidal current, ellipse semi-major axis',    'Meter second-1'
        'tide_Cangle', 'Tidal current inclination angle',           'Degrees between semi-major axis and East'
        'tide_Cphase', 'Tidal current phase angle',                 'Degrees'
        'tide_Pamp',   'Tidal potential amplitude',                 'Meter'
        'tide_Pphase', 'Tidal potential phase angle',               'Degrees'};
for k=1:size(vars,1)
  id = netcdf.defVar(ncid, vars{k,1}, 'NC_DOUBLE', d3);
  netcdf.putAtt(ncid, id, 'long_name', vars{k,2});
  netcdf.putAtt(ncid, id, 'units', vars{k,3});
end
%
gid = netcdf.getConstant('NC_GLOBAL');
netcdf.putAtt(ncid, gid, 'date', date);
netcdf.putAtt(ncid, gid, 'start_tide_mjd', start_tide_mjd);
netcdf.putAtt(ncid, gid, 'components', components);
%
netcdf.endDef(ncid);
netcdf.close(ncid);
return
