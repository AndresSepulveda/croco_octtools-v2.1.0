oct_start; graphics_toolkit qt; set(0,'defaultfigurevisible','off');
H=[pwd,'/CROCO_FILES/croco_his.nc']; G=[pwd,'/CROCO_FILES/croco_grd.nc'];
mkdir('VIZ'); cd VIZ
function T(name,f)
  try
    figure(1); clf; f(); drawnow; print(1,'-dpng','-r70',[name,'.png']); printf('OK   %s\n',name);
  catch e
    printf('FAIL %s: %s (%s:%d)\n',name,e.message,e.stack(1).name,e.stack(1).line);
  end
end
T('hs_temp_pcolor',@() oct_horizslice(H,'temp',3,-10,[1 1 1 1],1,0,[],[],[],[],[],[],10,1,'100 500 1000',2,1,0.1,[],[],G,[],[],NaN));
T('hs_temp_contourf',@() oct_horizslice(H,'temp',3,-100,[1 1 1 1],1,0,[],[],[],[],[],[],10,2,'500',0,1,0.1,[],[],G,[],[],NaN));
T('hs_zeta_contour',@() oct_horizslice(H,'zeta',3,0,[1 1 1 1],1,0,[],[],[],[],[],[],10,3,'',0,1,0.1,[],[],G,[],[],NaN));
T('hs_vort_gray',@() oct_horizslice(H,'*Vort',3,-10,[1 1 1 1],1,0,[],[],[],[],[],[],10,4,'',0,1,0.1,[],[],G,[],[],NaN));
T('hs_speed_stream',@() oct_horizslice(H,'*Speed',3,-10,[1 1 1 1],1,0,[],[],[],[],[],[],10,1,'',-1,1,0.1,[],[],G,[],[],2000));
T('hs_temp_seawifs',@() oct_horizslice(H,'temp',3,32,[1 1 1 1],1,0,[],[],[],[],[],[],10,5,'',0,1,0.1,[],[],G,[],[],NaN));
T('vslice_temp',@() oct_vertslice(H,G,[9 20],[-33 -33],'temp',3,1,[],[],10,[],[],[],[],1,[],[],NaN));
T('vslice_u',@() oct_vertslice(H,G,[12 12],[-38 -28],'u',3,1,[],[],10,[],[],[],[],2,[],[],NaN));
T('vslice_speed',@() oct_vertslice(H,G,[9 20],[-36 -30],'*Speed',3,1,[],[],10,[],[],[],[],1,[],[],NaN));
T('hovmuller',@() oct_hovmuller(H,G,[9 20],[-33 -33],'temp',1:6,-10,1,[],[],10,[],[],[],[],1));
T('tseries_temp',@() oct_time_series(H,G,14,-33,'temp',-50,1));
T('tseries_zeta',@() oct_time_series(H,G,14,-33,'zeta',0,1));
T('tseries_u_lev',@() oct_time_series(H,G,14,-33,'u',20,1));
T('tseries_ke',@() oct_time_series(H,G,14,-33,'*Ke',-20,1));
T('vprof_temp',@() oct_vert_profile(H,G,14,-33,'temp',3,1,NaN));
T('vprof_v',@() oct_vert_profile(H,G,14,-33,'v',3,1,NaN));
T('vprof_rho',@() oct_vert_profile(H,G,14,-33,'*Rho',3,1,NaN));
