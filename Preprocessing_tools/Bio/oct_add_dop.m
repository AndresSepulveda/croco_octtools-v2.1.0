function oct_add_dop(oafile,climfile,inifile,gridfile,seas_datafile,...
                 ann_datafile,cycle,makeoa,makeclim,makequota,makeini,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,dop]=oct_add_dop(climfile,gridfile,...
%                                       seas_datafile,ann_datafile,...
%                                       cycle);
%
%  Add DOP (mMol C m-3) in a CROCO climatology file
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
%    [longrd,latgrd,dop] : surface field to plot (as an illustration)
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
zdop=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Z'));
kmax=max(find(zdop<hmax))-1;
zdop=zdop(1:kmax);
%disp('Size zdop=')
size(zdop);
netcdf.close(ncid);
%
% open the OA file  
% 
if (makeoa)
  disp('Add_dop: creating variables and attributes for the OA file')
  ncid = netcdf.open(oafile, 'NC_WRITE');
%  redef(nc);

  %Create Dimensions
  did_dop_time = netcdf.defDim(ncid, 'dop_time', length(t));
  %Create Variable
  vid_dop_time = netcdf.defVar(ncid, 'dop_time', 'NC_DOUBLE', did_dop_time);
%
%%
%
  %Create Dimensions
  did_Zdop = netcdf.defDim(ncid, 'Zdop', length(zdop));
  %Create Variable
  vid_Zdop = netcdf.defVar(ncid, 'Zdop', 'NC_DOUBLE', did_Zdop);
%
%%
%
  %Create Variable
  vid_DOP = netcdf.defVar(ncid, 'DOP', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_Zdop, did_dop_time]);
%
%%
%
  %Create Attribute

  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'dop_time'), 'long_name', 'time for dop');
  oct_write_time_attributes(ncid,'dop_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);
%
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zdop'), 'long_name', 'Depth for DOP');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zdop'), 'units', 'm');
%
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOP'), 'long_name', 'DOP');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOP'), 'units', 'mMol C m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOP'), 'fields', 'DOP, scalar, series');
%
%%  endef(nc);
%
%% Write variables
% record deth and time and close
%
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'dop_time'), t*30);  % if time in month in the dataset !!!
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Zdop'), zdop);
  netcdf.close(ncid);
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_dop: creating variables and attributes for the Climatology file')
%
% open the clim file  
% 
  ncid = netcdf.open(climfile, 'NC_WRITE');
%%  redef(nc);
  did_dop_time = netcdf.defDim(ncid, 'dop_time', length(t););
  vid_dop_time = netcdf.defVar(ncid, 'dop_time', 'NC_DOUBLE', did_dop_time);
  vid_DOP = netcdf.defVar(ncid, 'DOP', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_dop_time]);
%
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'dop_time'), 'long_name', 'time for dop');
  oct_write_time_attributes(ncid,'dop_time',cycle,time_unit_att,time_second_unit_att,...
    calendar_att,insecond,add_cycle);
%
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOP'), 'long_name', 'DOP');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOP'), 'units', 'mMol C m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOP'), 'fields', 'DOP, scalar, series');
%
%%  endef(nc);
%
% record the time and close
%
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'dop_time'), t*30);  % if time in month in the dataset !!!
  netcdf.close(ncid);
end
% %
% if (makeini)
% disp('Add_dop: creating variables and attributes for the Initial file')
% %
% % open the clim file
% %
% nc=oct_netcdf(inifile,'write');
% redef(nc);
% nc{'DOP'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
% %
% nc{'DOP'}.long_name = ncchar('DOP');
% nc{'DOP'}.long_name = 'DOP';
% nc{'DOP'}.units = ncchar('mMol C m-3');
% nc{'DOP'}.units = 'mMol C m-3';
% %
% endef(nc);
% close(nc)
% end

return
