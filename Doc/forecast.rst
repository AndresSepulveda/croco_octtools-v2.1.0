Forecasts 
=========

With the method described by :cite:t:`marchesiello_mercator_2008`, 
CROCO can be used to downscale global forecasts in order to provide higher 
resolution forecasting.

.. warning::

   This method is only available with Matlab croco_tools


It is advised to start from building a regional 
configuration following the dedicated tutorials and testing it with climatological 
or interannual forcing. 

Then, specifically for the forecast system, you 
will need to set the forecast parameters in ``crocotools_param.m``, define 
cpp key ``ROBUST_DIAG`` in cppdefs.h and recompile the model using jobcomp, 
then edit ``croco_forecast.in``. Finally, run the script ``run_croco_forecast.bash`` 
that will download global forecast (ocean and atmosphere), create specific 
forcing files using the Forecast_tools Matlab package, then run croco for the 
current period.  

Strategy of Forecast_tools
--------------------------

CROCO_TOOLS allows running both inter-annual and real-time simulations. 
In the latter case, we rely on operational global ocean circulation models 
for the initial and lateral boundary conditions and operational global 
atmospheric models (introduced through bulk formulations) for surface forcing. 
In order to limit the volume of data transferred over the Internet, we use 
OPeNDAP (Matlab) or the Copernicus Marine Service Toolbox (Python) and extract 
only the necessary subgrid. We use the U.S. NCEP/NOAA data base for atmospheric 
forcing and the European CMEMS data for oceanic forcing. 

In a regional domain with low intrinsic variability where the circulation is 
directly forced by surface fluxes (away from fronts and eddies), initialization 
is of lower importance. However, if oceanic intrinsic variability with low 
predictability is dominant (e.g., mesoscale eddies with monthly time-scale), 
the model may well provide a statistically reliable image of the eddy field, 
but out of phase at any given time. An initialization method is therefore 
needed to bring ocean fields into phase with real time. Here, we do not perform 
data assimilation, but rely on the global CMEMS forecast products, which 
assimilates satellite altimetry and in-situ data. Newtonian nudging is used 
to adjust CMEMS data to CROCO dynamics in a downscaling procedure.

The strategy for a hindcast/forecast cycle is as follows. The simulation 
starts at t0-hdays (hdays=1, t0 being the present time) and ends at t0+fdays 
(fdays=3). The model is run using interpolated data from CMEMS for lateral 
boundary conditions and NCEP for surface forcing. CMEMS data or a CROCO 
restart file (from a previous forecast) is used for initialization at t0-1, 
while nudging assimilates CMEMS data in the interior domain (with a nudging 
time-scale of about 10 days). A Shell script (run_croco_forecast.bash) 
manages the whole procedure: download and pre-processing, forecast simulations, 
post-processing (plot_forecast_croco.m), data storage and preparation of 
the next forecast cycle.

Set forecast parameters
-----------------------

#. Edit ``crocotools_param.m``

   In section 7 Make sure that ``OGCM=mercator`` and set your login/password 
   (http://marine.copernicus.eu) to access CMEMS data through the python 
   Copernicus Marine Service Toolbox in Forecast_tools directory.

   ::
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % 8 - Parameters for the forecast system
        %
        %     --> select OGCM name above (mercator ...)
        %     --> select Aforc name (GFS)
        %     --> don't forget to define in cppdefs.h:
        %             - ROBUST_DIAG
        %             - CLIMATOLOGY
        %             - BULK_FLUX
        %             - TIDES if you choose so, but without TIDERAMP
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        FRCST_dir = [FORC_DATA_DIR,'Forecast/'];  % path to local OGCM data directory
        %
        %
        % Number of hindcast / forecast days
        %
        hdays=1;
        fdays=3;
        %
        % Local time= UTC + timezone
        %
        timezone = +2;
        %
        % Add tides
        %
        add_tides_fcst = 1;       % 1: add tides
        %
        %  MERCATOR cases (See Section 7): 
        %  =============
        %
        if strcmp(OGCM,'mercator')
            if mercator_type==3
                % ========================
                % 3 -> For Global Forecast PSY4
                % ========================
                product_id={'cmems_mod_glo_phy_anfc_0.083deg_P1D-m'  ...
                            'cmems_mod_glo_phy-cur_anfc_0.083deg_P1D-m', ...
                            'cmems_mod_glo_phy-thetao_anfc_0.083deg_P1D-m', ...
                            'cmems_mod_glo_phy-so_anfc_0.083deg_P1D-m'};
            %
            elseif mercator_type==4
                % ========================
                % 4 -> For Mediterannean Forecast PSY4 4.2km
                % ========================
                product_id={'cmems_mod_med_phy-ssh_anfc_4.2km_P1D-m', ...
                            'cmems_mod_med_phy-cur_anfc_4.2km_P1D-m', ...
                            'cmems_mod_med_phy-tem_anfc_4.2km_P1D-m', ... 
                            'cmems_mod_med_phy-sal_anfc_4.2km_P1D-m'};
            %
            elseif mercator_type==5
                % ========================
                % 5 -> For Mediterannean Forecast PSY4 4.2km (ssh detided)
                % ========================
                product_id={'cmems_mod_med_phy-ssh_anfc_detided_4.2km_P1D-m', ...
                            'cmems_mod_med_phy-cur_anfc_4.2km_P1D-m', ...
                            'cmems_mod_med_phy-tem_anfc_4.2km_P1D-m', ... 
                            'cmems_mod_med_phy-sal_anfc_4.2km_P1D-m'};
            %
            else           
            end
        end 


   Make sure that ``OGCM=mercator`` (section 7), choose the hindcast/forecast 
   period ``hdays/fdays`` (start with default),
   set your time zone and then your login/password (http://marine.copernicus.eu) 
   to access CMEMS data through motuclient python package in Forecast_tools 
   directory.


   .. warning:: 

      CMEMS url and files may sometimes change name, resulting in system 
      failure until we make the necessary adjustments.


#. Edit ``croco_forecast.in`` if you want to adjust some default parameters like 
   nudging coefficient to forecast data ( by default on the order of 15 days)

   ::

          nudg_cof:    TauT_in, TauT_out, TauM_in, TauM_out  [days for all]
                        1.       15.      1.      15.

   .. warning:: 
      ``croco_forecast.in`` contains template variables for NTIMES, DT, NDTFAST, 
      NRST,NWRT and NAVG


Compiling
---------

#. Edit ``cppdefs.h`` for defining forcing and nudging procedures:

   ::

        # define BULK_FLUX

                      /* Lateral Forcing */
        # define CLIMATOLOGY
        # ifdef CLIMATOLOGY
        #  define ZCLIMATOLOGY
        #  define M2CLIMATOLOGY
        #  define M3CLIMATOLOGY
        #  define TCLIMATOLOGY

        #  define ZNUDGING
        #  define M2NUDGING
        #  define M3NUDGING
        #  define TNUDGING
        #   define ROBUST_DIAG
        # endif

   ``ROBUST_DIAG`` sets non-zero nudging coefficients tauT_out for nudging to 
   CMEMS forecast (T,S) data.


#. Re-compile the model:

   ::

        ./jobcomp > jobcomp_forecast.log

Running the script
------------------

#. Copy run_croco_forecast.bash from SCRIPTS/Plurimonths_scripts to local directory. 

#. Edit run_croco_forecasts.bash. 

   Check in particular the locations of matlab executable and loaddap library 
   (used to extract NCEP atmospheric forecast data)
   
   ::

       export TOOLSDIR=$HOME/croco/croco_tools/Forecast_tools
       export RUNDIR=${PWD} 
       export MATLAB=/usr/local/bin/matlab
       export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/loaddap-3.5.2/lib

   Check the forecast cycle options (default choice is generally fine but 
   you may want to set RESTART=1 after the first forecast cycle)

   ::

        # Clean results of previous forecasts
        #
        export CLEAN=0
        #
        # Get forcing files from DODS SERVER and process them for CROCO
        # PRE_PROCESS=1 ==> do the work (0 otherwise)
        #
        export PRE_PROCESS=1
        #
        # Restart from previous forecast
        #
        export RESTART=0
        #
        # Run hindcast/forecast
        #
        export RUN=1
        #
        #
        # Make a few plots
        export PLOT=1
        #
        #=======================================================================
        # Define time parameters (it will modify croco_forecast.in)
        #=======================================================================
        #
        # Model time step [seconds]
        DT=3600
        # Number of barotropic time steps within one baroclinic time step [number]
        # NDTFAST in croco.in
        NFAST=60
        # Hindcast depth [days] see crocotools_param (hdays/fdays)
        NDAYS_HIND=1
        # Forecast depth [days]
        NDAYS_FCST=3
        # Output frequency [hours]
        #   average
        ND_AVG=24
        #   history (if = -1 set equal to NUMTIMES)
        ND_HIS=6
        #   restart (if = -1 set equal to NUMTIMES)
        ND_RST=24


#. Run the script (from Terminal or from Crontab)

   ::

        ./run_croco_forecast.bash
