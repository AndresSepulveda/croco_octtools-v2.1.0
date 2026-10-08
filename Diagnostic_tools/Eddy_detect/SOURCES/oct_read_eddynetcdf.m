function [ID,time,lon,lat,Area,Energy,Vorticity,...
          Radius,MaxSSH,MinSSH,MeanSSH,Amplitude,U,V]=oct_read_eddynetcdf(ncid,indx)
%
% Read eddies properties from a netcdf file
%
time=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time'));
ID=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'ID'));
lon=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon'));
lat=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat'));
Area=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Area'));
Energy=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Energy'));
Vorticity=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Vorticity'));
Radius=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Radius'));
MaxSSH=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'MaxSSH'));
MinSSH=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'MinSSH'));
MeanSSH=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'MeanSSH'));
Amplitude=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Amplitude'));
U=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'U'));
V=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'V'));

return
