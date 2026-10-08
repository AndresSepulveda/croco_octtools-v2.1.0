oct_start
crocotools_param
set(0,'defaultfigurevisible','off');
figure; oct_test_clim(clmname,grdname,'temp',1,coastfileplot); print('-dpng','p_clim.png');
figure; oct_test_clim(ininame,grdname,'salt',1,coastfileplot);
figure; oct_test_bry(bryname,grdname,'temp',1,obc); print('-dpng','p_bry.png');
figure; oct_test_bry(bryname,grdname,'u',1,obc);
figure; oct_test_forcing(frcname,grdname,'spd',[1 4 7 10],3,coastfileplot); print('-dpng','p_frc.png');
figure; oct_test_forcing(blkname,grdname,'tair',[1 4 7 10],3,coastfileplot);
figure; oct_plot_tide(grdname,frcname,1,0.5,2,coastfileplot); print('-dpng','p_tide.png');
figure; oct_clm_tides(grdname,frcname,Ntides,Ymin,Mmin,Dmin,Hmin,Min_min,Smin,Yorig,lon0,lat0,Z0);
disp('PLOTS OK')
