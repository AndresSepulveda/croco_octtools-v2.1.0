function oct_add_talk(oafile,climfile,inifile,gridfile,seas_datafile,...
  ann_datafile,cycle,makeoa,makeclim,makeini,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,talk]=oct_add_talk(climfile,gridfile,...
%                                       seas_datafile,ann_datafile,...
%                                       cycle);
%
%  pierrick 2001
%
%  Add talk (mMol P m-3) in a CROCO climatology file
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
%    [longrd,latgrd,talk] : surface field to plot (as an illustration)
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
ztalk=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Z'));
kmax=max(find(ztalk<hmax))-1;
ztalk=ztalk(1:kmax);
netcdf.close(ncid);
%
% open the OA file
%
if (makeoa)
  disp('Add_talk: creating variables and attributes for the OA file')
  ncid = netcdf.open(oafile, 'NC_WRITE');
  %%  redef(nc);
  did_talk_time = netcdf.defDim(ncid, 'talk_time', length(t));
  vid_talk_time = netcdf.defVar(ncid, 'talk_time', 'NC_DOUBLE', did_talk_time);
  did_Ztalk = netcdf.defDim(ncid, 'Ztalk', length(ztalk));
  vid_Ztalk = netcdf.defVar(ncid, 'Ztalk', 'NC_DOUBLE', did_Ztalk);
  vid_TALK = netcdf.defVar(ncid, 'TALK', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_Ztalk, did_talk_time]);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'talk_time'), 'long_name', 'time for TALK');
  oct_write_time_attributes(ncid,'talk_time',cycle,time_unit_att,time_second_unit_att,...
    calendar_att,insecond,add_cycle);
 
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Ztalk'), 'long_name', 'Depth for TALK');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Ztalk'), 'units', 'm');
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'TALK'), 'long_name', 'TALK');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'TALK'), 'units', 'mMol C m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'TALK'), 'fields', 'TALK, scalar, series');
  %
  %%  endef(nc);
  %
  % record deth and time and close
  %
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'talk_time'), t*30);  % if time in month in the dataset !!!
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Ztalk'), ztalk);
  netcdf.close(ncid);
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_talk: creating variables and attributes for the Climatology file')
  %
  % open the clim file
  %
  ncid = netcdf.open(climfile, 'NC_WRITE');
  %%  redef(nc);
  did_talk_time = netcdf.defDim(ncid, 'talk_time', length(t););
  vid_talk_time = netcdf.defVar(ncid, 'talk_time', 'NC_DOUBLE', did_talk_time);
  vid_TALK = netcdf.defVar(ncid, 'TALK', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_talk_time]);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'talk_time'), 'long_name', 'time for TALK');
  oct_write_time_attributes(ncid,'talk_time',cycle,time_unit_att,time_second_unit_att,...
    calendar_att,insecond,add_cycle);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'TALK'), 'long_name', 'TALK');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'TALK'), 'units', 'mMol C m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'TALK'), 'fields', 'TALK, scalar, series');
  %
  %%  endef(nc);
  %
  % record the time and close
  %
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'talk_time'), t*30);  % if time in month in the dataset !!!
  netcdf.close(ncid);
end
% %
% % Same thing for the Initial file
% %
% if (makeini)
% disp('Add_talk: creating variables and attributes for the Initial file')
% %
% % open the clim file
% %
% nc=oct_netcdf(inifile,'write');
% redef(nc);
% nc{'TALK'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
% %
% nc{'TALK'}.long_name = ncchar('TALK');
% nc{'TALK'}.long_name = 'TALK';
% nc{'TALK'}.units = ncchar('mMol C m-3');
% nc{'TALK'}.units = 'mMol C m-3';
% %
% endef(nc);
% close(nc)
% end

return
