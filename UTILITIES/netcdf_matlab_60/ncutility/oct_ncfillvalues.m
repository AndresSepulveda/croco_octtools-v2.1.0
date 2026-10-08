function theResult = oct_ncfillvalues

% oct_ncfillvalues -- Create a NetCDF file containing default fill-values.
%  oct_ncfillvalues (no arguments) creates 'oct_ncfillvalues.nc', containing
%   variables with the default NetCDF fill-values.  Use "oct_ncdump" to
%   see the exact NetCDF file structure.  This routine returns a
%   Matlab "struct" of fill-values if an output argument is given.
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 14-Apr-1999 10:02:09.

help(mfilename)

theNames = {'ncbyte', 'ncchar', 'ncshort', 'nclong', 'ncfloat', 'ncdouble'};

f_id = netcdf.create('oct_ncfillvalues.nc', 'NC_CLOBBER');

netcdf.putAtt(f_id, netcdf.getConstant('NC_GLOBAL'), 'CreatedOn', datestr(now));
netcdf.putAtt(f_id, netcdf.getConstant('NC_GLOBAL'), 'CreatedBy', mfilename);
netcdf.putAtt(f_id, netcdf.getConstant('NC_GLOBAL'), 'MatlabVersion', version);
netcdf.putAtt(f_id, netcdf.getConstant('NC_GLOBAL'), 'Computer', computer);

did_index = netcdf.defDim(f_id, 'index', 1);

for i = 1:length(theNames)
	f_id{theNames{i}} = feval(theNames{i}, 'index');
end

netcdf.endDef(f_id);

result = [];
for i = 1:length(theNames)
	theFillValue = f_id{theNames{i}}(1);
	result = setfield(result, theNames{i}, theFillValue);
	f_id{theNames{i}}.FillValue_ = theFillValue;
end

netcdf.close(f_id);

if nargout > 0
	theResult = result;
else
	disp(result)
end
