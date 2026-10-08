Philosophy
----------

Two scripts are used to set-up your Matlab environment and your configuration 
settings: 

======================= ==============================================
**start.m**             useful paths for croco_tools Matlab scripts
**crocotools_param.m**  namelist file for Matlab pre-processing
======================= ==============================================

* ``start.m``: has  to  be  launched  at  the beginning  of  any  matlab  
  session to set the path to utilities and croco tools routines. Edit mypath 
  and myutilpath
* ``crocotools_param.m``: defines all the parameters and paths needed to 
  build the grid, forcing and boundary files. Edit the different sections.

.. note:: 
  
  In the ``croco_tools`` toolbox, the native Matlab Netcdf library is not 
  used. A dedicated Netcdf library is provided and used. Its path is added 
  to your Matlab environment through the the ``start.m`` script.

* Steps for creating a configuration are:

  * build the grid
  * build the atmospheric forcing (not necessary when coupling with an 
    atmospheric model)
  * build the lateral boundary conditions (3D currents, temperature and 
    salinity, barotropic currents, surface elevation)
  * build the initial conditions

