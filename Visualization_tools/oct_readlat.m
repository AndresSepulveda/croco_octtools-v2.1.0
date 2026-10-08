function lat=oct_readlat(ncid)
% OCT_READLAT Read latitude using procedural netcdf API
%
%  Octave version (Sep-2026): returns a double array in (eta,xi) order
%  (netcdf.getVar gives (xi,eta): transposed here). ncid is an open
%  netcdf id or a file name.
%
closeit=0;
if ischar(ncid)
  ncid=netcdf.open(ncid,'NC_NOWRITE'); closeit=1;
end
try
  lat = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lat_rho'))).';
catch
  try
    lat = 1e-5 * double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'y_rho'))).';
  catch
    if closeit, netcdf.close(ncid); end
    error('OCT_READLAT: no horizontal coordinate found')
  end
end
if closeit, netcdf.close(ncid); end
return
