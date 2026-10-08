function  oct_create_forcing_tideonly(frcname,grdname,title)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	Create an empty netcdf forcing file
%       frcname: name of the forcing file
%       grdname: name of the grid file
%       title: title in the netcdf file  
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
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ncid = netcdf.open(grdname, 'NC_NOWRITE');
[~,L]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_psi'));
[~,M]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_psi'));
netcdf.close(ncid);
Lp=L+1;
Mp=M+1;

nw_id = netcdf.create(frcname, 'NC_CLOBBER');
%result = redef(nw);

%
%  Create dimensions
%

did_xi_u = netcdf.defDim(nw_id, 'xi_u', L);
did_eta_u = netcdf.defDim(nw_id, 'eta_u', Mp);
did_xi_v = netcdf.defDim(nw_id, 'xi_v', Lp);
did_eta_v = netcdf.defDim(nw_id, 'eta_v', M);
did_xi_rho = netcdf.defDim(nw_id, 'xi_rho', Lp);
did_eta_rho = netcdf.defDim(nw_id, 'eta_rho', Mp);
did_xi_psi = netcdf.defDim(nw_id, 'xi_psi', L);
did_eta_psi = netcdf.defDim(nw_id, 'eta_psi', M);

%
% Create global attributes
%

% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'title', title);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'date', date);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'grd_file', grdname);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'type', 'CROCO tide-only forcing file');

netcdf.close(nw_id);
