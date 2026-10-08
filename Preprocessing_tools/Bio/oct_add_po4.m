function oct_add_po4(oafile,climfile,inifile,gridfile,seas_datafile,...
  ann_datafile,cycle,makeoa,makeclim,makeini,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,po4]=oct_add_po4(climfile,gridfile,...
%                                       seas_datafile,ann_datafile,...
%                                       cycle);
%
%  pierrick 2001
%
%  Add phosphate (mMol P m-3) in a CROCO climatology file
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
%    [longrd,latgrd,po4] : surface field to plot (as an illustration)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
netcdf.close(ncid);
ncid = netcdf.open(ann_datafile, 'NC_NOWRITE');
zpo4=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Z'));
kmax=max(find(zpo4<hmax))-1;
zpo4=zpo4(1:kmax);
netcdf.close(ncid);
%
% open the OA file
%
if (makeoa)
  disp('Add_po4: creating variables and attributes for the OA file')
  ncid = netcdf.open(oafile, 'NC_WRITE');
  %%  redef(nc);
  did_po4_time = netcdf.defDim(ncid, 'po4_time', length(t));
  vid_po4_time = netcdf.defVar(ncid, 'po4_time', 'NC_DOUBLE', did_po4_time);
  did_Zpo4 = netcdf.defDim(ncid, 'Zpo4', length(zpo4));
  vid_Zpo4 = netcdf.defVar(ncid, 'Zpo4', 'NC_DOUBLE', did_Zpo4);
  vid_PO4 = netcdf.defVar(ncid, 'PO4', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_Zpo4, did_po4_time]);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'po4_time'), 'long_name', 'time for phosphate');
  oct_write_time_attributes(ncid,'po4_time',cycle,time_unit_att,time_second_unit_att,...
                        calendar_att,insecond,add_cycle);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zpo4'), 'long_name', 'Depth for PO4');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zpo4'), 'units', 'm');
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PO4'), 'long_name', 'Phosphate');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PO4'), 'units', 'mMol P m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PO4'), 'fields', 'PO4, scalar, series');
  %
  %%  endef(nc);
  %
  % record deth and time and close
  %
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'po4_time'), t*30);  % if time in month in the dataset !!!
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Zpo4'), zpo4);
  netcdf.close(ncid);
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_po4: creating variables and attributes for the Climatology file')
  %
  % open the clim file
  %
  ncid = netcdf.open(climfile, 'NC_WRITE');
  %%  redef(nc);
  did_po4_time = netcdf.defDim(ncid, 'po4_time', length(t););
  vid_po4_time = netcdf.defVar(ncid, 'po4_time', 'NC_DOUBLE', did_po4_time);
  vid_PO4 = netcdf.defVar(ncid, 'PO4', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_po4_time]);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'po4_time'), 'long_name', 'time for phosphate');
  oct_write_time_attributes(ncid,'po4_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PO4'), 'long_name', 'Phosphate');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PO4'), 'units', 'mMol P m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'PO4'), 'fields', 'PO4, scalar, series');
  %
  %%  endef(nc);
  %
  % record the time and close
  %
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'po4_time'), t*30);  % if time in month in the dataset !!!
  netcdf.close(ncid);
end
% if (makeini)
% % Same thing for the Initial file
% %
% disp('Add_po4: creating variables and attributes for the Initial file')
% %
% % open the clim file

% nc=oct_netcdf(inifile,'write');
% redef(nc);
% nc{'PO4'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;

% nc{'PO4'}.long_name = ncchar('Phosphate');
% nc{'PO4'}.long_name = 'Phosphate';
% nc{'PO4'}.units = ncchar('mMol P m-3');
% nc{'PO4'}.units = 'mMol P m-3';

% endef(nc);
% close(nc)
% end
return
