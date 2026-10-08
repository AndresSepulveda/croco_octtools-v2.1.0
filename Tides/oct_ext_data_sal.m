function [amp,pha]=oct_ext_data_sal(grdname,salname,ampname,phaname,itide)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Extract and interpolate self-attraction and loading tidal data
%
%  Further Information:  
%  http://www.crocoagrif.org/croco_tools/
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
%  June 2015 Patrick Marchesiello
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Octave version (Sep-2026): netcdf.* API of the octave-netcdf package.
%  ampname/phaname are (tide,lat,lon) in the file -> start/count [lon lat tide].
%
default=NaN;
%
% Read in the grid (netcdf.getVar gives (xi,eta): transpose to (eta,xi))
%
ng_id = netcdf.open(grdname, 'NC_NOWRITE');
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
% Open SAL file
%
ncid = netcdf.open(salname, 'NC_NOWRITE');
X=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon')));
Y=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat')));
X=X(:); Y=Y(:);
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
% Read amplitude and phase for tide itide
%
names={ampname,phaname};
out=cell(1,2);
for nv=1:2
  varid=netcdf.inqVarID(ncid, names{nv});
  data=[];
  for n=[2 1 3]
    ii=ilist{n};
    if ~isempty(ii)
      tmp=double(netcdf.getVar(ncid,varid,[ii(1)-1 j(1)-1 itide-1],...
                                          [length(ii) length(j) 1])).';
      if n==1, data=cat(2,tmp,data); else, data=cat(2,data,tmp); end
    end
  end
  out{nv}=data;
end
amp=out{1};
pha=out{2};
netcdf.close(ncid);
%
% Interpolate complex
%
cdata=amp.*exp(1i*pha*pi/180);
i_cdata(:,:)=interp2(x,y,cdata,lon,lat,'linear');
amp=abs(i_cdata);
pha=180/pi*angle(i_cdata);
%
return
