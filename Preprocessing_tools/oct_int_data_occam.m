function oct_int_data_occam(oaname,datafile,vname,vlon,vlat,...
                        dataname,londata,latdata,oct_tridim);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%  pierrick 2003
%
%  Ext tracers in a CROCO climatology file
%  take seasonal data for the upper levels and annual data for the
%  lower levels
%
%  input:
%    
%    oaname      : croco oa file to process (netcdf)
%    datafile : regular longitude - latitude - z seasonal data 
%                    file used for the upper levels  (netcdf)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
disp(['Horizontal  interpolations of ',vname])
%
% Read in the datafile 
%
nciddata = netcdf.open(datafile, 'NC_NOWRITE');
x=netcdf.getVar(nciddata, netcdf.inqVarID(nciddata, londata));
y=netcdf.getVar(nciddata, netcdf.inqVarID(nciddata, latdata));
Z=-netcdf.getVar(nciddata, netcdf.inqVarID(nciddata, 'Z'));
t=netcdf.getVar(nciddata, netcdf.inqVarID(nciddata, 'T'));
tlen=length(t);
Ndata=length(Z);
%
% Open the grid file  
% 
ng_id = netcdf.open(oaname, 'NC_NOWRITE');
lon=netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, vlon));
lon(lon<0)=lon(lon<0)+360;
lat=netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, vlat));
netcdf.close(ng_id);
[M,L]=size(lon);
dl=0.5;
minlon=min(min(lon))-dl;
maxlon=max(max(lon))+dl;
minlat=min(min(lat))-dl;
maxlat=max(max(lat))+dl;
imin=max(find(x<=minlon));
imax=min(find(x>=maxlon));
jmin=max(find(y<=minlat));
jmax=min(find(y>=maxlat));
x=x(imin:imax);
y=y(jmin:jmax);
%
% Open the OA file  
% 
ncid = netcdf.open(oaname, 'NC_WRITE');
if oct_tridim
  Zmodel=-netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Z'));
  Nmodel=length(Z);
  if Nmodel~=Ndata
    error('Number of vertical levels mismatch')
  end
  if Zmodel~=Z
    error('Vertical levels mismatch')
  end
end
%
% loop on time
%
for l=1:tlen
  disp(['  Time index ',num2str(l),' of ',num2str(tlen)]) 
  if oct_tridim
    for k=1:Ndata
      data=squeeze(netcdf.getVar(nciddata, netcdf.inqVarID(nciddata, dataname)));
      datazgrid(k,:,:)=interp2(x,y,data,lon,lat,'cubic');
    end
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, vname), l,:,:,:-1, 1, datazgrid);  % [conv] 0-based
  else
    data=squeeze(netcdf.getVar(nciddata, netcdf.inqVarID(nciddata, dataname)));
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, vname), l,:,:-1, 1, interp2(x,y,data,lon,lat,'cubic'));  % [conv] 0-based
  end
end
netcdf.close(ncid);
netcdf.close(nciddata);
return
