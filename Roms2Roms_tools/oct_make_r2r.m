%---------------------------------------------------------------------------------------
%
%  oct_make_r2r  (make_roms2roms)
%
%  Generate boundary perimeter file from ROMS parent data.
%  Designed for compatibility with
%  arbitrary horizontal orientation of the grid system and
%  desired vertical s-coordinate ('new' or 'old').
%
%  Note that when run this script it tests for the presence of a .mat file
%  which contains various interpolation coefficients related to your child
%  and parent grids.  If the .mat file is not there it will calculate the coefficients
%
%
%  Jeroen Molemaker and Evan Mason in 2007-2009 at UCLA
%
%  Octave version (Oct-2026): calls the oct_ routines (netcdf.* API of
%  octave-netcdf). The parent files are given by name (par_files, e.g.
%  croco_avg.nc or croco_his.nc, several files or a pattern) instead of
%  the numbered files croco_avg.NNNNN.nc (first_file, total_num_files,
%  num_records_per_file are not needed anymore): the number of records of
%  each file is read in the file, and the records already written (same
%  time) are skipped. "!rm -rf *.mat" deleted ALL the .mat files of the
%  current folder: now only the old coefficient files r2r_coefs_*.mat
%  are deleted (they must be recomputed when the grids change).
%
%---------------------------------------------------------------------------------------
%clear all
%disp(' ')
%---------------------------------------------------------------------------------------
% USER-DEFINED VARIABLES & OPTIONS START HERE
%---------------------------------------------------------------------------------------
%
%---------------------------------------------------------------------------------------
% 1.  GENERAL
%---------------------------------------------------------------------------------------


    % Parent...
      par_dir = '/home/livecroco/Desktop/Run/CROCO_FILES/';
      par_grd    = 'croco_grd.nc';
      par_file   = 'croco';
      par_tind   = 1;            % frame number in parent file
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
% 2. BOUNDARY FILE
%---------------------------------------------------------------------------------------
    obcflag              = [1 0 1 1];      % open boundaries flag (1=open , [S E N W])
    bry_cycle            =  0;             % 0 means no cycle
    bry_fname         = 'croco_bry.nc.1'; % bry filename
    bry_type             = 'avg';          % 'avg', 'his' or 'rst' (used when par_files is empty)
    par_files            = {};             % parent file(s) in par_dir, in time order:
                                           %   {}  -> [par_file '_' bry_type '.nc'], e.g. croco_avg.nc
                                           %   'croco_his.nc'  or  {'croco_avg.nc','croco_avg_2.nc'}
                                           %   'croco_avg.*.nc' (pattern: all the matching files)
    first_record         =   1;            % first record used in the first parent file
    last_record          =  [];            % last record used in the last parent file ([] = all)

%---------------------------------------------------------------------------------------
% USER-DEFINED VARIABLES & OPTIONS END HERE
%---------------------------------------------------------------------------------------
%

% Put the various paths/filenames/variables together

    % Child and parent s-coord parameters into chdscd and parscd
    chdscd.theta_s = chd_thetas;
    chdscd.theta_b = chd_thetab;
    chdscd.hc      = chd_hc;
    chdscd.N       = chd_N;
    chdscd.scoord  = chdscoord;


    parscd.theta_s = par_thetas;
    parscd.theta_b = par_thetab;
    parscd.hc      = par_hc;
    parscd.N       = par_N;
    parscd.scoord  = parscoord;

    % ROMS parent and child grid files
    parentgrid = [par_dir  par_grd]
    childgrid  = [chd_dir  chd_grd]


%---------------------------------------------------------------------------------------
%   BOUNDARY PERIMETER FILE
%---------------------------------------------------------------------------------------

    oct_r2r_clean_coefs   % deletes r2r_coefs_*.mat (function: not shadowed by a variable 'dir')

    bry_filename  = [chd_dir bry_fname];

    % Parent files (croco_avg.nc, croco_his.nc...) and time of their records
    [par_list,par_times] = oct_r2r_parent_files(par_dir,par_files,par_file,bry_type);

    % Create the bry file
    disp(['Creating boundary file: ' bry_filename]);
    oct_r2r_create_bry(bry_filename,childgrid,obcflag,chdscd,bry_cycle);

    % Get parent subgrid bounds
    disp(' ')
    disp('Get parent subgrids for each open boundary')
    limits = oct_r2r_bry_subgrid(parentgrid, childgrid,obcflag)

    chd_tind = [0];
    last_time = -Inf;
    nfiles = numel(par_list);
    for parfile = 1:nfiles % loop through all parent data files
       par_data = par_list{parfile};
       nrec = numel(par_times{parfile});
       rec0 = 1;
       rec1 = nrec;
       if parfile==1
         rec0 = first_record;
       end
       if parfile==nfiles && ~isempty(last_record)
         rec1 = min(last_record,nrec);
       end
       par_tind = rec0:rec1;
       % records already written (e.g. first record of a history file
       % equal to the last record of the previous file) are skipped
       par_tind = par_tind(par_times{parfile}(par_tind) > last_time);
       if isempty(par_tind)
         disp(['No new record in ',par_data])
         continue
       end
       last_time = par_times{parfile}(par_tind(end));
       chd_tind = (1:numel(par_tind)) + chd_tind(end);

       disp('==============================================================')
       disp(' ')
       disp(['Processing: ' par_data])
       disp(' ')
       disp(['--- using parent record(s)  ', num2str(par_tind)])
       disp(['--- setting child record(s) ', num2str(chd_tind)]);

       oct_r2r_hv(parentgrid, par_data, par_tind,           ...
              childgrid, bry_filename, chd_tind,     ...
              chdscd,parscd,obcflag,limits)

    end   %  loop through parent data files
    disp(' ')
    disp('=============== Boundary file done ===============')
    disp(' ')
