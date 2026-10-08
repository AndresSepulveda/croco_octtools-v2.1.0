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
%  octave-netcdf). "!rm -rf *.mat" deleted ALL the .mat files of the
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
      par_dir = '/home/claude/testrun/R2R/PAR/';
      par_grd    = 'croco_grd.nc';
      par_file   = 'croco';
      par_tind   = 1;            % frame number in parent file
      par_thetas = 7;
      par_thetab = 2;
      par_hc     = 200.0;
      par_N      = 32;
      parscoord  = 'new2008';    % parent 'new' or 'old' type scoord


    % Child...
      chd_dir    = '/home/claude/testrun/R2R/CHD/';
      chd_grd    = 'croco_grd.nc';
      chd_file   = 'croco_ini.nc';        % name of new ini file
      chd_thetas = 7;
      chd_thetab = 2;
      chd_hc     = 200.0;
      chd_N      = 32;
      chdscoord  = 'new2008';                 % child 'new' or 'old' type scoord

%---------------------------------------------------------------------------------------
% 2. BOUNDARY FILE
%---------------------------------------------------------------------------------------
    obcflag              = [1 1 1 1];      % open boundaries flag (1=open , [S E N W])
    bry_cycle            =  0;             % 0 means no cycle
    bry_fname         = 'croco_bry.nc'; % bry filename
    bry_type             = 'avg';          % 'avg', 'his' or 'rst'
    total_num_files      =  2;            % number of files to read
    first_file           =  00010;            % first avg/his file, eg roms_avg.0282.nc gives 282
    first_record         =   1;            % desired record no. from first avg/his file
    last_record          =   3;            % desired record no. from last avg/his file
    num_records_per_file =   5;            % number of records per parent output file
    fourdigit=0;

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

    old_coefs = dir('r2r_coefs_*.mat');
    for k = 1:numel(old_coefs)
      delete(old_coefs(k).name);
    end

    bry_filename  = [chd_dir bry_fname];
    par_data_path = [par_dir par_file '_' bry_type '.'];

    % Create the bry file
    disp(['Creating boundary file: ' bry_filename]);
    oct_r2r_create_bry(bry_filename,childgrid,obcflag,chdscd,bry_cycle);

    % Get parent subgrid bounds
    disp(' ')
    disp('Get parent subgrids for each open boundary')
    limits = oct_r2r_bry_subgrid(parentgrid, childgrid,obcflag)

    chd_tind = [0];
    for parfile = 1:total_num_files; % loop through all parent data files
%    for parfile = 1:1
       fld  = (parfile-1) * num_records_per_file + first_file;

       if fourdigit==1
         sfld = sprintf('%04d',fld);
       else
         sfld = sprintf('%05d',fld);
       end

       par_data = [par_data_path sfld '.nc'];

       if (parfile==1)
        rec0 = first_record;
       else
        rec0 = 1.;
       end
       if (parfile==total_num_files)
        rec1 = last_record;
       else
        rec1 = num_records_per_file;
       end
       par_tind = [rec0:rec1];
       chd_tind = par_tind - par_tind(1) + 1 + chd_tind(end);

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
