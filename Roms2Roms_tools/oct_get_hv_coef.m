function A = oct_get_hv_coef(zp,zc,coef2d,elem2d,lonp,latp,lonc,latc,mismatch)
%
%  Sparse 3d interpolation matrix A from the parent grid (Np,Mp,Lp) to
%  the child grid (Nc,Mc,Lc):  Fc = reshape(A*reshape(Fp,Np*Mp*Lp,1),Nc,Mc,Lc)
%  A = Av*Ah: horizontal interpolation (coef2d, elem2d from
%  oct_get_tri_coef) then vertical interpolation (oct_get_v_coef).
%  zp and zc must be in ascending order (k index).
%
%  mismatch (optional, m): when the lowest child point is more than
%  'mismatch' below the interpolated parent bottom, an extra point is
%  added below by nearest neighbour horizontal extrapolation.
%  Default 10000 (boundary files, R2RV2); the initial file routines
%  (INIV2) use 200.
%
%         (c) 2007 Jeroen Molemaker
%  Octave version (Oct-2026): delaunayn/dsearchn of Octave, the
%  mismatch criterion is an argument (the two original copies of
%  get_hv_coef.m only differed by this value).
%
if nargin<9 || isempty(mismatch)
  mismatch = 10000;
end
[Np,Mp,Lp] = size(zp);
[Nc,Mc,Lc] = size(zc);
ndimp = Np*Mp*Lp;
ndimt = (Np+1)*Mc*Lc;
%
%  Ah interpolates from a (np,mp,lp) grid to a (np+1,mc,lc) grid.
%
ca = zeros(Np+1,Mc,Lc,3);
ic = zeros(Np+1,Mc,Lc,3);
jc = zeros(Np+1,Mc,Lc,3);
sub2d = repmat(reshape(1:Mc*Lc,Mc,Lc),[1 1 3]);
for k = 2:Np+1
  ca(k,:,:,:) = coef2d;
  ic(k,:,:,:) = k + (Np+1)*(sub2d-1);
  jc(k,:,:,:) = (k-1) + Np*(elem2d-1);
end
lon0 = mean(lonc(:));
lat0 = mean(latc(:));
[xp,yp] = oct_gnomonic(lonp,latp,lon0,lat0);
[xc,yc] = oct_gnomonic(lonc,latc,lon0,lat0);
%
% Extra point below the parent bottom where the child is much deeper
%
zp_low = reshape(zp(1,:,:),Mp,Lp);
zc_low = reshape(zc(1,:,:),Mc,Lc);
zt_low = sum(coef2d.*zp_low(elem2d),3);
hmax = min(zp_low(:));
nlev = round(abs(hmax/mismatch));
tri_lev = cell(nlev,1);
X_tmp = zeros(Mp*Lp,2,max(nlev,1));
for lev = 1:nlev
  depth = lev*hmax/(nlev+1);
  shallow = find(zp_low > depth);
  x_tmp = xp; y_tmp = yp;
  x_tmp(shallow) = x_tmp(shallow) + 2;
  y_tmp(shallow) = y_tmp(shallow) + 2;
  X_tmp(:,:,lev) = [x_tmp(:) y_tmp(:)];
  tri_lev{lev} = delaunayn(X_tmp(:,:,lev));
end
if nlev>0
  disp('--- fixing parent/child topo mismatch (may take a while...)')
end
done = 10;
for i = 1:Mc
  for j = 1:Lc
    if nlev>0 && zt_low(i,j) > zc_low(i,j)+mismatch
      lev = round(zc_low(i,j)*(nlev+1)/hmax);
      lev = min(nlev,max(1,lev));
      nnel = dsearchn(X_tmp(:,:,lev),tri_lev{lev},[xc(i,j) yc(i,j)]);
      ca(1,i,j,:) = [1 0 0];
      ic(1,i,j,:) = 1 + (Np+1)*(sub2d(i,j,1)-1);
      jc(1,i,j,:) = 1 + Np*(nnel-1);
    else                  %% Trivial extra point
      ca(1,i,j,:) = ca(2,i,j,:);
      ic(1,i,j,:) = 1 + (Np+1)*(sub2d(i,j,1)-1);
      jc(1,i,j,:) = jc(2,i,j,:);
    end
  end
  percent_done = round(100*i/Mc);
  if nlev>0 && percent_done>=done
    disp(['------ ' num2str(percent_done) '% done'])
    done = done + 10;
  end
end
Ah = sparse(ic(:),jc(:),ca(:),ndimt,ndimp);
clear ic jc ca
zc_tmp = reshape(Ah*reshape(zp,ndimp,1),Np+1,Mc,Lc);
zc_tmp(1,:,:) = zc_tmp(1,:,:) - 0.1;  %% Avoid double z point in every column.
Av = oct_get_v_coef(zc_tmp,zc);
A  = Av*Ah;
return
