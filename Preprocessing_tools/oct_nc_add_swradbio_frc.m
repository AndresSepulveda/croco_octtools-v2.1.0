function oct_nc_add_swradbio_frc(fname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Add swradbio (solar short-wave radiation without diurnal cycle) 
%  in frc climatological atmopheric forcing file. 
%  Variable needed by biogeochemical model PISCES
%
%
%  Further Information:
%  http://www.crocoagrif.org
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
%
%  June 2014: G.Cambon (IRD/LEGOS)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nw_id = netcdf.open(fname, 'NC_WRITE');
netcdf.reDef(nw_id);
%
% Add variables and attributes
%
vid_swradbio = netcdf.defVar(nw_id, 'swradbio', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_srf_time]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swradbio'), 'long_name', 'solar shortwave radiation - no night');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swradbio'), 'units', 'Watts meter-2');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swradbio'), 'positive', 'downward flux, heating');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swradbio'), 'negative', 'upward flux, cooling');
result = endef(nw_id);
netcdf.close(nw_id);
