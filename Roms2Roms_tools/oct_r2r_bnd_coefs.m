function C = oct_r2r_bnd_coefs(G,mismatch)
%
%  Interpolation coefficients parent subgrid -> child boundary strip
%  (G from oct_r2r_bnd_grids): C.elem2d, C.coef2d, C.nnel, C.A
%
%  Octave version (Oct-2026). mismatch: see oct_get_hv_coef.
%
if nargin<2, mismatch = []; end
[C.elem2d,C.coef2d,C.nnel] = oct_get_tri_coef(G.lons,G.lats,G.lonc,G.latc,G.masks);
C.A = oct_get_hv_coef(G.zs,G.zc,C.coef2d,C.elem2d,G.lons,G.lats,G.lonc,G.latc,mismatch);
return
