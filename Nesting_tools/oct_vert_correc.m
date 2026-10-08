function oct_vert_correc(ncfile,tindex,biol,pisces,namebiol,namepisces,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Vertically reinterpolate embedded 3D variables
% when the topography (and so the sigma grid) has
% been changed
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
%  Copyright (c) 2004-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Octave version (Sep-2026): netcdf.* API of the octave-netcdf package.
%
%  Vertical corrections of the 3D fields at s_rho levels after the
%  interpolation from the parent grid: the fields interpolated on the
%  parent topography (hraw in the child grid file) are re-interpolated
%  on the s-levels of the new child topography (h), with oct_change_sigma.
%
%  All the variables with dimensions (xi,eta,s_rho,time) are corrected
%  (physics and biogeochemistry), so biol/pisces/namebiol/namepisces
%  are kept only for compatibility. tindex=[] processes all the records.
%  An optional 7th argument restricts the correction to one variable
%  (used by oct_vert_correc_onefield).
%
if nargin>=7
  onlyfield=varargin{1};
else
  onlyfield='';
end
disp(' ')
disp(' Vertical corrections... ')
ncid = netcdf.open(ncfile, 'NC_WRITE');
gid = netcdf.getConstant('NC_GLOBAL');
[~,N] = netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
%
% Vertical grid parameters (variables, or global attributes in old files)
%
try
  theta_s = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_s')));
  theta_b = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_b')));
  hc      = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'hc')));
catch
  theta_s = double(netcdf.getAtt(ncid, gid, 'theta_s'));
  theta_b = double(netcdf.getAtt(ncid, gid, 'theta_b'));
  hc      = double(netcdf.getAtt(ncid, gid, 'hc'));
end
try
  vtransform = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Vtransform')));
catch
  vtransform = 1; %Old Vtransform
  disp([' NO VTRANSFORM parameter found'])
  disp([' USE TRANSFORM default value vtransform = 1'])
end
theta_s=theta_s(1); theta_b=theta_b(1); hc=hc(1); vtransform=vtransform(1);
%
% Child grid: old (parent) topography hraw and new topography h
%
grd_file = netcdf.getAtt(ncid, gid, 'grd_file');
ng_id = netcdf.open(grd_file, 'NC_NOWRITE');
hnew  = double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'h'))).';
[Mp,Lp] = size(hnew);
hold  = double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'hraw'), [0 0 0], [Lp Mp 1])).';
lon.r = double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lon_rho'))).';
lat.r = double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lat_rho'))).';
lon.u = double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lon_u'))).';
lat.u = double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lat_u'))).';
lon.v = double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lon_v'))).';
lat.v = double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'lat_v'))).';
msk.r = double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'mask_rho'))).';
msk.u = double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'mask_u'))).';
msk.v = double(netcdf.getVar(ng_id, netcdf.inqVarID(ng_id, 'mask_v'))).';
netcdf.close(ng_id);
%
% Sea surface elevation variable (zeta or SSH), if any
%
zvid=[];
for zname={'zeta','SSH'}
  try
    zvid = netcdf.inqVarID(ncid, zname{1});
    break
  end
end
%
% Loop on the 3D variables at s_rho levels
%
[~,nvars] = netcdf.inq(ncid);
zcache_t = -1;
for v=0:nvars-1
  [vname,~,dimids] = netcdf.inqVar(ncid, v);
  if numel(dimids)~=4, continue, end
  dn = cell(1,4); dl = zeros(1,4);
  for k=1:4
    [dn{k},dl(k)] = netcdf.inqDim(ncid, dimids(k));
  end
  if ~strcmp(dn{3},'s_rho'), continue, end
  if ~isempty(onlyfield) && ~strcmp(vname,onlyfield), continue, end
  if strncmp(dn{1},'xi_u',4)
    pos='u';
  elseif strcmp(dn{2},'eta_v')
    pos='v';
  else
    pos='r';
  end
  if isempty(tindex)
    trange=1:dl(4);
  else
    trange=tindex(tindex<=dl(4));
  end
  for t=trange
    disp(['  ',vname,' - record ',num2str(t)])
%
%   zeta of the same record (0 if not available)
%
    zeta=0*hnew;
    if ~isempty(zvid)
      [~,~,zd]=netcdf.inqVar(ncid, zvid);
      [~,nz]=netcdf.inqDim(ncid, zd(end));
      if t<=nz
        zeta=double(netcdf.getVar(ncid, zvid, [0 0 t-1], [Lp Mp 1])).';
      end
    end
    zrold=oct_zlevs(hold,zeta,theta_s,theta_b,hc,N,'r',vtransform);
    zrnew=oct_zlevs(hnew,zeta,theta_s,theta_b,hc,N,'r',vtransform);
    if pos=='u'
      zold=0.5*(zrold(:,:,1:end-1)+zrold(:,:,2:end));
      znew=0.5*(zrnew(:,:,1:end-1)+zrnew(:,:,2:end));
    elseif pos=='v'
      zold=0.5*(zrold(:,1:end-1,:)+zrold(:,2:end,:));
      znew=0.5*(zrnew(:,1:end-1,:)+zrnew(:,2:end,:));
    else
      zold=zrold;
      znew=zrnew;
    end
%
%   (xi,eta,s) <-> (s,eta,xi)
%
    data=permute(double(netcdf.getVar(ncid, v, [0 0 0 t-1], [dl(1) dl(2) N 1])),[3 2 1]);
    data=oct_change_sigma(lon.(pos),lat.(pos),msk.(pos),data,zold,znew);
    netcdf.putVar(ncid, v, [0 0 0 t-1], [dl(1) dl(2) N 1], permute(data,[3 2 1]));
  end
end
netcdf.close(ncid);
return
