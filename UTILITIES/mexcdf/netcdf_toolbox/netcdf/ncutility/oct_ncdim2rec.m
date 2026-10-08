function oct_ncdim2rec(theNetCDF_id, theDim)

% oct_ncdim2rec -- Convert static dimension to record dimension.
%  oct_ncdim2rec(theNetCDF, theDim) converts one of the dimensions
%   of theNetCDF, given as theDim, to a record-dimension.
%   The arguments may be strings or NetCDF entities.
%   The chosen dimension must be left-most in all the
%   variables that use it.
 
% Copyright (C) 2001 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 13-Nov-2001 09:25:59.
% Updated    03-Mar-2003 16:25:27.

if nargin < 1, help(mfilename), return, end

if ischar(theNetCDF_id)
	theFilename = theNetCDF_id;
	theNetCDF_id = netcdf.open(theFilename, 'NC_NOWRITE');
	if isempty(theNetCDF_id)
		disp([' ## Unable to open as NetCDF: "' theFilename '"'])
		return
	end
elseif ~isa(theNetCDF_id, 'oct_netcdf')
	disp([' ## Not a "oct_netcdf" object.'])
	return
end

if ischar(theDim)
	theDimname = theDim;
	theDim = theNetCDF_id(theDimname);
	if isempty(theDim)
		disp([' ## Not a NetCDF dimension: "' theDimname '"'])
		return
	end
elseif ~isa(theDim, 'ncdim')
	disp([' ## Not a NetCDF dimension.'])
end

if isrecdim(theDim)
	netcdf.close(theNetCDF_id);
	disp([' ## Already is a NetCDF record-dimension: "' theDimname '"'])
	return
end

% Open a randomly-named temporary file.

for i = 1:100
	tmpname = ['temp' int2str(rand(1, 1)*10^9) '.nc'];
	f_id = netcdf.create(tmpname, 'NC_NOCLOBBER');
	if ~isempty(f_id), break, end
end

if isempty(f_id)
	netcdf.close(theNetCDF_id);
	disp([' ## Unable to open temporary NetCDF file.'])
	return
end

% Define the record-dimension.

theDimname = name(theDim);
f_id(theDimname) = 0;

% Pour everything into the new file.

f_id < theNetCDF_id;

% Get full filenames.

theNetCDFname = name(theNetCDF_id)
theTmpname = name(f_id)

% Close both files.

netcdf.close(theNetCDF_id);
netcdf.close(f_id);

% Copy temporary file to original name.

fcopy(theTmpname, theNetCDFname)

% Delete temporary file.

oct_delete(theTmpname)
