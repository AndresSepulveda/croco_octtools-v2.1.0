%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a PISCES forcing file
%
%  Extrapole and interpole surface data to get surface boundary
%  conditions for PISCES (forcing netcdf file)
%
%  Data input format (netcdf):
%     ndep(T, Y, X)
%     T : time [Months]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%  Data source : IRI/LDEO Climate Data Library 
%                (Atlas of Surface Marine Data 1994)
%
%    http://ingrid.ldgo.columbia.edu/
%    http://iridl.ldeo.columbia.edu/SOURCES/.DASILVA/
%
%  Pierrick Penven, IRD, 2005.                                    %
%  Olivier Aumont the master, IRD, 2006.                          %
%  Patricio Marchesiello, chief, IRD, 2007.                       %
%  Christophe Eugene Raoul Menkes, the slave, IRD, 2007.          %
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp('Creating biology forcing file')
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
%  Title - Grid file name - Forcing file name
%
crocotools_param
%
% bioname
%
%bioname='croco_frcbio.nc'
%
% Nitrogen deposition file 
%
ndep_file=[woapisces_dir,'Ndep_CMIP_NCAR-CCMI-2-0_gn_199001-201012-clim.nc'];
ndep_name='ndep';
%time=woa_time;
time=[0.5:1:11.5];
cycle=woa_cycle;
disp(' ')
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Read in the grid
%
disp(' ')
disp(' Read in the grid...')
ncid = netcdf.open(grdname, 'NC_NOWRITE');
[~,Lp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_rho'));
[~,Mp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_rho'));
L=Lp-1;
M=Mp-1;
lon=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'));
lat=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'));
angle=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'));
netcdf.close(ncid);
%
% create dust forcing file
%
disp(' Creating file')
%nc = oct_netcdf(bioname, 'clobber');
ncid = netcdf.open(bioname, 'NC_WRITE');
%%result = redef(nc);
%
did_xi_u = netcdf.defDim(ncid, 'xi_u', L);
did_xi_v = netcdf.defDim(ncid, 'xi_v', Lp);
did_xi_rho = netcdf.defDim(ncid, 'xi_rho', Lp);
did_eta_u = netcdf.defDim(ncid, 'eta_u', Mp);
did_eta_v = netcdf.defDim(ncid, 'eta_v', M);
did_eta_rho = netcdf.defDim(ncid, 'eta_rho', Mp);
%
did_ndepo_time = netcdf.defDim(ncid, 'ndepo_time', length(time));
vid_ndepo_time = netcdf.defVar(ncid, 'ndepo_time', 'NC_DOUBLE', did_ndepo_time);
vid_ndepo = netcdf.defVar(ncid, 'ndepo', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_ndepo_time]);
vid_noyndepo = netcdf.defVar(ncid, 'noyndepo', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_ndepo_time]);
vid_nhxndepo = netcdf.defVar(ncid, 'nhxndepo', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_ndepo_time]);
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ndepo_time'), 'long_name', 'time for nitrogen deposition');
oct_write_time_attributes(ncid,'ndepo_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ndepo'), 'long_name', 'Nitrogen Deposition');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ndepo'), 'units', 'KgN m-2 s-1');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ndepo'), 'fields', 'ndepo, scalar, series');
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'noyndepo'), 'long_name', 'NOy Deposition');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'noyndepo'), 'units', 'KgN m-2 s-1');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'noyndepo'), 'fields', 'noyndepo, scalar, series');
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'nhxndepo'), 'long_name', 'NHx Deposition');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'nhxndepo'), 'units', 'KgN m-2 s-1');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'nhxndepo'), 'fields', 'nhxndepo, scalar, series');
%
%%endef(nc);

% Create global attributes
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'title', CROCO_title);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'date', date);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'grd_file', grdname);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'type', 'CROCO biology forcing file');

% Write time variable
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ndepo_time'), time.*30);  % if time in month in the dataset !!!

netcdf.close(ncid);

ncid = netcdf.open(bioname, 'NC_WRITE');
%
% Loop on time
for tindex=1:length(time)
  time=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'ndepo_time'));
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ndepo'), tindex,:,:-1, 1, max(0.,oct_ext_data(ndep_file,'ndep',tindex,...);  % [conv] 0-based
             lon,lat,time,Roa,1));
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'noyndepo'), tindex,:,:-1, 1, max(0.,oct_ext_data(ndep_file,'noyndepo',tindex,...);  % [conv] 0-based
             lon,lat,time,Roa,1));
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'nhxndepo'), tindex,:,:-1, 1, max(0.,oct_ext_data(ndep_file,'nhxndepo',tindex,...);  % [conv] 0-based
             lon,lat,time,Roa,1));
end
%
netcdf.close(ncid);
if (makeplot)
%
% Make a few plots
%
disp(' Make a few plots...')
oct_test_bioforcing(bioname,grdname,'ndepo',[1 4 7 10],3,coastfileplot)
oct_test_bioforcing(bioname,grdname,'noyndepo',[1 4 7 10],3,coastfileplot)
oct_test_bioforcing(bioname,grdname,'nhxndepo',[1 4 7 10],3,coastfileplot)
end % if makeplot
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
