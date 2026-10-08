function self = oct_ncvar(theVarname, theVartype, theDimnames_id, theNetcdf_id)

% oct_ncvar/oct_ncvar -- Constructor for oct_ncvar class.
%  oct_ncvar('theVarname', 'theVartype', {theDimnames}, theNetcdf) allocates
%   an oct_ncvar object with 'theVarname', 'theVartype', and {theDimnames},
%   in theNetcdf, a oct_netcdf object.  The re-direction syntax is
%   theNetcdf < oct_ncvar('theVarname', 'theVartype', {theDimnames}).
%   The result is assigned silently to "ans" if no output argument
%   is given.
%  oct_ncvar('theVarname', theNetcdf) returns an oct_ncvar object that
%   represents the existing variable named 'theVarName' in theNetcdf.
%  oct_ncvar('', 'theVartype', {theDimnames}) returns an oct_ncvar object for:
%   theNetcdf{'theVarname'} = oct_ncvar('theVartype', {theDimnames}).
%  oct_ncvar (no argument) returns a generic "oct_ncvar" object, suitable
%   for use as a composite variable.
%  oct_ncvar (no argument) returns a raw "oct_ncvar" object.
 
% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:55:19.

if nargin < 1 & nargout < 1
    help(mfilename)
    return
end

if nargout > 0, self = []; end

% Basic structure.

theStruct.itsVartype = '';
theStruct.itsDimnames = {''};
theStruct.itsOrientation = [];
theStruct.itsSubset = [];
theStruct.itsOffset = [];
theStruct.itsOrigin = [];
theStruct.itsVars = {};
theStruct.itsSrcsubs = {};
theStruct.itsDstsubs = {};
theStruct.itsSlice = [];

% Raw "oct_ncvar" object.

if nargin < 1 & nargout > 0
   self = class(theStruct, 'oct_ncvar', ncitem);
   return
end
    
if nargin == 1 & isa(theVarname, 'ncitem')
   theNCItem = theVarname;
   if varid(theNCItem) >= 0
      result = oct_ncvar(name(theNCItem), oct_netcdf(ncid(theNCItem)));
     else
      result = [];
   end
   if nargout > 0
       self = result;
   else
       ncans(result)
   end
   return
end

if nargin == 2
   theNetcdf_id = theVartype;
   theNCid = ncid(theNetcdf_id);
   switch class(theVarname)
   case 'char'
      [theVarid, status] = ncmex('varid', theNCid, theVarname);
   case 'double'
      theVarindex = theVarname;
      theVarid = theVarindex-1;
      [theVarname, theVartype, theVarndims, theVardimids, theVarnatts, status] = ...
            ncmex('varinq', theNCid, theVarid);
   otherwise
      status = -1;
      warning(' ## Illegal syntax')
   end
   if status >= 0
      theStruct.itsVartype = theVartype;
      result = class(theStruct, 'oct_ncvar', ...
            ncitem(theVarname, theNCid, -1, theVarid));
    else
      result = [];
   end
   if nargout > 0
       self = result;
   else
       ncans(result)
   end
   return
end

theNCid = -1;
if nargin > 3, theNCid = ncid(theNetcdf_id); end

if strcmp(theVartype, 'int'), theVartype = 'long'; end

if isa(theDimnames_id, 'cell')
   if length(theDimnames_id) == 1
      theDimnames_id = theDimnames_id{1};
   end
end
if isstr(theDimnames_id), theDimnames_id = {theDimnames_id}; end

theDimids = zeros(1, length(theDimnames_id)) - 1;
for i = 1:length(theDimnames_id)
   theDimids(i) = ncmex('dimid', theNCid, theDimnames_id{i});
end

status = 0;
theVarid = -1;
if theNCid ~= -1
   [theVarid, status] = ncmex('varid', theNCid, theVarname);
   if status < 0
      namelen = max(length(theVarname), fatnames(theNetcdf_id));
      theTempname = setstr(zeros(1, namelen) + abs('-'));
      [theVarid, status] = ncmex('vardef', theNCid, theTempname, ...
            theVartype, -1, theDimids);
      if status < 0
         status = ncmex('redef', theNCid);
         if status >= 0
            [theVarid, status] = ncmex('vardef', theNCid, theTempname, ...
                  theVartype, -1, theDimids);
         end
      end
      if status >= 0 & ~strcmp(theVarname, theTempname)
         isFatNames = any(fatnames(theNetcdf_id));
         if isFatNames, theNetcdf_id = endef(theNetcdf_id); end
         status = ncmex('varrename', theNCid, theVarid, theVarname);
         if isFatNames, theNetcdf_id = redef(theNetcdf_id); end
      end
   end
end

if status >= 0
   theStruct.itsVartype = theVartype;
   theStruct.itsDimnames = theDimnames_id;
   theStruct.itsSlice = zeros(1, length(theDimnames_id));
   result = class(theStruct, 'oct_ncvar', ...
      ncitem(theVarname, theNCid, -1, theVarid));
  else
   result = [];
end

if nargout > 0
   self = result;
else
   ncans(result)
end
