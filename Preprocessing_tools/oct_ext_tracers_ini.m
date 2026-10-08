function oct_ext_tracers_ini(ininame,grdname,seas_datafile,ann_datafile,...
                         dataname,vname,type,tini);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% P. Marchesiello - 2005. Adapted from P. Penven's oct_ext_tracers.m 
%
%  Ext tracers in a CROCO initial file
%  take seasonal data for the upper levels and annual data for the
%  lower levels
%
%  input:
%    ininame       : CROCO initial file name
%    grdname       : CROCO grid file name    
%    seas_datafile : regular longitude - latitude - z seasonal data 
%                    file used for the upper levels  (netcdf)
%    ann_datafile  : regular longitude - latitude - z annual data 
%                    file used for the lower levels  (netcdf)
%    dataname      : variable name in data file
%    vname         : variable name in CROCO file
%    type          : position on C-grid ('r', 'u', 'v', 'p')
%    tini          : initialisation time [days]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(' ')
%
% set the value of ro (oa decorrelation scale [m]) 
% and default (value if no data)
%
ro=0;
default=NaN;
disp([' Ext tracers: ro = ',num2str(ro/1000),...
      ' km - default value = ',num2str(default)])

% Open initial file
%
%
% Initial file: vertical grid parameters
%
ncid = netcdf.open(ininame, 'NC_WRITE');
theta_s = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_s')));
theta_b = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_b')));
hc      = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'hc')));
[~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
try
  vtransform = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Vtransform')));
catch
  vtransform=1; %Old Vtransform
  disp([' NO VTRANSFORM parameter found'])
  disp([' USE TRANSFORM default value vtransform = 1'])
end
%
% Grid (netcdf.getVar gives (xi,eta): transpose to (eta,xi))
%
ng_id = netcdf.open(grdname, 'NC_NOWRITE');
lon=double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lon_rho'))).';
lat=double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lat_rho'))).';
h=double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'h'))).';
netcdf.close(ng_id);
[M,L]=size(lon);
%
% Seasonal (monthly) and annual datasets
%
ncidseas = netcdf.open(seas_datafile, 'NC_NOWRITE');
X=double(netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'X')));
Y=double(netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'Y')));
Zseas=-double(netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'Z')));
T=double(netcdf.getVar(ncidseas, netcdf.inqVarID(ncidseas, 'T'))).*30;
X=X(:); Y=Y(:); Zseas=Zseas(:); T=T(:);
tlen=length(T);
Nzseas=length(Zseas);
ncidann = netcdf.open(ann_datafile, 'NC_NOWRITE');
Zann=-double(netcdf.getVar(ncidann, netcdf.inqVarID(ncidann, 'Z')));
Zann=Zann(:);
Nz=length(Zann);
%
% Find the time index
%
ll=find(T<=tini);
if (size(ll,1) ~= 0)
 l=ll(size(ll,1));
else
 l=1;
end
disp(['   ext_tracers_ini: time index: ',num2str(l),' of total: ',num2str(tlen)])
%
% Get a subgrid
%
dl=2;
lonmin=min(min(lon))-dl;
lonmax=max(max(lon))+dl;
latmin=min(min(lat))-dl;
latmax=max(max(lat))+dl;
j=find(Y>=latmin & Y<=latmax);
i1=find(X-360>=lonmin & X-360<=lonmax);
i2=find(X>=lonmin & X<=lonmax);
i3=find(X+360>=lonmin & X+360<=lonmax);
x=cat(1,X(i1)-360,X(i2),X(i3)+360);
y=Y(j);
ilist={i1,i2,i3};
%
% Horizontal interpolation of the annual data (levels below the seasonal ones)
% data(T=1,Z=k,Y=j,X=ii): start/count in Fortran order [X Y Z T]
%
if Nz > Nzseas
  if Zseas~=Zann(1:length(Zseas)) 
    error('vertical levels dont match')
  end
  datazgrid=zeros(Nz,M,L);
  vid_ann=netcdf.inqVarID(ncidann, dataname);
  % annual file: (T,Z,Y,X) or (Z,Y,X) depending on the dataset
  [~,~,dids_ann]=netcdf.inqVar(ncidann, vid_ann);
  nd_ann=length(dids_ann);
  missval=double(netcdf.getAtt(ncidann, vid_ann, 'missing_value'));
  for k=Nzseas+1:Nz
    data=[];
    for n=[2 1 3]
      ii=ilist{n};
      if ~isempty(ii)
        tmp=double(netcdf.getVar(ncidann,vid_ann,...
                   [ii(1)-1 j(1)-1 k-1 zeros(1,nd_ann-3)],[length(ii) length(j) 1 ones(1,nd_ann-3)])).';
        if n==1, data=cat(2,tmp,data); else, data=cat(2,data,tmp); end
      end
    end
    data=oct_get_missing_val(x,y,data,missval,ro,default);
    datazgrid(k,:,:)=interp2(x,y,data,lon,lat,'cubic');
  end
end
netcdf.close(ncidann);
%
% Horizontal interpolation of the seasonal data
%
disp(['   ext_tracers_ini: horizontal interpolation of seasonal data'])
vid_seas=netcdf.inqVarID(ncidseas, dataname);
missval=double(netcdf.getAtt(ncidseas, vid_seas, 'missing_value'));
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
  data=oct_get_missing_val(x,y,data,missval,ro,default);
  datazgrid(k,:,:)=interp2(x,y,data,lon,lat,'cubic');
end
netcdf.close(ncidseas);
%
% Vertical interpolation
%
disp('   ext_tracers_ini: vertical interpolation')
zcroco=oct_zlevs(h,0.*h,theta_s,theta_b,hc,N,'r',vtransform);
if type=='u'
  zcroco=oct_rho2u_3d(zcroco);
end
if type=='v'
  zcroco=oct_rho2v_3d(zcroco);
end
[~,Mz,Lz]=size(zcroco);
zmin=min(min(min(zcroco)));
zmax=max(max(max(zcroco)));
z=Zann;
addsurf=max(z)<zmax;
addbot=min(z)>zmin;
if addsurf
 z=[100;z];
end
if addbot
 z=[z;-100000];
end
Nz=min(find(z<zmin));
z=z(1:Nz);
var=datazgrid; clear datazgrid;
if addsurf
  var=cat(1,var(1,:,:),var);
end
if addbot
  var=cat(1,var,var(end,:,:));
end
var=var(1:Nz,:,:);
var=oct_ztosigma(flip(var,1),zcroco,flipud(z));
%
% Write record 1: (N,eta,xi) -> (xi,eta,N)
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, vname), [0 0 0 0], [Lz Mz N 1], permute(var,[3 2 1]));
netcdf.close(ncid);
return
