function  oct_create_forcing_QSCAT(frcname,grdname,title,QSCAT_blk,smst,...
                         shft,swft,srft,sstt,ssst,smsc,...
                         shfc,swfc,srfc,sstc,sssc)
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
result=close(ncid);
Lp=L+1;
Mp=M+1;

nw_id = netcdf.create(frcname, 'NC_CLOBBER');
result = redef(nw_id);

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
did_sms_time = netcdf.defDim(nw_id, 'sms_time', length(smst));
did_shf_time = netcdf.defDim(nw_id, 'shf_time', length(shft));
did_swf_time = netcdf.defDim(nw_id, 'swf_time', length(swft));
did_sst_time = netcdf.defDim(nw_id, 'sst_time', length(sstt));
did_srf_time = netcdf.defDim(nw_id, 'srf_time', length(srft));
did_sss_time = netcdf.defDim(nw_id, 'sss_time', length(ssst));
%
%  Create variables and attributes
%
vid_sms_time = netcdf.defVar(nw_id, 'sms_time', 'NC_DOUBLE', did_sms_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sms_time'), 'long_name', 'surface momentum stress time');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sms_time'), 'units', 'days');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sms_time'), 'cycle_length', smsc);

vid_shf_time = netcdf.defVar(nw_id, 'shf_time', 'NC_DOUBLE', did_shf_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'shf_time'), 'long_name', 'surface heat flux time');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'shf_time'), 'units', 'days');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'shf_time'), 'cycle_length', shfc);

vid_swf_time = netcdf.defVar(nw_id, 'swf_time', 'NC_DOUBLE', did_swf_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swf_time'), 'long_name', 'surface freshwater flux time');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swf_time'), 'units', 'days');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swf_time'), 'cycle_length', swfc);


vid_sst_time = netcdf.defVar(nw_id, 'sst_time', 'NC_DOUBLE', did_sst_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sst_time'), 'long_name', 'sea surface temperature time');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sst_time'), 'units', 'days');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sst_time'), 'cycle_length', sstc);

vid_sss_time = netcdf.defVar(nw_id, 'sss_time', 'NC_DOUBLE', did_sss_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sss_time'), 'long_name', 'sea surface salinity time');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sss_time'), 'units', 'days');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sss_time'), 'cycle_length', sssc);

vid_srf_time = netcdf.defVar(nw_id, 'srf_time', 'NC_DOUBLE', did_srf_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'srf_time'), 'long_name', 'solar shortwave radiation time');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'srf_time'), 'units', 'days');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'srf_time'), 'cycle_length', srfc);

vid_sustr = netcdf.defVar(nw_id, 'sustr', 'NC_DOUBLE', [did_xi_u, did_eta_u, did_sms_time]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sustr'), 'long_name', 'surface u-momentum stress');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sustr'), 'units', 'Newton meter-2');

vid_svstr = netcdf.defVar(nw_id, 'svstr', 'NC_DOUBLE', [did_xi_v, did_eta_v, did_sms_time]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'svstr'), 'long_name', 'surface v-momentum stress');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'svstr'), 'units', 'Newton meter-2');

if QSCAT_blk
vid_uwnd = netcdf.defVar(nw_id, 'uwnd', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_sms_time]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'uwnd'), 'long_name', 'u-wind');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'uwnd'), 'units', 'm/s');

vid_vwnd = netcdf.defVar(nw_id, 'vwnd', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_sms_time]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'vwnd'), 'long_name', 'v-wind');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'vwnd'), 'units', 'm/s');

vid_wspd = netcdf.defVar(nw_id, 'wspd', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_sms_time]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'wspd'), 'long_name', '10m wind speed');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'wspd'), 'units', 'm/s');
end

vid_shflux = netcdf.defVar(nw_id, 'shflux', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_shf_time]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'shflux'), 'long_name', 'surface net heat flux');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'shflux'), 'units', 'Watts meter-2');

vid_swflux = netcdf.defVar(nw_id, 'swflux', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_swf_time]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swflux'), 'long_name', 'surface freshwater flux (E-P)');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swflux'), 'units', 'centimeter day-1');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swflux'), 'positive', 'net evaporation');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swflux'), 'negative', 'net precipitation');

vid_SST = netcdf.defVar(nw_id, 'SST', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_sst_time]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'SST'), 'long_name', 'sea surface temperature');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'SST'), 'units', 'Celsius');

vid_SSS = netcdf.defVar(nw_id, 'SSS', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_sss_time]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'SSS'), 'long_name', 'sea surface salinity');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'SSS'), 'units', 'PSU');

vid_dQdSST = netcdf.defVar(nw_id, 'dQdSST', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_sst_time]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'dQdSST'), 'long_name', 'surface net heat flux sensitivity to SST');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'dQdSST'), 'units', 'Watts meter-2 Celsius-1');

vid_swrad = netcdf.defVar(nw_id, 'swrad', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_srf_time]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swrad'), 'long_name', 'solar shortwave radiation');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swrad'), 'units', 'Watts meter-2');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swrad'), 'positive', 'downward flux, heating');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swrad'), 'negative', 'upward flux, cooling');

result = endef(nw_id);

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
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'type', 'CROCO forcing file');

%
% Write time variables
%

netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'sms_time'), smst);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'shf_time'), shft);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'swf_time'), swft);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'sst_time'), sstt);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'srf_time'), srft);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'sss_time'), ssst);

netcdf.close(nw_id);
