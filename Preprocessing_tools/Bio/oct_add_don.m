function oct_add_don(oafile,climfile,inifile,gridfile,seas_datafile,...
                 ann_datafile,cycle,makeoa,makeclim,makequota,makeini,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,doc]=oct_add_doc(climfile,gridfile,...
%                                       seas_datafile,ann_datafile,...
%                                       cycle);
%
%  Add DOC (mMol C m-3) in a CROCO climatology file
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
%    [longrd,latgrd,doc] : surface field to plot (as an illustration)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
zdon=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Z'));
kmax=max(find(zdon<hmax))-1;
zdon=zdon(1:kmax);
%disp('Size zdon=')
size(zdon);
netcdf.close(ncid);
%
% open the OA file  
% 
if (makeoa)
  disp('Add_don: creating variables and attributes for the OA file')
  ncid = netcdf.open(oafile, 'NC_WRITE');
 % redef(nc);

  %Create Dimensions
  did_don_time = netcdf.defDim(ncid, 'don_time', length(t));
  %Create Variable
  vid_don_time = netcdf.defVar(ncid, 'don_time', 'NC_DOUBLE', did_don_time);
%
%%
%
  %Create Dimensions
  did_Zdon = netcdf.defDim(ncid, 'Zdon', length(zdon));
  %Create Variable
  vid_Zdon = netcdf.defVar(ncid, 'Zdon', 'NC_DOUBLE', did_Zdon);
%
%%
%
  %Create Variable
  vid_DON = netcdf.defVar(ncid, 'DON', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_Zdon, did_don_time]);
%
%%
%
  %Create Attribute

  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'don_time'), 'long_name', 'time for don');
  oct_write_time_attributes(ncid,'don_time',cycle,time_unit_att,time_second_unit_att,...
    calendar_att,insecond,add_cycle);

%%
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zdon'), 'long_name', 'Depth for DON');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zdon'), 'units', 'm');
%%%
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DON'), 'long_name', 'DON');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DON'), 'units', 'mMol C m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DON'), 'fields', 'DON, scalar, series');
%%%
%%  endef(nc);
%
%% Write variables
%% record deth and time and close
%
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'don_time'), t*30);  % if time in month in the dataset !!!
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Zdon'), zdon);
  netcdf.close(ncid);
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_don: creating variables and attributes for the Climatology file')
%
% open the clim file  
% 
  ncid = netcdf.open(climfile, 'NC_WRITE');
%  redef(nc);
  did_don_time = netcdf.defDim(ncid, 'don_time', length(t););
  vid_don_time = netcdf.defVar(ncid, 'don_time', 'NC_DOUBLE', did_don_time);
  vid_DON = netcdf.defVar(ncid, 'DON', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_don_time]);
%
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'don_time'), 'long_name', 'time for don');
  oct_write_time_attributes(ncid,'don_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);
%
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DON'), 'long_name', 'DON');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DON'), 'units', 'mMol C m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DON'), 'fields', 'DON, scalar, series');
%
%%  endef(nc);
%
% record the time and close
%
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'don_time'), t*30);  % if time in month in the dataset !!!
  netcdf.close(ncid);
end
% %
% % Same thing for the Initial file
% %
% if (makeini)
% disp('Add_don: creating variables and attributes for the Initial file')
% %
% % open the clim file  
% % 
% nc=oct_netcdf(inifile,'write');
% redef(nc);
% nc{'DON'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
% %
% nc{'DON'}.long_name = ncchar('DON');
% nc{'DON'}.long_name = 'DON';
% nc{'DON'}.units = ncchar('mMol C m-3');
% nc{'DON'}.units = 'mMol C m-3';
% %
% endef(nc);
% close(nc)
% end

return
