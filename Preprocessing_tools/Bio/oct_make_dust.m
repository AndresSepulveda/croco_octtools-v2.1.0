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
%  Updated    Oct-2026 : Octave version (octave-netcdf, netcdf.* API)
%  Andres Sepulveda 2026 - Octave adaptations
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
% create dust forcing file
%
disp(' Creating file')
ncid = netcdf.create(bioname,'NC_CLOBBER');
%
did_xi_u    = netcdf.defDim(ncid,'xi_u',L);
did_xi_v    = netcdf.defDim(ncid,'xi_v',Lp);
did_xi_rho  = netcdf.defDim(ncid,'xi_rho',Lp);
did_eta_u   = netcdf.defDim(ncid,'eta_u',Mp);
did_eta_v   = netcdf.defDim(ncid,'eta_v',M);
did_eta_rho = netcdf.defDim(ncid,'eta_rho',Mp);
%
did_time = netcdf.defDim(ncid,'dust_time',length(time));
vid_time = netcdf.defVar(ncid,'dust_time','double',did_time);
dims3 = [did_xi_rho did_eta_rho did_time];   % (dust_time,eta_rho,xi_rho)
vnames = {'dust','dustfer','dustpo4','dustsi','solubility2'};
lnames = {'Dust Deposition','Fe Dust Deposition','PO4 Dust Deposition',...
          'Si Dust Deposition','Fe solubility from Mahowald'};
units  = {'Kg m-2 s-1','Kg m-2 s-1','Kg m-2 s-1','Kg m-2 s-1','%'};
for n=1:length(vnames)
  netcdf.defVar(ncid,vnames{n},'double',dims3);
end
%
oct_write_time_attributes(ncid,'dust_time',cycle,time_unit_att,time_second_unit_att,...
  calendar_att,insecond,add_cycle);
%
for n=1:length(vnames)
  vid=netcdf.inqVarID(ncid,vnames{n});
  netcdf.putAtt(ncid,vid,'long_name',lnames{n});
  netcdf.putAtt(ncid,vid,'units',units{n});
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
vid_time=netcdf.inqVarID(ncid,'dust_time');
%
% Loop on time
%
for tindex=1:length(time)
  time=double(netcdf.getVar(ncid,vid_time,tindex-1,1));
  for n=1:length(vnames)
    % nc{var}(tindex,:,:)=X  ->  Fortran order [xi eta time]
    data=max(0.,oct_ext_data(dust_file,vnames{n},tindex,lon,lat,time,Roa,1));
    netcdf.putVar(ncid,netcdf.inqVarID(ncid,vnames{n}),[0 0 tindex-1],[Lp Mp 1],data.');
  end
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
