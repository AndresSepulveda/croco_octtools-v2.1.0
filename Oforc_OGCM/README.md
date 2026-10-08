## 23-02-2024 : Update to use the Copernicus Marine Toolbox
 
 - see Copernicus_Marine_Toolbox_installation.md

## 24-11-2020 : Update by Gildas Cambon
Now you can process oceanic forcing from the global daily glorys12 reanalysis
at 1/12 degree resolution.
It is distributed by copernicus/mecator =>  https://resources.marine.copernicus.eu/

It use the python-motu client to download a space and time 
extraction of the reanalysis.
Have a look at the routines :
- download_mercator_frcst_python.m
- get_file_python_mercator.m

## 14-02-2014 : Gildas Cambon
Now it use the ECCO2 data, every 3 days

## 01-19-2006 : Pierrick Penven
make_OGCM.m is a way to get initial and boundary conditions. For CROCO simulations from different global oceanic models. For the moment it works with SODA and ECCO. it uses DODS to extract the subgrids
