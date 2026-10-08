function pv = oct_ertel(fname,gname,lambda,tindex);                     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   epv    - The oct_ertel potential vorticity with respect to property 'lambda'
%
%                                       [ curl(u) + f ]
%   -  epv is given by:           EPV = --------------- . del(lambda)
%                                            rho
%
%   -  pvi,pvj,pvk - the x, y, and z components of the potential vorticity.
%
%   -  Ertel PV is calculated on horizontal rho-points, vertical w-points.
%
%   fname - The CROCO NetCDF history file.
%   gname - The CROCO NetCDF grid file.
%   lambda - The property 'lambda' above.  (Must be defined on rho-points.)
%   tindex   - The time index at which to calculate the potential vorticity.
%
% Adapted from rob hetland.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Depths
%
z_r=oct_get_depths(fname,gname,tindex,'r');
%
% Grid parameters
%
[N,M,L]=size(z_r);
ngid = netcdf.open(gname, 'NC_NOWRITE');
pm=oct_tridim(double(netcdf.getVar(ngid, netcdf.inqVarID(ngid, 'pm'))).',N);
pn=oct_tridim(double(netcdf.getVar(ngid, netcdf.inqVarID(ngid, 'pn'))).',N);
f=oct_tridim(double(netcdf.getVar(ngid, netcdf.inqVarID(ngid, 'f'))).',N);
netcdf.close(ngid);
ncid = netcdf.open(fname, 'NC_NOWRITE');
try
  rho0=double(netcdf.getAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'rho0'));
catch
  rho0=1025;
end
u=read3d(ncid,'u',tindex);
v=read3d(ncid,'v',tindex);
try
  lbd=read3d(ncid,lambda,tindex);
  if strcmp(lambda,'rho')
    lbd=lbd+1000;
  end
catch
  t=read3d(ncid,'temp',tindex);
  s=read3d(ncid,'salt',tindex);
  lbd=oct_rho_eos(t,s,z_r);
  clear t s
end
netcdf.close(ncid);
dz_r = z_r(2:end,:,:)-z_r(1:end-1,:,:);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Ertel potential vorticity, term 1: [f + (dv/dx - du/dy)]*dlambda/dz
%
% Compute d(v)/d(xi) at PSI-points.
%
dvdxi=(v(:,1:end,2:end)-v(:,1:end,1:end-1)).*...
             0.25.*(pm(:,1:end-1,2:end)+pm(:,2:end,2:end)...
                   +pm(:,1:end-1,1:end-1)+pm(:,2:end,1:end-1));
%
%  Compute d(u)/d(eta) at PSI-points.
%
dudeta=(u(:,2:end,1:end)-u(:,1:end-1,1:end)).*...
             0.25.*(pn(:,1:end-1,2:end)+pn(:,2:end,2:end)...
                   +pn(:,1:end-1,1:end-1)+pn(:,2:end,1:end-1));
%
%  Compute Ertel potential vorticity <k hat> at horizontal RHO-points and
%  vertical W-points.
%
omega = dvdxi - dudeta;
pvk = ( f(2:end,2:end-1,2:end-1)+... 
          0.125.*( omega(1:end-1,2:end,1:end-1)...
                  +omega(1:end-1,2:end,2:end)...
                  +omega(1:end-1,1:end-1,1:end-1)...
                  +omega(1:end-1,1:end-1,2:end)...
		  +omega(2:end,2:end,1:end-1)...
                  +omega(2:end,2:end,2:end)...
                  +omega(2:end,1:end-1,1:end-1)...
                  +omega(2:end,1:end-1,2:end))).*...
           (lbd(2:end,2:end-1,2:end-1)...
           -lbd(1:end-1,2:end-1,2:end-1))./...
          dz_r(:,2:end-1,2:end-1);
clear dvdxi dudeta omega 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Ertel potential vorticity, term 2: (dv/dz)*(drho/dx)
%
%  Compute d(v)/d(z) at horizontal V-points and vertical W-points
%
dvdz=(v(2:end,:,:)-v(1:end-1,:,:))./...
           (0.5.*(dz_r(:,1:end-1,:)+dz_r(:,2:end,:)));
%
%  Compute d(lambda)/d(xi) at horizontal U-points and vertical RHO-points
%
dldxi = (lbd(:,:,2:end)-lbd(:,:,1:end-1)).*...
          0.5.*(pm(:,:,2:end)+pm(:,:,1:end-1));
%
%  Add in term 2 contribution to Ertel potential vorticity <i hat>.
%
pvi =  0.5 .*(dvdz(:,2:end,2:end-1)+dvdz(:,1:end-1,2:end-1))...
     .*0.25.*( dldxi(2:end,2:end-1,1:end-1)+dldxi(2:end,2:end-1,2:end)...
              +dldxi(1:end-1,2:end-1,1:end-1)+dldxi(1:end-1,2:end-1,2:end));
clear dvdz dldxi
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Ertel potential vorticity, term 3: (du/dz)*(drho/dy)
%
%  Compute d(u)/d(z) at horizontal U-points and vertical W-points
%
dudz=(u(2:end,:,:)-u(1:end-1,:,:))./...
           (0.5.*(dz_r(:,:,1:end-1)+dz_r(:,:,2:end)));
%
%  Compute d(rho)/d(eta) at horizontal V-points and vertical RHO-points
%
dldeta = (lbd(:,2:end,:)-lbd(:,1:end-1,:)).*...
          0.5.*(pn(:,2:end,:)+pn(:,1:end-1,:));
%
%  Add in term 3 contribution to Ertel potential vorticity <j hat>.
%
pvj =  0.5 .*(dudz(:,2:end-1,2:end)+dudz(:,2:end-1,1:end-1))...
     .*0.25.*( dldeta(2:end,1:end-1,2:end-1)+dldeta(2:end,2:end,2:end-1)...
              +dldeta(1:end-1,1:end-1,2:end-1)+dldeta(1:end-1,2:end,2:end-1));
clear dudz dldeta
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sum potential vorticity components, and divide by rho0
%
pvi = -pvi./rho0;
pvj =  pvj./rho0;
pvk =  pvk./rho0;
%
pv=NaN*zeros(N+1,M,L);
pv(2:N,2:M-1,2:L-1) = pvi + pvj + pvk;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
%----------------------------------------------------------------------
%
function var=read3d(ncid,vname,tindex)
%
% Read the record tindex of a (time,s,eta,xi) variable with the
% octave-netcdf API and return it as (s,eta,xi)
%
vid=netcdf.inqVarID(ncid,vname);
[~,~,dd]=netcdf.inqVar(ncid,vid);
cnt=zeros(1,numel(dd));
for k=1:numel(dd)
  [~,cnt(k)]=netcdf.inqDim(ncid,dd(k));
end
start=zeros(1,numel(dd));
if numel(dd)==4
  start(4)=tindex-1; cnt(4)=1;
end
var=permute(double(netcdf.getVar(ncid,vid,start,cnt)),[3 2 1]);
return
