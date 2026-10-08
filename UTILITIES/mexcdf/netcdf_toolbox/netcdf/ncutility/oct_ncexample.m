function oct_ncexample

% oct_ncexample.m -- "NetCDF Toolbox for Matlab-5" example.
%  oct_ncexample (no argument) is a short example that lists
%   itself, builds a simple NetCDF file, then displays
%   its variables.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 12-Jun-1997 16:23:04.

type(mfilename)

help(mfilename)
 
% ---------------------------- DEFINE THE FILE --------------------------- %

ncquiet                                              % No NetCDF warnings.

ncid = netcdf.create('oct_ncexample.nc', 'NC_CLOBBER');  % Create NetCDF file.

netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'description', 'NetCDF Example');  % Global attributes.
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'author', 'Dr. Charles R. Denham');
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'date', 'June 9, 1997');

did_latitude = netcdf.defDim(ncid, 'latitude', 10);  % Define dimensions.
did_longitude = netcdf.defDim(ncid, 'longitude', 10);

ncid{'latitude'} = 'latitude';                         % Define variables.
ncid{'longitude'} = 'longitude';
ncid{'depth'} = {'latitude', 'longitude'};

netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'latitude'), 'units', 'degrees');  % Attributes.
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'longitude'), 'units', 'degrees');
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'depth'), 'units', 'meters');

% ---------------------------- STORE THE DATA ---------------------------- %

latitude = [0 10 20 30 40 50 60 70 80 90];           % Matlab data.
longitude = [0 20 40 60 80 100 120 140 160 180];
depth = rand(length(latitude), length(longitude));

netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'latitude'), latitude);  % Put all the data.
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'longitude'), longitude);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'depth'), depth);

ncid = close(ncid);                                      % Close the file.

% ---------------------------- RECALL THE DATA --------------------------- %

ncid = netcdf.open('oct_ncexample.nc', 'NC_NOWRITE');  % Open NetCDF file.
description = ncid.description(:)                      % Global attribute.
variables = var(ncid);                                 % Get variable data.
for i = 1:length(variables)
   disp([name(variables{i}) ' =']), disp(' ')
   disp(variables{i}(:))
end
ncid = close(ncid);                                      % Close the file.

% --------------------------------- DONE --------------------------------- %
