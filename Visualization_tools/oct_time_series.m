function oct_time_series(hisfile,gridfile,lon0,lat0,vname,vlevel,coef)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% oct_time_series: copy of time_series with oct_ prefix
%
% Defaults values
%
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
  vlevel=-10;
  disp(['Default vertical level: ',num2str(vlevel)])
end
if nargin < 7
  coef=1;
  disp(['Default coef: ',num2str(coef)])
end
%
% Get default values
%
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
%
% Find j,i indices for the profile
%
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
ncid = netcdf.open(hisfile,'NC_NOWRITE');
ngid = netcdf.open(gridfile,'NC_NOWRITE');
h_full = double(netcdf.getVar(ngid,netcdf.inqVarID(ngid,'h'))).';
netcdf.close(ngid)
[Mr,Lr]=size(h_full);
if vname(1)=='u'
  ir=I:min(I+1,Lr); jr=J;
elseif vname(1)=='v'
  ir=I; jr=J:min(J+1,Mr);
else
  ir=I; jr=J;
end
iu=max(I-1,1):I; jv=max(J-1,1):J;       % u,v points around a rho point
is2d=0;
if vname(1)~='*'
  try
    [~,~,dd]=netcdf.inqVar(ncid,netcdf.inqVarID(ncid,vname));
  catch
    netcdf.close(ncid);
    error(['Variable ',vname,' not found in ',hisfile])
  end
  is2d=(numel(dd)<=3);
end
if is2d
  var = coef*slab(ncid,vname,[],[],J,I);
elseif vlevel>0
  switch vname
    case {'*Ke','*Speed'}
      u = mean(reshape(slab(ncid,'u',[],vlevel,J,iu),[],numel(iu)),2);
      v = mean(reshape(slab(ncid,'v',[],vlevel,jv,I),[],numel(jv)),2);
      if strcmp(vname,'*Ke')
        var = coef.*0.5.*(u.^2+v.^2);
      else
        var = coef.*sqrt(u.^2+v.^2);
      end
    case '*Rho_pot'
      var = coef*oct_rho_pot(slab(ncid,'temp',[],vlevel,J,I),slab(ncid,'salt',[],vlevel,J,I));
    case '*Chla'
      var = coef*0.020*(slab(ncid,'SPHYTO',[],vlevel,J,I)+...
                        slab(ncid,'LPHYTO',[],vlevel,J,I))*6.625*12.;
      var(var<=0)=NaN;
    otherwise
      if vname(1)=='*'
        disp('Sorry not implemented yet')
        netcdf.close(ncid);
        return
      end
      var = coef*slab(ncid,vname,[],vlevel,J,I);
  end
else
%
% z-level: interpolation of the profile at each time step
%
  try
    zeta = mean(reshape(slab(ncid,'zeta',[],[],jr,ir),[],numel(jr)*numel(ir)),2);
  catch
    zeta = [];
  end
  h = mean(mean(h_full(jr,ir)));
  [theta_s,theta_b,hc,Nr,s_coord]=scoord(ncid,h_full);
  switch vname
    case {'*Ke','*Speed'}
      u = mean(slab(ncid,'u',[],[],J,iu),3);
      v = mean(slab(ncid,'v',[],[],jv,I),3);
      if strcmp(vname,'*Ke')
        var2 = coef.*0.5.*(u.^2+v.^2);
      else
        var2 = coef.*sqrt(u.^2+v.^2);
      end
    case '*Rho_pot'
      var2 = coef*oct_rho_pot(slab(ncid,'temp',[],[],J,I),slab(ncid,'salt',[],[],J,I));
    case '*Chla'
      var2 = coef*0.020*(slab(ncid,'SPHYTO',[],[],J,I)+...
                         slab(ncid,'LPHYTO',[],[],J,I))*6.625*12.;
      var2(var2<=0)=NaN;
    otherwise
      if vname(1)=='*'
        disp('Sorry not implemented yet')
        netcdf.close(ncid);
        return
      end
      if numel(ir)>1 || numel(jr)>1
        var2 = coef*slab(ncid,vname,[],[],J,I);
      else
        var2 = coef*slab(ncid,vname,[],[],jr,ir);
      end
  end
  if isvector(var2), var2=var2(:).'; end      % one time step
  [T,N]=size(var2);
  if isempty(zeta), zeta=zeros(T,1); end
  if N==Nr+1
    type='w';
  else
    type='r';
  end
  var=NaN(1,T);
  for l=1:T
    Z=squeeze(oct_zlevs(h,zeta(l),theta_s,theta_b,hc,Nr,type,s_coord));
    var(l)=interp1(Z(:),var2(l,:).',vlevel);
  end
end
time=[];
for nm={'scrum_time','time','ocean_time'}
  try
    time = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,nm{1})))/(24*3600);
    break
  end
end
netcdf.close(ncid)
if isempty(time), time=1:numel(var); end
plot(time,var,'k')
hold on
plot(time,var,'r.')
hold off
xlabel('Time [days]')
if is2d
  ylabel([vname])
elseif vlevel>0
  ylabel([vname,' - level = ',num2str(vlevel)])
else
  ylabel([vname,' - z = ',num2str(vlevel)])
end
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
