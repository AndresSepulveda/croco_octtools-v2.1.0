function theResult = inquire(self)

% oct_netcdf/inquire -- Deep inquiry of a netCDF file.
%  inquire(self) returns self, a oct_netcdf object, after
%   updating its fields with the results of a deep inquiry
%   into all of its dimensions, variables, and attributes.

if nargin < 1, help(mfilename), return, end

result = [];

[ndims, nvars, ngatts, theRecdim, status] = ncmex(id(self));

if status ~= 0
   warning(' ## ' mfilename ' failure.')
   return
end

% Variables.

theVars = cell(nvars, 1);
for theVarid = -1:nvars-1
   theVars{i} = oct_ncvar(id(self), theVarid);
end

self = var(self, theVars);
result = self;

if nargout > 0, theResult = result; end
