oct_start; set(0,'defaultfigurevisible','off');
P=[pwd,'/NEST/']; pg=[P,'croco_grd.nc']; cg=[P,'croco_grd.nc.1'];
g=netcdf.open(pg,'NC_NOWRITE'); [~,L]=netcdf.inqDim(g,netcdf.inqDimID(g,'xi_rho')); [~,M]=netcdf.inqDim(g,netcdf.inqDimID(g,'eta_rho'));
lon=netcdf.getVar(g,netcdf.inqVarID(g,'lon_rho')); netcdf.close(g);
f=[P,'dust_par.nc']; nc=netcdf.create(f,'NC_CLOBBER');
dx=netcdf.defDim(nc,'xi_rho',L); de=netcdf.defDim(nc,'eta_rho',M); dt=netcdf.defDim(nc,'dust_time',12);
vt=netcdf.defVar(nc,'dust_time','double',dt); vd=netcdf.defVar(nc,'dust','double',[dx de dt]);
netcdf.putAtt(nc,vd,'long_name','dust deposition');
netcdf.putAtt(nc,netcdf.getConstant('NC_GLOBAL'),'type','dust'); netcdf.endDef(nc);
netcdf.putVar(nc,vt,15:30:360); netcdf.putVar(nc,vd,[0 0 0],[L M 12],repmat(double(lon),[1 1 12])+reshape(1:12,1,1,12));
netcdf.close(nc);
oct_nested_file(cg,f,[P,'dust_par.nc.1'],'dust test',0,0);
figure; oct_plot_nestdust([P,'dust_par.nc.1'],'dust',[1 6],1); print('-dpng','pdust.png');
disp('DUST OK')
