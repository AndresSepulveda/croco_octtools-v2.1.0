%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO initial file from Global Atlas (WOA or CARS)
%
%  Extrapole and interpole fields from a
%  Climatology to get initial conditions for
%  CROCO (initial netcdf files) .
%
%  Data input format (netcdf):
%     variable(T, Z, Y, X)
%     T : time [Months]
%     Z : Depth [m]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%  Data source : IRI/LDEO Climate Data Library (World Ocean Atlas 1998)
%    http://ingrid.ldgo.columbia.edu/
%    http://iridl.ldeo.columbia.edu/SOURCES/.NOAA/.NODC/.WOA98/
%
%  Pierrick Penven, IRD, 2005.
%  Olivier Aumont, IRD, 2006.
%  Patricio Marchesiello, IRD 2007
%  Christophe Eugene Raoul Menkes, IRD 2013
%  Elodie Gutknecht, 2013
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
%  Title 
%
crocotools_param
%
%  Data climatologies file names:
%
no3_seas_data=[climato_dir,'no3_month.cdf'];
no3_ann_data=[climato_dir,'no3_ann.cdf'];
o2_seas_data=[climato_dir,'o2_month.cdf'];
o2_ann_data=[climato_dir,'o2_ann.cdf'];
chla_seas_data=[chla_dir,'chla_seas.cdf'];

NO3min=0.01;
O2min=0.01;
%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
disp('')
disp('====================================================== ')
disp('=> You need the croco_oa.nc file created by oct_make_clim.m ')
disp('=> with makeoa=1 from crocotools_param.m                ')
disp('====================================================== ')
%
% Add variables in the files
%
oct_add_no3(oaname,clmname,ininame,grdname,no3_seas_data,...
        no3_ann_data,woa_cycle,makeoa,makeclim)

oct_add_o2(oaname,clmname,ininame,grdname,o2_seas_data,...
        o2_ann_data,woa_cycle,makeoa,makeclim)

	
%
% Horizontal extrapolation
%
if (makeoa)

  oct_ext_tracers(oaname,no3_seas_data,no3_ann_data,...
              'nitrate','NO3','no3_time','Zno3',Roa);

  oct_ext_tracers(oaname,o2_seas_data,o2_ann_data,...
              'oxygen','O2','o2_time','Zo2',Roa);

end


%
% Vertical interpolations 
%
if (makeclim)
  disp(' ')
  disp(' Vertical interpolations')
  disp(' ')
  disp(' O2...')
  oct_vinterp_clm(clmname,grdname,oaname,'O2','o2_time','Zo2',0,'r');  
  disp(' ')
  disp(' NO3...')
  oct_vinterp_clm(clmname,grdname,oaname,'NO3','no3_time','Zno3',0,'r');
%
% Remove low values for oligotrophic areas
%
  ncid = netcdf.open(clmname, 'NC_WRITE');
  [~,tlen]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'no3_time'));
  for l=1:tlen
    NO3=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'NO3'));
    NO3(NO3<NO3min)=NO3min;
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'NO3'), l,:,:,:-1, 1, NO3);  % [conv] 0-based
  end
  netcdf.close(ncid);
  
  ncid = netcdf.open(clmname, 'NC_WRITE');
  [~,tlen]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'o2_time'));
  for l=1:tlen
    O2=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'O2'));
    O2(O2<O2min)=O2min;
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'O2'), l,:,:,:-1, 1, O2);  % [conv] 0-based
  end
  netcdf.close(ncid);
 
  
%
%  CHla		 
  disp(' ')
  disp(' CHla...')
  oct_add_chla(clmname,grdname,chla_seas_data,woa_cycle,Roa);
%
%  Phyto		 
  disp(' ')
  disp(' Phyto...')
  oct_add_phyto(clmname);
%
%  Zoo
  disp(' ')
  disp(' Zoo...')
  oct_add_zoo(clmname);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% Make a few plots
%

if (makeplot)
  disp(' ')
  disp(' Make a few plots...')
  oct_test_clim(clmname,grdname,'O2',1,coastfileplot)
  figure
  oct_test_clim(clmname,grdname,'NO3',1,coastfileplot)
  figure
  oct_test_clim(clmname,grdname,'CHLA',1,coastfileplot)
  figure
  oct_test_clim(clmname,grdname,'PHYTO',1,coastfileplot)
end 

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



