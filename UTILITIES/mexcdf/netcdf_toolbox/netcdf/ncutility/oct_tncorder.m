function oct_tncorder(m, n)

% oct_tncorder -- Test of NetCDF row vs. column dominance.
%  oct_tncorder(m, n) shows how a Matlab array of size [m n]
%   is actually stored in a NetCDF file.
 
% Copyright (C) 2002 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 18-Oct-2002 16:59:50.
% Updated    18-Oct-2002 16:59:50.

if nargin < 1, help(mfilename), m = 3; end
if nargin < 2, n = m; end

if ischar(m), m = eval(m); end
if ischar(n), n = eval(n); end

fclose('all');

ncfile = [mfilename '.nc'];

ncid = netcdf.create(ncfile, 'NC_CLOBBER');

did_i = netcdf.defDim(ncid, 'i', m);
did_j = netcdf.defDim(ncid, 'j', n);

vid_x = netcdf.defVar(ncid, 'x', 'NC_DOUBLE', [did_j, did_i]);

matlab_array = zeros(m, n);
matlab_array(:) = 1:prod(size(matlab_array));

netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'x'), matlab_array);

netcdf.close(ncid);

ptr = wcvarptr(ncfile, 'x');

fid = fopen(ncfile, 'r');
fseek(fid, ptr, 'bof');
in_netcdf_file = fread(fid, [1, 9], 'double');
fclose(fid);

oct_delete(ncfile)

matlab_array
in_netcdf_file

a = matlab_array;
b = in_netcdf_file;

if min(m, n) > 1
	if a(:) == b(:)
        disp(' ## Matlab array is stored by columns in NetCDF.')
	else
        disp(' ## Matlab array is stored by rows in NetCDF.')
	end
end
