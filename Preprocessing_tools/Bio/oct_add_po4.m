function oct_add_po4(oafile,climfile,inifile,gridfile,seas_datafile,...
  ann_datafile,cycle,makeoa,makeclim,makeini,Yorig);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [longrd,latgrd,po4]=add_po4(climfile,gridfile,...
%                                       seas_datafile,ann_datafile,...
%                                       cycle);
%
%  pierrick 2001
%  Updated    Oct-2026 : Octave version (octave-netcdf, netcdf.* API)
%  Andres Sepulveda 2026 - Octave adaptations
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
% options for write_time_attributes
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
ncid=netcdf.open(gridfile,'NC_NOWRITE');
hmax=max(max(double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'h')))));
netcdf.close(ncid);
%
% read in the datafiles
%
ncid=netcdf.open(seas_datafile,'NC_NOWRITE');
t=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'T')));
t=t(:);
netcdf.close(ncid);
ncid=netcdf.open(ann_datafile,'NC_NOWRITE');
zpo4=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'Z')));
zpo4=zpo4(:);
kmax=max(find(zpo4<hmax))-1;
zpo4=zpo4(1:kmax);
netcdf.close(ncid);
%
% open the OA file
%
if (makeoa)
  disp('Add_po4: creating variables and attributes for the OA file')
  ncid=netcdf.open(oafile,'NC_WRITE');
  netcdf.reDef(ncid);
  %
  % Create dimensions and variables (netcdf.defVar: dims in reversed order)
  %
  did_t=oct_defdim(ncid,'po4_time',length(t));
  vid_t=oct_defvar(ncid,'po4_time','double',did_t);
  did_z=oct_defdim(ncid,'Zpo4',length(zpo4));
  vid_z=oct_defvar(ncid,'Zpo4','double',did_z);
  did_xi=netcdf.inqDimID(ncid,'xi_rho');
  did_eta=netcdf.inqDimID(ncid,'eta_rho');
  vid_v=oct_defvar(ncid,'PO4','double',[did_xi did_eta did_z did_t]);
  %
  % Create attributes
  %
  netcdf.putAtt(ncid,vid_t,'long_name','time for phosphate');
  oct_write_time_attributes(ncid,'po4_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);
  netcdf.putAtt(ncid,vid_z,'long_name','Depth for PO4');
  netcdf.putAtt(ncid,vid_z,'units','m');
  netcdf.putAtt(ncid,vid_v,'long_name','Phosphate');
  netcdf.putAtt(ncid,vid_v,'units','mMol P m-3');
  netcdf.putAtt(ncid,vid_v,'fields','PO4, scalar, series');
  netcdf.endDef(ncid);
  %
  % record depth and time and close
  %
  netcdf.putVar(ncid,vid_t,0,length(t),t*30); % if time in month in the dataset !!!
  netcdf.putVar(ncid,vid_z,0,length(zpo4),zpo4);
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
  ncid=netcdf.open(climfile,'NC_WRITE');
  netcdf.reDef(ncid);
  did_t=oct_defdim(ncid,'po4_time',length(t));
  vid_t=oct_defvar(ncid,'po4_time','double',did_t);
  did_s=netcdf.inqDimID(ncid,'s_rho');
  did_xi=netcdf.inqDimID(ncid,'xi_rho');
  did_eta=netcdf.inqDimID(ncid,'eta_rho');
  vid_v=oct_defvar(ncid,'PO4','double',[did_xi did_eta did_s did_t]);
  %
  netcdf.putAtt(ncid,vid_t,'long_name','time for phosphate');
  oct_write_time_attributes(ncid,'po4_time',cycle,time_unit_att,time_second_unit_att,...
                      calendar_att,insecond,add_cycle);
  %
  netcdf.putAtt(ncid,vid_v,'long_name','Phosphate');
  netcdf.putAtt(ncid,vid_v,'units','mMol P m-3');
  netcdf.putAtt(ncid,vid_v,'fields','PO4, scalar, series');
  netcdf.endDef(ncid);
  %
  % record the time and close
  %
  netcdf.putVar(ncid,vid_t,0,length(t),t*30); % if time in month in the dataset !!!
  netcdf.close(ncid);
end
%
% (the initial file part is commented out in the Matlab version)
%
return
