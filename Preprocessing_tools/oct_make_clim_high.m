%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO climatology file
%
%  Extrapole and interpole temperature and salinity from a
%  Climatology to get boundary and initial conditions for
%  CROCO (climatology and initial netcdf files) .
%  Get the velocities and sea surface elevation via a 
%  geostrophic computation.
%
%  Data input format (netcdf):
%     temperature(T, Z, Y, X)
%     T : time [Months]
%     Z : Depth [m]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%  Data source : IRI/LDEO Climate Data Library (World Ocean Atlas 1998)
%    http://ingrid.ldgo.columbia.edu/
%    http://iridl.ldeo.columbia.edu/SOURCES/.NOAA/.NODC/.WOA98/
%
%  Pierrick Penven, IRD, 2002.
%  Pierrick Menkes, IRD, 2006.
%
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Common parameters
%
crocotools_param
%
%  Title 
%
title='Climatology';
%
%  Switches for selecting what to process (1=ON)
%
makeclim=1; %1: process boundary data
makeoa=1;   %1: process oa data
makeini=0;  %1: process initial data
%
%  Grid file name - Climatology file name
%  Initial file name - OA file name
%
grdname='croco_grd.nc';
frcname='croco_frc_ERS_smooth.nc'
%croco_frc.nc';
clmname='croco_clm_high.nc';
ininame='croco_ini.nc';
oaname ='croco_oa_high.nc';
%
%  Day of initialisation
%
tini=0;  
%
% Set times and cycles: monthly climatology for all data
%
time=[15:30:345];    % time 
cycle=365;           % cycle 
%
%  Data climatologies file names:
%
%    temp_month_data : monthly temperature climatology
%    temp_ann_data   : annual temperature climatology
%    salt_month_data : monthly salinity climatology
%    salt_ann_data   : annual salinity climatology
%
temp_month_data='../WOA2001/temp_month_corrected.cdf';
temp_ann_data='../WOA2001/temp_ann_corrected.cdf';
insitu2pot=1;   %1: transform in-situ temperature to potential temperature
salt_month_data='../WOA2001/salt_month_corrected.cdf';
salt_ann_data='../WOA2001/salt_ann_corrected.cdf';
%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Title
%
disp(' ')
disp([' Making the clim: ',clmname])
disp(' ')
disp([' Title: ',title])
%
% Read in the grid
%
disp(' ')
disp(' Read in the grid...')
ncid = netcdf.open(grdname, 'NC_NOWRITE');
[~,Lp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_rho'));
[~,Mp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_rho'));
hmax=max(max(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'))));
netcdf.close(ncid);
%
% Create the climatology file
%
if (makeclim)
  disp(' ')
  disp(' Create the climatology file...')
  oct_create_climfile(clmname,grdname,title,...
                  theta_s,theta_b,hc,N,...
                  time,cycle,'clobber');
end
%
% Create the OA file
%
if (makeoa)
  disp(' ')
  disp(' Create the OA file...')
  ncid = netcdf.open(temp_ann_data, 'NC_NOWRITE');
  Z=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Z'));
  kmax=max(find(Z<hmax))-1;
  Z=Z(1:kmax);
  netcdf.close(ncid);
  oct_create_oafile(oaname,grdname,title,Z,...
                time,cycle,'clobber');
%
% Horizontal extrapolations 
%
  disp(' ')
  disp(' Horizontal extrapolations')
  disp(' ')
  disp(' Temperature...')
  oct_ext_tracers(oaname,temp_month_data,temp_ann_data,...
              'temperature','temp','tclm_time','Z');
  disp(' ')
  disp(' Salinity...')
  oct_ext_tracers(oaname,salt_month_data,salt_ann_data,...
              'salinity','salt','sclm_time','Z');
end
%
% Vertical interpolations 
%
if (makeclim)
  disp(' ')
  disp(' Vertical interpolations')
  disp(' ')
  disp(' Temperature...')
  oct_vinterp_clm(clmname,grdname,oaname,'temp','tclm_time','Z',0,'r');
  disp(' ')
  disp(' Salinity...')
  oct_vinterp_clm(clmname,grdname,oaname,'salt','sclm_time','Z',0,'r');
  if (insitu2pot)
    disp(' ')
    disp(' Compute potential temperature from in-situ...')
    oct_getpot(clmname,grdname)
  end
%
% Geostrophy
%
  disp(' ')
  disp(' WARNING NO geostrophic currents IN THIS CLIM')
%  oct_geost_currents(clmname,grdname,oaname,frcname,zref,obc,0)
end
%
% Initial file
%
if (makeini)
  disp(' ')
  disp(' Initial')
  oct_create_inifile(ininame,grdname,title,...
                 theta_s,theta_b,hc,N,...
                 tini,'clobber');
  disp(' ')
  disp(' Temperature...')
  oct_vinterp_clm(ininame,grdname,oaname,'temp','tclm_time','Z',tini,'r',1);
  disp(' ')
  disp(' Salinity...')
  oct_vinterp_clm(ininame,grdname,oaname,'salt','sclm_time','Z',tini,'r',1);
  if (insitu2pot)
    disp(' ')
    disp(' Compute potential temperature from in-situ...')
    oct_getpot(ininame,grdname)
  end
end		 
%
% Make a few plots
%
disp(' ')
disp(' Make a few plots...')
oct_test_clim(clmname,grdname,'temp',1)
figure
oct_test_clim(clmname,grdname,'salt',1)
figure
oct_test_clim(clmname,grdname,'temp',6)
figure
oct_test_clim(clmname,grdname,'salt',6)
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
