function oct_plot_nestclim(clim_file,grid_file,tracer,l)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Test the climatology and initial files.
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
%  Sections and surface plot of record l of a 3D field of a child
%  climatology / initial / restart file.
%
ncid = netcdf.open(clim_file, 'NC_NOWRITE');
gid = netcdf.getConstant('NC_GLOBAL');
vid = netcdf.inqVarID(ncid, tracer);
[~,~,dids] = netcdf.inqVar(ncid, vid);
[~,L]=netcdf.inqDim(ncid, dids(1));
[~,M]=netcdf.inqDim(ncid, dids(2));
[~,N]=netcdf.inqDim(ncid, dids(3));
var=permute(double(netcdf.getVar(ncid, vid, [0 0 0 l-1], [L M N 1])),[3 2 1]);  % (N,M,L)
vid=netcdf.inqVarID(ncid, 'u'); [~,~,d]=netcdf.inqVar(ncid, vid); [~,Lu]=netcdf.inqDim(ncid,d(1)); [~,Mu]=netcdf.inqDim(ncid,d(2));
u=double(netcdf.getVar(ncid, vid, [0 0 N-1 l-1], [Lu Mu 1 1])).';
vid=netcdf.inqVarID(ncid, 'v'); [~,~,d]=netcdf.inqVar(ncid, vid); [~,Lv]=netcdf.inqDim(ncid,d(1)); [~,Mv]=netcdf.inqDim(ncid,d(2));
v=double(netcdf.getVar(ncid, vid, [0 0 N-1 l-1], [Lv Mv 1 1])).';
try
  theta_s=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_s')));
  theta_b=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_b')));
  hc=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'hc')));
catch
  theta_s=double(netcdf.getAtt(ncid, gid, 'theta_s'));
  theta_b=double(netcdf.getAtt(ncid, gid, 'theta_b'));
  hc=double(netcdf.getAtt(ncid, gid, 'hc'));
end
try
  vtransform=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Vtransform')));
catch
  vtransform=1; %Old Vtransform
end
theta_s=theta_s(1); theta_b=theta_b(1); hc=hc(1); vtransform=vtransform(1);
netcdf.close(ncid);
%
% Grid (transposed to (eta,xi))
%
ncid = netcdf.open(grid_file, 'NC_NOWRITE');
lat  =double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'))).';
lon  =double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'))).';
pm   =double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'pm'))).';
h    =double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'))).';
angle=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'))).';
mask =double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'))).';
netcdf.close(ncid);
mask(mask==0)=NaN;
%
% Sections
%
jstep=max(1,round((M/3)-1));
image=0;
z = oct_zlevs(h,0*h,theta_s,theta_b,hc,N,'r',vtransform);
for j=1:jstep:M
  image=image+1;
  if image>4, break, end
  subplot(2,2,image)
  field=squeeze(var(:,j,:));
  topo=squeeze(h(j,:));
  mask_vert=squeeze(mask(j,:));
  dx=1./squeeze(pm(j,:));
  xrad=zeros(1,L);
  for i=2:L
    xrad(i)=xrad(i-1)+0.5*(dx(i)+dx(i-1));
  end
  x=repmat(xrad/1000,N,1);
  field=repmat(mask_vert,N,1).*field;
  pcolor(x,squeeze(z(:,j,:)),field)
  colorbar
  shading interp
  hold on
  plot(xrad/1000,-topo,'k')
  hold off
  title([tracer,' - j=',num2str(j)])
end
%
% Surface
%
figure
sst=squeeze(var(N,:,:));
[u,v,lonred,latred]=oct_uv_vec2rho(u,v,lon,lat,angle,mask,3,[0 0 0 0]);
spd=sqrt(u.^2+v.^2);
pcolor(lon,lat,mask.*sst)
shading flat
hold on
quiver(lonred,latred,u,v,'k')
hold off
axis image
colorbar
title([tracer,' surface - max speed : ',num2str(100*max(spd(:))),' cm/s'])
return
