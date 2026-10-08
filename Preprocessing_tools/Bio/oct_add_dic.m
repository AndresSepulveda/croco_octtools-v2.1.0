function oct_add_dic(oafile,climfile,inifile,gridfile,seas_datafile,...
  ann_datafile,cycle,makeoa,makeclim,makeini,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,dic]=oct_add_dic(climfile,gridfile,...
%                                       seas_datafile,ann_datafile,...
%                                       cycle);
%
%  pierrick 2001
%
%  Add DIC (mMol C m-3) in a CROCO climatology file
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
%    [longrd,latgrd,dic] : surface field to plot (as an illustration)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% options for oct_write_time_attributes
insecond = 0 ;
add_cycle = 1 ; 
%
%
% Initialize Yorig if not provided
if ~exist('Yorig', 'var') ,  Yorig = [] ; , end
%
% Get time attributes
[time_unit_att,time_second_unit_att,calendar_att]=...
                    oct_get_time_attributes(Yorig);
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
zdic=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Z'));
kmax=max(find(zdic<hmax))-1;
zdic=zdic(1:kmax);
netcdf.close(ncid);
%
% open the OA file
%
if (makeoa)
  disp('Add_dic: creating variables and attributes for the OA file')
  ncid = netcdf.open(oafile, 'NC_WRITE');
  %%  redef(nc);
  did_dic_time = netcdf.defDim(ncid, 'dic_time', length(t));
  vid_dic_time = netcdf.defVar(ncid, 'dic_time', 'NC_DOUBLE', did_dic_time);
  did_Zdic = netcdf.defDim(ncid, 'Zdic', length(zdic));
  vid_Zdic = netcdf.defVar(ncid, 'Zdic', 'NC_DOUBLE', did_Zdic);
  vid_DIC = netcdf.defVar(ncid, 'DIC', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_Zdic, did_dic_time]);
  oct_write_time_attributes(ncid,'dic_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);
  
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zdic'), 'long_name', 'Depth for DIC');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zdic'), 'units', 'm');
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DIC'), 'long_name', 'DIC');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DIC'), 'units', 'mMol C m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DIC'), 'fields', 'DIC, scalar, series');
  %
  %%  endef(nc);
  %
  % record deth and time and close
  %
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'dic_time'), t*30);  % if time in month in the dataset !!!
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Zdic'), zdic);
  netcdf.close(ncid);
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_dic: creating variables and attributes for the Climatology file')
  %
  % open the clim file
  %
  ncid = netcdf.open(climfile, 'NC_WRITE');
  %%  redef(nc);
  did_dic_time = netcdf.defDim(ncid, 'dic_time', length(t););
  vid_dic_time = netcdf.defVar(ncid, 'dic_time', 'NC_DOUBLE', did_dic_time);
  vid_DIC = netcdf.defVar(ncid, 'DIC', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_dic_time]);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'dic_time'), 'long_name', 'time for DIC');
  oct_write_time_attributes(ncid,'dic_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DIC'), 'long_name', 'DIC');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DIC'), 'units', 'mMol C m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DIC'), 'fields', 'DIC, scalar, series');
  %
  %%  endef(nc);
  %
  % record the time and close
  %
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'dic_time'), t*30);  % if time in month in the dataset !!!
  netcdf.close(ncid);
end
% %
% % Same thing for the Initial file
% if (makeini)
% %
% disp('Add_dic: creating variables and attributes for the Initial file')
% %
% % open the clim file
% %
% nc=oct_netcdf(inifile,'write');
% redef(nc);
% nc{'DIC'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
% %
% nc{'DIC'}.long_name = ncchar('DIC');
% nc{'DIC'}.long_name = 'DIC';
% nc{'DIC'}.units = ncchar('mMol C m-3');
% nc{'DIC'}.units = 'mMol C m-3';
% endef(nc);
% close(nc)
% end




return
