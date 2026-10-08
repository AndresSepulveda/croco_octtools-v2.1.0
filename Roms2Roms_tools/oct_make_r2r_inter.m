%---------------------------------------------------------------------------------------
%
%  oct_make_r2r_inter  (make_roms2roms, interannual)
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
%  Add interanual loop, Lionel 2014
%
%  Octave version (Oct-2026): calls the oct_ routines (netcdf.* API of
%  octave-netcdf; the boundary file is opened with netcdf.open instead
%  of the old netcdf toolbox). Only the r2r_coefs_*.mat files are
%  deleted at the start (was "!rm -rf *.mat").
%
%---------------------------------------------------------------------------------------
clear all
close all
disp(' ')
%---------------------------------------------------------------------------------------
% USER-DEFINED VARIABLES & OPTIONS START HERE
%---------------------------------------------------------------------------------------
%
%---------------------------------------------------------------------------------------
% 1.  GENERAL
%---------------------------------------------------------------------------------------

    
    % Parent...
      par_dir    = '/balearic/lrenault/ROMS/USW12/Outputs/HIS/temp/';
      par_grd    = '../../../usw12_grd.nc';
      par_file   = 'usw12';
      par_tind   = 1;            % frame number in parent file
      par_thetas = 6.5;
      par_thetab = 1.5;
      par_hc     = 250.0;
      par_N      = 42;
      par_scoord  = 'new2008';    % parent 'new' or 'old' type scoord


    % Child...
      chd_dir    = '/balearic/lrenault/ROMS/USW4/';
      chd_grd    = 'usw43_grd.nc';
      chd_file   = 'usw43_ini_June2005.nc';        % name of new ini file
      chd_thetas = 6.5;
      chd_thetab = 1.5;
      chd_hc     = 250.0;
      chd_N      = 42;
      chd_scoord  = 'new2008';                 % child 'new' or 'old' type scoord


%---------------------------------------------------------------------------------------
% 2. BOUNDARY FILE
%---------------------------------------------------------------------------------------
    obcflag              = [1 0 1 1];      % open boundaries flag (1=open , [S E N W])
    bry_cycle            =  0;             % 0 means no cycle
    bry_filename         = 'usw43_bry_2005.nc'; % bry filename
    bry_type             = 'his';          % 'avg', 'his' or 'rst'
    total_num_files      =  370;            % number of files to read
    first_file           =  3773;            % first avg/his file, eg roms_avg.0282.nc gives 282
    first_record         =   1;            % desired record no. from first avg/his file
    last_record          =   1;            % desired record no. from last avg/his file
    num_records_per_file =   1;            % number of records per parent output file
    Yref                 =  2005;          % Reference year in the simulation
    Mref                 =  5;             % Reference month 
    Dref                 =  1;             % Reference day
    Ymin                 =  2005;          % Starting year
    Ymax                 =  2005;          % Ending year

%---------------------------------------------------------------------------------------
% USER-DEFINED VARIABLES & OPTIONS END HERE
%---------------------------------------------------------------------------------------
%
    dateref=datenum(Yref, Mref, Dref);
    ocean_time=dateref:num_records_per_file:dateref+total_num_files-1;

% Put the various paths/filenames/variables together

    % Child and parent s-coord parameters into chdscd and parscd
    chdscd.theta_s = chd_thetas;
    chdscd.theta_b = chd_thetab;
    chdscd.hc      = chd_hc;
    chdscd.N       = chd_N;
    chdscd.scoord  = chd_scoord;


    parscd.theta_s = par_thetas;
    parscd.theta_b = par_thetab;
    parscd.hc      = par_hc;
    parscd.N       = par_N;
    parscd.scoord  = par_scoord;

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

    par_data_path = [par_dir par_file '_' bry_type '.'];


    % Get parent subgrid bounds
    disp(' ')
    disp('Get parent subgrids for each open boundary')
    limits = oct_r2r_bry_subgrid(parentgrid, childgrid,obcflag); 

      % Compute the coeff for each OBC

    oct_r2r_coef_inter(parentgrid,childgrid,       ...
                     chdscd,parscd,      ...
                     obcflag, limits);
   % Load the coeff for each obc
    for bnd = 1:4
      if bnd==1
         disp('South boundary')
         fcoef = 'r2r_coefs_south.mat';
         if exist(fcoef,'file')
           load(fcoef)
           A_south=A;coef2d_south=coef2d;elem2d_south=elem2d;nnel_south=nnel;
         else
           A_south=0;coef2d_south=0;elem2d_south=0;nnel_south=0;
         end
       end
       if bnd==2
         disp('East boundary')
         fcoef = 'r2r_coefs_east.mat';
         if exist(fcoef,'file')
           load(fcoef)
           A_east=A;coef2d_east=coef2d;elem2d_east=elem2d;nnel_east=nnel;
         else
           A_east=0;coef2d_east=0;elem2d_east=0;nnel_east=0;
         end
       end
       if bnd==3
         disp('North boundary')
         fcoef = 'r2r_coefs_north.mat';
         if exist(fcoef,'file')
           load(fcoef)
           A_north=A;coef2d_north=coef2d;elem2d_north=elem2d;nnel_north=nnel;
         else
           A_north=0;coef2d_north=0;elem2d_north=0;nnel_north=0;
         end
       end
       if bnd==4
         disp('West boundary')
         fcoef = 'r2r_coefs_west.mat';
         if exist(fcoef,'file')
           load(fcoef)
           A_west=A;coef2d_west=coef2d;elem2d_west=elem2d;nnel_west=nnel;
         else
           A_west=0;coef2d_west=0;elem2d_west=0;nnel_west=0;
         end
       end
    end

    for Ym=Ymin:Ymax

      chd_tind = [0];
      % Create the bry file
      bname  = [chd_dir, bry_filename, num2str(Ym), '.nc'];
      disp(['Creating boundary file: ' bname]);
      oct_r2r_create_bry(bname,childgrid,obcflag,chdscd,bry_cycle);
      % Open the bry file
      nd=netcdf.open(bname,'NC_WRITE');

      % Get the corresponding files
      indt = find(ocean_time>=datenum(Ym,1,1)-num_records_per_file-1 & ocean_time<=datenum(Ym+1, 1, 1)+num_records_per_file); 
      fld  = first_file + indt(1:num_records_per_file:end)-1;
      total_year_files = length(fld);
     
       for parfile = 1:length(fld); % loop through corresponding parent data files
          sfld = sprintf('%04d',fld(parfile));
          par_data = [par_data_path sfld '.nc'];
          par_tind=1:num_records_per_file;
          chd_tind = par_tind - par_tind(1) + 1 + chd_tind(end);
          disp('==============================================================')
          disp(' ')
          disp(['Processing: ' par_data])
          disp(' ')

          oct_r2r_hv_inter(parentgrid, par_data, par_tind,           ...
                       childgrid, bname, chd_tind,     ...
                       chdscd,parscd,obcflag,limits,nd,  ...
                       A_south,coef2d_south,elem2d_south,nnel_south, ...
                       A_east,coef2d_east,elem2d_east,nnel_east, ...
                       A_north,coef2d_north,elem2d_north,nnel_north, ...
                       A_west,coef2d_west,elem2d_west,nnel_west);
       end   %  loop through parent data files
        disp(' ')
        disp('=============== Boundary file done ===============')
        disp(' ')
       netcdf.close(nd);
    end
