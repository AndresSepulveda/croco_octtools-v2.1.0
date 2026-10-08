function  oct_create_bulk(frcname,grdname,title,bulkt,bulkc,Yorig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	Create an empty netcdf heat flux bulk forcing file
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
%  Copyright (c) 2005 by Patrick Marchesiello
%  e-mail:Patrick.Marchesiello@ird.fr  
%
%  Updated 14-Oct-2005 add sustr,svstr,uwnd,vwnd vars
%  Updated    25-Oct-2006 by Pierrick Penven (uwnd and vwnd)
%  Updated    8-Apr-2009 by Gildas Cambon (add longwave in)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ncid = netcdf.open(grdname, 'NC_NOWRITE');
[~,L]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_psi'));
[~,M]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_psi'));
netcdf.close(ncid);
Lp=L+1;
Mp=M+1;
%
% options for oct_write_time_attributes
insecond = 0;
add_cycle = 1 ; 
%
% Initialize Yorig if not provided
if ~exist('Yorig', 'var') ,  Yorig = [] ; , end
%
% Get time attributes
[time_unit_att,time_second_unit_att,calendar_att]=...
      oct_get_time_attributes(Yorig);
%
nw_id = netcdf.create(frcname, 'NC_CLOBBER');
%
%  Create dimensions
%
did_xi_rho = netcdf.defDim(nw_id, 'xi_rho', Lp);
did_eta_rho = netcdf.defDim(nw_id, 'eta_rho', Mp);
did_xi_psi = netcdf.defDim(nw_id, 'xi_psi', L);
did_eta_psi = netcdf.defDim(nw_id, 'eta_psi', M);
did_xi_u = netcdf.defDim(nw_id, 'xi_u', L);
did_eta_u = netcdf.defDim(nw_id, 'eta_u', Mp);
did_xi_v = netcdf.defDim(nw_id, 'xi_v', Lp);
did_eta_v = netcdf.defDim(nw_id, 'eta_v', M);
did_bulk_time = netcdf.defDim(nw_id, 'bulk_time', netcdf.getConstant('NC_UNLIMITED'));
%
%  Create variables and attributes
%
vid_bulk_time = netcdf.defVar(nw_id, 'bulk_time', 'NC_DOUBLE', did_bulk_time);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'bulk_time'), 'long_name', 'bulk formulation execution time');
oct_write_time_attributes(nw_id,'bulk_time',bulkc,time_unit_att,time_second_unit_att,...
                          calendar_att,insecond,add_cycle);

vid_tair = netcdf.defVar(nw_id, 'tair', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_bulk_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'tair'), 'long_name', 'surface air temperature');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'tair'), 'units', 'Celsius');

vid_rhum = netcdf.defVar(nw_id, 'rhum', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_bulk_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'rhum'), 'long_name', 'relative humidity');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'rhum'), 'units', 'fraction');

vid_prate = netcdf.defVar(nw_id, 'prate', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_bulk_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'prate'), 'long_name', 'precipitation rate');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'prate'), 'units', 'cm day-1');

vid_wspd = netcdf.defVar(nw_id, 'wspd', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_bulk_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'wspd'), 'long_name', 'wind speed 10m');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'wspd'), 'units', 'm s-1');

vid_radlw = netcdf.defVar(nw_id, 'radlw', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_bulk_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'radlw'), 'long_name', 'net outgoing longwave radiation');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'radlw'), 'units', 'Watts meter-2');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'radlw'), 'positive', 'upward flux, cooling water');

vid_radlw_in = netcdf.defVar(nw_id, 'radlw_in', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_bulk_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'radlw_in'), 'long_name', 'downward longwave radiation');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'radlw_in'), 'units', 'Watts meter-2');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'radlw_in'), 'positive', 'downward flux, warming water');

vid_radsw = netcdf.defVar(nw_id, 'radsw', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_bulk_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'radsw'), 'long_name', 'shortwave radiation');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'radsw'), 'units', 'Watts meter-2');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'radsw'), 'positive', 'downward flux, heating water');

vid_sustr = netcdf.defVar(nw_id, 'sustr', 'NC_DOUBLE', [did_xi_u, did_eta_u, did_bulk_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sustr'), 'long_name', 'surface u-momentum stress');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sustr'), 'units', 'Newton meter-2');

vid_svstr = netcdf.defVar(nw_id, 'svstr', 'NC_DOUBLE', [did_xi_v, did_eta_v, did_bulk_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'svstr'), 'long_name', 'surface v-momentum stress');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'svstr'), 'units', 'Newton meter-2');

vid_uwnd = netcdf.defVar(nw_id, 'uwnd', 'NC_DOUBLE', [did_xi_u, did_eta_u, did_bulk_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'uwnd'), 'long_name', 'u-wind');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'uwnd'), 'units', 'm/s');

vid_vwnd = netcdf.defVar(nw_id, 'vwnd', 'NC_DOUBLE', [did_xi_v, did_eta_v, did_bulk_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'vwnd'), 'long_name', 'v-wind');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'vwnd'), 'units', 'm/s');


%
% Create global attributes
%

netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'title', title);
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'date', date);
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'grd_file', grdname);
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'type', 'CROCO heat flux bulk forcing file');

%
% Leave define mode and write time variables
%
netcdf.endDef(nw_id);
for tndx=1:length(bulkt)
   if mod(tndx,20)==0
     disp(['Time Step Bulk: ',num2str(tndx),' of ',num2str(length(bulkt))])
   end
  netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'bulk_time'), tndx-1, 1, bulkt(tndx));   % start is 0-based
end
netcdf.close(nw_id);
