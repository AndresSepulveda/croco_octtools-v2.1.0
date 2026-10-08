function test_dimid ( ncfile )
% TEST_DIMID
%
% Test 1:  Retrieve a dimid.
% Test 2:  Bad ncid.
% Test 3:  Empty set ncid.
% Test 4:  Empty string dim name.
% Test 5:  Empty set dim name.
% Test 6:  Bad dim name.

if nargin < 1
    ncfile = 'foo.nc';
end


create_ncfile(ncfile);

test_normal_dimid(ncfile);
test_bad_ncid(ncfile);
test_empty_set_ncid(ncfile);
test_empty_string_dimname(ncfile);
test_empty_set_dimname(ncfile);
test_bad_dimname(ncfile);

fprintf('DIMID succeeded.\n');
%--------------------------------------------------------------------------
function create_ncfile(ncfile)
[ncid, status] = oct_mexnc ( 'create', ncfile, nc_clobber_mode );
if status, error(oct_mexnc('strerror',status)), end

[xdimid, status] = oct_mexnc ( 'def_dim', ncid, 'x', 20 );
if status, error(oct_mexnc('strerror',status)), end

[status] = oct_mexnc ( 'enddef', ncid );
if status, error(oct_mexnc('strerror',status)), end

status = oct_mexnc ( 'close', ncid );
if status, error(oct_mexnc('strerror',status)), end


%--------------------------------------------------------------------------
function test_normal_dimid(ncfile)
% Retrieve a dimid.

[ncid, status] = oct_mexnc('open', ncfile, nc_nowrite_mode );
if status, error(oct_mexnc('strerror',status)), end

[dimid, status] = oct_mexnc('DIMID', ncid, 'x');
if status, error(oct_mexnc('strerror',status)), end
if ( dimid ~= 0 )
	error('failed');
end

if dimid ~= 0
	error('failed');
end

status = oct_mexnc ( 'close', ncid );
if status, error(oct_mexnc('strerror',status)), end

%--------------------------------------------------------------------------
function test_bad_ncid(ncfile)

[ncid, status] = oct_mexnc('open', ncfile, nc_nowrite_mode );
if status, error(oct_mexnc('strerror',status)), end

[test_dimid, status] = oct_mexnc ( 'dimid', -2, 'x' );
if ( status >= 0 )
	error('Succeeded when it should have failed');
end

status = oct_mexnc ( 'close', ncid );
if status, error(oct_mexnc('strerror',status)), end



%--------------------------------------------------------------------------
function test_empty_set_ncid(ncfile)

[ncid, status] = oct_mexnc('open', ncfile, nc_nowrite_mode );
if status, error(oct_mexnc('strerror',status)), end

try
	[test_dimid, status] = oct_mexnc ( 'dimid', [], 'x' );
	error('failed');
end

status = oct_mexnc ( 'close', ncid );
if status, error(oct_mexnc('strerror',status)), end


%--------------------------------------------------------------------------
function test_empty_string_dimname(ncfile)

[ncid, status] = oct_mexnc('open', ncfile, nc_nowrite_mode );
if status, error(oct_mexnc('strerror',status)), end

testid = 'Test 4';
try
	[test_dimid, status] = oct_mexnc ( 'dimid', ncid, '' );
	error('failed');
end

status = oct_mexnc ( 'close', ncid );
if status, error(oct_mexnc('strerror',status)), end



%--------------------------------------------------------------------------
function test_empty_set_dimname(ncfile)

[ncid, status] = oct_mexnc('open', ncfile, nc_nowrite_mode );
if status, error(oct_mexnc('strerror',status)), end

try
	[test_dimid, status] = oct_mexnc ( 'dimid', ncid, [] );
	error('failed');
end

status = oct_mexnc ( 'close', ncid );
if status, error(oct_mexnc('strerror',status)), end

%--------------------------------------------------------------------------
function test_bad_dimname(ncfile)

[ncid, status] = oct_mexnc('open', ncfile, nc_nowrite_mode );
if status, error(oct_mexnc('strerror',status)), end

[test_dimid, status] = oct_mexnc ( 'dimid', ncid, 'y' );
if ( status >= 0 )
	error('failed'); 
end

status = oct_mexnc ( 'close', ncid );
if status, error(oct_mexnc('strerror',status)), end

