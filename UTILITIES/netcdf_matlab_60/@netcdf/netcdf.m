function self_id = oct_netcdf(theFilename, thePermission)

% oct_netcdf/oct_netcdf -- Constructor for oct_netcdf class.
%
%  oct_netcdf (no arguments) shows extensive "help".
%  oct_netcdf('version') shows the present version number.
%
%  oct_netcdf('theFilename', 'thePermission') creates and/or
%   opens 'theFilename' if 'thePermission' is one of
%   {'clobber', 'noclobber', 'write', 'nowrite'} or a
%   unique abbreviation thereof.  The "oct_netcdf" object
%   is assigned silently to "ans" if no output argument
%   is provided.
%
%  oct_netcdf('thePermission') invokes Matlab's "uiputfile"
%   or "uigetfile" dialog for selecting the file to create
%   or open, respectively, depending on 'thePermission'
%   (default = 'nowrite' if possible, then 'noclobber').
%
%  oct_netcdf('random') creates a NetCDF file with a unique,
%   random name, suitable for use as a temporary file.
%
%  self = oct_netcdf (no argument) calls "oct_netcdf('nowrite')",
%   which invokes matlab's "uigetfile" dialog.  The returned
%   "self" is the "oct_netcdf" object that was opened.
%
%  oct_netcdf(theNCid) returns a "oct_netcdf" object corresponding
%   to theNCid of an open NetCDF file.  This function does
%   not re-open the file.  TheNCid is the formal identification
%   number that would be returned ordinarily by a call to the
%   NetCDF "nccreate" or "ncopen" function.
%
%  Other permissions: The word 'readonly' is a synonym for 'nowrite'.
%   The word 'define' can be used to open an existing file in 'define'
%   mode, although this is not strictly necessary, since the "NetCDF
%   Toolbox" switches context automatically, as needed.
%
% <<<<<<<<<< Language Synopsis of the NetCDF Toolbox >>>>>>>>>>
%
%   [...] denotes default value.
%
%   Create or open a NetCDF file:
%      f = oct_netcdf('myNetCDF.nc', 'clobber | noclobber')
%      f = oct_netcdf('myNetCDF.nc', 'write | [nowrite]')
%         where f is the returned "oct_netcdf" object.
%      f = oct_netcdf('clobber | noclobber') for "uiputfile" dialog.
%      f = oct_netcdf('write | [nowrite]') for "uigetfile" dialog.
%      f = oct_netcdf('random') to create a randomly named file.
%
%   Define a NetCDF global attribute:
%      f.myGlobalAttribute = [myGlobalAttributeDoubleData]
%      f.myGlobalAttribute = 'myGlobalAttributeCharData'
%      f.myGlobalAttribute = nctype(myGlobalAttributeData)
%         where nctype = [ncdouble] | ncfloat | nclong | ...
%                         ncint | ncshort | ncbyte | [ncchar]
%         (N.B. default depends on context.)
%         (See "NetCDF User's Guide" for datatype definitions.)
%         
%      f.myGlobalAttribute = [] deletes the attribute.
%      g = f.myGlobalAttribute is the object.
%      g(:) = [] deletes the attribute.
%
%   Define a NetCDF record-dimension:
%      f('myRecordDimension') = 0 defines a record-dimension.
%      f('myRecordDimension') = [] deletes the dimension.
%      r = f('myRecordDimension') is the object.
%      r(:) = [] deletes the dimension.
%      r(:) = newSize resizes the dimension.
%
%   Define a NetCDF dimension:
%      f('myDimension') = myDimensionLength
%      f('myDimension') = [] deletes the dimension.
%      d = f('myDimension') is the object.
%      d(:) = [] deletes the dimension.
%      d(:) = newSize resizes the dimension.
%      isrecdim(d) determines whether d is the record-dimension.
%      iscoord(v) determines whether d is a coordinate-dimension.
%
%   Define a NetCDF variable:
%      f{'myVariable'} = nctype(myRecordDimension, myDimension, ...)
%      f{'myVariable'} = nctype(myDimension, ...)
%      f{'myVariable'} = nctype(r, d, ...)
%      f{'myVariable'} = nctype(d, ...)
%      f('myVariable') = [] deletes the variable.
%      v = f{'myVariable'} returns the object.
%      v = f{'myVariable', 1} returns the object -- auto-scaling enabled.
%      v(:) = [] deletes the variable.
%      iscoord(v) determines whether v is a coordinate-variable.
%      isscalar(v) determines whether v is a scalar-variable.
%
%   Define a NetCDF attribute:
%      f{'myVariable'}.myAttribute = [myAttributeDoubleData]
%      f{'myVariable'}.myAttribute = 'myAttributeCharData'
%      f{'myVariable'}.myAttribute = nctype(myAttributeData)
%      f{'myVariable'}.myAttribute = [] deletes the attribute.
%      v.myAttribute = [myAttributeDoubleData]
%      v.myAttribute = 'myAttributeCharData'
%      v.myAttribute = nctype(myAttributeData)
%      v.myAttribute = [] deletes the attribute.
%      a = f{'myVariable'}.myAttribute is the object.
%      a = v.myAttribute is the object.
%      a(:) = [] deletes the attribute.
%
%   Store and retrieve NetCDF variable data:
%      f{'myVariable'}(i, j, ...) = myVariableData
%      f{'myVariable', 1}(i, j, ...) = myVariableData -- auto-scaling enabled.
%      v(i, j, ...) = myVariableData
%      myVariableData = f{'myVariable'}(i, j, ...)
%      myVariableData = f{'myVariable', 1}(i, j, ...) -- auto-scaling enabled.
%      myVariableData = v(i, j, ...)
%
%   Store and retrieve NetCDF attribute data: (always a row vector)
%      f.myGlobalAttribute(i) = myGlobalAttributeData
%      g(i) = myGlobalAttributeData
%      f{'myVariable'}.myAttribute(i) = myAttributeData
%      v.myAttribute(i) = myAttributeData
%      a(i) = myAttributeData
%      myGlobalAttributeData = f.myGlobalAttribute(i)
%      myGlobalAttributeData = g(i)
%      myAttributeData = f{'myVariable'}.myAttribute(i)
%      myAttributeData = v.myAttribute(i)
%      myAttributeData = a(i)
%      EXCEPTION: v.FillValue_ references the "_FillValue" attribute.
%                 Use the "fillval(v, ...)" method to avoid confusion.
%
%   Store and retrieve NetCDF record data:
%      s = f(0) returns the object.
%      t = s(0) returns the record template as a struct.
%      u = r(i) returns the i-th record data as a struct.
%      x = r(i).field(...) returns a subset of a field (variable).
%      s(i) = t sets the i-th record to the struct data.
%
%   Indexing defaults for NetCDF variables and attributes:
%      ":" means 'all', including unstated indices to the right.
%         Otherwise, unstated indices to the right default to 1.
%         Note: ":" does NOT impose columnization on the result.
%
%   Last index:
%      The keyword "end" can serve as the last index for any
%         dimensional direction, as in "v(1:2:end, ...)".
%
%   Duplication of NetCDF objects via "<" operator:
%         (Also see use of "copy" below.)
%      f < myObject copies the complete myObject into NetCDF
%         file f, where myObject represents a dimension,
%         variable, attribute, or another NetCDF file.
%      f < myRecord copies the data of myRecord object into f.
%      v < myVariable copies the data and attributes of myVariable into v.
%      v < myAttribute copies myAttribute into variable v.
%      v < myArray copies myArray into the data of v.
%      a < myAttribute copies the contents of myAttribute into attribute a.
%      a < myArray copies myArray into attribute a.
%
%   Duplication of NetCDF objects via "copy":
%      copy(f, myNetCDF) copies oct_netcdf f into myNetCDF.
%      copy(d, f) copies dimension d into oct_netcdf f.
%      copy(a, f) copies attribute a into oct_netcdf f.
%      copy(a, v) copies attribute a into variable v.
%      copy(v, f, copyData, copyAttributes) copies variable v into
%         oct_netcdf f, as directed by the flags (defaults = 0).
%      copy(v, myVariable, copyData, copyAttributes) copies the
%         contents of variable v into variable myVariable, as
%         directed by the flags (defaults = 0).
%
%   Deletion of objects.
%      oct_delete(myObject1, myObject2, ...) deletes the objects.
%
%   Lists of objects:
%      dim(f) returns the dimension objects of f in a cell-array.
%      var(f) returns the variable objects of f in a cell-array.
%      att(f) returns the global attribute objects of f in a cell-array.
%      dim(v) returns the dimension objects of v in a cell-array.
%      att(v) returns the attribute objects of v in a cell-array.
%      coord(f) returns the coordinate-variable objects of f.
%      recdim(f) returns the record-dimension object of f.
%      recdim(v) returns the record-dimension object of v.
%      recvar(f) returns the record-variable objects of f in a cell-array.
%
%   Basic properties of NetCDF objects:
%      name(x) returns the name of object x.
%      name(x, 'newname') renames object x to 'newname'.
%      ncnames({list_of_objects}) returns the names of the objects.
%      size(x) returns the Matlab-like size of object x.
%      size(x, k) returns the k-th element of the size of object x.
%      ncsize(x) returns the NetCDF-like size of object x.
%      ncsize(x, k) returns the k-th element of the ncsize of object x.
%      length(x) returns the Matlab-like length of object x.
%      datatype(x) returns the datatype of object x.
%      class(x) returns the class of x.
%      ncclass(x) returns the oct_netcdf oct_parent class of derived x.
%      oct_parent(x) returns the oct_parent (oct_netcdf or oct_ncvar) of object x.
%      permission(x) returns the oct_parent file's create/open permission.
%      mode(x) returns the oct_parent file's current "define" mode.
%      fillval(v, ...) manipulates the "_FillValue" attribute.
%      setfill(f, ...) manipulates the "fill-mode" of f.
%      orient(v, ...) manipulates the get/put orientation of v.
%      oct_resize(d, newsize) resizes dimension d to the newsize.
%      oct_resize(v, [newsize]) resizes variable v to the [newsize].
%
%   Unsigned interpretation of integer data:
%      unsigned(v) returns the "unsigned" flag of variable v.
%      unsigned(v, isUnsigned) sets the "unsigned" flag of variable v.
%      unsigned(a) returns the "unsigned" flag of attribute a.
%      unsigned(a, isUnsigned) sets the "unsigned" flag of attribute v.
%
%   Automatic scaling of variable data:
%      autoscale(v, isAutoScaling) sets the "autostate" state of variable v.
%      autoscale(v) returns the current "autoscale" state of variable v.
%
%   Automatic substitution of fill-value by NaN:
%      autonan(v, isAutoNaNing) sets the "autonan" state of variable v.
%      autonan(v) returns the current "autonan" state of variable v.
%
%   Quick-mode for variable input/output:
%      quick(v, isQuick) sets the variable v to "quick" mode.
%      quick(v) returns the current "quick" state of variable v.
%
%   Arithmetic operators with NetCDF objects (right-side only):
%      y = d op x returns d(:) op x for operator op, such as "-".
%      y = v op x returns v(:) op x for operator op, such as "-".
%      y = a op x returns a(:) op x for operator op, such as "-".
%      y = op d returns op d(:) for unary operator op, such as '-'.
%      y = op v returns op v(:) for unary operator op, such as '-'.
%      y = op a returns op a(:) for unary operator op, such as '-'.
%
%   NetCDF Conventions:
%      v.FillValue_ references the "_FillValue" attribute.
%         (Matlab cannot parse a beginning under-score.)
%
%   Save/Load NetCDF Variables (no attributes transfered):
%      oct_ncsave('myNetCDF.nc', ...) updates variables in 'myNetCDF.nc'.
%      oct_ncload('myNetCDF.nc', ...) loads variables from 'myNetCDF.nc'.
%
%   Composite-Variables: (Not for the faint-of-heart!)
%      v = var(v1, s1, d1, v2, s2, d2, ...) returns a composite-
%         variable using NetCDF variables v1, ..., whose s1, ...
%         source-indices map to the d1, ... destination-indices
%         in the composite output array.  See "help oct_ncvar/var".
%
%   Miscellaneous:
%      isepic(v) determines whether v is an EPIC variable.
%      fatnames(f) invokes the "fatnames" facility.
%      ncweb() links to the WWW home-page of the NetCDF Toolbox.
%
%   Example M-Files:
%      oct_ncexample() creates, populates, and reads a NetCDF file.
%      oct_tnetcdf() exercizes the NetCDF Toolbox extensively.
%
%   WWW: <http://crusty.er.usgs.gov/~cdenham/MexCDF/nc4ml5.html>.
%
% <<<<<<<<<<<<<<<<< End of NetCDF Language Synopsis >>>>>>>>>>>>>>>>>
 
% Copyright (C) 1996-7 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

% Updated    18-Aug-1997 09:39:52.
% Updated    20-May-1999 09:33:04.
% Updated    24-Aug-1999 09:12:11.
% Updated    10-Apr-2000 21:07:48.

ncwhatsnew

if nargin == 1 & nargout < 1 & isequal(theFilename, 'version')
	version(ncitem)
	return
end

if nargin < 1 & nargout < 1
   help(mfilename)
   ncversion
   disp(' ')
   return
end

if nargout > 0, self_id = []; end

% Open with dialog as 'nowrite'.

if nargout > 0 & nargin < 1
   result_id = netcdf.open('nowrite', 'NC_NOWRITE');
   if ~isempty(result_id)
      ncregister(result_id)
      result_id = ncregister(result_id);
   end
   self_id = result_id;
   return
end

if nargin < 2, thePermission = ''; end

result_id = [];

% Randomly named file.

if nargin == 1 & strcmp(theFilename, 'random')
   result_id = [];
   count = 0;
   while isempty(result_id) & count < 32
		thePWD = pwd;
		if thePWD(length(thePWD)) ~= filesep
			thePWD = [thePWD filesep];
		end
      theFilename = [thePWD 'temp' int2str(rand(1, 1) .* 10000) '.nc'];
      result_id = netcdf.create(theFilename, 'NC_NOCLOBBER');
   end
   if ~isempty(result_id)
      ncregister(result_id)
      result_id = ncregister(result_id);
   end
   if nargout > 0
      self_id = result_id;
   else
      ncans(result_id)
   end
   return
end

if nargin == 1
   switch class(theFilename)
   case 'double'
      theNCid = theFilename;
      theStruct.itsPermission = 'unknown';
      theStruct.itsDefineMode = 'unknown';
      theStruct.itsFillMode = 'unknown';
      theStruct.itsMaxNameLen = 0;
      result_id = class(theStruct, 'oct_netcdf', ncitem('', theNCid));
      result_id = ncregister(result_id);
      if nargout > 0
         self_id = result_id;
      else
         ncans(result_id)
      end
      return
   case 'char'
      thePermission = '';
      thePerm = ncpermission(theFilename);
      switch thePerm
      case {'nowrite', 'write', 'noclobber', 'clobber', ...
            'readonly', 'define'}
         thePermission = thePerm;
         theFilename = '*';
      otherwise
         thePermission = 'nowrite';
      end
   otherwise
      return
   end
end

if isempty(thePermission), thePermission = 'nowrite'; end

if any(theFilename == '*')
   switch thePermission
   case {'noclobber', 'clobber'}
		theSuggested = theFilename;
		if isequal(theFilename, '*')
			theSuggested = 'unnamed.nc';
		else
			theSuggested(theSuggested == '*') = '';
		end
      [theFile, thePath] = uiputfile(theSuggested, 'Save NetCDF As');
      if ~any(theFile), return, end
   case {'nowrite', 'write', 'readonly', 'define'}
      [theFile, thePath] = uigetfile(theFilename, 'Select NetCDF File');
      if ~any(theFile), return, end
   otherwise
      return
   end
   theFilename = [thePath theFile];
   result_id = netcdf.create(theFilename, upper(thePermission))  % [conv] modo variable;
   if ~isempty(result_id)
      ncregister(result_id)
      result_id = ncregister(result_id);
   end
   if nargout > 0
      self_id = result_id;
   else
      ncans(result_id)
   end
   return
end

thePermission = ncpermission(thePermission);

switch thePermission
case 'define'
   result_id = netcdf.open(theFilename, 'NC_WRITE');
   if ~isempty(result_id), redef(result_id), end
   if nargout > 0
      self_id = result_id;
   else
      ncans(result_id)
   end
   return
otherwise
end

theDefineMode = '';
theFillMode = 'fill';   % The NetCDF default.
theMaxNameLen = 0;

theStruct.itsPermission = thePermission;
theStruct.itsDefineMode = theDefineMode;
theStruct.itsFillMode = theFillMode;
theStruct.itsMaxNameLen = theMaxNameLen;

result_id = class(theStruct, 'oct_netcdf', ncitem(theFilename));

switch thePermission
case {'clobber', 'noclobber'}
   result_id = create(result_id, thePermission);
   if ncid(result_id) >= 0, theDefineMode = 'define'; end
case {'write', 'nowrite'}
   result_id = open(result_id, thePermission);
   if ncid(result_id) >= 0
      theDefineMode = 'data';
     elseif exist(name(result_id)) ~= 2
      result_id = open(result_id, 'clobber');
      if ncid(result_id) >= 0, theDefineMode = 'define'; end
   end
otherwise
   help oct_netcdf
   warning([' ## No such permission: ' thePermission])
end

if ncid(result_id) >= 0
   netcdf.putAtt(result_id, netcdf.getConstant('NC_GLOBAL'), 'itsDefineMode', theDefineMode);
   ncregister(result_id)
   result_id = ncregister(result_id);
  else
   disp([' ## NetCDF file not opened: ' theFilename])
   result_id = [];
end

if nargout > 0
   self_id = result_id;
else
   ncans(result_id)
end

function theResult = ncpermission(thePermission)

% oct_netcdf/ncpermission -- Resolve permission string.
%  oct_netcdf/ncpermission('thePermission') returns the NetCDF permission
%   string corresponding to 'thePermission', which may be uniquely
%   abbreviated.

thePerm = lower(thePermission);

% Lists of shortened permissions: must pre-allocate.

clobber = [];
noclobber = [];
write = [];
nowrite = [];
readonly = [];
define = [];

perms = {'clobber', 'noclobber', 'write', 'nowrite', 'readonly', 'define'};
for j = 1:length(perms)
   p = perms{j};
   c = cell(1, length(p));
   for i = 1:length(perms{j})
      c{i} = p;
      p(length(p)) = '';
   end
   eval([perms{j} ' = c;']);
end

% Formal name of thePermission.

switch thePerm
case clobber
   thePermission = 'clobber';
case noclobber
   thePermission = 'noclobber';
case write
   thePermission = 'write';
case [nowrite readonly]
   thePermission = 'nowrite';
case [define]
   thePermission = 'define';
otherwise
end

if nargout > 0, theResult = thePermission; end
