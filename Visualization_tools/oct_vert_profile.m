function oct_vert_profile(hisfile,gridfile,lon0,lat0,vname,tindex,coef,Yorig)
% OCT_VERT_PROFILE: oct_ prefixed copy of vert_profile using oct_ helpers

if nargin < 1
  error('You must specify a file name')
end
if nargin < 2
  gridfile=hisfile;
  disp(['Default grid name: ',gridfile])
end
if nargin < 3
  lon0=[];
end
if nargin < 4
  lat0=[];
end
if nargin < 5
  vname='temp';
  disp(['Default variable to plot: ',vname])
end
if nargin < 6
  tindex=1;
  disp(['Default time index: ',num2str(tindex)])
end
if nargin < 7
  coef=1;
  disp(['Default coef: ',num2str(coef)])
end
if nargin < 8
  Yorig=NaN;
end

% Get default values
if isempty(gridfile)
  gridfile=hisfile;
end
if vname(1)=='u'
  [lat,lon,mask]=oct_read_latlonmask(gridfile,'u');
elseif vname(1)=='v'
  [lat,lon,mask]=oct_read_latlonmask(gridfile,'v');
else
  [lat,lon,mask]=oct_read_latlonmask(gridfile,'r');
end
if isempty(lon0) | isempty(lat0)
  lat0=mean(mean(lat));
  lon0=mean(mean(lon));
end

% Find j,i indices for the profile
disp(['lon0 = ',num2str(lon0),' - lat0 = ',num2str(lat0)])
[J,I]=find((lat(1:end-1,1:end-1)<=lat0 & lat(2:end,2:end)>lat0 &...
            lon(2:end,1:end-1)<=lon0 & lon(1:end-1,2:end)>lon0)==1);
if isempty(I) |  isempty(J)
  disp('Warning: profile place not found')
  [M,L]=size(lon);
  I=round(L/2);
  J=round(M/2);
end
disp(['I = ',int2str(I),' J = ',int2str(J)])
lon1=lon(J,I);
lat1=lat(J,I);
disp(['lon1 = ',num2str(lon1),' - lat1 = ',num2str(lat1)])
%
% Octave version (Sep-2026): point hyperslab reads with the octave-netcdf
% API (local function slab), s-coordinate parameters from the global
% attributes or the variables (local function scoord).
%
ngid = netcdf.open(gridfile,'NC_NOWRITE');
try
  h_full = double(netcdf.getVar(ngid,netcdf.inqVarID(ngid,'h'))).';
catch
  netcdf.close(ngid);
  error(['h not found in ',gridfile])
end
netcdf.close(ngid);
[Mr,Lr]=size(h_full);
if vname(1)=='u'
  ir=I:min(I+1,Lr); jr=J;
elseif vname(1)=='v'
  ir=I; jr=J:min(J+1,Mr);
else
  ir=I; jr=J;
end
iu=max(I-1,1):I; jv=max(J-1,1):J;
ncid = netcdf.open(hisfile,'NC_NOWRITE');
try
  zeta = mean(mean(slab(ncid,'zeta',tindex,[],jr,ir)));
catch
  zeta = 0;
end
h = mean(mean(h_full(jr,ir)));
[theta_s,theta_b,hc,Nr,s_coord]=scoord(ncid,h_full);
if vname(1)=='*'
  switch vname
    case {'*Ke','*Speed'}
      u=mean(reshape(slab(ncid,'u',tindex,[],J,iu),[],numel(iu)),2);
      v=mean(reshape(slab(ncid,'v',tindex,[],jv,I),[],numel(jv)),2);
      if strcmp(vname,'*Ke')
        var=coef.*0.5.*(u.^2+v.^2);
      else
        var=coef.*sqrt(u.^2+v.^2);
      end
    case '*Rho'
      temp=slab(ncid,'temp',tindex,[],J,I);
      salt=slab(ncid,'salt',tindex,[],J,I);
      z=squeeze(oct_zlevs(h,zeta,theta_s,theta_b,hc,Nr,'r',s_coord));
      var=coef*oct_rho_eos(temp(:),salt(:),z(:));
    case '*Rho_pot'
      var=coef*oct_rho_pot(slab(ncid,'temp',tindex,[],J,I),slab(ncid,'salt',tindex,[],J,I));
    case '*Chla'
      var=coef*0.020*(slab(ncid,'SPHYTO',tindex,[],J,I)+...
                      slab(ncid,'LPHYTO',tindex,[],J,I))*6.625*12.;
      var(var<=0)=NaN;
    otherwise
      disp('Sorry not implemented yet')
      netcdf.close(ncid);
      return
  end
else
  try
    var=coef*slab(ncid,vname,tindex,[],J,I);
  catch
    netcdf.close(ncid);
    error(['Variable ',vname,' not found in ',hisfile])
  end
end
var=var(:);
N=length(var);
if N==Nr+1
  type='w';
else
  type='r';
end
Z=squeeze(oct_zlevs(h,zeta,theta_s,theta_b,hc,Nr,type,s_coord));
netcdf.close(ncid)
[day,month,year,imonth,thedate]=...
  oct_get_date(hisfile,tindex,Yorig);
plot(var,Z(:),'k')
hold on
plot(var,Z(:),'r.')
hold off
ylabel('Depth [m]')
xlabel([vname,' - ',thedate])
oct_savefig('install',gcf);   % File > Save (As): extension follows the format
return
%
%----------------------------------------------------------------------
%
function v=slab(ncid,name,trange,krange,jrange,irange)
%
% Octave-netcdf hyperslab read of a CROCO variable. The ranges are
% contiguous 1-based index vectors in CDL order (time, s, eta, xi);
% [] means the whole dimension. The result is returned in CDL order
% (time,s,eta,xi) without the missing dimensions, then squeezed.
%
vid=netcdf.inqVarID(ncid,name);
[~,~,dd]=netcdf.inqVar(ncid,vid);
nd=numel(dd);
dn=cell(1,nd); dl=zeros(1,nd);
for k=1:nd
  [dn{k},dl(k)]=netcdf.inqDim(ncid,dd(k));
end
start=zeros(1,nd); count=dl;
for k=1:nd
  if k==1
    r=irange;
  elseif k==2
    r=jrange;
  elseif strncmp(dn{k},'s_',2)
    r=krange;
  else
    r=trange;
  end
  if ~isempty(r)
    start(k)=r(1)-1; count(k)=numel(r);
  end
end
v=double(netcdf.getVar(ncid,vid,start,count));
if nd>1
  v=permute(v,nd:-1:1);
end
v=squeeze(v);
return
%
%----------------------------------------------------------------------
%
function [theta_s,theta_b,hc,Nr,s_coord]=scoord(ncid,h)
%
% s-coordinate parameters: global attributes (CROCO outputs) or
% variables (croco_tools files)
%
gid=netcdf.getConstant('NC_GLOBAL');
prm=struct('theta_s',[],'theta_b',[],'Tcline',[],'hc',[]);
for nm=fieldnames(prm)'
  try
    prm.(nm{1})=double(netcdf.getAtt(ncid,gid,nm{1}));
  catch
    try
      prm.(nm{1})=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,nm{1})));
    end
  end
  if ~isempty(prm.(nm{1})), prm.(nm{1})=prm.(nm{1})(1); end
end
theta_s=prm.theta_s; theta_b=prm.theta_b; hc=prm.hc;
if ~isempty(prm.Tcline)
  hc=min(min(min(h)),prm.Tcline);
end
[~,Nr]=netcdf.inqDim(ncid,netcdf.inqDimID(ncid,'s_rho'));
s_coord=1;
VertCoordType='';
try
  VertCoordType=netcdf.getAtt(ncid,gid,'VertCoordType');
end
if isempty(VertCoordType)
  try
    s_coord=double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'Vtransform')));
    s_coord=s_coord(1);
  end
elseif strcmp(strtrim(char(VertCoordType(:)')),'NEW')
  s_coord=2;
end
if s_coord==2 && ~isempty(prm.Tcline)
  hc=prm.Tcline;
end
return
