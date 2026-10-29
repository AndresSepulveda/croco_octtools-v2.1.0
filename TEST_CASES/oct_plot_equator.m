%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Make plots from the results of the EQUATOR test case
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
%  Copyright (c) 2007 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Octave version (oct_plot_equator.m, 2026): old netcdf toolbox calls replaced by
%  oct_tc_open/oct_tc_var/oct_tc_att/oct_tc_dim/oct_tc_close (octave-netcdf),
%  croco_tools functions by their oct_ versions.
%  Andres Sepulveda 2026 - Octave adaptations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%
makepdf=0;
tndx=99; 
j=17;   % middle of the basin
i=21;
%
% Read data
%
nc=oct_tc_open('equator_his.nc','r');
h=oct_tc_all(nc,'h');
x1=oct_tc_all(nc,'x_rho');
y1=oct_tc_all(nc,'y_rho');
x=squeeze(x1(j,:));
tndx=min(tndx,length(oct_tc_all(nc,'scrum_time')));
zeta=squeeze(oct_tc_sq(oct_tc_var(nc,'zeta')(tndx,:,:),3,oct_tc_ndims(nc,'zeta')));
t=squeeze(mean(oct_tc_sq(oct_tc_var(nc,'temp')(tndx,:,j:j+1,:),4,oct_tc_ndims(nc,'temp')),2));
t2=squeeze(mean(mean(oct_tc_sq(oct_tc_var(nc,'temp')(:,:,j:j+1,i:i+1),4,oct_tc_ndims(nc,'temp')),4),3));
time=oct_tc_all(nc,'scrum_time');
[N,L]=size(t);
sst=squeeze(oct_tc_sq(oct_tc_var(nc,'temp')(tndx,N,:,:),4,oct_tc_ndims(nc,'temp')));
u=oct_u2rho_2d(squeeze(oct_tc_sq(oct_tc_var(nc,'u')(tndx,N,:,:),4,oct_tc_ndims(nc,'u'))));
v=oct_v2rho_2d(squeeze(oct_tc_sq(oct_tc_var(nc,'v')(tndx,N,:,:),4,oct_tc_ndims(nc,'v'))));
theta_s=oct_tc_att(nc,'theta_s');
theta_b=oct_tc_att(nc,'theta_b');
hc=oct_tc_att(nc,'hc');
oct_tc_close(nc);
%
zr=oct_zlevs(h,zeta,theta_s,theta_b,hc,N,'r');
z2=squeeze(mean(mean(zr(:,j:j+1,i:i+1),3),2));
zr=squeeze(zr(:,j,:));
xr=reshape(x,1,L);
xr=repmat(xr,[N 1])/1e5;
%
% First plot
%
figure('position',[100 100 500 700])
%
subplot(2,1,1)
[C4,h4]=contour(1980+time/(360*24*3600),z2,t2',[4:2:30],'k');
axis([-inf inf -300 0])
clabel(C4,h4)
xlabel('Time (years)')
ylabel('Depth (m)')
title('EQUATOR - T evolution from homogeneous conditions')
%
subplot(2,1,2)
[C1,h1]=contour(xr(:,2:end-2),zr(:,2:end-2),t(:,2:end-2),[5:1:19],'k');
if isfinite(C1)
  clabel(C1,h1)
end
hold on
[C2,h2]=contour(xr(:,2:end-2),zr(:,2:end-2),t(:,2:end-2),[20 20],'r');
clabel(C2,h2)
set(h2,'LineWidth',1.5)
[C3,h3]=contour(xr(:,2:end-2),zr(:,2:end-2),t(:,2:end-2),[21:1:30],'k');
clabel(C3,h3)
axis([-inf inf -300 0])
hold off
xlabel('Longitude')
ylabel('Depth (m)')
title('EQUATOR - Temperature [^oC] Eq. section')
%
if makepdf
 oct_export_fig -transparent -pdf equator_sections.pdf
end

%
% Second plot
%
figure('position',[100 100 500 700])
%
subplot(2,1,1)
oct_contourf(x1(2:end-1,2:end-1)/1e5,y1(2:end-1,2:end-1)/1e5,...
         sst(2:end-1,2:end-1),20)
caxis([10 25])
colorbar
axis([1 39 -12 12])
xlabel('Longitude')
ylabel('Latitude')
grid on
title('EQUATOR - SST [^oC]')
%
subplot(2,1,2)
sst=100*sqrt(u.^2+v.^2);
oct_contourf(x1(2:end-1,2:end-1)/1e5,y1(2:end-1,2:end-1)/1e5,...
         sst(2:end-1,2:end-1),20,'linestyle','none')
caxis([0 150])
colorbar
hold on
quiver(x1(2:2:end-1,2:2:end-1)/1e5,y1(2:2:end-1,2:2:end-1)/1e5,...
         u(2:2:end-1,2:2:end-1),v(2:2:end-1,2:2:end-1),'k')
axis([1 39 -12 12])
xlabel('Longitude')
ylabel('Latitude')
title('EQUATOR - Speed [cm.s^{-1}]')
%
if makepdf
 oct_export_fig -transparent -pdf equator_speed.pdf
end
