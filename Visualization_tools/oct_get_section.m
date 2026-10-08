function [X,Z,VAR]=oct_get_section(fname,gname,lonsec,latsec,vname,tindex);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function [X,Z,VAR]=oct_get_section(fname,gname,lonsec,latsec,vname,tindex);  
%
%  Extract a vertical slice in any direction (or along a curve)
%  from a CROCO netcdf file.
%
% 
% On Input:
% 
%    fname       History NetCDF file name (character string). 
%    gname       Grid NetCDF file name (character string). 
%    lonsec      Longitudes of the points of the section. 
%                 (vector or [min max] or single value if N-S section).
%                (default: [12 18])
%    latsec      Latitudes of the points of the section. 
%                 (vector or [min max] or single value if E-W section)
%                (default: -34)
%
%    NB: if lonsec and latsec are vectors, they must have the same length.
%
%    vname       NetCDF variable name to process (character string).
%                (default: temp)
%    tindex      Netcdf time index (integer).
%                (default: 1) 
%
% On Output:
%
%    X           Slice X-distances (km) from the first point (2D matrix).
%    Z           Slice Z-positions (matrix). 
%    VAR         Slice of the variable (matrix).
%
%  Further Information:  
%  http://www.croco-ocean.org
%  
%  This file is part of CROCOTOOLS
%
%  CROCOTOOLS is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation; either version 2  
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
%  Copyright (c) 2002-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated 2006 by Juliet Hermes (UCT): increase of dl to prevent
%  errors when doing zonal or meridian sections.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
interp_type='linear';
%
% Defaults values
%
if nargin < 1
  error('You must specify a file name')
end
if nargin < 2
  gname=fname;
  disp(['Default grid name: ',gname])
end
if nargin < 3
  lonsec=[12 18];
  disp(['Default longitude: ',num2str(lonsec)])
end
if nargin < 4
  latsec=-34;
  disp(['Default latitude: ',num2str(latsec)])
end
if nargin < 5
  vname='temp';
  disp(['Default variable to plot: ',vname])
end
if nargin < 6
  tindex=1;
  disp(['Default time index: ',num2str(tindex)])
end
%
% Find maximum grid angle size (dl)
%
[lat,lon,mask]=oct_read_latlonmask(gname,'r');
[M,L]=size(lon);
dl=1.5* max([max(max(abs(lon(2:M,:)-lon(1:M-1,:)))) ...
        max(max(abs(lon(:,2:L)-lon(:,1:L-1)))) ...
        max(max(abs(lat(2:M,:)-lat(1:M-1,:)))) ...
        max(max(abs(lat(:,2:L)-lat(:,1:L-1))))]);
%
% Read point positions
%
[type,vlevel]=oct_get_type(fname,vname,10);
if (vlevel==0)
   error([vname,' is a 2D-H variable'])
   return
end  
[lat,lon,mask]=oct_read_latlonmask(gname,type);
[M,L]=size(lon);
%
% Find minimal subgrids limits
%
minlon=min(lonsec)-dl;
minlat=min(latsec)-dl;
maxlon=max(lonsec)+dl;
maxlat=max(latsec)+dl;
sub=lon>minlon & lon<maxlon & lat>minlat & lat<maxlat;
if (sum(sum(sub))==0)
  error('Section out of the domain')
end
ival=sum(sub,1);
jval=sum(sub,2);
imin=min(find(ival~=0));
imax=max(find(ival~=0));
jmin=min(find(jval~=0));
jmax=max(find(jval~=0));
%
% Get subgrids
%
lon=lon(jmin:jmax,imin:imax);
lat=lat(jmin:jmax,imin:imax);
sub=sub(jmin:jmax,imin:imax);
mask=mask(jmin:jmax,imin:imax);
%
% Put latitudes and longitudes of the section in the correct vector form
%
if (length(lonsec)==1)
  disp(['N-S section at longitude: ',num2str(lonsec)])
  if (length(latsec)==1)
    error('Need more points to do a section')
  elseif (length(latsec)==2)
    latsec=(latsec(1):dl:latsec(2));
  end
  lonsec=0.*latsec+lonsec;
elseif (length(latsec)==1)
  disp(['E-W section at latitude: ',num2str(latsec)])
  if (length(lonsec)==2)
    lonsec=(lonsec(1):dl:lonsec(2));
  end
  latsec=0.*lonsec+latsec;
elseif (length(lonsec)==2 & length(latsec)==2)
  Npts=ceil(max([abs(lonsec(2)-lonsec(1))/dl ...
                  abs(latsec(2)-latsec(1))/dl]));
  if lonsec(1)==lonsec(2)
    lonsec=lonsec(1)+zeros(1,Npts+1);
  else
    lonsec=(lonsec(1):(lonsec(2)-lonsec(1))/Npts:lonsec(2));
  end
  if latsec(1)==latsec(2)
    latsec=latsec(1)+zeros(1,Npts+1);
  else
    latsec=(latsec(1):(latsec(2)-latsec(1))/Npts:latsec(2));
  end
elseif (length(lonsec)~= length(latsec))
  error('Section latitudes and longitudes are not of the same length')
end
Npts=length(lonsec);
%
% Get the subgrid
%
sub=0*lon;
for i=1:Npts
  sub(lon>lonsec(i)-dl & lon<lonsec(i)+dl & ...
      lat>latsec(i)-dl & lat<latsec(i)+dl)=1;
end
%
%  get the coefficients of the objective analysis
%
londata=lon(sub==1);
latdata=lat(sub==1);
coef=oct_oacoef(londata,latdata,lonsec,latsec,100e3);
%
% Get the mask
%
mask=mask(sub==1);
m1=griddata(londata,latdata,mask,lonsec,latsec,'nearest');
%mask(isnan(mask))=0;
%mask=mean(mask)+coef*(mask-mean(mask));
%mask(mask>0.5)=1;
%mask(mask<=0.5)=NaN;
londata=londata(mask==1);
latdata=latdata(mask==1);
%
%  Get the vertical levels
%
ncid = netcdf.open(gname, 'NC_NOWRITE');
h=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'))).';
hmin=min(min(h));
h=h(jmin:jmax,imin:imax);
netcdf.close(ncid);
h=h(sub==1);
h=h(mask==1);
%h=mean(h)+coef*(h-mean(h));
h=griddata(londata,latdata,h,lonsec,latsec,interp_type);
%
%
% Octave version (Sep-2026): hyperslab reads (0-based start/count in
% Fortran order: xi, eta, s, time) of the sub-domain, transposed to
% (eta,xi).
%
ni=imax-imin+1; nj=jmax-jmin+1;
ncid = netcdf.open(fname, 'NC_NOWRITE');
gid = netcdf.getConstant('NC_GLOBAL');
zeta=[];
for nm={'hmorph','zeta'}
  tmp=[];
  try
    vid=netcdf.inqVarID(ncid, nm{1});
    [~,~,dd]=netcdf.inqVar(ncid, vid);
    if numel(dd)==3
      tmp=double(netcdf.getVar(ncid, vid, [imin-1 jmin-1 tindex-1], [ni nj 1])).';
    else
      tmp=double(netcdf.getVar(ncid, vid, [imin-1 jmin-1], [ni nj])).';
    end
    tmp=tmp(sub==1);
    tmp=tmp(mask==1);
    tmp=griddata(londata,latdata,tmp,lonsec,latsec,interp_type);
  end
  if strcmp(nm{1},'hmorph')
    if ~isempty(tmp), h=tmp; end
  else
    zeta=tmp;
  end
end
if isempty(zeta)
  zeta=0.*h;
end
%
% s-coordinate parameters (global attributes or variables)
%
prm=struct('theta_s',[],'theta_b',[],'Tcline',[],'hc',[]);
for nm=fieldnames(prm)'
  try
    prm.(nm{1})=double(netcdf.getAtt(ncid, gid, nm{1}));
  catch
    try
      prm.(nm{1})=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, nm{1})));
    end
  end
  if ~isempty(prm.(nm{1})), prm.(nm{1})=prm.(nm{1})(1); end
end
theta_s=prm.theta_s; theta_b=prm.theta_b; Tcline=prm.Tcline; hc=prm.hc;
if ~isempty(Tcline)
  hc=min(hmin,Tcline);
end
[~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
s_coord=1;
VertCoordType='';
try
  VertCoordType=netcdf.getAtt(ncid, gid, 'VertCoordType');
end
if isempty(VertCoordType)
  try
    s_coord=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Vtransform')));
    s_coord=s_coord(1);
  end
elseif strcmp(strtrim(char(VertCoordType(:)')),'NEW')
  s_coord=2;
end
if s_coord==2 && ~isempty(Tcline)
  hc=Tcline;
end
if type=='w', ztype='w'; else, ztype='r'; end
Z=squeeze(oct_zlevs(h,zeta,theta_s,theta_b,hc,N,ztype,s_coord));
[N,Nsec]=size(Z);
VAR=0.*Z;
vid=netcdf.inqVarID(ncid, vname);
for k=1:N
  var=double(netcdf.getVar(ncid, vid, [imin-1 jmin-1 k-1 tindex-1], [ni nj 1 1])).';
  var=var(sub==1);
  var=var(mask==1);
  var=griddata(londata,latdata,var,lonsec,latsec,interp_type);
  VAR(k,:)=m1.*var;
end
netcdf.close(ncid);
dist=oct_spheric_dist(latsec(1),latsec,lonsec(1),lonsec)/1e3;
X=squeeze(oct_tridim(dist,N));
return
