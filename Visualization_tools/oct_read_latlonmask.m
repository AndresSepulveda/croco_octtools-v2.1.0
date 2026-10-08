function [lat,lon,mask]=oct_read_latlonmask(fname,type);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% oct_read_latlonmask: copy of read_latlonmask using native netcdf

% netcdf.getVar returns (xi,eta): the fields are transposed to (eta,xi)
ncid = netcdf.open(fname,'NC_NOWRITE');
try
  lat = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lat_rho'))).';
catch
  try
    lat = 1e-5*double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'y_rho'))).';
  catch
    netcdf.close(ncid);
    error('READ_LATLONMASK: no latitude variable found')
  end
end
try
  lon = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lon_rho'))).';
catch
  try
    lon = 1e-5*double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'x_rho'))).';
  catch
    netcdf.close(ncid);
    error('READ_LATLONMASK: no longitude variable found')
  end
end
try
  mask = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'mask_rho'))).';
catch
  mask = [];
end
if isempty(mask)
  mask = 1+0*lon;
end
netcdf.close(ncid);

[Mp,Lp]=size(mask);

if (type=='u')
  lat=oct_rho2u_2d(lat);
  lon=oct_rho2u_2d(lon);
  mask=mask(:,1:Lp-1).*mask(:,2:Lp);
end
if (type=='v')
  lat=oct_rho2v_2d(lat);
  lon=oct_rho2v_2d(lon);
  mask=mask(1:Mp-1,:).*mask(2:Mp,:);
end

mask(mask==0)=NaN;

return
