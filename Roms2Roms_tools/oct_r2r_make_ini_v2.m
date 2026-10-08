function oct_r2r_make_ini_v2(par_grd,par_data,chd_grd,chd_data,   ...
                             chdscd,parscd,scoord_switch_p,scoord_switch_c,ndomx,ndomy)
%--------------------------------------------------------------
%
%  Make a CROCO/ROMS initial file on a child grid from a record of a
%  parent history/average/restart file.
%
%  input
%  =====
%  par_grd:         parent grid .nc file name
%  par_data:        parent history .nc file name
%  chd_grd:         child grid .nc file name
%  chd_data:        child ini .nc file name (oct_r2r_create_ini)
%  chdscd:          child grid s-coordinate parameters (structure)
%  parscd:          parent grid s-coordinate parameters (structure,
%                   with parscd.tind = parent record)
%  scoord_switch_p: parent s-coordinate ('old1994','new2006','new2008')
%  scoord_switch_c: child s-coordinate
%  ndomx,ndomy:     the child grid is processed in ndomx*ndomy chunks
%                   (to limit the memory used by the interpolation matrix)
%
%  Heavily modified from French produce
%  Jeroen Molemaker (UCLA); nmolem@atmos.ucla.edu
%
%  Octave version (Oct-2026):
%  - netcdf.* API of octave-netcdf; only the parent subgrid and the
%    record tind are read (hyperslabs in Fortran order xi,eta,s,time)
%    instead of the whole 4D variables (ncread);
%  - Octave's tsearch (no tsearch.m / tsrchmx.mexa64);
%  - chunks overlap by one point, so that the u (v) points between two
%    chunks are also computed (they were left at 0 when ndomx (ndomy)>1);
%  - mismatch criterion of 200 m in oct_get_hv_coef, as in INIV2;
%  - sc_r, Cs_r and Cs_w are written.
%--------------------------------------------------------------
%
N_c = chdscd.N; theta_b_c = chdscd.theta_b; theta_s_c = chdscd.theta_s; hc_c = chdscd.hc;
N_p = parscd.N; theta_b_p = parscd.theta_b; theta_s_p = parscd.theta_s; hc_p = parscd.hc;
tind = parscd.tind;
if nargin<9 || isempty(ndomx), ndomx = 1; end
if nargin<10 || isempty(ndomy), ndomy = 1; end
mismatch = 200;
%
% Set correct time in ini file
%
np = netcdf.open(par_data,'NC_NOWRITE');
ocean_time = [];
for nm = {'scrum_time','time','ocean_time'}
  try
    ocean_time = double(netcdf.getVar(np,netcdf.inqVarID(np,nm{1}),tind-1,1));
    break
  end
end
if isempty(ocean_time)
  netcdf.close(np);
  error('No time variable (scrum_time, time or ocean_time) in the parent file')
end
nc = netcdf.open(chd_data,'NC_WRITE');
netcdf.putVar(nc,netcdf.inqVarID(nc,'scrum_time'),0,1,ocean_time);
%
% Full parent grid and triangulation
%
ng = netcdf.open(par_grd,'NC_NOWRITE');
lonp = rd2(ng,'lon_rho');
latp = rd2(ng,'lat_rho');
[Mpp,Lpp] = size(latp);
lonp(lonp<0) = lonp(lonp<0) + 360;
disp('going delaunay');
tri_fullpar = delaunay(lonp(:),latp(:));
disp('returndelaunay');
%
% Child grid and chunks
%
cg = netcdf.open(chd_grd,'NC_NOWRITE');
[~,Lp] = netcdf.inqDim(cg,netcdf.inqDimID(cg,'xi_rho'));
[~,Mp] = netcdf.inqDim(cg,netcdf.inqDimID(cg,'eta_rho'));
szx = floor(Lp/ndomx);
szy = floor(Mp/ndomy);
icmin = (0:ndomx-1)*szx; jcmin = (0:ndomy-1)*szy;
icmax = (1:ndomx)*szx;   jcmax = (1:ndomy)*szy;
icmin(1) = 1; jcmin(1) = 1;
icmax(end) = Lp; jcmax(end) = Mp;
for domx = 1:ndomx
 for domy = 1:ndomy
  disp(['Chunk ',num2str(domx),' ',num2str(domy)])
  icb = icmin(domx); ice = min(icmax(domx)+1,Lp);   % 1 point overlap
  jcb = jcmin(domy); jce = min(jcmax(domy)+1,Mp);
%
% Child grid chunk
%
  hc    = rd2(cg,'h',icb,ice,jcb,jce);
  maskc = rd2(cg,'mask_rho',icb,ice,jcb,jce);
  lonc  = rd2(cg,'lon_rho',icb,ice,jcb,jce);
  latc  = rd2(cg,'lat_rho',icb,ice,jcb,jce);
  angc  = rd2(cg,'angle',icb,ice,jcb,jce);
  umask = maskc(:,1:end-1).*maskc(:,2:end);
  vmask = maskc(1:end-1,:).*maskc(2:end,:);
  cosc  = cos(angc);
  sinc  = sin(angc);
  lonc(lonc<0) = lonc(lonc<0) + 360;
%
% Minimal parent subgrid containing the chunk
%
  t = tsearch(lonp(:),latp(:),tri_fullpar,lonc(:),latc(:));
  if any(~isfinite(t))
    disp('Warning in r2r_make_ini: outside point(s) detected.');
    [lonc2,latc2] = oct_fix_outside_child(lonc,latc,t);
    t = tsearch(lonp(:),latp(:),tri_fullpar,lonc2(:),latc2(:));
  end
  index = tri_fullpar(t,:);
  [idxj,idxi] = ind2sub([Mpp Lpp], index);
  imin = max(1, min(idxi(:))-1);  imax = min(max(idxi(:))+1, Lpp);
  jmin = max(1, min(idxj(:))-1);  jmax = min(max(idxj(:))+1, Mpp);
  hs    = rd2(ng,'h',imin,imax,jmin,jmax);
  masks = rd2(ng,'mask_rho',imin,imax,jmin,jmax);
  lons  = rd2(ng,'lon_rho',imin,imax,jmin,jmax);
  lats  = rd2(ng,'lat_rho',imin,imax,jmin,jmax);
  angs  = rd2(ng,'angle',imin,imax,jmin,jmax);
  lons(lons<0) = lons(lons<0) + 360;
  coss = cos(angs); sins = sin(angs);
  if any(isnan(masks(:)))
    disp('Setting NaNs in masks to zero')
    masks(isnan(masks)) = 0;
    disp('You probably have land masking defined in cppdefs.h...')
  end
%
% Z-coordinate (3D) on minimal subgrid and child grid
%
  zs = oct_zlevs3(hs, hs*0, theta_s_p, theta_b_p, hc_p, N_p, 'r', scoord_switch_p);
  [zc,Cs_r] = oct_zlevs3(hc, hc*0, theta_s_c, theta_b_c, hc_c, N_c, 'r', scoord_switch_c);
  [zw,Cs_w] = oct_zlevs3(hc, hc*0, theta_s_c, theta_b_c, hc_c, N_c, 'w', scoord_switch_c);
  [Np,Mps,Lps] = size(zs);
  [Nc,Mc,Lc] = size(zc);
  disp('Computing interpolation coefficients');
  [elem2d,coef2d,nnel] = oct_get_tri_coef(lons,lats,lonc,latc,masks);
  A = oct_get_hv_coef(zs,zc,coef2d,elem2d,lons,lats,lonc,latc,mismatch);
%
% zeta
%
  disp('--- zeta')
  zetas = rdpar(np,'zeta',tind,imin,imax,jmin,jmax,0);
  zetas = oct_fillmask(zetas,1,masks,nnel);
  zetac = sum(coef2d.*zetas(elem2d),3).*maskc;
%
% temp, salt
%
  disp('--- temp')
  var = oct_fillmask(rdpar(np,'temp',tind,imin,imax,jmin,jmax,N_p),1,masks,nnel);
  ini_temp = reshape(A*reshape(var,Np*Mps*Lps,1),Nc,Mc,Lc);
  disp('--- salt')
  var = oct_fillmask(rdpar(np,'salt',tind,imin,imax,jmin,jmax,N_p),1,masks,nnel);
  ini_salt = reshape(A*reshape(var,Np*Mps*Lps,1),Nc,Mc,Lc);
%
% Staggered velocities averaged to rho points
%
  disp('--- baroclinic velocity');
  ud = rdpar(np,'u',tind,imin,imax-1,jmin,jmax,N_p);
  vd = rdpar(np,'v',tind,imin,imax,jmin,jmax-1,N_p);
  ur = oct_u2rho(ud);
  vr = oct_v2rho(vd);
%
% Rotate to north
%
  us = zeros(Np,Mps,Lps);
  vs = zeros(Np,Mps,Lps);
  for k = 1:Np
    urk = reshape(ur(k,:,:),Mps,Lps); vrk = reshape(vr(k,:,:),Mps,Lps);
    us(k,:,:) = urk.*coss - vrk.*sins;
    vs(k,:,:) = vrk.*coss + urk.*sins;
  end
  us(isnan(us)) = 0;
  vs(isnan(vs)) = 0;
  us = oct_fillmask(us,0,masks,nnel);
  vs = oct_fillmask(vs,0,masks,nnel);
  ud = reshape(A*reshape(us,Np*Mps*Lps,1),Nc,Mc,Lc);
  vd = reshape(A*reshape(vs,Np*Mps*Lps,1),Nc,Mc,Lc);
%
% Rotate to child orientation
%
  us = zeros(Nc,Mc,Lc);
  vs = zeros(Nc,Mc,Lc);
  for k=1:Nc
    udk = reshape(ud(k,:,:),Mc,Lc); vdk = reshape(vd(k,:,:),Mc,Lc);
    us(k,:,:) = udk.*cosc + vdk.*sinc;
    vs(k,:,:) = vdk.*cosc - udk.*sinc;
  end
%
% Back to staggered locations
%
  u = 0.5*(us(:,:,1:Lc-1) + us(:,:,2:Lc));
  v = 0.5*(vs(:,1:Mc-1,:) + vs(:,2:Mc,:));
%
% Barotropic velocity
%
  disp('--- barotropic velocity');
  dz  = zw(2:end,:,:)-zw(1:end-1,:,:);
  dzu = 0.5*(dz(:,:,1:end-1)+dz(:,:,2:end));
  dzv = 0.5*(dz(:,1:end-1,:)+dz(:,2:end,:));
  ubar = reshape(sum(dzu.*u,1)./sum(dzu,1),Mc,Lc-1).*umask;
  vbar = reshape(sum(dzv.*v,1)./sum(dzv,1),Mc-1,Lc).*vmask;
%
% Zero-ing out the mask
%
  m3 = repmat(reshape(maskc,[1 Mc Lc]),[Nc 1 1]);
  ini_temp = ini_temp.*m3;
  ini_salt = ini_salt.*m3;
  u = u.*repmat(reshape(umask,[1 Mc Lc-1]),[Nc 1 1]);
  v = v.*repmat(reshape(vmask,[1 Mc-1 Lc]),[Nc 1 1]);
%
% Write (Fortran order: xi, eta, s, time)
%
  disp(' Writing ini file')
  put4(nc,'temp',permute(ini_temp,[3 2 1]),icb,jcb);
  put4(nc,'salt',permute(ini_salt,[3 2 1]),icb,jcb);
  put4(nc,'u',permute(u,[3 2 1]),icb,jcb);
  put4(nc,'v',permute(v,[3 2 1]),icb,jcb);
  put3(nc,'zeta',zetac.',icb,jcb);
  put3(nc,'ubar',ubar.',icb,jcb);
  put3(nc,'vbar',vbar.',icb,jcb);
 end
end
netcdf.putVar(nc,netcdf.inqVarID(nc,'Cs_w'),Cs_w);
netcdf.putVar(nc,netcdf.inqVarID(nc,'Cs_r'),Cs_r);
netcdf.close(cg);
netcdf.close(ng);
netcdf.close(np);
netcdf.close(nc);
disp(' Initial file done')
return
%
%======================================================================
%
function v = rd2(nc,name,i0,i1,j0,j1)
% 2D grid variable (or its hyperslab j0:j1,i0:i1) as (eta,xi)
vid = netcdf.inqVarID(nc,name);
if nargin<3
  v = double(netcdf.getVar(nc,vid)).';
else
  v = double(netcdf.getVar(nc,vid,[i0-1 j0-1],[i1-i0+1 j1-j0+1])).';
end
return
%
function v = rdpar(np,name,tind,i0,i1,j0,j1,N)
% parent field on (j0:j1,i0:i1) at record tind: (eta,xi) or (s,eta,xi)
vid = netcdf.inqVarID(np,name);
if N==0
  v = double(netcdf.getVar(np,vid,[i0-1 j0-1 tind-1],[i1-i0+1 j1-j0+1 1])).';
else
  v = permute(double(netcdf.getVar(np,vid,[i0-1 j0-1 0 tind-1],[i1-i0+1 j1-j0+1 N 1])),[3 2 1]);
end
try
  fv = double(netcdf.getAtt(np,vid,'_FillValue'));
  v(v==fv) = NaN;
end
v(isnan(v)) = 0;
return
%
function put4(nc,name,x,icb,jcb)
[a,b,c] = size(x);
netcdf.putVar(nc,netcdf.inqVarID(nc,name),[icb-1 jcb-1 0 0],[a b c 1],x);
return
%
function put3(nc,name,x,icb,jcb)
[a,b] = size(x);
netcdf.putVar(nc,netcdf.inqVarID(nc,name),[icb-1 jcb-1 0],[a b 1],x);
return
