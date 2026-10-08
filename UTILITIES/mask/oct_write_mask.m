function status=oct_write_mask(Gname,rmask,umask,vmask,pmask)
%
% OCT_WRITE_MASK  write the Land/Sea masks in a CROCO grid file
%   (octave-netcdf). The masks are given in (xi,eta) order, i.e. as
%   returned by netcdf.getVar / oct_read_mask. Missing variables are
%   defined. If only rmask is given, the U-, V- and PSI- masks are
%   computed with uvp_masks.
%
if nargin<3
  [umask,vmask,pmask]=uvp_masks(rmask);
end
names={'mask_rho','mask_u','mask_v','mask_psi'};
dims={{'xi_rho','eta_rho'},{'xi_u','eta_u'},{'xi_v','eta_v'},{'xi_psi','eta_psi'}};
lnames={'mask on RHO-points','mask on U-points','mask on V-points','mask on PSI-points'};
vals={rmask,umask,vmask,pmask};
ncid=netcdf.open(Gname,'NC_WRITE');
redef=0;
for k=1:4
  try
    netcdf.inqVarID(ncid,names{k});
  catch
    if ~redef, netcdf.reDef(ncid); redef=1; end
    d1=netcdf.inqDimID(ncid,dims{k}{1}); d2=netcdf.inqDimID(ncid,dims{k}{2});
    vid=netcdf.defVar(ncid,names{k},'double',[d1 d2]);
    netcdf.putAtt(ncid,vid,'long_name',lnames{k});
  end
end
if redef, netcdf.endDef(ncid); end
for k=1:4
  netcdf.putVar(ncid,netcdf.inqVarID(ncid,names{k}),[0 0],size(vals{k}),double(vals{k}));
end
netcdf.close(ncid);
status=1;
return
