function oct_rem_avg_zeta(clmname,grdname,oaname)
%
% Pierrick 2003
%
% remove the domaine average of zeta
%
%
%  grid parameters
%
ncid = netcdf.open(grdname, 'NC_NOWRITE');
pm=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'pm'));
pn=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'pn'));
rmask=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'));
[M,L]=size(rmask);
netcdf.close(ncid);
%
%  Model grid vertical levels
%
noa_id = netcdf.open(oaname, 'NC_NOWRITE');
ncid = netcdf.open(clmname, 'NC_WRITE');
[~,tlen]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'zeta_time'));
%
%  Time loop
%
for l=1:tlen
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  ssh=squeeze(netcdf.getVar(noa_id, netcdf.inqVarID(noa_id, 'zeta')));
  avgssh=sum(sum(rmask.*ssh./(pm.*pn)))/sum(sum(rmask./(pm.*pn)));
  ssh=ssh-avgssh;
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'zeta'), l,:,:-1, 1, ssh);  % [conv] 0-based
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'SSH'), l,:,:-1, 1, ssh);  % [conv] 0-based
end
netcdf.close(ncid);
netcdf.close(noa_id);
