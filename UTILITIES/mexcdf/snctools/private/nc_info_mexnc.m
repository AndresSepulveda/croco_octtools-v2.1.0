function fileinfo = nc_info_mexnc(ncfile)

fileinfo = struct('Name','/','Datatype',[],'Attribute',[],'Dimension',[],'Dataset',[],'Group',[]);
fileinfo.Filename = ncfile;

[ncid, status]=oct_mexnc('open', ncfile, nc_nowrite_mode );
if status ~= 0
    ncerr = oct_mexnc('strerror', status);
    error ( 'snctools:info:oct_mexnc:OPEN', ncerr );
end



[ndims, nvars, ngatts, record_dimension, status] = oct_mexnc('INQ', ncid); %#ok<ASGLU>
if status ~= 0
    ncerr = oct_mexnc('strerror', status);
    oct_mexnc('close',ncid);
    error ( 'snctools:info:oct_mexnc:INQ', ncerr );
end


%
% Get the dimensions
if ndims == 0
	Dimension = struct ( [] );
else
	if ndims > 0
		Dimension(1)=nc_getdiminfo_mexnc ( ncid, 0 );
	end
	Dimension = repmat ( Dimension, ndims,1 );
	for dimid = 1:ndims-1
		Dimension(dimid+1)=nc_getdiminfo_mexnc ( ncid, dimid );
	end
end



% Get the global attributes.
if ngatts == 0
	fileinfo.Attribute = [];
else
    Attribute = struct('Name','','Nctype',NaN,'Datatype','','Value',NaN);
    Attribute = repmat(Attribute,ngatts,1);
	Attribute = repmat ( Attribute, ngatts, 1 );
	for attnum = 0:ngatts-1
		Attribute(attnum+1) = nc_getattsinfo_mexnc(ncid,nc_global,attnum );
	end
	fileinfo.Attribute = Attribute;
end





%
% Get the variable information.
if nvars == 0
	Dataset = struct([]);
else
	if ( nvars > 0 )
		Dataset(1) = nc_getvarinfo_mexnc ( ncid, 0 );
	end
	Dataset = repmat ( Dataset, nvars, 1 );
	for varid=1:nvars-1
		Dataset(varid+1) = nc_getvarinfo_mexnc ( ncid, varid );
	end
end

fileinfo.Dimension = Dimension;
fileinfo.Dataset = Dataset;


oct_mexnc('close',ncid);


return









