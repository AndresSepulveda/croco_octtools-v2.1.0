function oct_r2r_coef_inter(par_grd,chd_grd,chdscd,parscd,obcflag,limits)
%--------------------------------------------------------------
%  Compute the interpolation coefficients of each open boundary and
%  save them in r2r_coefs_<south|east|north|west>.mat
%  (used by oct_make_r2r_inter / oct_r2r_hv_inter).
%
%  Jeroen Molemaker (UCLA); Evan Mason (ULPGC), June 2007
%  modified from R2r_h, extract the coeff computation
%  Octave version (Oct-2026): netcdf.* API of octave-netcdf (the old
%  netcdf toolbox syntax nc{'var'}(...) does not exist in Octave).
%--------------------------------------------------------------
for bnd = 1:4
  disp('-------------------------------------------------------------')
  if ~obcflag(bnd)
    disp('Closed boundary')
    continue
  end
  G = oct_r2r_bnd_grids(par_grd,chd_grd,bnd,limits,chdscd,parscd);
  disp([upper(G.name(1)),G.name(2:end),' boundary'])
  disp('Computing interpolation coefficients');
  C = oct_r2r_bnd_coefs(G);
  elem2d = C.elem2d; coef2d = C.coef2d; nnel = C.nnel; A = C.A;
  save('-v7',['r2r_coefs_',G.name,'.mat'],'elem2d','coef2d','nnel','A')
end
return
