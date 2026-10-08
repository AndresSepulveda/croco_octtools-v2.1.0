function oct_write_ECMWF(fname,vname,lon,lat,time,var,Yorig)

%----------------------------------------------------------
%
% Update June 2010, S Illig
%----------------------------------------------------------

disp(['    Create ',fname])
ncid = netcdf.create([fname], 'NC_CLOBBER');
%
did_lon = netcdf.defDim(ncid, 'lon', length(lon));
did_lat = netcdf.defDim(ncid, 'lat', length(lat));
did_time = netcdf.defDim(ncid, 'time', length(time));
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
vid_time = netcdf.defVar(ncid, 'time', 'NC_FLOAT', did_time);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'time'), 'long_name', 'Time');
eval(['netcdf.getAtt(ncid, netcdf.inqVarID(ncid, ''time''), 'units')= ncchar(''days since ',num2str(Yorig),'-01-01  00:00:00'');'])
eval(['netcdf.getAtt(ncid, netcdf.inqVarID(ncid, ''time''), 'units')= ''days since ',num2str(Yorig),'-01-01  00:00:00'';'])
%
vid_vname = netcdf.defVar(ncid, 'vname', 'NC_FLOAT', [did_lon, did_lat, did_time]);
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, vname), 'missing_value', 9999.0);
%
netcdf.endDef(ncid);
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon'), lon);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat'), lat);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'time'), time);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, vname), var);

%
netcdf.close(ncid);
return

