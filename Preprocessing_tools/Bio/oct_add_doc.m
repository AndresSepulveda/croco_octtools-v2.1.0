function oct_add_doc(oafile,climfile,inifile,gridfile,seas_datafile,...
  ann_datafile,cycle,makeoa,makeclim,makeini,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,doc]=oct_add_doc(climfile,gridfile,...
%                                       seas_datafile,ann_datafile,...
%                                       cycle);
%
%  pierrick 2001
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
zdoc=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Z'));
kmax=max(find(zdoc<hmax))-1;
zdoc=zdoc(1:kmax);
netcdf.close(ncid);
%
% open the OA file
%
if (makeoa)
  disp('Add_doc: creating variables and attributes for the OA file')
  ncid = netcdf.open(oafile, 'NC_WRITE');
  %%  redef(nc);
  did_doc_time = netcdf.defDim(ncid, 'doc_time', length(t));
  vid_doc_time = netcdf.defVar(ncid, 'doc_time', 'NC_DOUBLE', did_doc_time);
  did_Zdoc = netcdf.defDim(ncid, 'Zdoc', length(zdoc));
  vid_Zdoc = netcdf.defVar(ncid, 'Zdoc', 'NC_DOUBLE', did_Zdoc);
  vid_DOC = netcdf.defVar(ncid, 'DOC', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_Zdoc, did_doc_time]);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'doc_time'), 'long_name', 'time for doc');
  oct_write_time_attributes(ncid,'doc_time',cycle,time_unit_att,time_second_unit_att,...
    calendar_att,insecond,add_cycle);

  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zdoc'), 'long_name', 'Depth for DOC');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Zdoc'), 'units', 'm');
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOC'), 'long_name', 'DOC');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOC'), 'units', 'mMol C m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOC'), 'fields', 'DOC, scalar, series');
  %
  %%  endef(nc);
  %
  % record deth and time and close
  %
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'doc_time'), t*30);  % if time in month in the dataset !!!
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Zdoc'), zdoc);
  netcdf.close(ncid);
end
%
% Same thing for the Clim file
%
if (makeclim)
  disp('Add_doc: creating variables and attributes for the Climatology file')
  %
  % open the clim file
  %
  ncid = netcdf.open(climfile, 'NC_WRITE');
  %%  redef(nc);
  did_doc_time = netcdf.defDim(ncid, 'doc_time', length(t););
  vid_doc_time = netcdf.defVar(ncid, 'doc_time', 'NC_DOUBLE', did_doc_time);
  vid_DOC = netcdf.defVar(ncid, 'DOC', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_doc_time]);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'doc_time'), 'long_name', 'time for doc');
  oct_write_time_attributes(ncid,'doc_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);
  %
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOC'), 'long_name', 'DOC');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOC'), 'units', 'mMol C m-3');
  % [conv] línea ncchar duplicada omitida
  netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'DOC'), 'fields', 'DOC, scalar, series');
  %
  %%  endef(nc);
  %
  % record the time and close
  %
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'doc_time'), t*30);  % if time in month in the dataset !!!
  netcdf.close(ncid);
end
% %
% % Same thing for the Initial file
% %
% if (makeini)
% disp('Add_doc: creating variables and attributes for the Initial file')
% %
% % open the clim file
% %
% nc=oct_netcdf(inifile,'write');
% redef(nc);
% nc{'DOC'} = ncdouble('time','s_rho','eta_rho','xi_rho') ;
% %
% nc{'DOC'}.long_name = ncchar('DOC');
% nc{'DOC'}.long_name = 'DOC';
% nc{'DOC'}.units = ncchar('mMol C m-3');
% nc{'DOC'}.units = 'mMol C m-3';
% %
% endef(nc);
% close(nc)
% end

return
