%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO climatology file
%
%  Extrapole and interpole temperature and salinity from a
%  Climatology to get boundary and initial conditions for
%  CROCO (climatology and initial netcdf files) .
%  Get data from ORCA 05 climatology
%
%  Data input format (netcdf):
%     temperature(T, Z, Y, X)
%     T : time [Months]
%     Z : Depth [m]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%  Data source : ORCA 05 Lionel Gourdeau 2005
%
%  Lefevre Jerome, IRD, 2005.
%
%  Version of 10-AUG-2005
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
%  Title 
%
title='Climatology';
%
%  Switches for selecting what to process (1=ON)
%
makeclim=1; %1: process boundary data
makeoa=1;   %1: process oa data
makeini=1;  %1: process initial data
%
%  Grid file name - Climatology file name
%  Initial file name - OA file name
%
%grdname='croco_fd_plat_3000m_grd.nc';
grdname='croco_grd.nc';
clmname='croco_clm_r05.nc';
ininame='croco_ini_r05.nc';
oaname ='croco_oa_r05.nc';

%
%  Vertical grid parameters
%  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%  !!! WARNING WARNING WARNING WARNING WARNING  !!!
%  !!!   THESE MUST IDENTICAL IN THE .IN FILE   !!!
%  !!! WARNING WARNING WARNING WARNING WARNING  !!!
%  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%
theta_s=6.;
theta_b=0.;
hc=5;
N=30; % number of vertical levels (rho)
%
%  Open boundaries switches
%  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%  !!! WARNING WARNING WARNING WARNING WARNING  !!!
%  !!!   MUST BE CONFORM TO THE CPP SWITCHES    !!!
%  !!! WARNING WARNING WARNING WARNING WARNING  !!!
%  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%
obc=[1 0 1 1]; % open boundaries (1=open , [S E N W])
%
%  Day of initialisationbarotropic_currents
%
tini=15;  
%
% Set times and cycles: monthly climatology for all data
%
time=[15:30:345];    % time 
cycle=365;           % cycle
%
%  Data climatology file name:
%
Dir_Data='/export/serveraid_vol0/CROCO_HOME/croco_tools/DATA_PACIFIC/ORCA05_clim/'
datafile=[Dir_Data,'ORCA05_monthly_clim.cdf'];
%
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
  disp(' Create the climatology file.oct_barotropic_currents..')
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
    ncid = netcdf.open(datafile, 'NC_NOWRITE');
  Z=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Z'));
  netcdf.close(ncid);
  oct_create_oafile(oaname,grdname,title,Z,...
                time,cycle,'clobber');
%
% Horizontal extrapolations 
%
  disp(' ')
  disp(' Horizontal interpolations')
  disp(' ')
  disp(' Temperature...')
  int_data_orca(oaname,datafile,'temp','lon_rho','lat_rho','TEMP','lonT','latT',1);
  disp(' ')
  disp(' Salinity...')
  int_data_orca(oaname,datafile,'salt','lon_rho','lat_rho','SALT','lonT','latT',1);
  disp(' ')
  disp(' U...')
  int_data_orca(oaname,datafile,'u','lon_u','lat_u','U','lonU','latT',1);
  disp(' ')
  disp(' V...')
  int_data_orca(oaname,datafile,'v','lon_v','lat_v','V','lonT','latV',1);
  disp(' ')
  disp(' ZETA...')
  int_data_orca(oaname,datafile,'zeta','lon_rho','lat_rho','SSH','lonT','latT',0);
  
  ncidoa = netcdf.open(oaname, 'NC_WRITE');
  netcdf.putVar(ncidoa, netcdf.inqVarID(ncidoa, 'ssh'), :,:,:-1, 1, netcdf.getVar(ncidoa, netcdf.inqVarID(ncidoa, 'zeta')));  % [conv] 0-based
  netcdf.close(ncidoa);
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
  disp(' ')
  disp(' U...')
  oct_vinterp_clm(clmname,grdname,oaname,'u','uclm_time','Z',0,'u');
  disp(' ')
  disp(' V...')
  oct_vinterp_clm(clmname,grdname,oaname,'v','vclm_time','Z',0,'v');
  disp(' ')
  disp(' ZETA...')
  oct_rem_avg_zeta(clmname,grdname,oaname)
  disp(' ')
  disp(' UBAR & VBAR...')
  oct_barotropic_currents(clmname,grdname,obc) 
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
  ncidini = netcdf.open(ininame, 'NC_WRITE');
ncidclm = netcdf.open(clmname, 'NC_NOWRITE');
		 
  tindex=find(time==tini)
  if isempty(tindex),
    disp('Error : Indice for tini is not found, chek')		 ;
  end  
  disp(' ')
  disp(' Temperature...')
  netcdf.putVar(ncidini, netcdf.inqVarID(ncidini, 'temp'), 1,:,:,:-1, 1, netcdf.getVar(ncidclm, netcdf.inqVarID(ncidclm, 'temp')));  % [conv] 0-based
  disp(' ')
  disp(' Salinity ...')
  netcdf.putVar(ncidini, netcdf.inqVarID(ncidini, 'salt'), 1,:,:,:-1, 1, netcdf.getVar(ncidclm, netcdf.inqVarID(ncidclm, 'salt')));  % [conv] 0-based
  disp(' ')
  disp(' U ...')
  netcdf.putVar(ncidini, netcdf.inqVarID(ncidini, 'u'), 1,:,:,:-1, 1, netcdf.getVar(ncidclm, netcdf.inqVarID(ncidclm, 'u')));  % [conv] 0-based
  disp(' ')
  disp(' V ...')
  netcdf.putVar(ncidini, netcdf.inqVarID(ncidini, 'v'), 1,:,:,:-1, 1, netcdf.getVar(ncidclm, netcdf.inqVarID(ncidclm, 'v')));  % [conv] 0-based
  disp(' ')
  disp(' UBAR & VBAR...')  
  netcdf.putVar(ncidini, netcdf.inqVarID(ncidini, 'ubar'), 1,:,:-1, 1, netcdf.getVar(ncidclm, netcdf.inqVarID(ncidclm, 'ubar')));  % [conv] 0-based
  netcdf.putVar(ncidini, netcdf.inqVarID(ncidini, 'vbar'), 1,:,:-1, 1, netcdf.getVar(ncidclm, netcdf.inqVarID(ncidclm, 'vbar')));  % [conv] 0-based
   netcdf.getVar(ncidini, netcdf.inqVarID(ncidini, 'vbar'))  
  disp(' ')
  disp(' ZETA...')      
  netcdf.putVar(ncidini, netcdf.inqVarID(ncidini, 'zeta'), 1,:,:-1, 1, netcdf.getVar(ncidclm, netcdf.inqVarID(ncidclm, 'zeta')));  % [conv] 0-based
   netcdf.getVar(ncidini, netcdf.inqVarID(ncidini, 'zeta')) 
  netcdf.close(ncidini);
  netcdf.close(ncidclm);
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
