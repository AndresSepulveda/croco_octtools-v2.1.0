function dinfo = nc_getdiminfo_mexnc(arg1,arg2)
% MEXNC backend for NC_GETDIMINFO

% If we are here, then we must have been given something local.
if ischar(arg1) && ischar(arg2)
    dinfo = handle_char_nc_getdiminfo(arg1,arg2);
elseif isnumeric(arg1) && isnumeric(arg2)
	dinfo = handle_numeric_nc_getdiminfo(arg1,arg2);
else
	error('snctools:getdiminfo_MEX:badInputDatatypes', ...
	      'Must supply either two character or two numeric arguments.');
end

return


%--------------------------------------------------------------------------
function dinfo = handle_char_nc_getdiminfo(ncfile,dimname)

[ncid,status ]=oct_mexnc('open', ncfile, nc_nowrite_mode );
if status ~= 0
	ncerror = oct_mexnc ( 'strerror', status );
	error ( 'snctools:getdiminfo:oct_mexnc:openFailed', ncerror );
end


[dimid, status] = oct_mexnc('INQ_DIMID', ncid, dimname);
if ( status ~= 0 )
	oct_mexnc('close',ncid);
	ncerror = oct_mexnc ( 'strerror', status );
	error ( 'snctools:getdiminfo:oct_mexnc:inq_dimidFailed', ncerror );
end


dinfo = handle_numeric_nc_getdiminfo(ncid,dimid);

oct_mexnc('close',ncid);






%--------------------------------------------------------------------------
function dinfo = handle_numeric_nc_getdiminfo(ncid,dimid)

[unlimdim, status] = oct_mexnc ( 'inq_unlimdim', ncid );
if status ~= 0
	oct_mexnc('close',ncid);
	ncerror = oct_mexnc ( 'strerror', status );
	error ( 'snctools:getdiminfo:MEXNC:inq_ulimdimFailed', ncerror );
end

[dimname, dimlength, status] = oct_mexnc('INQ_DIM', ncid, dimid);
if status ~= 0
	oct_mexnc('close',ncid);
	ncerror = oct_mexnc ( 'strerror', status );
	error ( 'snctools:getdiminfo:MEXNC:inq_dimFailed', ncerror );
end

dinfo.Name = dimname;
dinfo.Length = dimlength;

if dimid == unlimdim
	dinfo.Unlimited = true;
else
	dinfo.Unlimited = false;
end

return


