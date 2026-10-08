function theResult = oct_ncmkmask(inFile, outFile, fillValue)

% oct_ncmkmask -- Make a NetCDF "mask" file.
%  oct_ncmkmask('inFile', 'outFile', fillValue) creates a "mask"
%   file named 'outFile', based on the 'inFile'.  The output
%   variables have the names and dimensions of the input
%   variables, but they contain byte-data, filled with the
%   given fillValue (default = 0).  Attributes are ignored.
%   If a file is entered as an open "oct_netcdf" object, it
%   will remain open at the end of this routine.  Use '*'
%   to open a file via dialog.
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 06-Jan-1999 17:59:45.

VERBOSE = 1;

if nargout > 0, theResult = []; end

if nargin < 1, help(mfilename); end
if nargin < 1, inFile = '*'; end
if nargin < 2, outFile = '*'; end

if nargin < 3, fillValue = 0; end
if ischar(fillValue), fillValue = eval(fillValue); end

% Input file.

if isa(inFile, 'oct_netcdf')
	f_id = inFile;
else
	f_id = netcdf.open(inFile, 'NC_NOWRITE');
end

if isempty(f_id), return, end

% Output file.

if isa(outFile, 'oct_netcdf')
	g_id = outFile;
elseif any(outFile == '*')
	[p, outFile, e, v] = fileparts(name(f_id));
	outFile = ['*' outFile '.msk'];
	g_id = netcdf.create(outFile, 'NC_CLOBBER');
else
	g_id = netcdf.create(outFile, 'NC_NOCLOBBER');
end

if isempty(g_id) & ~isa(inFile, 'oct_netcdf')
	netcdf.close(f_id);
	return
end

% Creation information.

netcdf.putAtt(g_id, netcdf.getConstant('NC_GLOBAL'), 'CreatedBy', mfilename);
netcdf.putAtt(g_id, netcdf.getConstant('NC_GLOBAL'), 'CreatedOn', datestr(now));
netcdf.putAtt(g_id, netcdf.getConstant('NC_GLOBAL'), 'BasedOnFile', name(f));

% Transfer the dimensions.

if VERBOSE
	disp([' ## Data File: ' name(f_id)])
	disp([' ## Mask File: ' name(g_id)])
	disp(' ## Defining dimensions ...')
end

d = dim(f_id);
for i = 1:length(d)
	if isrecdim(d{i})
		theLength = 0;   % Record-dimension.
	else
		theLength = length(d{i});
	end
	if VERBOSE, disp([' ##    ' name(d{i}) ' ...']), end
	g_id(name(d{i})) = theLength;
end

% Re-create the variables as "byte" data.

if VERBOSE, disp(' ## Defining variables ...'), end
v = var(f_id);
for i = 1:length(v)
	if VERBOSE, disp([' ##    ' name(v{i}) ' ...']), end
	d = ncnames(dim(v{i}));   % Dim. names.
	g_id{name(v{i})} = ncbyte(d{:});   % New variable.
	g_id{name(v{i})}.FillValue_ = fillValue;   % Fill it.
end

g_id = endef(g_id);

% Expand record-variables, if any.

r = recdim(g_id);
if ~isempty(r)
	if VERBOSE, disp(' ## Filling record-variables ...'), end
	v = var(r);
	for i = 1:length(v)
		if VERBOSE, disp([' ##    ' name(v{i}) ' ...']), end
		sz = length((netcdf.inqVar(f_id, netcdf.inqVarID(f_id, name(v{i)))  % [conv] ncsize→inqVar ndims)});
		for i = 1:length(sz)
			indices{i} = sz(i);
		end
		v{i}(indices{:}) = fillValue;
	end
end

% Done.

if VERBOSE, disp(' ## Done.'), end
if ~isa(outFile, 'oct_netcdf'), close(g_id), end
if ~isa(inFile, 'oct_netcdf'), close(f_id), end
