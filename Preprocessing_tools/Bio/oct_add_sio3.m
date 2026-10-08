function oct_add_sio3(oafile,climfile,inifile,gridfile,seas_datafile,...
  ann_datafile,cycle,makeoa,makeclim,makeini,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,sio3]=oct_add_sio3(climfile,gridfile,...
%                                       seas_datafile,ann_datafile,...
%                                       cycle);
%
%  pierrick 2001
%
%  Add silicate (mMol Si m-3) in a CROCO climatology file
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
%    [longrd,latgrd,SiO3] : surface field to plot (as an illustration)
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
zsi=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Z'));
kmax=max(find(zsi<hmax))-1;
zsi=zsi(1:kmax);
netcdf.close(ncid);
%
% open the OA file
%
if (makeoa)
  disp('Add_sio3: creating variables and attributes for the OA file')
  ncid = netcdf.open(oafile, 'NC_WRITE');
  %%  redef(nc);
  did_si_time = netcdf.defDim(ncid, 'si_time', length(t));
  vid_si_time = netcdf.defVar(ncid, 'si_time', 'NC_DOUBLE', did_si_time);
  did_Zsi = netcdf.defDim(ncid, 'Zsi', length(zsi));
  vid_Zsi = netcdf.defVar(ncid, 'Zsi', 'NC_DOUBLE', did_Zsi);
  vid_Si = netcdf.defVar(ncid, 'Si', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_Zsi, did_si_time]);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'si_time'), 'long_name', 'time for silicate');
  oct_write_time_attributes(ncid,'si_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zsi'), 'long_name', 'Depth for Si');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zsi'), 'units', 'm');
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Si'), 'long_name', 'Silicate');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Si'), 'units', 'mMol Si m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Si'), 'fields', 'Si, scalar, series');
  %
  %%  endef(nc);
  %
  % record deth and time and close
  %
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'si_time'), t*30);  % if time in month in the dataset !!!
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Zsi'), zsi);
  netcdf.close(ncid);
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_sio3: creating variables and attributes for the Climatology file')
  %
  % open the clim file
  %
  ncid = netcdf.open(climfile, 'NC_WRITE');
  %%  redef(nc);
  did_si_time = netcdf.defDim(ncid, 'si_time', length(t););
  vid_si_time = netcdf.defVar(ncid, 'si_time', 'NC_DOUBLE', did_si_time);
  vid_Si = netcdf.defVar(ncid, 'Si', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_si_time]);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'si_time'), 'long_name', 'time for silicate');
  oct_write_time_attributes(ncid,'si_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Si'), 'long_name', 'Silicate');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Si'), 'units', 'mMol Si m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Si'), 'fields', 'Si, scalar, series');
  %
  %%  endef(nc);
  %
  % record the time and close
  %
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'si_time'), t*30);  % if time in month in the dataset !!!
  netcdf.close(ncid);
end
% if (makeini)
% % Same thing for the Initial file
% %
% disp('Add_si: creating variables and attributes for the Initial file')
% %
% % open the clim file

% nc=oct_netcdf(inifile,'write');
% redef(nc);
% nc{'Si'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;

% nc{'Si'}.long_name = ncchar('Silicate');
% nc{'Si'}.long_name = 'Silicate';
% nc{'Si'}.units = ncchar('mMol Si m-3');
% nc{'Si'}.units = 'mMol Si m-3';

% endef(nc);
% close(nc)
% end
return
