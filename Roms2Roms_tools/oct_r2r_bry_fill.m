function oct_r2r_bry_fill(np,nd,G,C,par_tind,chd_tind,bnd)
%
%  oct_r2r_bry_fill(np,nd,G,C,par_tind,chd_tind,bnd)
%
%  Interpolate the parent records par_tind on the child open boundary
%  bnd and write them in the child boundary file at records chd_tind.
%  Common part of r2r_hv and r2r_hv_inter.
%
%  np       : netcdf id of the parent history/average file (open)
%  nd       : netcdf id of the child boundary file (open, NC_WRITE)
%  G        : grids of the boundary (oct_r2r_bnd_grids)
%  C        : interpolation coefficients (oct_r2r_bnd_coefs or .mat file)
%
%  Octave version (Oct-2026) of the record loop of roms2roms_hv
%  (J. Molemaker, E. Mason, UCLA). The parent fields are read with
%  hyperslabs (only the subgrid and the record needed: 0-based start,
%  count in Fortran order xi,eta,s,time) instead of whole variables;
%  the boundary arrays are written with netcdf.putVar in Fortran order
%  (xi or eta, s, time).
%
A = C.A; coef2d = C.coef2d; elem2d = C.elem2d; nnel = C.nnel;
imin = G.imin; imax = G.imax; jmin = G.jmin; jmax = G.jmax;
li = imax-imin+1; lj = jmax-jmin+1;
N_p = G.N_p;
masks = G.masks;
coss = cos(G.angs); sins = sin(G.angs);
cosc = cos(G.angc); sinc = sin(G.angc);
[Np,Mp,Lp] = size(G.zs);
[Nc,Mc,Lc] = size(G.zc);
%
% Prepare for estimating barotropic velocity
%
dz  = G.zw(2:end,:,:)-G.zw(1:end-1,:,:);
dzu = 0.5*(dz(:,:,1:end-1)+dz(:,:,2:end));
dzv = 0.5*(dz(:,1:end-1,:)+dz(:,2:end,:));
bn = G.name;
for loop = 1:numel(par_tind)
  tind = par_tind(loop);
  tout = chd_tind(loop);
%
% Surface elevation on minimal subgrid and child grid
%
  zetas = rdpar(np,'zeta',tind,imin,imax,jmin,jmax,0);
  zetas = oct_fillmask(zetas,1,masks,nnel);
  zetac = sum(coef2d.*zetas(elem2d),3);
%
% Tracers
%
  for svar = {'temp','salt'}
    var = rdpar(np,svar{1},tind,imin,imax,jmin,jmax,N_p);
    var = oct_fillmask(var,1,masks,nnel);
    var = reshape(A*reshape(var,Np*Mp*Lp,1),Nc,Mc,Lc);
    putbry(nd,[svar{1},'_',bn],tout,edge3d(var,bnd));
  end
%
% Staggered velocities moved to rho-points
%
  if (imin==1 || imax==G.nxp)
    ud = rdpar(np,'u',tind,imin,imax-1,jmin,jmax,N_p);
    ur = oct_u2rho(ud);
  else
    ud = rdpar(np,'u',tind,imin-1,imax,jmin,jmax,N_p);
    ur = 0.5*(ud(:,:,1:end-1) + ud(:,:,2:end));
  end
  if (jmin==1 || jmax==G.nyp)
    vd = rdpar(np,'v',tind,imin,imax,jmin,jmax-1,N_p);
    vr = oct_v2rho(vd);
  else
    vd = rdpar(np,'v',tind,imin,imax,jmin-1,jmax,N_p);
    vr = 0.5*(vd(:,1:end-1,:) + vd(:,2:end,:));
  end
%
% Rotate to north
%
  us = zeros(Np,Mp,Lp);
  vs = zeros(Np,Mp,Lp);
  for k = 1:Np
    urk = reshape(ur(k,:,:),Mp,Lp); vrk = reshape(vr(k,:,:),Mp,Lp);
    us(k,:,:) = urk.*coss - vrk.*sins;
    vs(k,:,:) = vrk.*coss + urk.*sins;
  end
%
% 3d interpolation of us and vs to child grid
%
  us(isnan(us)) = 0;
  vs(isnan(vs)) = 0;
  us = oct_fillmask(us,0,masks,nnel);
  vs = oct_fillmask(vs,0,masks,nnel);
  ud = reshape(A*reshape(us,Np*Mp*Lp,1),Nc,Mc,Lc);
  vd = reshape(A*reshape(vs,Np*Mp*Lp,1),Nc,Mc,Lc);
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
% Back to staggered u and v points
%
  u = 0.5*(us(:,:,1:Lc-1) + us(:,:,2:Lc));
  v = 0.5*(vs(:,1:Mc-1,:) + vs(:,2:Mc,:));
  u = u.*G.umask;
  v = v.*G.vmask;
  if any(isnan(u(:))), error('nans in u velocity!'), end
  if any(isnan(v(:))), error('nans in v velocity!'), end
%
% Barotropic velocity
%
  [~,Mu,Lu] = size(u);
  [~,Mv,Lv] = size(v);
  ubar = reshape(sum(dzu.*u,1)./sum(dzu,1),Mu,Lu);
  vbar = reshape(sum(dzv.*v,1)./sum(dzv,1),Mv,Lv);
%
% Save perimeter zeta, ubar, vbar, u and v data to bryfile
%
  putbry(nd,['zeta_',bn],tout,edge2d(zetac,bnd));
  putbry(nd,['ubar_',bn],tout,edge2d(ubar,bnd));
  putbry(nd,['vbar_',bn],tout,edge2d(vbar,bnd));
  putbry(nd,['u_',bn],tout,edge3d(u,bnd));
  putbry(nd,['v_',bn],tout,edge3d(v,bnd));
end
return
%
%======================================================================
%
function v = rdpar(np,name,tind,i0,i1,j0,j1,N)
%
% Parent field on the subgrid (j0:j1,i0:i1) at record tind:
% (eta,xi) for N=0, (s,eta,xi) otherwise
%
vid = netcdf.inqVarID(np,name);
if N==0
  v = double(netcdf.getVar(np,vid,[i0-1 j0-1 tind-1],[i1-i0+1 j1-j0+1 1])).';
else
  v = double(netcdf.getVar(np,vid,[i0-1 j0-1 0 tind-1],[i1-i0+1 j1-j0+1 N 1]));
  v = permute(v,[3 2 1]);
end
try
  fv = double(netcdf.getAtt(np,vid,'_FillValue'));
  v(v==fv) = NaN;
end
v(isnan(v)) = 0;                  % land: filled by oct_fillmask
return
%
function e = edge2d(f,bnd)
% boundary line of a 2d (M,L) field, as a column vector
switch bnd
  case 1, e = f(1,:);
  case 2, e = f(:,end);
  case 3, e = f(end,:);
  case 4, e = f(:,1);
end
e = e(:);
return
%
function e = edge3d(f,bnd)
% boundary section of a 3d (N,M,L) field, as (M or L, N): Fortran order
% of the (xi or eta, s_rho) variables of the boundary file
[N,M,L] = size(f);
switch bnd
  case 1, e = reshape(f(:,1,:),N,L);
  case 2, e = reshape(f(:,:,end),N,M);
  case 3, e = reshape(f(:,end,:),N,L);
  case 4, e = reshape(f(:,:,1),N,M);
end
e = e.';
return
%
function putbry(nd,name,tout,x)
% write record tout of a boundary variable (netcdf.putVar does not
% check the size: the count is taken from x and checked against the file)
vid = netcdf.inqVarID(nd,name);
[~,~,dimids] = netcdf.inqVar(nd,vid);
len = zeros(1,numel(dimids)-1);
for k=1:numel(len)
  [~,len(k)] = netcdf.inqDim(nd,dimids(k));
end
if numel(len)==1
  cnt = numel(x);
else
  cnt = size(x);
end
if ~isequal(cnt(:)',len)
  error(['oct_r2r_bry_fill: size of ',name,' is ',mat2str(cnt),...
         ' but the boundary file expects ',mat2str(len)])
end
netcdf.putVar(nd,vid,[zeros(1,numel(len)) tout-1],[len 1],x);
return
