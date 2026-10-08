function test_deflate ( ncfile )

if nargin == 0
	ncfile = 'foo.nc';
end

v = oct_mexnc('inq_libvers');
if v(1) ~= '4'
	fprintf('deflate tests filtered out when the library version is less than 4.0.\n');
	return
end

test_netcdf3_classic(ncfile);    
test_netcdf3_64bit(ncfile);                 
test_netcdf4_1d_shuffle_off_deflate_off(ncfile);
test_netcdf4_1d_shuffle_off_deflate_on(ncfile); 
test_netcdf4_1d_shuffle_on_deflate_off(ncfile);
test_netcdf4_1d_shuffle_on_deflate_on(ncfile); 

fprintf ( 'DEF_VAR_DEFLATE succeeded.\n' );
fprintf ( 'INQ_VAR_DEFLATE succeeded.\n' );

return


%--------------------------------------------------------------------------
function test_netcdf3_classic(ncfile)
% This test should fail because deflate is not allowed on oct_netcdf-3.  
% Period.

[ncid, status] = oct_mexnc ( 'create', ncfile, nc_clobber_mode );
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[xdimid,status] = oct_mexnc('def_dim',ncid,'x',100);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[xdvarid, status] = oct_mexnc ( 'def_var', ncid, 'x', nc_double, 1, xdimid );
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

try
	status = oct_mexnc('def_var_deflate',ncid,varid,0,0,0);
catch
	% Good.  We caught the error.  Just close the file and be done
	% with it.
	status = oct_mexnc ( 'close', ncid );
	return
end

error('should not have been able to deflate a oct_netcdf-3 variable');

return



%--------------------------------------------------------------------------
function test_netcdf3_64bit(ncfile)
% This test should fail because deflate is not allowed on oct_netcdf-3 files,
% whether they are 64-bit or not

mode = bitor(nc_clobber_mode,nc_64bit_offset_mode);
[ncid, status] = oct_mexnc ( 'create', ncfile, mode );
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[xdimid,status] = oct_mexnc('def_dim',ncid,'x',100);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[xdvarid, status] = oct_mexnc ( 'def_var', ncid, 'x', nc_double, 1, xdimid );
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

try
	status = oct_mexnc('def_var_deflate',ncid,varid,0,0,0);
catch
	% Good.  We caught the error.  Just close the file and be done
	% with it.
	status = oct_mexnc ( 'close', ncid );
	return
end

error('should not have been able to deflate a oct_netcdf-3 64bit offset variable');

return



%--------------------------------------------------------------------------
function test_netcdf4_1d_shuffle_off_deflate_off(ncfile)
% shuffle filter turned off 
% deflate filter turned off
% oct_netcdf-4

oct_delete(ncfile);
[ncid, status] = oct_mexnc ( 'create', ncfile, nc_netcdf4_classic );
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[xdimid,status] = oct_mexnc('def_dim',ncid,'x',100);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[varid, status] = oct_mexnc ( 'def_var', ncid, 'x', nc_double, 1, xdimid );
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

status = oct_mexnc('def_var_deflate',ncid,varid,0,0,0);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

status = oct_mexnc('enddef',ncid);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[shuffle,deflate,deflate_level,status] = oct_mexnc('inq_var_deflate',ncid,varid);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

if ( shuffle ~= 0 )
	error('1D shuffle failed');
end

if ( deflate ~= 0 )
	error('1D deflate failed');
end

if ( deflate_level ~= 0 )
	error('1D deflate_level failed');
end


status = oct_mexnc('close',ncid);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end


return



%--------------------------------------------------------------------------
function test_netcdf4_1d_shuffle_off_deflate_on(ncfile)
% 

oct_delete(ncfile);
[ncid, status] = oct_mexnc ( 'create', ncfile, nc_netcdf4_classic );
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[xdimid,status] = oct_mexnc('def_dim',ncid,'x',100);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[varid1, status] = oct_mexnc ( 'def_var', ncid, 'x1', nc_double, 1, xdimid );
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[varid2, status] = oct_mexnc ( 'def_var', ncid, 'x2', nc_double, 1, xdimid );
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[varid3, status] = oct_mexnc ( 'def_var', ncid, 'x3', nc_double, 1, xdimid );
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

status = oct_mexnc('def_var_deflate',ncid,varid1,0,1,0);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

status = oct_mexnc('def_var_deflate',ncid,varid2,0,1,5);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

status = oct_mexnc('def_var_deflate',ncid,varid3,0,1,9);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

status = oct_mexnc('enddef',ncid);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end


% var1
[shuffle,deflate,deflate_level,status] = oct_mexnc('inq_var_deflate',ncid,varid1);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

if ( shuffle ~= 0 )
	error('1D shuffle failed');
end

if ( deflate ~= 1 )
	error('1D deflate failed');
end

if ( deflate_level ~= 0 )
	error('1D deflate_level failed');
end



% var2
[shuffle,deflate,deflate_level,status] = oct_mexnc('inq_var_deflate',ncid,varid2);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

if ( shuffle ~= 0 )
	error('1D shuffle failed');
end

if ( deflate ~= 1 )
	error('1D deflate failed');
end

if ( deflate_level ~= 5 )
	error('1D deflate_level failed');
end



% var3
[shuffle,deflate,deflate_level,status] = oct_mexnc('inq_var_deflate',ncid,varid3);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

if ( shuffle ~= 0 )
	error('1D shuffle failed');
end

if ( deflate ~= 1 )
	error('1D deflate failed');
end

if ( deflate_level ~= 9 )
	error('1D deflate_level failed');
end



status = oct_mexnc('close',ncid);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end


return



%--------------------------------------------------------------------------
function test_netcdf4_1d_shuffle_on_deflate_off(ncfile)
% 

oct_delete(ncfile);
[ncid, status] = oct_mexnc ( 'create', ncfile, nc_netcdf4_classic );
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[xdimid,status] = oct_mexnc('def_dim',ncid,'x',100);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[varid, status] = oct_mexnc ( 'def_var', ncid, 'x', nc_double, 1, xdimid );
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

status = oct_mexnc('def_var_deflate',ncid,varid,1,0,0);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

status = oct_mexnc('enddef',ncid);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[shuffle,deflate,deflate_level,status] = oct_mexnc('inq_var_deflate',ncid,varid);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

if ( shuffle ~= 1 )
	error('1D shuffle failed');
end

if ( deflate ~= 0 )
	error('1D deflate failed');
end

if ( deflate_level ~= 0 )
	error('1D deflate_level failed');
end


status = oct_mexnc('close',ncid);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end


return



%--------------------------------------------------------------------------
function test_netcdf4_1d_shuffle_on_deflate_on(ncfile)
% shuffle filter turned off 
% deflate filter turned on 
% oct_netcdf-4

oct_delete(ncfile);
[ncid, status] = oct_mexnc ( 'create', ncfile, nc_netcdf4_classic );
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[xdimid,status] = oct_mexnc('def_dim',ncid,'x',100);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[varid1, status] = oct_mexnc ( 'def_var', ncid, 'x1', nc_double, 1, xdimid );
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[varid2, status] = oct_mexnc ( 'def_var', ncid, 'x2', nc_double, 1, xdimid );
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

[varid3, status] = oct_mexnc ( 'def_var', ncid, 'x3', nc_double, 1, xdimid );
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

status = oct_mexnc('def_var_deflate',ncid,varid1,1,1,0);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

status = oct_mexnc('def_var_deflate',ncid,varid2,1,1,5);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

status = oct_mexnc('def_var_deflate',ncid,varid3,1,1,9);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

status = oct_mexnc('enddef',ncid);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end


% var1
[shuffle,deflate,deflate_level,status] = oct_mexnc('inq_var_deflate',ncid,varid1);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

if ( shuffle ~= 1 )
	error('1D shuffle failed');
end

if ( deflate ~= 1 )
	error('1D deflate failed');
end

if ( deflate_level ~= 0 )
	error('1D deflate_level failed');
end



% var2
[shuffle,deflate,deflate_level,status] = oct_mexnc('inq_var_deflate',ncid,varid2);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

if ( shuffle ~= 1 )
	error('1D shuffle failed');
end

if ( deflate ~= 1 )
	error('1D deflate failed');
end

if ( deflate_level ~= 5 )
	error('1D deflate_level failed');
end



% var3
[shuffle,deflate,deflate_level,status] = oct_mexnc('inq_var_deflate',ncid,varid3);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end

if ( shuffle ~= 1 )
	error('1D shuffle failed');
end

if ( deflate ~= 1 )
	error('1D deflate failed');
end

if ( deflate_level ~= 9 )
	error('1D deflate_level failed');
end



status = oct_mexnc('close',ncid);
if ( status ~= 0 ), error(oct_mexnc ( 'strerror', status )), end


return



