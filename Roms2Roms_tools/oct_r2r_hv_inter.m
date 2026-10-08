function oct_r2r_hv_inter(par_grd,par_data,par_tind,chd_grd,bry_name,chd_tind,...
                          chdscd,parscd,obcflag,limits,nd, ...
                          A_south,coef2d_south,elem2d_south,nnel_south, ...
                          A_east,coef2d_east,elem2d_east,nnel_east, ...
                          A_north,coef2d_north,elem2d_north,nnel_north, ...
                          A_west,coef2d_west,elem2d_west,nnel_west)
%--------------------------------------------------------------
%  Same as oct_r2r_hv, with the interpolation coefficients given as
%  arguments (computed by oct_r2r_coef_inter) and the child boundary
%  file already open (nd = netcdf id, NC_WRITE), for the interannual
%  loop of oct_make_r2r_inter.
%
%  Jeroen Molemaker (UCLA); Evan Mason (ULPGC), June 2007
%  Octave version (Oct-2026): netcdf.* API of octave-netcdf (the old
%  netcdf toolbox syntax nd{'var'}(...) does not exist in Octave),
%  hyperslab reads, record loop in oct_r2r_bry_fill.
%--------------------------------------------------------------
np = netcdf.open(par_data,'NC_NOWRITE');
try
  oct_r2r_bry_time(np,nd,par_tind,chd_tind);
  coefs = {A_south,coef2d_south,elem2d_south,nnel_south;
           A_east, coef2d_east, elem2d_east, nnel_east;
           A_north,coef2d_north,elem2d_north,nnel_north;
           A_west, coef2d_west, elem2d_west, nnel_west};
  for bnd = 1:4
    disp('-------------------------------------------------------------')
    if ~obcflag(bnd)
      disp('Closed boundary')
      continue
    end
    G = oct_r2r_bnd_grids(par_grd,chd_grd,bnd,limits,chdscd,parscd);
    disp([upper(G.name(1)),G.name(2:end),' boundary'])
    C = struct('A',coefs{bnd,1},'coef2d',coefs{bnd,2},...
               'elem2d',coefs{bnd,3},'nnel',coefs{bnd,4});
    oct_r2r_bry_fill(np,nd,G,C,par_tind,chd_tind,bnd);
  end
catch err
  netcdf.close(np);
  rethrow(err)
end
netcdf.close(np);
return
