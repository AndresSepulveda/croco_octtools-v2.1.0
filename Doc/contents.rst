Contents
--------

List of directories in repository :

.. table:: 
   :widths: 20 80

   +-------------------------+------------------------------------------------------------------+
   | **Aforc_CFSR**          | Scripts for the recovery of surface forcing data                 |
   |                         | (based on CFSR reanalysis) for interannual                       | 
   |                         | simulations                                                      |
   +-------------------------+------------------------------------------------------------------+
   | **Aforc_ECMWF**         | Scripts for the recovery of surface forcing data                 |
   |                         | (based on ECMWF-ERAinterim simulations) for                      |
   |                         | interannual simulations                                          |
   +-------------------------+------------------------------------------------------------------+
   | **Aforc_ERA5**          | Scripts for the recovery of surface forcing data                 |
   |                         | (based on ECMWF-ERA5 simulations) for                            |
   |                         | interannual simulations                                          |
   +-------------------------+------------------------------------------------------------------+
   | **Aforc_NCEP**          | Scripts for the recovery of surface forcing data                 |
   |                         | (based on NCEP2 reanalysis) for                                  |
   |                         | interannual simulations                                          |
   +-------------------------+------------------------------------------------------------------+
   | **Aforc_QuikSCAT**      | Scripts for the recovery of wind stress from                     |
   |                         | satellite scatterometer data (QuickSCAT)                         |
   +-------------------------+------------------------------------------------------------------+
   | **Coupling_tools**      | Scripts for preparing coupled simulations                        |
   +-------------------------+------------------------------------------------------------------+
   | **Diagnostic_tools**    | A few Matlab scripts for animations and basic                    |
   |                         | statistical analysis                                             |
   +-------------------------+------------------------------------------------------------------+
   | **Forecast_tools**      | Scripts for the generation of an operational                     |
   |                         | oceanic forecast system                                          |
   +-------------------------+------------------------------------------------------------------+
   | **Nesting_tools**       | Preprocessing tools used to prepare nested models                |
   +-------------------------+------------------------------------------------------------------+
   | **Oforc_OGCM**          | Scripts for the recovery of initial and lateral                  |
   |                         | boundary conditions from global OGCMs                            |
   |                         | (SODA :cite:p:`carton_sea_2005` or CMEMS/Mercator                |
   |                         | :cite:p:`cmems_glorys12_2021`) for inter-annual simulations      |
   +-------------------------+------------------------------------------------------------------+
   | **Opendap_tools**       | LoadDAP mexcdf and several scripts to automatically              |
   |                         | download data over the Internet                                  |
   +-------------------------+------------------------------------------------------------------+
   | **Preprocessing_tools** | Preprocessing Matlab scripts (make_grid.m,                       |
   |                         | make_forcing, etc…)                                              |
   +-------------------------+------------------------------------------------------------------+
   | **Rivers**              | Scripts to prepare time-varying runoff forcing file              |
   |                         | and compute the runoff location                                  |
   +-------------------------+------------------------------------------------------------------+
   | **Tides**               | Matlab routines to prepare CROCO tidal                           |
   |                         | simulations. Tidal data are derived from the                     |
   |                         | Oregon State University global models of ocean                   |
   |                         | tides TPXO6 and TPXO7                                            |
   |                         | :cite:p:`egbert_efficient_2002`                                  |
   |                         | : http://www.oce.orst.edu/research/po/research/tide/global.html  |
   +-------------------------+------------------------------------------------------------------+
   | **Visualization_tools** | Matlab scripts for the CROCO visualization graphic               |
   |                         | user interface                                                   |
   +-------------------------+------------------------------------------------------------------+
   | **UTILITIES**           | Utilities/toolbox requested for matlab                           |
   |                         | crocotools programs                                              |
   +-------------------------+------------------------------------------------------------------+


Details on UTILITIES directory :

========================= =================================================================================================
**export_fig**            A MATLAB toolbox for exporting publication quality figures : https://github.com/altmany/export_fig
**mask**                  Land mask edition toolbox developed by A.Y. Shcherbina.
**mex60**                 Matlab NetCDF interface for 32 & 64 bits Linux architectures and old matlab version: 6 and before
**mexcdf/mexnc**          | Matlab NetCDF interface for 32 & 64 bits Linux architectures, MatlabR14sp1 until R2008a 
                          | (http://mexcdf.sourceforge.net/downloads/mexcdf-R2008a.r2691.zip). For next releases of Matlab, 
                          | R2008b, R2009a, it is more simpler, either use the native NetCDF toobox of matlab or use the 
                          | last release of mexcf at the same url for version after R2008a.
                          | (http://mexcdf.sourceforge.net/downloads/mexcdf.r2802.zip)
**mexcdf/netcdf_toolbox** The Matlab NetCDF toolbox available in the same mexcdf package.
**m_map**                 The Matlab mapping toolbox (http://www2.ocgy.ubc.ca/rich/map.html).
**netcdf_x86_64**         The NetCDF Fortran library for Linux, compiled with ifort on a 64 bits architecture.
========================= =================================================================================================

