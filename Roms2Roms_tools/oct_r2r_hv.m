function oct_r2r_hv(par_grd,par_data,par_tind,chd_grd,bry_name,chd_tind,...
                    chdscd,parscd,obcflag,limits)
%--------------------------------------------------------------
%  Extract variables from a parent ROMS/CROCO history (or average)
%  file to save in the boundary perimeter file of the child grid.
%
%  input
%  =====
%  par_grd:         parent grid .nc file name
%  par_data:        parent history .nc file name
%  par_tind:        time indices in the parent history file
%  chd_grd:         child grid .nc file name
%  bry_name:        child boundary .nc file name
%  chd_tind:        time indices in the child boundary file
%  chdscd:          child grid s-coordinate parameters (structure)
%  parscd:          parent grid s-coordinate parameters (structure)
%  obcflag:         open boundaries flag (1=open , [S E N W])
%  limits:          parent subgrids (oct_r2r_bry_subgrid)
%
%  The interpolation coefficients of each boundary are computed once and
%  saved in r2r_coefs_<south|east|north|west>.mat (read if present).
%
%  Inspired by Roms_tools (IRD).
%  Jeroen Molemaker (UCLA); Evan Mason (ULPGC), June 2007
%  Modified to use the matlab native netcdf, LR 2014
%  Octave version (Oct-2026): netcdf.* API of octave-netcdf with
%  hyperslab reads (ncread read whole 4D variables at each record),
%  record loop in oct_r2r_bry_fill.
%--------------------------------------------------------------
nd = netcdf.open(bry_name,'NC_WRITE');
np = netcdf.open(par_data,'NC_NOWRITE');
try
  oct_r2r_bry_time(np,nd,par_tind,chd_tind);
  for bnd = 1:4
    disp('-------------------------------------------------------------')
    if ~obcflag(bnd)
      disp('Closed boundary')
      continue
    end
    G = oct_r2r_bnd_grids(par_grd,chd_grd,bnd,limits,chdscd,parscd);
    disp([upper(G.name(1)),G.name(2:end),' boundary'])
    fcoef = ['r2r_coefs_',G.name,'.mat'];
    if exist(fcoef,'file')
      disp('Reading interpolation coefficients from file');
      C = load(fcoef);
    else
      disp('Computing interpolation coefficients');
      tic
      C = oct_r2r_bnd_coefs(G);
      elem2d = C.elem2d; coef2d = C.coef2d; nnel = C.nnel; A = C.A;
      save('-v7',fcoef,'elem2d','coef2d','nnel','A')
      toc
    end
    oct_r2r_bry_fill(np,nd,G,C,par_tind,chd_tind,bnd);
  end
catch err
  netcdf.close(np); netcdf.close(nd);
  rethrow(err)
end
netcdf.close(np);
netcdf.close(nd);
return
