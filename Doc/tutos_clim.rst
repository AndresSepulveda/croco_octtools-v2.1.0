Climatological pre-processing
-----------------------------

#. First you can download some datasets from 
   :ref:`available datasets <dataset_dwl>` 

#. First you may need to edit ``start.m``, which contains the path to all useful 
   croco_tools Matlab scripts:
   ::

        disp(['Add the paths of the different toolboxes'])
        tools_path=['~/croco/croco_tools/'];
        croco_path=['~/croco/croco/'];


   .. note:: 
      
      You can use these env variables in matlab by using ``getenv('ENVVAR')``, 
      example: if you have a ``$tools`` environment variables for croco_tools, 
      you can write in start.m: ``tools_path=[getenv('tools') '/'];`` 

#. Then edit ``crocotools_param.m``, which is the namelist file for Matlab 
   pre-processing:
   ``crocotools_param.m`` is separated into several sections:

   +--------------------------------------------------------------+------------------------------------------------------------+
   | 1 - Configuration parameters                                 | used by make_grid.m (and others..)                         |
   +--------------------------------------------------------------+------------------------------------------------------------+
   | 2 - Generic file and directory names                         | need to match your work architecture                       |
   +--------------------------------------------------------------+------------------------------------------------------------+
   | 3 - Surface forcing parameters                               | used by make_forcing.m and by make_bulk.m                  |
   +--------------------------------------------------------------+------------------------------------------------------------+
   | 4 - Open boundaries and initial conditions parameters        | used by make_clim.m, make_biol.m, make_bry.m,              |
   |                                                              | make_OGCM.m and  make_OGCM_frcst.m.                        |
   +--------------------------------------------------------------+------------------------------------------------------------+
   | 5 - Parameters for tidal forcing                             | used by  make_tides.m.                                     |
   +--------------------------------------------------------------+------------------------------------------------------------+
   | 6 - Reference date and simulation times                      | used for make_tides, make_CFSR (or make_NCEP),             |
   |                                                              | make_OGCM.                                                 |
   +--------------------------------------------------------------+------------------------------------------------------------+
   | 7 - Parameters for Interannual forcing                       | SODA, ECCO, CFSR, NCEP, ...                                |
   +--------------------------------------------------------------+------------------------------------------------------------+
   | 8 - Parameters for the forecast system                       | used by make_forecast.m                                    |
   +--------------------------------------------------------------+------------------------------------------------------------+
   | 9 - Parameters for the diagnostic tools                      | used by scripts in ``Diagnostic_tools``                    |
   +--------------------------------------------------------------+------------------------------------------------------------+


   The first section is already set for BENGUELA_LR configuration, so you just 
   need to change the second section: directory names:

   ::

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % 2 - Generic file and directory names 
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %
        %  CROCOTOOLS directory
        %
        CROCOTOOLS_dir = ['~/croco/croco_tools/'];
        %
        %  Run directory
        %
        RUN_dir=[pwd,'/'];
        %
        %  CROCO input netcdf files directory
        %
        CROCO_files_dir=[RUN_dir,'CROCO_FILES/'];
        %
        %  Global data directory (etopo, coads, datasets download from ftp, etc..)
        %
        DATADIR=['~/DATA/DATASETS_CROCOTOOLS/'];
        %
        %  Forcing data directory (ncep, quikscat, datasets download with opendap, etc..)
        %
        FORC_DATA_DIR = ['~/DATA/'];


   .. note:: 
      The ``crocotools_param.m`` is called at the beginning of all Preprocessing 
      script. You do not have to launch it independently.  

#. Now you are ready to launch pre-processing in Matlab:

   .. note::
      All the pre-processing scripts used for climatological forcing are in the 
      ``Preprocessing_tools`` directory

   Launch Matlab, and set up paths:
   :: 
        
        matlab
        start

   Build the grid:
   ::

        make_grid

   During the grid generation process, the question 
   “Do you want to use editmask ? y,[n]” is asked. The default answer is n 
   (for no). If the answer is y (for yes), editmask, the graphic interface 
   developed by A.Y.Shcherbina, will be launched to manually edit the mask. 
   Otherwise the mask is generated from the unfiltered topography data. 
   A procedure prevents the existence of isolated land (or sea) points.

   Finally, a figure illustrates the obtained bottom topography. Note that at 
   his low resolution (1/3°), the topography has been strongly smoothed. 
    
   Build the atmospheric forcing: 2 options are available:

   * create a forcing file with wind stress (zonal and meridional components), 
     surface net heat flux, surface freshwater flux (E-P), solar shortwave 
     radiation, SST, SSS, surface net sensitivity to SST (used for heat flux 
     correction dQdSST for nudging towards model SST and model SSS)
   * or create a bulk file which will be read during the run to perform bulk 
     parameterization of the fluxes using COAMPS or Fairall 2003 formulation. 
     This bulk file contains: surface air temperature, relative humidity, 
     precipitation rate, wind speed at 10m, net outgoing longwave radiation, 
     downward longwave radiation, shortwave radiation, surface wind speed 
     (zonal and meridional components). It also contains surface wind stress 
     (zonal and meridional components), but it is not requested and used in 
     the model (except for specific debugging work). The bulk formulation 
     computes its own wind stress.

     ::

        make_bulk

     or:
     ::

        make_forcing

     The settings relative to surface forcing are in section 3 of 
     ``crocotools_param.m``. In the case of climatological forcing, 
     the variables are cycled. You can see that here, for the sake of 
     simplicity, we are running the model on a repeating climatological year 
     of 360 days.

     A few figures illustrate the wind stress vectors and norm at 4 different 
     periods of the year. 

     .. note:: 
         ``make_bulk`` creates a forcing file that will be used with the 
         cpp key ``BULK_FLUX``, while ``make_forcing`` creates a forcing file 
         containing wind stress directly and will be used when 
         ``undefined BULK_FLUX``. This second option is relevant if your 
         atmospheric forcing comes from an atmospheric model with sufficient 
         output frequency, or/and if your are comparing forced and coupled runs. 
         Otherwise it is suggested to use ``make_bulk``. 

     Build the lateral boundary conditions: 2 options are available:
     :: 

        make_bry

     .. note:: 
         ``make_bry`` requests that you have previously run ``make_forcing`` 
         to compute Ekman forcing at the surface. 

     or:
     ::

        make_clim

     The settings relative to boundary conditions are in section 4 of ``crocotools_param.m``. 

     A few figures illustrate vertical sections of temperature. 

     .. note:: 
      
         ``make_clim`` interpolates the oceanic forcing fields over the whole 
         domain: only boundary points + the 10 next points are actually used for 
         sponge + nudging. 
         *Advantage*:  sponge + nudging layers at the boundaries,  
         *Disadvantage*:  large amount of unused data.
         
         ``make_bry`` interpolates the oceanic forcing fields at the boundary 
         points only. 
         *Advantage*: light files (useful for long simulations), 
         *Disadvantage*: no nudging layers (only a sponge layer for smooth 
         transition between the boundaries and the interior values).

     Build the initial conditions:
     ::

        make_ini

#. You can look at your generated input files in ``CROCO_FILES`` directory:
   You should have:
   ::

        croco_grd.nc
        croco_ini.nc
        croco_blk.nc # or croco_frc.nc
        croco_bry.nc # or croco_clm.nc

#. Summary to create a simple configuration from climatology files:
   In Matlab, execute the following:

   ::

        start
        make_grid
        make_forcing   
        make_bulk
        make_bry       # or make_clim
        make_ini

   This will create:

   ::

        croco_grd.nc
        croco_frc.nc (or croco_blk.nc)
        croco_bry.nc (or croco_clim.nc)
        croco_ini.nc

