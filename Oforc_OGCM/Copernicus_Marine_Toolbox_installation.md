# Copernicus Marine Toolbox installation

The Copernicus Marine Toolbox is used to download and extract data from the Copernicus Marine Data Store (Global Ocean Physics Reanalysis, Global Ocean Physics Analysis and Forecast, ...) to create oceanic open boundary and initial conditions. [ https://data.marine.copernicus.eu/products ]


All the instructions can be found here :
- Installation and update : https://help.marine.copernicus.eu/en/articles/7970514-copernicus-marine-toolbox-installation
  
- Use : https://help.marine.copernicus.eu/en/collections/4060068-copernicus-marine-toolbox


## Prerequisites:
   * python version >= 3.9 & <3.12


## Location
The location of the executable (here after pathCMC) will be found typing :
```console
which copernicusmarine
```

Note that the value returned by your terminal here, will be your pathCMC to fill in your crocotools_param.m and download_glorys_data.sh script



## When it's installed :

You will have access to the copernicusmarine executable with various sub-command, very useful to get, extract and download data from the Copernicus Marine Data Store :

```console
copernicusmarine -h
```

Or alternatively:

```console
$CONDA_PREFIX/bin/copernicusmarine -h
```


To be used in the Matlab croco_tools, in the crocotools_param.m, you need to :

- define the path to the copernicusmarine executable (`pathCMC`) in crocotools_param.m at *section 7, Option for make_OGCM_frcst or make_OGCM_mercator*
- define your copernicus marine `login` and `password` in crocotools_param.m at *section 7, Options for for make_OGCM_frcst or make_OGCM_mercator*





