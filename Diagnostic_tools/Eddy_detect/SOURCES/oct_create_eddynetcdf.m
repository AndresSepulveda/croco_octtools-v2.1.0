function ncid=oct_create_eddynetcdf(fname);
%
%  function nc=oct_create_eddynetcdf(fname);
%
%
%
% Create an eddy netcdf file
%
% Pierrick Penven 2011
%
ncid = netcdf.create(fname, 'NC_CLOBBER');
netcdf.reDef(ncid);
did_entries = netcdf.defDim(ncid, 'entries', netcdf.getConstant('NC_UNLIMITED'));
%
vid_time = netcdf.defVar(ncid, 'time', 'NC_DOUBLE', did_entries);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'time'), 'long_name', 'Eddy time');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'time'), 'units', 'Days since Yorig/1/1');

vid_ID = netcdf.defVar(ncid, 'ID', 'NC_DOUBLE', did_entries);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'ID'), 'long_name', 'Eddy identification number');

vid_lon = netcdf.defVar(ncid, 'lon', 'NC_DOUBLE', did_entries);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lon'), 'long_name', 'Eddy longitude');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lon'), 'units', 'deg E');

vid_lat = netcdf.defVar(ncid, 'lat', 'NC_DOUBLE', did_entries);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lat'), 'long_name', 'Eddy latitude');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'lat'), 'units', 'deg N');

vid_Area = netcdf.defVar(ncid, 'Area', 'NC_DOUBLE', did_entries);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Area'), 'long_name', 'Eddy area');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Area'), 'units', 'm2');

vid_Energy = netcdf.defVar(ncid, 'Energy', 'NC_DOUBLE', did_entries);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Energy'), 'long_name', 'Eddy surface energy');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Energy'), 'units', 'm4.s-2');

vid_Vorticity = netcdf.defVar(ncid, 'Vorticity', 'NC_DOUBLE', did_entries);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Vorticity'), 'long_name', 'Eddy mean surface vorticity');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Vorticity'), 'units', 's-1');

vid_Radius = netcdf.defVar(ncid, 'Radius', 'NC_DOUBLE', did_entries);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Radius'), 'long_name', 'Eddy equivalent radius');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Radius'), 'units', 'm');

vid_MaxSSH = netcdf.defVar(ncid, 'MaxSSH', 'NC_DOUBLE', did_entries);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'MaxSSH'), 'long_name', 'Eddy maximum SSH');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'MaxSSH'), 'units', 'm');

vid_MinSSH = netcdf.defVar(ncid, 'MinSSH', 'NC_DOUBLE', did_entries);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'MinSSH'), 'long_name', 'Eddy minimum SSH');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'MinSSH'), 'units', 'm');

vid_MeanSSH = netcdf.defVar(ncid, 'MeanSSH', 'NC_DOUBLE', did_entries);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'MeanSSH'), 'long_name', 'Eddy mean SSH');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'MeanSSH'), 'units', 'm');

vid_Amplitude = netcdf.defVar(ncid, 'Amplitude', 'NC_DOUBLE', did_entries);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Amplitude'), 'long_name', 'Eddy amplitude');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Amplitude'), 'units', 'm');

vid_Ueddy = netcdf.defVar(ncid, 'Ueddy', 'NC_DOUBLE', did_entries);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Ueddy'), 'long_name', 'Eddy rotational speed (chelton et al., 2011)');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Ueddy'), 'units', '');

vid_Leddy = netcdf.defVar(ncid, 'Leddy', 'NC_DOUBLE', did_entries);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Leddy'), 'long_name', 'Eddy scale (chelton et al., 2011)');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'Leddy'), 'units', 'm');

vid_U = netcdf.defVar(ncid, 'U', 'NC_DOUBLE', did_entries);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'U'), 'long_name', 'Eddy zonal propagation speed');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'U'), 'units', 'm.s-1');

vid_V = netcdf.defVar(ncid, 'V', 'NC_DOUBLE', did_entries);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'V'), 'long_name', 'Eddy zonal propagation speed');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'V'), 'units', 'm.s-1');

% [conv] línea ncchar duplicada omitida
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'date', date);
netcdf.endDef(ncid);
return
