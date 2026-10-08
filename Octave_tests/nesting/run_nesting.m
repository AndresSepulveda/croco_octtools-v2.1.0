oct_start
crocotools_param
set(0,'defaultfigurevisible','off');
P=[pwd,'/NEST/'];  C=[pwd,'/CROCO_FILES/'];
pg=[P,'croco_grd.nc']; cg=[P,'croco_grd.nc.1'];
% child in the SE part of the parent, new topography, match volume
[i1,i2,j1,j2]=oct_nested_grid(pg,cg,10,25,8,22,3,topofile,1,0.25,15,hmin,1,500,4,2);
disp([i1 i2 j1 j2])
oct_nested_forcing(cg,[C,'croco_frc.nc'],[P,'croco_frc.nc.1'])
oct_nested_bulk(cg,[C,'croco_blk.nc'],[P,'croco_blk.nc.1'])
oct_nested_initial(cg,[C,'croco_ini.nc'],[P,'croco_ini.nc.1'],1,1,0,0,0)
oct_nested_clim(cg,[C,'croco_clm.nc'],[P,'croco_clm.nc.1'],1,1,0,0,0)
oct_nested_restart(cg,[C,'croco_rst.nc'],[P,'croco_rst.nc.1'],1,1)
disp('NEST OK')
