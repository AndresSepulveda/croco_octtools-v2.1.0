function oct_ext_tracers(oaname,seas_datafile,ann_datafile,...
                      dataname,vname,tname,zname,Roa);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Ext tracers in a CROCO climatology file
%  take seasonal data for the upper levels and annual data for the
%  lower levels
%
%  input:
%    
%    oaname      : croco oa file to process (netcdf)
%    seas_datafile : regular longitude - latitude - z seasonal data 
%                    file used for the upper levels  (netcdf)
%    ann_datafile  : regular longitude - latitude - z annual data 
%                    file used for the lower levels  (netcdf)
% 
%  Further Information:  
%  http://www.croco-ocean.org
%  
%  This file is part of CROCOTOOLS
%
%  CROCOTOOLS is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation; either version 2 of the License,
%  or (at your option) any later version.
%
%  CROCOTOOLS is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with this program; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
%  MA  02111-1307  USA
%
%  Copyright (c) 2001-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    5-Oct-2006 by Pierrick Penven (test for negative salinity)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
%
% set the default value if no data
%
default=NaN;
disp([' Ext tracers: Roa = ',num2str(Roa/1000),...
      ' km - default value = ',num2str(default)])
%
% Open and Read the grid file (netcdf.getVar gives (xi,eta): transpose)
% 
ng_id = netcdf.open(oaname, 'NC_NOWRITE');
lon=double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lon_rho'))).';
lat=double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lat_rho'))).';
netcdf.close(ng_id);
[M,L]=size(lon);
%
dl=2;
lonmin=min(min(lon))-dl;
lonmax=max(max(lon))+dl;
latmin=min(min(lat))-dl;
latmax=max(max(lat))+dl;
%
% Read in the datafile 
%
ncidseas = netcdf.open(seas_datafile, 'NC_NOWRITE');
X=double(netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'X')));
Y=double(netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'Y')));
Zseas=-double(netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'Z')));
T=double(netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'T')));
X=X(:); Y=Y(:); Zseas=Zseas(:); T=T(:);
tlen=length(T);
Nzseas=length(Zseas);
%
% get a subgrid
%
j=find(Y>=latmin & Y<=latmax);
i1=find(X-360>=lonmin & X-360<=lonmax);
i2=find(X>=lonmin & X<=lonmax);
i3=find(X+360>=lonmin & X+360<=lonmax);
x=cat(1,X(i1)-360,X(i2),X(i3)+360);
y=Y(j);
ilist={i1,i2,i3};
%
% Open the OA file  
% 
ncid = netcdf.open(oaname, 'NC_WRITE');
Z=-double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, zname)));
Z=Z(:);
Nz=length(Z);
%
% Check the time
%
tclim=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, tname))); 
tclim=tclim(:);
T=T*30; % if time in month in the dataset !!!
if (tclim~=T)
  error(['time mismatch  tclim = ',num2str(tclim'),...
         '  t = ',num2str(T')])
end
%
% Read the annual dataset
%
if Nz > Nzseas
  ncidann = netcdf.open(ann_datafile, 'NC_NOWRITE');
  zann=-double(netcdf.getVar(ncidann, netcdf.inqVarID(ncidann, 'Z')));
  zann=zann(:);
  if (Z~=zann(1:Nz))
    error('Vertical levels mismatch')
  end
%
% Interpole the annual dataset on the horizontal CROCO grid
%
  disp(' Ext tracers: horizontal interpolation of the annual data')
  if Zseas~=zann(1:length(Zseas)) 
    error('vertical levels dont match')
  end
  datazgrid=zeros(Nz,M,L);
  vid_ann=netcdf.inqVarID(ncidann, dataname);
  % annual file: (T,Z,Y,X) or (Z,Y,X) depending on the dataset
  [~,~,dids_ann]=netcdf.inqVar(ncidann, vid_ann);
  nd_ann=length(dids_ann);
  missval=double(netcdf.getAtt(ncidann, vid_ann, 'missing_value'));
  for k=Nzseas+1:Nz
%
%   data(T=1,Z=k,Y=j,X=ii) -> start/count in Fortran order [X Y Z T]
%
    data=[];
    for n=[2 1 3]
      ii=ilist{n};
      if ~isempty(ii)
        tmp=double(netcdf.getVar(ncidann,vid_ann,...
                   [ii(1)-1 j(1)-1 k-1 zeros(1,nd_ann-3)],[length(ii) length(j) 1 ones(1,nd_ann-3)])).';
        if n==1, data=cat(2,tmp,data); else, data=cat(2,data,tmp); end
      end
    end
    data=oct_get_missing_val(x,y,data,missval,Roa,default);
    datazgrid(k,:,:)=interp2(x,y,data,lon,lat,'cubic');
  end
  netcdf.close(ncidann);
end
%
% interpole the seasonal dataset on the horizontal croco grid
%
disp([' Ext tracers: horizontal interpolation of the seasonal data'])
%
% loop on time
%
vid_seas=netcdf.inqVarID(ncidseas, dataname);
missval=double(netcdf.getAtt(ncidseas, vid_seas, 'missing_value'));
vid_out=netcdf.inqVarID(ncid, vname);
for l=1:tlen
  disp(['time index: ',num2str(l),' of total: ',num2str(tlen)])
  if Nz <= Nzseas
    datazgrid=zeros(Nz,M,L);
  end
  for k=1:min([Nz Nzseas])
    data=[];
    for n=[2 1 3]
      ii=ilist{n};
      if ~isempty(ii)
        tmp=double(netcdf.getVar(ncidseas,vid_seas,...
                   [ii(1)-1 j(1)-1 k-1 l-1],[length(ii) length(j) 1 1])).';
        if n==1, data=cat(2,tmp,data); else, data=cat(2,data,tmp); end
      end
    end
    data=oct_get_missing_val(x,y,data,missval,Roa,default);
    datazgrid(k,:,:)=interp2(x,y,data,lon,lat,'cubic');
  end
%
% Test for salinity (no negative salinity !)
%
  if strcmp(vname,'salt')
    disp('salinity test')
    datazgrid(datazgrid<2)=2;
  end
%
% Write record l: (Z,eta,xi) -> (xi,eta,Z) for netcdf.putVar
%
  netcdf.putVar(ncid, vid_out, [0 0 0 l-1], [L M Nz 1], permute(datazgrid,[3 2 1]));
end
netcdf.close(ncid);
netcdf.close(ncidseas);
return
