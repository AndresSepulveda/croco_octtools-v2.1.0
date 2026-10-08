function test_attinq ( ncfile )

if nargin < 1
    ncfile = 'foo.nc';
end

create_test_file(ncfile);
test_double_precision(ncfile);
test_bad_ncid(ncfile);
test_bad_varid(ncfile);
test_att_does_not_exist(ncfile);
test_non_char_att_name(ncfile);

fprintf ( 1, 'ATTINQ succeeded.\n' );

%--------------------------------------------------------------------------
function create_test_file(ncfile);
[ncid, status] = oct_mexnc ( 'create', ncfile, nc_clobber_mode );
if status, error(oct_mexnc( 'strerror', status)), end


%
% DIMDEF
[xdimid, status] = oct_mexnc ( 'def_dim', ncid, 'x', 20 );
if status, error(oct_mexnc( 'strerror', status)), end

[varid, status] = oct_mexnc ( 'def_var', ncid, 'x', nc_double, 1, xdimid );
if status, error(oct_mexnc( 'strerror', status)), end

input_data = 3.14159;
status = oct_mexnc ( 'ATTPUT', ncid, varid, 'test_double', nc_double, 1, input_data );
if status, error(oct_mexnc( 'strerror', status)), end

[status] = oct_mexnc ( 'enddef', ncid );
if status, error(oct_mexnc( 'strerror', status)), end

status = oct_mexnc ( 'sync', ncid );
if status, error(oct_mexnc( 'strerror', status)), end

status = oct_mexnc ( 'close', ncid );
if status, error(oct_mexnc( 'strerror', status)), end


%--------------------------------------------------------------------------
function test_double_precision(ncfile)
% Test 1:  inquire about double precision attribute of a variable

[ncid, status] = oct_mexnc ( 'open', ncfile, nc_nowrite_mode );
if status, error( oct_mexnc ( 'strerror', status ) ), end

[varid,status] = oct_mexnc('inq_varid',ncid,'x');
if status, error( oct_mexnc ( 'strerror', status ) ), end

[datatype, len, status] = oct_mexnc('ATTINQ', ncid, varid, 'test_double');
if status < 0, error(oct_mexnc( 'strerror', status)), end

if ( datatype ~= 6 )
	error ( 'returned datatype was not NC_DOUBLE, ATTINQ failed' );
end
if ( len ~= 1 )
	error('returned length was not 1, ATTINQ failed');
end

status = oct_mexnc ( 'close', ncid );
if status, error(oct_mexnc( 'strerror', status)), end


%--------------------------------------------------------------------------
function test_bad_ncid(ncfile);

[ncid, status] = oct_mexnc ( 'open', ncfile, nc_nowrite_mode );
if status, error( oct_mexnc ( 'strerror', status ) ), end

[varid,status] = oct_mexnc('inq_varid',ncid,'x');
if status, error( oct_mexnc ( 'strerror', status ) ), end

%
% Test 2:  try to inquire from a bad ncid
[datatype, len, status] = oct_mexnc('ATTINQ', -1, varid, 'test_double');
if ( status >= 0 )
	error('ATTINQ succeeded on bad ncid');
end

status = oct_mexnc ( 'close', ncid );
if status, error(oct_mexnc( 'strerror', status)), end


%--------------------------------------------------------------------------
function test_bad_varid(ncfile);
% Test 3:  try to inquire from a bad varid

[ncid, status] = oct_mexnc ( 'open', ncfile, nc_nowrite_mode );
if status, error( oct_mexnc ( 'strerror', status ) ), end

[varid,status] = oct_mexnc('inq_varid',ncid,'x');
if status, error( oct_mexnc ( 'strerror', status ) ), end

[datatype, len, status] = oct_mexnc('ATTINQ', ncid, -5, 'test_double');
if ( status >= 0 )
	error('ATTINQ succeeded on bad varid');
end

status = oct_mexnc ( 'close', ncid );
if status, error(oct_mexnc( 'strerror', status)), end



%--------------------------------------------------------------------------
function test_att_does_not_exist(ncfile);
% Test 4:  try to inquire from a non existant attribute

[ncid, status] = oct_mexnc ( 'open', ncfile, nc_nowrite_mode );
if status, error( oct_mexnc ( 'strerror', status ) ), end

[varid,status] = oct_mexnc('inq_varid',ncid,'x');
if status, error( oct_mexnc ( 'strerror', status ) ), end

[datatype, len, status] = oct_mexnc('ATTINQ', ncid, varid, 'bad');
if ( status >= 0 )
	error ( 'ATTINQ succeeded on bad attribute name');
end

status = oct_mexnc ( 'close', ncid );
if status, error(oct_mexnc( 'strerror', status)), end



%--------------------------------------------------------------------------
function test_non_char_att_name(ncfile);
% Test 6:  try to inquire using a non character attribute name

[ncid, status] = oct_mexnc ( 'open', ncfile, nc_nowrite_mode );
if status, error( oct_mexnc ( 'strerror', status ) ), end

[varid,status] = oct_mexnc('inq_varid',ncid,'x');
if status, error( oct_mexnc ( 'strerror', status ) ), end

try
	[datatype, len, status] = oct_mexnc('ATTINQ', ncid, varid, int32(5));
	error ( '%s:  %s:  succeeded when it should have failed\n', mfilename, testid);
catch
	;
end



status = oct_mexnc ( 'close', ncid );
if status, error(oct_mexnc( 'strerror', status)), end

