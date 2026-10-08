function oct_write_NCEP_Mask(fname,vname,lon,lat,var)

%----------------------------------------------------------
%
% Update Feb 2008, J Lefevre
%----------------------------------------------------------

disp(['    Create ',fname])
ncid = netcdf.create([fname], 'NC_CLOBBER');
%
did_lon = netcdf.defDim(ncid, 'lon', length(lon));
did_lat = netcdf.defDim(ncid, 'lat', length(lat));
%
vid_lon = netcdf.defVar(ncid, 'lon', 'NC_FLOAT', did_lon);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lon'), 'long_name', 'longitude of RHO-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lon'), 'units', 'degree_east');
% 
vid_lat = netcdf.defVar(ncid, 'lat', 'NC_FLOAT', did_lat);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lat'), 'long_name', 'latitude of RHO-points');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lat'), 'units', 'degree_north');
%
vid_vname = netcdf.defVar(ncid, 'vname', 'NC_FLOAT', [did_lon, did_lat]);
%
netcdf.endDef(ncid);
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon'), lon);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat'), lat);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, vname), var);
%
netcdf.close(ncid);
return
