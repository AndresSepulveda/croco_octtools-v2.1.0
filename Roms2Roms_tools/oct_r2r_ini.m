%---------------------------------------------------------------------------------------
%
%  oct_r2r_ini  (roms2roms_ini)
%
%  Generate initial file from ROMS parent data.
%
%  Octave version (Oct-2026): calls oct_r2r_create_ini and
%  oct_r2r_make_ini_v2 (netcdf.* API of octave-netcdf).
%
%---------------------------------------------------------------------------------------
% USER-DEFINED VARIABLES & OPTIONS START HERE
%---------------------------------------------------------------------------------------
%
% R1KM_r2r
    % Parent...
      % Parent...
      par_dir    = '/home/livecroco/Desktop/Run/CROCO_FILES/';
      par_grd    = 'croco_grd.nc';
      par_ini   = 'croco_avg.nc';
      par_tind   = 2;            % frame number in parent file
      par_thetas = 7;
      par_thetab = 2;
      par_hc     = 200.0;
      par_N      = 32;
      parscoord  = 'new2008';    % parent 'new' or 'old' type scoord


    % Child...
      chd_dir    = '/home/livecroco/Desktop/Run/CROCO_FILES/';
      chd_grd    = 'croco_grd.nc.1';
      chd_file   = 'croco_ini.nc.1';        % name of new ini file
      chd_thetas = 7;
      chd_thetab = 2;
      chd_hc     = 200.0;
      chd_N      = 32;
      chdscoord  = 'new2008';                 % child 'new' or 'old' type scoord

  
         
%---------------------------------------------------------------------------------------
% USER-DEFINED VARIABLES & OPTIONS END HERE
%---------------------------------------------------------------------------------------
%
     % Child and parent s-coord parameters into chdscd and parscd
       chdscd.N       = chd_N;
       chdscd.theta_s = chd_thetas;
       chdscd.theta_b = chd_thetab;
       chdscd.hc      = chd_hc;

       parscd.N       = par_N;
       parscd.theta_s = par_thetas;
       parscd.theta_b = par_thetab;
       parscd.hc      = par_hc;
       parscd.tind    = par_tind;

     % ROMS parent and child grid files
       pargrd = [par_dir par_grd]; 
       chdgrd = [chd_dir chd_grd];

       parini = [par_dir par_ini];
       chdini = [chd_dir chd_file];

     if ~exist(chdini,'file')
      disp(['Creating initial file: ' chdini]);
      oct_r2r_create_ini(chdini, chdgrd, chd_N, chdscd, 'clobber')
     end
      ndomx=1;ndomy=1;
     oct_r2r_make_ini_v2(pargrd, parini, chdgrd, chdini, chdscd,parscd,parscoord,chdscoord, ndomx, ndomy)
     
     
  
     
     
     
     
     
     
