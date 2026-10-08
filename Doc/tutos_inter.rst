Interannual pre-processing
--------------------------

Dedicated scripts for interannual pre-processing can be found for the different 
forcing datasets in:

======================= ===========================================================================================
**Aforc_CFSR**          | Scripts for the recovery of surface forcing data (based on CFSR reanalysis) for
                        | interannual simulations
**Aforc_ECMWF**         | Scripts for the recovery of surface forcing data (based on ECMWF-ERAinterim simulations) for
                        | interannual simulations
**Aforc_ERA5**          | Scripts for the recovery of surface forcing data (based on ECMWF-ERA5 simulations) for
                        | interannual simulations
**Aforc_NCEP**          | Scripts for the recovery of surface forcing data (based on NCEP2 reanalysis) for
                        | interannual simulations
**Aforc_QuikSCAT**      Scripts for the recovery of wind stress from satellite scatterometer data (QuickSCAT)
**Forecast_tools**      Scripts for the generation of an operational oceanic forecast system
**Oforc_OGCM**          | Scripts for the recovery of initial and lateral boundary conditions from global OGCMs
                        | (SODA :cite:p:`carton_sea_2005` or CMEMS/Mercator :cite:p:`cmems_glorys12_2021`) for inter-annual simulations
======================= ===========================================================================================

#. Edit ``crocotools_param.m``
   First section should already be set if you have completed the previous 
   tutorial.

   In the second section, check the path to forcing data directory
   
   ::

        % 2 - Generic file and directory names 

        %  Forcing data directory (ncep, quikscat, datasets download with opendap, etc..)
        %
        FORC_DATA_DIR = ['~/DATA/'];

   In section 4, select only ini and bry (but no clim files, set: ``makeclim = 0;``) 
   to avoid too long pre-processing, and as it is the most usual set up
   ::

        %  initial/boundary data options (1 = process)
        %  (used in make_clim, make_biol, make_bry,
        %   make_OGCM.m and make_OGCM_frcst.m)
        %
        makeini    = 1;   % initial data
        makeclim   = 0;   % climatological data (for boundaries and nudging layers)
        makebry    = 1;   % lateral boundary data

   Edit section 6 for running January to March 2005
   ::

        % 6 - Reference date and simulation times

        Ymin          = 2005;          % first forcing year
        Ymax          = 2005;          % last  forcing year
        Mmin          = 1;             % first forcing month
        Mmax          = 3;             % last  forcing month

   .. note:: 
          An important aspect is the definition of time and especially the 
          choice of a time origin. The origin of time Yorig should be kept 
          the same for all the preprocessing and postprocessing steps.

   Edit section 7 for using ERA5 and mercator forcing sets
   
   ::

    % 7 - Parameters for Interannual forcing (SODA, mercator, CFSR, ERA5 ...)
    %
    %
    Download_data = 1;   % Get data from OPENDAP sites  
    level         = 0;   % AGRIF level; 0 = parent grid 
    %
    % ...
                     %           1/1/1979 - 31/3/2011
    makefrc      = 0;       % 1: create forcing files
    makeblk      = 1;       % 1: create bulk files
    QSCAT_blk    = 0;       % 1: a) correct NCEP frc/bulk files with
                        %        u,v,wspd fields from daily QSCAT data
                        %    b) download u,v,wspd in QSCAT frc file
    add_tides    = 0;       % 1: add tides
    add_waves    = 0;       % 1: add waves
    % ...
    %
    %--------------------------------------------------
    %  Options for make_ERA5 
    %--------------------------------------------------
    %
    ERA5_dir    = [FORC_DATA_DIR,'ERA5_',CROCO_config,'/'];        % ERA5 data dir. [croco format]
    My_ERA5_dir = [FORC_DATA_DIR,'ERA5_native_',CROCO_config,'/']; % ERA5 native data downloaded
                                                                   % with python script

    itolap_era5 = 2;                                               % 2 records = 2 hours
    %
    % ...
    %
    %--------------------------------------------
    % Options for make_OGCM_SODA or make_OGCM_mercator
    %--------------------------------------------
    %
    OGCM        = 'mercator';        % Select OGCM: SODA or mercator
    %
    OGCM_dir    = [FORC_DATA_DIR,OGCM,'_',CROCO_config,'/'];  % OGCM data dir. [croco format]
    %
    bry_prefix  = [CROCO_files_dir,'croco_bry_',OGCM,'_'];    % generic boundary file name
    clm_prefix  = [CROCO_files_dir,'croco_clm_',OGCM,'_'];    % generic climatology file name
    ini_prefix  = [CROCO_files_dir,'croco_ini_',OGCM,'_'];    % generic initial file name
    OGCM_prefix = [OGCM,'_'];                                 % generic OGCM file name 

    mercator_type=1;    % 1 -->  1/12 deg Mercator global reanalysis
                        % 2 -->  1/12 deg Mercator global analysis
                        % 3 -->  1/12 deg Mercator global forecast (See Section 8.)
                        % 4 -->  1/24 deg Mercator Mediterranean analysis/forecast (See Section 8.)
                        % 5 -->      the same than 4 but with detiding postprocessing on current and ssh

    %  =============
    %  To download CMEMS data: set login/password (http://marine.copernicus.eu) 
    %  and path to copernicusmarine executable
    %  see Oforc_OGCM/Copernicus_Marine_Toolbox_installation.md
    %
    %  Various sets of data are proposed in the Copernicus web site
    %
    if strcmp(OGCM,'mercator')
    %
    pathCMC='/path/to/home/copernicusmarine'; % copernicusmarine client
    %
    user     = 'XXXX';
    password = 'XXXX';
    %


#. Then you can run the Matlab pre-processing for these interannual forcing:
   You should already have you grid set up. Otherwise, run ``make_grid``

   To build your ERA5 interannual atmospheric forcing, script are in ``Aforc_ERA5/``.
   Details are available in ``README_ERA5.txt``. The download part used python script

   To build your CMEMS/mercator interannual ocean forcing, the useful script is 
   ``Oforc_OGCM/make_OGCM_mercator.m``.
   The download part used python script

   .. warning:: 
    
        As this pluri-month preprocessing can be longer and uses more CPU 
        ressources, you may need to submit it as a job. 
        A few example scripts (for SODA and CFSR) are provided:
   
        :: 
                
                cp ~/croco/croco_tools/example_job_prepro_matlab.pbs .

        Launch your pre-processing job
        ::

                qsub example_job_prepro_matlab.pbs

#. Check your generated files in ``CROCO_FILES``
   You should have
   ::

        croco_blk_ERA5_Y????M?.nc 
        croco_bry_mercator_Y????M?.nc
        croco_ini_mercator_Y????M?.nc



