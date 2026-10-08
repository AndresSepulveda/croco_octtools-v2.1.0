function nc_varrename_mexnc ( ncfile, old_variable_name, new_variable_name )
% MEXNC backend to NC_VARRENAME.

[ncid,status ]=oct_mexnc('OPEN',ncfile,nc_write_mode);
if status ~= 0
    ncerr = oct_mexnc('strerror', status);
    error ( 'snctools:varrename:oct_mexnc:OPEN', ncerr );
end


status = oct_mexnc('REDEF', ncid);
if status ~= 0
    oct_mexnc('close',ncid);
    ncerr = oct_mexnc('strerror', status);
    error ( 'snctools:varrename:oct_mexnc:REDEF', ncerr );
end


[varid, status] = oct_mexnc('INQ_VARID', ncid, old_variable_name);
if status ~= 0
    oct_mexnc('close',ncid);
    ncerr = oct_mexnc('strerror', status);
    error ( 'snctools:varrename:oct_mexnc:INQ_VARID', ncerr );
end


status = oct_mexnc('RENAME_VAR', ncid, varid, new_variable_name);
if status ~= 0
    oct_mexnc('close',ncid);
    ncerr = oct_mexnc('strerror', status);
    error ( 'snctools:varrename:oct_mexnc:RENAME_VAR', ncerr );
end


status = oct_mexnc('ENDDEF', ncid);
if status ~= 0
    oct_mexnc('close',ncid);
    ncerr = oct_mexnc('strerror', status);
    error ( 'snctools:varrename:oct_mexnc:ENDDEF', ncerr );
end


status = oct_mexnc('close',ncid);
if status ~= 0
    ncerr = oct_mexnc('strerror', status);
    error ( 'snctools:varrename:oct_mexnc:CLOSE', ncerr );
end


