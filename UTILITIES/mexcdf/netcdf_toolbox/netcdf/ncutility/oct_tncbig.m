function oct_tncbig(nBytes)

% oct_tncbig -- Test allowed size of file.
%  oct_tncbig(nBytes) creates a NetCDF file, then
%   an array of nBytes.  On Macintosh and PCWIN,
%   we have long had difficulty getting beyond
%   about 16K bytes, far too small for real work.
%   This has forced us to create larger files
%   on Unix machines.  Once created, such files
%   work on the smaller machines just fine.
 
% Copyright (C) 2000 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 23-Feb-2000 08:43:12.
% Updated    23-Feb-2000 09:00:51.

if nargin < 1, nBytes = 2^16; help(mfilename), end
if ischar(nBytes), nBytes = eval(nBytes); end

theFilename = [mfilename '.nc'];

n = 0;

while n < nBytes
	n = n + 1000;
	disp([' ## n: ' int2str(n)])
	ncid = netcdf.create(theFilename, 'NC_CLOBBER');
	did_index = netcdf.defDim(ncid, 'index', n);
	vid_x = netcdf.defVar(ncid, 'x', 'NC_BYTE', did_index);
	x = ncid{'x'};
	x(:) = zeros(1, n);
	status = close(ncid);
	oct_delete(theFilename)
	if ~isequal(status, [])
		disp(' ')
		disp([' ## Unable to close file on ' computer '.'])
		break
	end
end
