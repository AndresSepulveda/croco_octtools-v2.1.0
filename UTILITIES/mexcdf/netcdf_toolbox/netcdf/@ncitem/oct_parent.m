function theResult = oct_parent(self)

% ncitem/oct_parent -- Parent of a NetCDF item.
%  oct_parent(self) returns the oct_parent-object
%   of self, an "ncitem" object.  Non-global
%   attributes return an "oct_ncvar"; all others
%   return a "oct_netcdf".  The oct_parent of a "oct_netcdf"
%   is itself.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 25-Apr-1997 09:17:30.

if nargin < 1, help(mfilename), return, end

if nargout > 0
    theResult = [];
end

theNCid = ncid(self);
if theNCid < 0, return, end

theNetCDF_id = netcdf.open(theNCid, 'NC_NOWRITE');

switch ncclass(self)
case 'ncatt'
   if varid(self) >= 0
      theParent = oct_ncvar(ncitem('', ncid(self), -1, varid(self)));
   else
      theParent = ncregister(theNetCDF_id);
   end
otherwise
   theParent = ncregister(theNetCDF_id);
end

if nargout > 0
   theResult = theParent;
else
   theParent
end
