%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a PISCES forcing file
%
%  Extrapole and interpole surface data to get surface boundary
%  conditions for PISCES (forcing netcdf file)
%
%  Data input format (netcdf):
%     irondep(T, Y, X)
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
disp(' ')
disp('Creating biology forcing file')
%
%  Title - Grid file name - Forcing file name
%
crocotools_param
%
% bioname
%
%bioname='croco_frcbio.nc'
%
% Dust deposition file 
%
%dust_file=[woapisces_dir,'dust.iron.cdf'];
%dust_name='irondep';
%dust_file=[woapisces_dir,'dust_seas.cdf'];
dust_file=[woapisces_dir,'DUST_INCA_new_r360x180.nc'];
dust_name='dust';
%time=woa_time;
time=[0.5:1:11.5];
cycle=woa_cycle;
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
ncid = netcdf.create(bioname, 'NC_CLOBBER');
%nc = oct_netcdf(bioname, 'write');
%%result = redef(nc);
%
did_xi_u = netcdf.defDim(ncid, 'xi_u', L);
did_xi_v = netcdf.defDim(ncid, 'xi_v', Lp);
did_xi_rho = netcdf.defDim(ncid, 'xi_rho', Lp);
did_eta_u = netcdf.defDim(ncid, 'eta_u', Mp);
did_eta_v = netcdf.defDim(ncid, 'eta_v', M);
did_eta_rho = netcdf.defDim(ncid, 'eta_rho', Mp);
%
did_dust_time = netcdf.defDim(ncid, 'dust_time', length(time));
vid_dust_time = netcdf.defVar(ncid, 'dust_time', 'NC_DOUBLE', did_dust_time);
vid_dust = netcdf.defVar(ncid, 'dust', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_dust_time]);
vid_dustfer = netcdf.defVar(ncid, 'dustfer', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_dust_time]);
vid_dustpo4 = netcdf.defVar(ncid, 'dustpo4', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_dust_time]);
vid_dustsi = netcdf.defVar(ncid, 'dustsi', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_dust_time]);
vid_solubility2 = netcdf.defVar(ncid, 'solubility2', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_dust_time]);
%
oct_write_time_attributes(ncid,'dust_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);

%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'dust'), 'long_name', 'Dust Deposition');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'dust'), 'units', 'Kg m-2 s-1');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'dust'), 'fields', 'dust, scalar, series');
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'dustfer'), 'long_name', 'Fe Dust Deposition');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'dustfer'), 'units', 'Kg m-2 s-1');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'dustfer'), 'fields', 'dustfer, scalar, series');
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'dustpo4'), 'long_name', 'PO4 Dust Deposition');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'dustpo4'), 'units', 'Kg m-2 s-1');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'dustpo4'), 'fields', 'dustpo4, scalar, series');
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'dustsi'), 'long_name', 'Si Dust Deposition');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'dustsi'), 'units', 'Kg m-2 s-1');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'dustsi'), 'fields', 'dustsi, scalar, series');
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'solubility2'), 'long_name', 'Fe solubility from Mahowald');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'solubility2'), 'units', ');  %';
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'solubility2'), 'fields', 'solubility2, scalar, series');
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
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'dust_time'), time.*30);  % if time in month in the dataset !!!

netcdf.close(ncid);

ncid = netcdf.open(bioname, 'NC_WRITE');
%
% Loop on time
%
for tindex=1:length(time)
  time=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'dust_time'));
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'dust'), tindex,:,:-1, 1, max(0.,oct_ext_data(dust_file,'dust',tindex,...);  % [conv] 0-based
             lon,lat,time,Roa,1));
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'dustfer'), tindex,:,:-1, 1, max(0.,oct_ext_data(dust_file,'dustfer',tindex,...);  % [conv] 0-based
             lon,lat,time,Roa,1));
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'dustpo4'), tindex,:,:-1, 1, max(0.,oct_ext_data(dust_file,'dustpo4',tindex,...);  % [conv] 0-based
             lon,lat,time,Roa,1));
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'dustsi'), tindex,:,:-1, 1, max(0.,oct_ext_data(dust_file,'dustsi',tindex,...);  % [conv] 0-based
             lon,lat,time,Roa,1));
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'solubility2'), tindex,:,:-1, 1, max(0.,oct_ext_data(dust_file,'solubility2',tindex,...);  % [conv] 0-based
             lon,lat,time,Roa,1));
end
netcdf.close(ncid);
if (makeplot)
%
% Make a few plots
%
disp(' Make a few plots...')
oct_test_bioforcing(bioname,grdname,'dust',[1 4 7 10],3,coastfileplot)
oct_test_bioforcing(bioname,grdname,'dustfer',[1 4 7 10],3,coastfileplot)
oct_test_bioforcing(bioname,grdname,'dustpo4',[1 4 7 10],3,coastfileplot)
oct_test_bioforcing(bioname,grdname,'dustsi',[1 4 7 10],3,coastfileplot)
end % if makeplot
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
