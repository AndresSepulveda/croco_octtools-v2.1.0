function [x,y,data]=oct_get_topex2014(lonmin,lonmax,latmin,latmax,fname)
%
% Get altimetry data [m] from a AVISO netcdf file
%
% Pierrick Penven 2004
%
dataname='adt';
%
%
%
nciddat = netcdf.open(fname, 'NC_NOWRITE');
T=netcdf.getVar(nciddat, netcdf.inqVarID(nciddat, 'time'));
X=netcdf.getVar(nciddat, netcdf.inqVarID(nciddat, 'lon'));
Y=netcdf.getVar(nciddat, netcdf.inqVarID(nciddat, 'lat'));
%
disp(['AVISO - ',datestr(T+datenum(1950,1,1))])

%
% get a subgrid
%
j=find(Y>=latmin & Y<=latmax);
i1=find(X-360>=lonmin & X-360<=lonmax);
i2=find(X>=lonmin & X<=lonmax);
i3=find(X+360>=lonmin & X+360<=lonmax);
x=cat(1,X(i1)-360,X(i2),X(i3)+360);
y=Y(j);
%
%  Read data
%
data=[];
if ~isempty(i2)
  data=squeeze(netcdf.getVar(nciddat, netcdf.inqVarID(nciddat, dataname)));
end
if ~isempty(i1)
  data=cat(2,squeeze(netcdf.getVar(nciddat, netcdf.inqVarID(nciddat, dataname))),data);
end
if ~isempty(i3)
  data=cat(2,data,squeeze(netcdf.getVar(nciddat, netcdf.inqVarID(nciddat, dataname))));
end
netcdf.close(nciddat);
%
% A few transformations (zeta in meters)
%
data(data<-1e9)=NaN;
data=data*0.0001;
%
return
