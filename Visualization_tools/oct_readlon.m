function lon=oct_readlon(ncid)
% OCT_READLON Read longitude using procedural netcdf API
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
  lon = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lon_rho'))).';
catch
  try
    lon = 1e-5 * double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'x_rho'))).';
  catch
    if closeit, netcdf.close(ncid); end
    error('OCT_READLON: no horizontal coordinate found')
  end
end
if closeit, netcdf.close(ncid); end
return
