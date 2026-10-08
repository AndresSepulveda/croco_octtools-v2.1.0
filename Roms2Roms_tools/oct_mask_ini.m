function oct_mask_ini(grdname,ininame)
%
%  oct_mask_ini(grdname,ininame)
%
%  Apply the land mask of the grid to an initial file (zeta, ubar, vbar,
%  u, v, temp, salt of the first record are set to 0 on land).
%
%  Octave version (Oct-2026) of mask_ini.m: it was a script with the
%  file names written inside and 42 levels, using the old netcdf
%  toolbox; now a function with the file names as arguments, the
%  number of levels read in the file, netcdf.* API (Fortran order).
%
ng = netcdf.open(grdname,'NC_NOWRITE');
mask = double(netcdf.getVar(ng,netcdf.inqVarID(ng,'mask_rho')));   % (xi,eta)
netcdf.close(ng);
umask = mask(1:end-1,:).*mask(2:end,:);
vmask = mask(:,1:end-1).*mask(:,2:end);
nci = netcdf.open(ininame,'NC_WRITE');
masks = struct('zeta',mask,'ubar',umask,'vbar',vmask,'u',umask,'v',vmask,...
               'temp',mask,'salt',mask);
for nm = fieldnames(masks)'
  vid = netcdf.inqVarID(nci,nm{1});
  [~,~,dimids] = netcdf.inqVar(nci,vid);
  len = zeros(1,numel(dimids));
  for k=1:numel(dimids)
    [~,len(k)] = netcdf.inqDim(nci,dimids(k));
  end
  m = masks.(nm{1});
  if numel(len)==3                         % (xi,eta,time)
    f = double(netcdf.getVar(nci,vid,[0 0 0],[len(1:2) 1]));
    netcdf.putVar(nci,vid,[0 0 0],[len(1:2) 1],f.*m);
  else                                     % (xi,eta,s,time)
    for k = 1:len(3)
      f = double(netcdf.getVar(nci,vid,[0 0 k-1 0],[len(1:2) 1 1]));
      netcdf.putVar(nci,vid,[0 0 k-1 0],[len(1:2) 1 1],f.*m);
    end
  end
end
netcdf.close(nci);
disp(['Mask applied to ',ininame])
return
