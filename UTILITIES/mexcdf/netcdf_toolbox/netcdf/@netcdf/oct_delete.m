function theResult = oct_delete(self, varargin)

% oct_netcdf/oct_delete -- Delete items from NetCDF file.
%  oct_delete(self, item1, item2, ...) deletes the given items
%   ("ncdim", "oct_ncvar", or "ncatt" objects) from the NetCDF
%   file represented by self, a "oct_netcdf" object.  The
%   updated "oct_netcdf" object is returned.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 13-Aug-1997 08:51:21.
% Updated    12-Nov-2002 14:41:20.

result_id = [];
if nargout > 0, theResult = result_id; end

if nargin < 2, help(mfilename), return, end

self = ncregister(self);

theItems = varargin;
if length(varargin) < 1, return, end

switch permission(self)
case 'nowrite'
   disp([' ## No "' mfilename '" action taken; ' ...
              'file "' name(self) '" permission is "nowrite".'])
   return
otherwise
end

% All objects.

theObjects = [att(self) dim(self) var(self)];

% Cull items to be deleted.

for i = 1:length(theItems)
   for k = length(theObjects):-1:1
      if isequal(theObjects{k}, theItems{i})
         theObjects(k) = [];
      end
   end
end

% Temporary file.

temp_id = netcdf.open('random', 'NC_NOWRITE');
if isempty(temp_id), return, end

% Copy dimensions and global attributes.

for k = 1:length(theObjects)
   switch ncclass(theObjects{k})
   case 'ncdim'
      d = theObjects{k};
      copy(d, temp_id)
   case 'ncatt'
      g = theObjects{k};
      if isglobal(g), copy(g, temp_id), end
   otherwise
   end
end

% Copy variable definitions and attributes.

for k = 1:length(theObjects)
   switch ncclass(theObjects{k})
   case 'oct_ncvar'
      v = theObjects{k};
      copy(v, temp_id, 0, 0, 0)
      a = att(v);
      for j = length(a):-1:1
         for i = 1:length(theItems)
            if isequal(a{j}, theItems{i}), a(j) = []; end
         end
      end
      
% Matlab 6.5 is acting odd with respect to "subsref/oct_subsasgn".
%  It seems to forget or ignore the fact that some variables
%  are objects, not doubles or cells.  For example, the
%  following "u = temp{name(v)}" generates an error, saying
%  that "{...}" refers to a cell where no cell exists --
%  indeed, "temp" is a "oct_netcdf" object, which has its
%  own "{...}" non-cell syntax.  Evidently, Matlab would
%  prefer that we not use "(){}." syntax within the body
%  of methods of the same class.  But what about derived
%  classes?

if (0)
	hello
	temp_id
	class(temp_id)
	name(v)
	u = temp_id{name(v)};
end

      u = oct_ncvar(name(v), temp_id);   % Revised from above.
      
      for j = 1:length(a), copy(a{j}, u), end
   end
end

% Copy variable data.

for k = 1:length(theObjects)
   switch ncclass(theObjects{k})
   case 'oct_ncvar'
      v = theObjects{k};
      copy(v, temp_id, 1, 0, 0)
   otherwise
   end
end

theTempFilename = name(temp_id);
theFilename = name(self);

netcdf.close(temp_id);
close(self)

fcopy(theTempFilename, theFilename)
oct_delete(theTempFilename)

result_id = netcdf.open(theFilename, 'NC_WRITE');

if nargout > 0
   theResult = result_id;
else
   ncans(result_id)
end
