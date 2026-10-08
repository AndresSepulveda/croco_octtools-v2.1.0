function oct_add_fer(oafile,climfile,inifile,gridfile,seas_datafile,...
  ann_datafile,cycle,makeoa,makeclim,makeini,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,fer]=oct_add_fer(climfile,gridfile,...
%                                       seas_datafile,ann_datafile,...
%                                       cycle);
%
%  pierrick 2001
%
%  Add iron (mMol Fe m-3) in a CROCO climatology file
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
%    [longrd,latgrd,fer] : surface field to plot (as an illustration)
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
netcdf.close(ncid);
ncid = netcdf.open(ann_datafile, 'NC_NOWRITE');
zfer=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Z'));
kmax=max(find(zfer<hmax))-1;
zfer=zfer(1:kmax);
netcdf.close(ncid);
%
% open the OA file
%
if (makeoa)
  disp('Add_fer: creating variables and attributes for the OA file')
  ncid = netcdf.open(oafile, 'NC_WRITE');
  %%  redef(nc);
  did_fer_time = netcdf.defDim(ncid, 'fer_time', length(t));
  vid_fer_time = netcdf.defVar(ncid, 'fer_time', 'NC_DOUBLE', did_fer_time);
  did_Zfer = netcdf.defDim(ncid, 'Zfer', length(zfer));
  vid_Zfer = netcdf.defVar(ncid, 'Zfer', 'NC_DOUBLE', did_Zfer);
  vid_FER = netcdf.defVar(ncid, 'FER', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_Zfer, did_fer_time]);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'fer_time'), 'long_name', 'time for iron');
  oct_write_time_attributes(ncid,'fer_time',cycle,time_unit_att,time_second_unit_att,...
    calendar_att,insecond,add_cycle);

  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zfer'), 'long_name', 'Depth for FER');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zfer'), 'units', 'm');
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'FER'), 'long_name', 'Iron');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'FER'), 'units', 'uMol Fe m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'FER'), 'fields', 'FER, scalar, series');
  %
  %%  endef(nc);
  %
  % record deth and time and close
  %
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'fer_time'), t*30);  % if time in month in the dataset !!!
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Zfer'), zfer);
  netcdf.close(ncid);
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_fer: creating variables and attributes for the Climatology file')
  %
  % open the clim file
  %
  ncid = netcdf.open(climfile, 'NC_WRITE');
  %%  redef(nc);
  did_fer_time = netcdf.defDim(ncid, 'fer_time', length(t));
  vid_fer_time = netcdf.defVar(ncid, 'fer_time', 'NC_DOUBLE', did_fer_time);
  vid_FER = netcdf.defVar(ncid, 'FER', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_fer_time]);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'fer_time'), 'long_name', 'time for iron');
  oct_write_time_attributes(ncid,'fer_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'FER'), 'long_name', 'Iron');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'FER'), 'units', 'uMol Fe m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'FER'), 'fields', 'FER, scalar, series');
  %
  %%  endef(nc);
  %
  % record the time and close
  %
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'fer_time'), t*30);  % if time in month in the dataset !!!
  netcdf.close(ncid);
end
% if (makeini)
% disp('Add_fer: creating variables and attributes for the Initial file')
% %
% % open the clim file
% %
% nc=oct_netcdf(inifile,'write');
% redef(nc);
% nc{'FER'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
% %
% nc{'FER'}.long_name = ncchar('FER');
% nc{'FER'}.long_name = 'FER';
% nc{'FER'}.units = ncchar('uMol Fe m-3');
% nc{'FER'}.units = 'uMol Fe m-3';
% %
% endef(nc);
% close(nc)
% end
return
