function Av = oct_get_v_coef(zp,zc)
%
%  Sparse matrix of the vertical linear interpolation from zp (Np,M,L)
%  to zc (Nc,M,L) for each water column (both ascending in k).
%
%  (c) 2007 Jeroen Molemaker, UCLA. Octave version (Oct-2026).
%
[Np,Mc,Lc] = size(zp);
[Nc,Mc,Lc] = size(zc);
ca = zeros(Nc,Mc,Lc,2);
ic = zeros(Nc,Mc,Lc,2);
jc = zeros(Nc,Mc,Lc,2);
for i = 1:Mc
  for j = 1:Lc
    ka  = sub2ind([Nc Mc Lc],1,i,j):sub2ind([Nc Mc Lc],Nc,i,j);
    k2d = repmat(ka(:),1,2);
    [coef1d,elem1d] = oct_get_1d_coef(zp(:,i,j),zc(:,i,j));
    ca(:,i,j,:) = coef1d;
    ic(:,i,j,:) = k2d;
    jc(:,i,j,:) = elem1d + Np*(i-1) + Np*Mc*(j-1);
  end
end
ndimc = Nc*Mc*Lc;
ndimp = Np*Mc*Lc;
Av = sparse(ic(:),jc(:),ca(:),ndimc,ndimp);
return
