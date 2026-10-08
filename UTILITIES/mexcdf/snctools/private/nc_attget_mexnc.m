function values = nc_attget_mexnc(ncfile, varname, attribute_name )

[ncid, status] =oct_mexnc('open', ncfile, nc_nowrite_mode );
if ( status ~= 0 )
    ncerror = oct_mexnc ( 'strerror', status );
    error ( 'snctools:attget:oct_mexnc:open', ncerror );
end

switch class(varname)
    case 'double'
        varid = varname;
        
    case 'char'
        varid = figure_out_varid ( ncid, varname );
        
    otherwise
        error ( 'snctools:attget:badType', 'Must specify either a variable name or NC_GLOBAL' );    
end

funcstr = determine_funcstr(ncid,varid,attribute_name);

% And finally, retrieve the attribute.
[values, status]=oct_mexnc(funcstr,ncid,varid,attribute_name);
if ( status ~= 0 )
    ncerror = oct_mexnc ( 'strerror', status );
    err_id = ['snctools:attget:oct_mexnc:' funcstr ];
    error ( err_id, ncerror );
end

status = oct_mexnc('close',ncid);
if ( status ~= 0 )
    ncerror = oct_mexnc ( 'strerror', status );
    error ( 'snctools:attget:oct_mexnc:close', ncerror );
end


return;








%--------------------------------------------------------------------
function funcstr = determine_funcstr(ncid,varid,attribute_name)
% This function is for the mex-file backend.  Determine which netCDF function
% string we invoke to retrieve the attribute value.

[dt, status]=oct_mexnc('inq_atttype',ncid,varid,attribute_name);
if ( status ~= 0 )
    oct_mexnc('close',ncid);
    ncerror = oct_mexnc ( 'strerror', status );
    error ( 'snctools:attget:oct_mexnc:inqAttType', ncerror );
end

switch ( dt )
    case nc_double
        funcstr = 'GET_ATT_DOUBLE';
    case nc_float
        funcstr = 'GET_ATT_FLOAT';
    case nc_int
        funcstr = 'GET_ATT_INT';
    case nc_short
        funcstr = 'GET_ATT_SHORT';
    case nc_byte
        funcstr = 'GET_ATT_SCHAR';
    case nc_char
        funcstr = 'GET_ATT_TEXT';
    otherwise
        oct_mexnc('close',ncid);
        error ( 'snctools:attget:badDatatype', 'Unhandled datatype ID %d', dt );
end

return





%--------------------------------------------------------------------------
function varid = figure_out_varid(ncid,varname)
% Did the user do something really stupid like say 'global' when they meant
% NC_GLOBAL?
if isempty(varname)
    varid = nc_global;
    return;
end

if ( strcmpi(varname,'global') )
    [varid, status] = oct_mexnc ( 'inq_varid', ncid, varname ); %#ok<ASGLU>
    if status
        % Ok, the user meant NC_GLOBAL
        warning ( 'snctools:attget:doNotUseGlobalString', ...
            'Please consider using NC_GLOBAL or -1 instead of the string ''%s''.', varname );
        varid = nc_global;
        return;
    end
end

[varid, status] = oct_mexnc('inq_varid',ncid,varname);
if ( status ~= 0 )
    oct_mexnc('close',ncid);
    ncerror = oct_mexnc('strerror',status);
    error('snctools:attget:oct_mexnc:inqVarID',ncerror);
end
