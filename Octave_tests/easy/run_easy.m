oct_start; graphics_toolkit qt
fig=oct_easy;
h=guidata(fig);
printf('init: xsize=%s ysize=%s rot=%s lon=%s lat=%s dl=%s nx=%s ny=%s\n',get(h.edit1,'String'),get(h.edit2,'String'),get(h.edit3,'String'),get(h.edit4,'String'),get(h.edit5,'String'),get(h.edit10,'String'),get(h.edit6,'String'),get(h.edit7,'String'));
drawnow; pause(1); system('import -window root ./easy_init.png');
function press(o)
  f=get(o,'Callback'); f{1}(o,[],f{2:end}); drawnow;
end
set(h.edit3,'String','20'); set(h.edit2,'String','600');
for k=1:6
  set(h.popupmenu1,'Value',k); press(h.popupmenu1);
  printf('plot %d ok, nx=%s ny=%s\n',k,get(h.edit6,'String'),get(h.edit7,'String'));
  if k==2 || k==3, pause(0.5); system(sprintf('import -window root ./easy_%d.png',k)); end
end
set(h.edit3,'String','80'); press(h.pushbutton1); printf('rotation clipped to %s\n',get(h.edit3,'String'));
set(h.edit3,'String','20'); press(h.pushbutton1);
press(h.pushbutton4);
printf('window closed: %d\n',~ishghandle(fig));
crocotools_param;
nc=netcdf.open(grdname,'NC_NOWRITE'); lo=netcdf.getVar(nc,netcdf.inqVarID(nc,'lon_rho')).'; la=netcdf.getVar(nc,netcdf.inqVarID(nc,'lat_rho')).'; netcdf.close(nc);
printf('grid %s lon %.2f..%.2f lat %.2f..%.2f\n',mat2str(size(lo)),min(lo(:)),max(lo(:)),min(la(:)),max(la(:)));
S=load('easy_grid_params.mat'); disp(S)
% reopen: parameters from easy_grid_params.mat
fig=oct_easy; h=guidata(fig); printf('reopen: rot=%s ysize=%s\n',get(h.edit3,'String'),get(h.edit2,'String')); delete(fig);
disp('EASY OK')
