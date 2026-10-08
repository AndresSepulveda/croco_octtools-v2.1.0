function theResult = var(self, theName, theType, theDims)

% oct_netcdf/var -- Variables of a oct_netcdf object.
%  var(self) returns the cell-list of oct_ncvar objects
%   associated with self, a oct_netcdf object.
%  var(self, 'theName') returns the oct_ncvar object whose
%   name is theName, associated with self, a oct_netcdf object.
%  var(self, 'theName', 'theType', {theDims}) defines a
%   new NetCDF variable in self, with theName, theType
%   (default  = 'double'), and theDims (a cell-list of
%   ncdim objects, possibly empty).  The new oct_ncvar object
%   is returned.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 09:33:06.

if nargin < 1, help(mfilename), return, end

result = [];

switch nargin
  case 1
   [ndims, nvars, ngatts, recdim, status] = ...
      ncmex('inquire', ncid(self));
   theVars = cell(1, nvars);
   for theVarindex = 1:nvars
      theVars{theVarindex} = oct_ncvar(theVarindex, self);
   end
   result = theVars;
  case 2
   result = oct_ncvar(theName, self);
  case 4
   result = oct_ncvar(theName, theType, theDims, self);
  otherwise
   warning(' ## Illegal syntax.')
end

if nargout > 0
   theResult = result;
else
   disp(result)
end
