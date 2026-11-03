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
%  Updated    Oct-2026 : Octave version (octave-netcdf, netcdf.* API)
%  Andres Sepulveda 2026 - Octave adaptations
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
ncid=netcdf.open(grdname,'NC_NOWRITE');
[~,Lp]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'xi_rho'));
[~,Mp]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'eta_rho'));
L=Lp-1;
M=Mp-1;
lon=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lon_rho'))).';
lat=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lat_rho'))).';
angle=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'angle'))).';
netcdf.close(ncid);
%
% add the N deposition to the (existing) biology forcing file
% (created by oct_make_dust.m)
%
disp(' Creating file')
ncid = netcdf.open(bioname,'NC_WRITE');
netcdf.reDef(ncid);
%
% horizontal dimensions: defined only if they do not exist yet
%
dnames={'xi_u','xi_v','xi_rho','eta_u','eta_v','eta_rho'};
dlens =[L Lp Lp Mp M Mp];
for n=1:length(dnames)
  try
    netcdf.inqDimID(ncid,dnames{n});
  catch
    netcdf.defDim(ncid,dnames{n},dlens(n));
  end
end
did_xi_rho  = netcdf.inqDimID(ncid,'xi_rho');
did_eta_rho = netcdf.inqDimID(ncid,'eta_rho');
%
did_time = netcdf.defDim(ncid,'ndepo_time',length(time));
vid_time = netcdf.defVar(ncid,'ndepo_time','double',did_time);
dims3 = [did_xi_rho did_eta_rho did_time];   % (ndepo_time,eta_rho,xi_rho)
vnames = {'ndepo','noyndepo','nhxndepo'};
dnames = {'ndep','noyndepo','nhxndepo'};     % names in the data file
lnames = {'Nitrogen Deposition','NOy Deposition','NHx Deposition'};
for n=1:length(vnames)
  netcdf.defVar(ncid,vnames{n},'double',dims3);
end
%
netcdf.putAtt(ncid,vid_time,'long_name','time for nitrogen deposition');
oct_write_time_attributes(ncid,'ndepo_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);
%
for n=1:length(vnames)
  vid=netcdf.inqVarID(ncid,vnames{n});
  netcdf.putAtt(ncid,vid,'long_name',lnames{n});
  netcdf.putAtt(ncid,vid,'units','KgN m-2 s-1');
  netcdf.putAtt(ncid,vid,'fields',[vnames{n},', scalar, series']);
end
%
% Create global attributes
%
gid=netcdf.getConstant('NC_GLOBAL');
netcdf.putAtt(ncid,gid,'title',CROCO_title);
netcdf.putAtt(ncid,gid,'date',date);
netcdf.putAtt(ncid,gid,'grd_file',grdname);
netcdf.putAtt(ncid,gid,'type','CROCO biology forcing file');
netcdf.endDef(ncid);
%
% Write time variable
%
netcdf.putVar(ncid,vid_time,0,length(time),time.*30); % if time in month in the dataset !!!

netcdf.close(ncid);

ncid=netcdf.open(bioname,'NC_WRITE');
vid_time=netcdf.inqVarID(ncid,'ndepo_time');
%
% Loop on time
for tindex=1:length(time)
  time=double(netcdf.getVar(ncid,vid_time,tindex-1,1));
  for n=1:length(vnames)
    % nc{var}(tindex,:,:)=X  ->  Fortran order [xi eta time]
    data=max(0.,oct_ext_data(ndep_file,dnames{n},tindex,lon,lat,time,Roa,1));
    netcdf.putVar(ncid,netcdf.inqVarID(ncid,vnames{n}),[0 0 tindex-1],[Lp Mp 1],data.');
  end
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
