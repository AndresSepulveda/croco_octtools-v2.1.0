function oct_add_no3(oafile,climfile,inifile,gridfile,seas_datafile,...
  ann_datafile,cycle,makeoa,makeclim,makeini,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,no3]=oct_add_no3(climfile,gridfile,...
%                                       seas_datafile,ann_datafile,...
%                                       cycle);
%
%  Add nitrate (mMol N m-3) in a CROCO climatology file
%  take seasonal data for the upper levels and annual data for the
%  lower levels
%
%  input:
%
%    climfile      : croco climatology file to process (netcdf)
%    gridfile      : croco grid file (netcdf)
%    seas_datafile : regular longitude - latitude - z seasonal data
%                    file used for the upper levels  (netcdf)
%    ann_datafile  : regular longitude - latitude - z annual data
%                    file used for the lower levels  (netcdf)
%    cycle         : time length (days) of climatology cycle (ex:360 for
%                    annual cycle) - 0 if no cycle.
%
%   output:
%
%    [longrd,latgrd,no3] : surface field to plot (as an illustration)
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
%
% options for oct_write_time_attributes
insecond = 0  ;
add_cycle = 1 ; 
%
% Initialize Yorig if not provided
if ~exist('Yorig', 'var') ,  Yorig = []; , end
%
% Get time attributes
[time_unit_att,time_second_unit_att,calendar_att]=...
    oct_get_time_attributes(Yorig);
%
%
% Read in the grid
%
ncid = netcdf.open(gridfile, 'NC_NOWRITE');
hmax=max(max(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'))));
netcdf.close(ncid);
%
% read in the datafiles
%
ncid = netcdf.open(seas_datafile, 'NC_NOWRITE');
t=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'T'));
t;
netcdf.close(ncid);
ncid = netcdf.open(ann_datafile, 'NC_NOWRITE');
zno3=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Z'));
kmax=max(find(zno3<hmax))-1;
zno3=zno3(1:kmax);
%disp('Size zno3=')
size(zno3);
netcdf.close(ncid);
%
% open the OA file
%
if (makeoa)
  disp('Add_no3: creating variables and attributes for the OA file')
  ncid = netcdf.open(oafile, 'NC_WRITE');
  % redef(nc);

  %Create Dimensions
  did_no3_time = netcdf.defDim(ncid, 'no3_time', length(t));
  %Create Variable
  vid_no3_time = netcdf.defVar(ncid, 'no3_time', 'NC_DOUBLE', did_no3_time);
  %
  %%
  %
  %Create Dimensions
  did_Zno3 = netcdf.defDim(ncid, 'Zno3', length(zno3));
  %Create Variable
  vid_Zno3 = netcdf.defVar(ncid, 'Zno3', 'NC_DOUBLE', did_Zno3);
  %
  %%
  %
  %Create Variable
  vid_NO3 = netcdf.defVar(ncid, 'NO3', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_Zno3, did_no3_time]);
  %
  %%
  %
  %Create Attribute

  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'no3_time'), 'long_name', 'time for nitrate');
  oct_write_time_attributes(ncid,'no3_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);
  %%%
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zno3'), 'long_name', 'Depth for NO3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zno3'), 'units', 'm');
  %%%
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3'), 'long_name', 'Nitrate');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3'), 'units', 'mMol N m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3'), 'fields', 'NO3, scalar, series');
  %%%
  %%  endef(nc);
  %
  %% Write variables
  %% record depth and time and close
  %
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'no3_time'), t*30);  % if time in month in the dataset !!!
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Zno3'), zno3);
  netcdf.close(ncid);
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_no3: creating variables and attributes for the Climatology file')
  %
  % open the clim file
  %
  ncid = netcdf.open(climfile, 'NC_WRITE');
  % redef(nc);
  did_no3_time = netcdf.defDim(ncid, 'no3_time', length(t););
  vid_no3_time = netcdf.defVar(ncid, 'no3_time', 'NC_DOUBLE', did_no3_time);
  vid_NO3 = netcdf.defVar(ncid, 'NO3', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_no3_time]);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'no3_time'), 'long_name', 'time for nitrate');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'no3_time'), 'units', time_unit_att);
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'no3_time'), 'calendar', calendar_att);
  if cycle~=0
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'no3_time'), 'cycle_length', cycle);
  end
  oct_write_time_attributes(ncid,'tclm_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3'), 'long_name', 'Nitrate');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3'), 'units', 'mMol N m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'NO3'), 'fields', 'NO3, scalar, series');
  %
  %%  endef(nc);
  %
  % record the time and close
  %
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'no3_time'), t*30);  % if time in month in the dataset !!!
  netcdf.close(ncid);
end
% %
% if (makeini)
% % Same thing for the Initial file
% %
% disp('Add_no3: creating variables and attributes for the Initial file')
% %
% % open the clim file

% nc=oct_netcdf(inifile,'write');
% redef(nc);
% nc{'NO3'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;

% nc{'NO3'}.long_name = ncchar('Nitrate');
% nc{'NO3'}.long_name = 'Nitrate';
% nc{'NO3'}.units = ncchar('mMol N m-3');
% nc{'NO3'}.units = 'mMol N m-3';

% endef(nc);
% close(nc)
% end

return
