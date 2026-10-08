function nc_attput_mex(ncfile,varname,attname,attval)
% MEXNC handler for NC_ATTPUT.

if isnumeric(ncfile) && isnumeric(varname)
    % File is already open.
    attput(ncfile,varname,attname,attval);
    return
end


[ncid, status] =oct_mexnc('open',ncfile,nc_write_mode);
if  status ~= 0 
    ncerr = oct_mexnc('strerror',status);
    error('snctools:attput:oct_mexnc:open',ncerr);
end

try
    % Put into define mode.
    status = oct_mexnc('redef',ncid);
    if ( status ~= 0 )
        ncerr = oct_mexnc('strerror',status);
        error('snctools:attput:oct_mexnc:redef',ncerr);
    end
    
    if isnumeric(varname)
        varid = varname;
    else
        [varid, status] = oct_mexnc('inq_varid',ncid,varname);
        if ( status ~= 0 )
            ncerr = oct_mexnc('strerror',status);
            error('snctools:attput:oct_mexnc:inq_varid',ncerr);
        end
    end
    
    attput(ncid,varid,attname,attval);
    
    status = oct_mexnc('enddef',ncid);
    if ( status ~= 0 )
        ncerr = oct_mexnc('strerror',status);
        error('snctools:attput:oct_mexnc:enddef',ncerr);
    end

catch %#ok<CTCH>
	oct_mexnc('close',ncid);
	rethrow(lasterror);	
end

status = oct_mexnc('close',ncid);
if ( status ~= 0 )
    ncerr = oct_mexnc('strerror',status);
    error('snctools:attput:oct_mexnc:close',ncerr);
end


return;


%--------------------------------------------------------------------------
function attput(ncid,varid,attname,attval)

% If the attribute is '_FillValue', then force the value to have the
% correct dataype.
if strcmp(attname,'_FillValue')
    [xtype,status] = oct_mexnc('INQ_VARTYPE',ncid,varid);
    if ( status ~= 0 )
        ncerr = oct_mexnc('strerror',status);
        error ('snctools:attput:oct_mexnc:inq_vartype',ncerr);
    end

    switch(xtype)
        case nc_double
            attval = double(attval);
        case nc_float
            attval = single(attval);
        case nc_int
            attval = int32(attval);
        case nc_short
            attval = int16(attval);
        case nc_byte
            attval = int8(attval);
        case nc_char
            attval = char(attval);
    end
end


% Figure out which oct_mexnc operation to perform.
switch class(attval)
    case 'double'
        funcstr = 'put_att_double';
        xtype = nc_double;
    case 'single'
        funcstr = 'put_att_float';
        xtype = nc_float;
    case 'int32'
        funcstr = 'put_att_int';
        xtype = nc_int;
    case 'int16'
        funcstr = 'put_att_short';
        xtype = nc_short;
    case 'int8'
        funcstr = 'put_att_schar';
        xtype = nc_byte;
    case 'uint8'
        funcstr = 'put_att_uchar';
        xtype = nc_byte;
    case 'char'
        funcstr = 'put_att_text';
        xtype = nc_char;
    otherwise
        error('snctools:attput:oct_mexnc:unhandledDatatype', ...
            'attribute class %s is not handled by %s', ...
            class(attval), mfilename );
end

status = oct_mexnc(funcstr,ncid,varid,attname,xtype,numel(attval),attval);
if ( status ~= 0 )
    ncerr = oct_mexnc('strerror',status);
    error(['snctools:attput:oct_mexnc:' lower(funcstr)], ...
        'PUT_ATT operation failed:  %s',ncerr);
end
