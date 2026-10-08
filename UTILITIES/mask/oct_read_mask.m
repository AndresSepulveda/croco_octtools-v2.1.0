function [spherical,x,y,bath,rmask]=oct_read_mask(Gname)
% OCT_READ_MASK simple NetCDF reader for mask-related vars using octave-oct_netcdf
ncid = netcdf.open(Gname,'NC_NOWRITE');

% dimensions
xid = netcdf.inqDimID(ncid,'xi_rho'); [~,Im] = netcdf.inqDim(ncid,xid);
yid = netcdf.inqDimID(ncid,'eta_rho'); [~,Jm] = netcdf.inqDim(ncid,yid);

spherical = 0; x=[]; y=[]; bath=zeros([Im Jm]); rmask=ones([Im Jm]);

try
  vid = netcdf.inqVarID(ncid,'spherical');
  s = char(netcdf.getVar(ncid,vid)); s = s(1);
  if (s=='T' || s=='t'), spherical=1; end
end

if spherical
  try
    x = netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lon_rho'));
    y = netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lat_rho'));
  catch
    [y,x]=meshgrid(1:Jm,1:Im);
  end
else
  try
    x = netcdf.getVar(ncid,netcdf.inqVarID(ncid,'x_rho'));
    y = netcdf.getVar(ncid,netcdf.inqVarID(ncid,'y_rho'));
  catch
    [y,x]=meshgrid(1:Jm,1:Im);
  end
end

try
  rmask = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'mask_rho')));
catch
  rmask = ones([Im Jm]);
end

% bathymetry
try
  bath = netcdf.getVar(ncid,netcdf.inqVarID(ncid,'hraw'));
catch
  try
    bath = netcdf.getVar(ncid,netcdf.inqVarID(ncid,'h'));
  catch
    bath = zeros([Im Jm]);
  end
end

netcdf.close(ncid);
return
