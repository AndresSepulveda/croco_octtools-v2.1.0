function oct_ncdimadd(theSrcFile, theDstFile, theDimName_id, theDimLength_id)

% oct_ncdimadd -- Add a dimension to a NetCDF file.
%  oct_ncdimadd(theSrcFile, theDstFile, 'theDimName', theDimLength)
%   copies the components of theSrcFile to theDstFile (either
%   filenames or "oct_netcdf" objects), and adds the given dimension.
%   If originally open, the files remain open.  NOTE: theDstFile
%   must be new or never have been closed or placed in "data" mode
%   previously.  If to be created, "clobber" permission is used.
%   To add more than one dimension, use cell-arrays for the names
%   and lengths.
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 06-Oct-1999 10:48:23.
% Updated    06-Oct-1999 11:41:43.

if nargin < 4, help(mfilename), return, end

if ischar(theDimLength_id)
	theDimLength_id = eval(theDimLength_id);
end

% Open source file.

if isa('oct_netcdf', theSrcFile)
	f_id = theSrcFile;
else
	f_id = netcdf.open(theSrcFile, 'NC_NOWRITE');
end

% Open destination file.

if isempty(f_id), return, end

if isa('oct_netcdf', theDstFile)
	g_id = theDstFile;
else
	g_id = netcdf.create(theDstFile, 'NC_CLOBBER');
end

if isempty(g_id), close(f_id), return, end

% Check destination for "data" mode.

theMode = mode(g_id);
switch theMode
case 'data'
	disp(' ## Output file requires "define" mode initially.')
	close(g_id), close(f_id), return
end

% Copy.

disp([' ## Source file:      ' name(f_id)])
disp([' ## Destination file: ' name(f_id)])

g_id < att(f_id);   % Copy existing global attributes.
g_id < dim(f_id);   % Copy existing dimensions.

if ~iscell(theDimName_id)
	theDimName_id = {theDimName_id};
end

if ~iscell(theDimLength_id)
	theDimLength_id = {theDimLength_id};
end

% Too few dimension lengths provided; adjust.

while length(theDimLength_id) < length(theDimName_id)
	theDimLength_id{end+1} = theDimLength_id{end};
end

% Add new dimensions.

nDims = length(theDimName_id);

for i = 1:nDims
	disp([' ## ' int2str(nDims-i+1) ' Defining dimension: ' theDimName_id{i}])
	g_id(theDimName_id{i}) = theDimLength_id{i};
end

% Define existing variables and attributes.

v = var(f_id);
nVars = length(v);

for i = 1:nVars
	disp([' ## ' int2str(nVars-i+1) ' Defining variable: ' name(v{i})])
	copy(v{i}, g_id, 0, 1, 1);
end

% Fill existing variables.

for i = 1:nVars
	disp([' ## ' int2str(nVars-i+1) ' Filling variable: ' name(v{i})])
	copy(v{i}, g_id, 1, 0, 0);
end

% Close files.

if ischar(theDstFile)
	g_id = close(g_id);
	if ~isempty(g_id)
		disp(' ## Unable to close destination file.')
	end
end

if ischar(theSrcFile)
	f_id = close(f_id);
	if ~isempty(f_id)
		disp(' ## Unable to close source file.')
	end
end
