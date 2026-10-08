function indx=oct_write_eddynetcdf(ncid,indx,ID,time,lon,lat,...
                               Area,Energy,Vorticity,...
                               Radius,MaxSSH,MinSSH,MeanSSH,Amplitude,...
                               Ueddy,Leddy,U,V)
%
% function indx=oct_write_eddynetcdf(nc,indx,ID,time,lon,lat,...
%                               Area,Energy,Vorticity,...
%                               Radius,MaxSSH,MinSSH,MeanSSH,Amplitude,...
%                               Ueddy,Leddy,U,V)
%
%
% wrtie an eddy netcdf file
%
% Pierrick Penven 2011
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'time'), indx-1, 1, time);  % [conv] 0-based
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ID'), indx-1, 1, ID);  % [conv] 0-based
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon'), indx-1, 1, lon);  % [conv] 0-based
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat'), indx-1, 1, lat);  % [conv] 0-based
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Area'), indx-1, 1, Area);  % [conv] 0-based
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Energy'), indx-1, 1, Energy);  % [conv] 0-based
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Vorticity'), indx-1, 1, Vorticity);  % [conv] 0-based
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Radius'), indx-1, 1, Radius);  % [conv] 0-based
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'MaxSSH'), indx-1, 1, MaxSSH);  % [conv] 0-based
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'MinSSH'), indx-1, 1, MinSSH);  % [conv] 0-based
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'MeanSSH'), indx-1, 1, MeanSSH);  % [conv] 0-based
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Amplitude'), indx-1, 1, Amplitude);  % [conv] 0-based
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Ueddy'), indx-1, 1, Ueddy);  % [conv] 0-based
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Leddy'), indx-1, 1, Leddy);  % [conv] 0-based
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'U'), indx-1, 1, U);  % [conv] 0-based
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'V'), indx-1, 1, V);  % [conv] 0-based
indx=indx+1;

return
