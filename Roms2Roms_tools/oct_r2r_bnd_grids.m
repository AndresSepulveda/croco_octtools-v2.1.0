function G = oct_r2r_bnd_grids(par_grd,chd_grd,bnd,limits,chdscd,parscd)
%
%  G = oct_r2r_bnd_grids(par_grd,chd_grd,bnd,limits,chdscd,parscd)
%
%  Child boundary strip (2 rows/columns) and minimal parent subgrid of
%  the open boundary bnd (1:S 2:E 3:N 4:W), with their s-levels.
%  Common part of r2r_hv, r2r_hv_inter and r2r_coef_inter (it was
%  repeated in the three routines).
%
%  Octave version (Oct-2026): hyperslab reads with the netcdf.* API of
%  octave-netcdf (0-based start, count in Fortran order (xi,eta)),
%  transposed to (eta,xi).
%
nc = netcdf.open(chd_grd,'NC_NOWRITE');
[~,npc] = netcdf.inqDim(nc,netcdf.inqDimID(nc,'xi_rho'));
[~,mpc] = netcdf.inqDim(nc,netcdf.inqDimID(nc,'eta_rho'));
switch bnd
  case 1, name='south'; i0=1;     i1=npc; j0=1;     j1=2;
  case 2, name='east';  i0=npc-1; i1=npc; j0=1;     j1=mpc;
  case 3, name='north'; i0=1;     i1=npc; j0=mpc-1; j1=mpc;
  case 4, name='west';  i0=1;     i1=2;   j0=1;     j1=mpc;
end
G.name = name;
G.i0 = i0; G.i1 = i1; G.j0 = j0; G.j1 = j1;
G.hc    = rd2(nc,'h',i0,i1,j0,j1);
G.maskc = rd2(nc,'mask_rho',i0,i1,j0,j1);
G.angc  = rd2(nc,'angle',i0,i1,j0,j1);
G.lonc  = rd2(nc,'lon_rho',i0,i1,j0,j1);
G.latc  = rd2(nc,'lat_rho',i0,i1,j0,j1);
netcdf.close(nc);
[Mc,Lc] = size(G.maskc);
maskc3d = repmat(reshape(G.maskc,[1 Mc Lc]),[chdscd.N 1 1]);
G.umask = maskc3d(:,:,2:end).*maskc3d(:,:,1:end-1);
G.vmask = maskc3d(:,2:end,:).*maskc3d(:,1:end-1,:);
%
% Minimal parent subgrid
%
G.imin = limits(bnd,1); G.imax = limits(bnd,2);
G.jmin = limits(bnd,3); G.jmax = limits(bnd,4);
np = netcdf.open(par_grd,'NC_NOWRITE');
[~,G.nxp] = netcdf.inqDim(np,netcdf.inqDimID(np,'xi_rho'));
[~,G.nyp] = netcdf.inqDim(np,netcdf.inqDimID(np,'eta_rho'));
G.masks = rd2(np,'mask_rho',G.imin,G.imax,G.jmin,G.jmax);
G.lons  = rd2(np,'lon_rho',G.imin,G.imax,G.jmin,G.jmax);
G.lats  = rd2(np,'lat_rho',G.imin,G.imax,G.jmin,G.jmax);
G.angs  = rd2(np,'angle',G.imin,G.imax,G.jmin,G.jmax);
G.hs    = rd2(np,'h',G.imin,G.imax,G.jmin,G.jmax);
netcdf.close(np);
if any(isnan(G.masks(:)))
  disp('Setting NaNs in masks to zero')
  G.masks(isnan(G.masks)) = 0;
  disp('You probably have land masking defined in cppdefs.h...')
end
%
% Z-coordinate (3D) on minimal subgrid and child grid
% Sasha recommends the 0 multiplication
%
G.zs = oct_zlevs3(G.hs, G.hs*0, parscd.theta_s, parscd.theta_b, parscd.hc, parscd.N, 'r', parscd.scoord);
G.zc = oct_zlevs3(G.hc, G.hc*0, chdscd.theta_s, chdscd.theta_b, chdscd.hc, chdscd.N, 'r', chdscd.scoord);
G.zw = oct_zlevs3(G.hc, G.hc*0, chdscd.theta_s, chdscd.theta_b, chdscd.hc, chdscd.N, 'w', chdscd.scoord);
G.N_p = parscd.N;
return
%
function v = rd2(nc,name,i0,i1,j0,j1)
% 2D hyperslab (eta j0:j1, xi i0:i1) of a grid variable, as (eta,xi)
v = double(netcdf.getVar(nc,netcdf.inqVarID(nc,name),[i0-1 j0-1],[i1-i0+1 j1-j0+1])).';
return
