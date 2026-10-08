function nc_adddim_mexnc(ncfile,dimname,dimlen)
% MEXNC backend to NC_ADDDIM.

[ncid, status] = oct_mexnc ( 'open', ncfile, nc_write_mode );
if status
    ncerr = oct_mexnc ( 'strerror', status );
    error_id = 'snctools:nc_adddim:openFailed';
    error ( error_id, ncerr );
end

status = oct_mexnc ( 'redef', ncid );
if status
    oct_mexnc ( 'close', ncid );
    ncerr = oct_mexnc ( 'strerror', status );
    error_id = 'snctools:nc_adddim:redefFailed';
    error ( error_id, ncerr );
end

[dimid, status] = oct_mexnc ('def_dim',ncid,dimname,dimlen); %#ok<ASGLU>
if status
    oct_mexnc ( 'close', ncid );
    ncerr = oct_mexnc ( 'strerror', status );
    error_id = 'snctools:nc_adddim:defdimFailed';
    error ( error_id, ncerr );
end

status = oct_mexnc ( 'enddef', ncid );
if status
    oct_mexnc ( 'close', ncid );
    ncerr = oct_mexnc ( 'strerror', status );
    error_id = 'snctools:nc_adddim:enddefFailed';
    error ( error_id, ncerr );
end

status = oct_mexnc ( 'close', ncid );
if status 
    ncerr = oct_mexnc ( 'strerror', status );
    error_id = 'snctools:nc_adddim:closeFailed';
    error ( error_id, ncerr );
end

return
