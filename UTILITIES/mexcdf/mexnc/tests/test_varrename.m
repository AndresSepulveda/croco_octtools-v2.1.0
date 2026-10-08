function test_varrename ( ncfile )
% TEST_VARRENAME
%

[ncid, status] = oct_mexnc ( 'create', ncfile, nc_clobber_mode );
if ( status < 0 )
	ncerr = oct_mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


%
% DIMDEF
[xdimid, status] = oct_mexnc ( 'def_dim', ncid, 'x', 20 );
if ( status < 0 )
	ncerr = oct_mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end
[ydimid, status] = oct_mexnc ( 'def_dim', ncid, 'y', 24 );
if ( status < 0 )
	ncerr = oct_mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end
[zdimid, status] = oct_mexnc ( 'def_dim', ncid, 'z', 32 );
if ( status < 0 )
	ncerr = oct_mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


%
% VARDEF
[xdvarid, status] = oct_mexnc ( 'def_var', ncid, 'x_double', 'double', 1, xdimid );
if ( status < 0 )
	ncerr = oct_mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  put_att_double failed on variable attribute, ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


%status = oct_mexnc ( 'sync', ncid );
%if ( status < 0 )
%	ncerr = oct_mexnc ( 'strerror', status );
%	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
%	error ( err_msg );
%end


[status] = oct_mexnc('VARRENAME', ncid, xdvarid, 'newname');
if ( status < 0 )
	ncerr = oct_mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


[nvarid, status] = oct_mexnc('INQ_VARID', ncid, 'newname');
if ( status < 0 )
	ncerr = oct_mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end


%
% Are they the same?
if ( nvarid ~= xdvarid )
	error ( 'INQ_VARID did not return the correct varid.  So VARRENAME failed.\n' );
end



%
% Bogus ncid
[status] = oct_mexnc('VARRENAME', -4, xdvarid, 'newname');
if ( status >= 0 )
	error ( 'Bogus ncid case succeeded for VARRENAME.\n' );
end

%
% Bogus varid
[status] = oct_mexnc('VARRENAME', ncid, -5, 'newname');
if ( status >= 0 )
	error ( 'Bogus varid case succeeded for VARRENAME.\n' );
end



%
% ENDEF
[status] = oct_mexnc ( 'enddef', ncid );
if ( status < 0 )
	ncerr = oct_mexnc ( 'strerror', status );
	err_msg = sprintf ( '%s:  ''%s''\n', mfilename, ncerr );
	error ( err_msg );
end




status = oct_mexnc ( 'close', ncid );
if ( status < 0 )
	ncerr = oct_mexnc ( 'strerror', status );
	msg = sprintf ( '%s:  %s\n', mfilename, ncerr );
	error ( msg );
end


fprintf ( 1, 'VARRENAME succeeded.\n' );

return












