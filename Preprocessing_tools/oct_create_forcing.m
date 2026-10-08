function  oct_create_forcing(frcname,grdname,title,smst,...
                         shft,swft,srft,sstt,ssst,smsc,...
                         shfc,swfc,srfc,sstc,sssc, Yorig)
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
%  Updated    Sep-2026 : octave-netcdf (netcdf.* API), dims in Fortran order
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
did_wwv_time = netcdf.defDim(nw_id, 'wwv_time', length(smst));
%
%  Create variables and attributes
%
vid_sms_time = netcdf.defVar(nw_id, 'sms_time', 'NC_DOUBLE', did_sms_time);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sms_time'), 'long_name', 'surface momentum stress time');
oct_write_time_attributes(nw_id,'sms_time',smsc,time_unit_att,time_second_unit_att,...
                          calendar_att,insecond,add_cycle);

vid_shf_time = netcdf.defVar(nw_id, 'shf_time', 'NC_DOUBLE', did_shf_time);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'shf_time'), 'long_name', 'surface heat flux time');
oct_write_time_attributes(nw_id,'shf_time',shfc,time_unit_att,time_second_unit_att,...
                          calendar_att,insecond,add_cycle);

vid_swf_time = netcdf.defVar(nw_id, 'swf_time', 'NC_DOUBLE', did_swf_time);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swf_time'), 'long_name', 'surface freshwater flux time');
oct_write_time_attributes(nw_id,'swf_time',swfc,time_unit_att,time_second_unit_att,...
                          calendar_att,insecond,add_cycle);

vid_sst_time = netcdf.defVar(nw_id, 'sst_time', 'NC_DOUBLE', did_sst_time);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sst_time'), 'long_name', 'sea surface temperature time');
oct_write_time_attributes(nw_id,'sst_time',sstc,time_unit_att,time_second_unit_att,...
                          calendar_att,insecond,add_cycle);

vid_sss_time = netcdf.defVar(nw_id, 'sss_time', 'NC_DOUBLE', did_sss_time);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sss_time'), 'long_name', 'sea surface salinity time');
oct_write_time_attributes(nw_id,'sss_time',sssc,time_unit_att,time_second_unit_att,...
                          calendar_att,insecond,add_cycle);

vid_srf_time = netcdf.defVar(nw_id, 'srf_time', 'NC_DOUBLE', did_srf_time);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'srf_time'), 'long_name', 'solar shortwave radiation time');
oct_write_time_attributes(nw_id,'srf_time',srfc,time_unit_att,time_second_unit_att,...
                          calendar_att,insecond,add_cycle);

vid_wwv_time = netcdf.defVar(nw_id, 'wwv_time', 'NC_DOUBLE', did_wwv_time);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'wwv_time'), 'long_name', 'surface wave fields time');
oct_write_time_attributes(nw_id,'wwv_time',smsc,time_unit_att,time_second_unit_att,...
                          calendar_att,insecond,add_cycle);

vid_sustr = netcdf.defVar(nw_id, 'sustr', 'NC_DOUBLE', [did_xi_u, did_eta_u, did_sms_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sustr'), 'long_name', 'surface u-momentum stress');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'sustr'), 'units', 'Newton meter-2');

vid_svstr = netcdf.defVar(nw_id, 'svstr', 'NC_DOUBLE', [did_xi_v, did_eta_v, did_sms_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'svstr'), 'long_name', 'surface v-momentum stress');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'svstr'), 'units', 'Newton meter-2');

vid_shflux = netcdf.defVar(nw_id, 'shflux', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_shf_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'shflux'), 'long_name', 'surface net heat flux');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'shflux'), 'units', 'Watts meter-2');

vid_swflux = netcdf.defVar(nw_id, 'swflux', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_swf_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swflux'), 'long_name', 'surface freshwater flux (E-P)');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swflux'), 'units', 'centimeter day-1');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swflux'), 'positive', 'net evaporation');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swflux'), 'negative', 'net precipitation');

vid_SST = netcdf.defVar(nw_id, 'SST', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_sst_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'SST'), 'long_name', 'sea surface temperature');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'SST'), 'units', 'Celsius');

vid_SSS = netcdf.defVar(nw_id, 'SSS', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_sss_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'SSS'), 'long_name', 'sea surface salinity');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'SSS'), 'units', 'PSU');

vid_dQdSST = netcdf.defVar(nw_id, 'dQdSST', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_sst_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'dQdSST'), 'long_name', 'surface net heat flux sensitivity to SST');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'dQdSST'), 'units', 'Watts meter-2 Celsius-1');

vid_swrad = netcdf.defVar(nw_id, 'swrad', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_srf_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swrad'), 'long_name', 'solar shortwave radiation');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swrad'), 'units', 'Watts meter-2');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swrad'), 'positive', 'downward flux, heating');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'swrad'), 'negative', 'upward flux, cooling');

vid_Awave = netcdf.defVar(nw_id, 'Awave', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_wwv_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'Awave'), 'long_name', 'wind induced wave amplitude');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'Awave'), 'units', 'm');

vid_Dwave = netcdf.defVar(nw_id, 'Dwave', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_wwv_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'Dwave'), 'long_name', 'wind induced wave direction');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'Dwave'), 'units', 'degree');

vid_Pwave = netcdf.defVar(nw_id, 'Pwave', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_wwv_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'Pwave'), 'long_name', 'wind induced wave period');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'Pwave'), 'units', 'second');


%
% Create global attributes
%

netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'title', title);
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'date', date);
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'grd_file', grdname);
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'type', 'CROCO forcing file');

%
% Leave define mode and write time variables
%
netcdf.endDef(nw_id);

netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'sms_time'), smst);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'shf_time'), shft);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'swf_time'), swft);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'sst_time'), sstt);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'srf_time'), srft);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'sss_time'), ssst);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'wwv_time'), smst);

netcdf.close(nw_id);
