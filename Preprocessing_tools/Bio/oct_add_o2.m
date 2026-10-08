function oct_add_o2(oafile,climfile,inifile,gridfile,month_datafile,...
  ann_datafile,cycle,makeoa,makeclim,makeini,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,o2]=oct_add_o2(climfile,gridfile,...
%                                       month_datafile,ann_datafile,...
%                                       cycle);
%
%  pierrick 2001
%
%  Add oxygen (mMol 0 m-3) in a CROCO climatology file
%  take monthly data for the upper levels and annual data for the
%  lower levels
%
%  input:
%
%    climfile      : croco climatology file to process (netcdf)
%    gridfile      : croco grid file (netcdf)
%    month_datafile : regular longitude - latitude - z monthly data
%                    file used for the upper levels  (netcdf)
%    ann_datafile  : regular longitude - latitude - z annual data
%                    file used for the lower levels  (netcdf)
%    cycle         : time length (days) of climatology cycle (ex:360 for
%                    annual cycle) - 0 if no cycle.
%
%   output:
%
%    [longrd,latgrd,o2] : surface field to plot (as an illustration)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% options for oct_write_time_attributes
insecond =  0 ;
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
ncid = netcdf.open(month_datafile, 'NC_NOWRITE');
t=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'T'));
netcdf.close(ncid);
ncid = netcdf.open(ann_datafile, 'NC_NOWRITE');
zo2=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Z'));
kmax=max(find(zo2<hmax))-1;
zo2=zo2(1:kmax);
netcdf.close(ncid);
%
% open the OA file
%
if (makeoa)
  disp('Add_o2: creating variables and attributes for the OA file')
  ncid = netcdf.open(oafile, 'NC_WRITE');
  %%  redef(nc);
  did_o2_time = netcdf.defDim(ncid, 'o2_time', length(t));
  vid_o2_time = netcdf.defVar(ncid, 'o2_time', 'NC_DOUBLE', did_o2_time);
  did_Zo2 = netcdf.defDim(ncid, 'Zo2', length(zo2));
  vid_Zo2 = netcdf.defVar(ncid, 'Zo2', 'NC_DOUBLE', did_Zo2);
  vid_O2 = netcdf.defVar(ncid, 'O2', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_Zo2, did_o2_time]);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'o2_time'), 'long_name', 'time for oxygen');
  oct_write_time_attributes(ncid,'o2_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);

  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zo2'), 'long_name', 'Depth for O2');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zo2'), 'units', 'm');
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2'), 'long_name', 'Oxygen');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2'), 'units', 'mMol O m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2'), 'fields', 'O2, scalar, series');
  %
  %%  endef(nc);
  %
  % record depth and time and close
  %
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'o2_time'), t*30);  % ojo aqui quite *30 % if time in month in the dataset !!!
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Zo2'), squeeze(zo2));
  netcdf.close(ncid);
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_o2: creating variables and attributes for the Climatology file')
  %
  % open the clim file
  %
  ncid = netcdf.open(climfile, 'NC_WRITE');
  %% redef(nc);
  did_o2_time = netcdf.defDim(ncid, 'o2_time', length(t));
  vid_o2_time = netcdf.defVar(ncid, 'o2_time', 'NC_DOUBLE', did_o2_time);
  vid_O2 = netcdf.defVar(ncid, 'O2', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_o2_time]);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'o2_time'), 'long_name', 'time for oxygen');
  oct_write_time_attributes(ncid,'o2_time',cycle,time_unit_att,time_second_unit_att,...
                        calendar_att,insecond,add_cycle);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2'), 'long_name', 'Oxygen');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2'), 'units', 'mMol O m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'O2'), 'fields', 'O2, scalar, series');
  %
  %%  endef(nc);
  %
  % record the time and close
  %
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'o2_time'), :,:-1, 1, t*30);  % if time in month in the dataset !!!  % [conv] 0-based
  netcdf.close(ncid);
end
% %
% if (makeini)
% % Same thing for the Initial file
% %
% disp('Add_o2: creating variables and attributes for the Initial file')
% %
% % open the clim file

% nc=oct_netcdf(inifile,'write');
% redef(nc);
% nc{'O2'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;

% nc{'O2'}.long_name = ncchar('Oxygen');
% nc{'O2'}.long_name = 'Oxygen';
% nc{'O2'}.units = ncchar('mMol O m-3');
% nc{'O2'}.units = 'mMol O m-3';

% endef(nc);
% close(nc)
% end

return
