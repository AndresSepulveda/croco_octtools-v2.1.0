oct_start; set(0,'defaultfigurevisible','off');
H=[pwd,'/CROCO_FILES/croco_his.nc']; G=[pwd,'/CROCO_FILES/croco_grd.nc'];
dv={'temp','salt','u','v','w','zeta','ubar','AKt','hbl','h','*Ke','*Rho','*Rho_pot','*Bvf','*Vort','*Pot_vort','*Psi','*Speed','*Transport','*Okubo','*z_SST-1C','*z_rho-1.25','*z_max_bvf','*z_max_dTdZ','*z_20C','*z_15C','*z_sig27','*z_sig26','*Lorbacher_MLD','*rfactor'};
bad=0;
for vl=[-50 32 0]
for k=1:numel(dv)
  try
    [la,lo,m,v]=oct_get_var(H,G,dv{k},3,vl,1,[1 1 1 1]);
    nf=sum(isfinite(v(:)));
    printf('%-16s vl=%4d %s finite=%4d range [%g %g]\n',dv{k},vl,mat2str(size(v)),nf,min(v(:)),max(v(:)));
    if ~isequal(size(v),size(la)), printf('   SIZE MISMATCH\n'); bad=bad+1; end
  catch e
    printf('%-16s vl=%4d ERROR %s (%s:%d)\n',dv{k},vl,e.message,e.stack(1).name,e.stack(1).line); bad=bad+1;
  end
end
end
printf('get_var errors: %d\n',bad);
