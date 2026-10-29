%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Make plots from the results of the BASIN test case
%
%  This is a rectangular, flat-bottomed basin with double-gyre wind forcing. 
%  When run, it produces a western boundary current flowing into a central 
%  "Gulf Stream" which goes unstable and generates eddies if resolution
%  is increased.
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
%  Copyright (c) 2002-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Octave version (oct_plot_basin.m, 2026): old netcdf toolbox calls replaced by
%  oct_tc_open/oct_tc_var/oct_tc_att/oct_tc_dim/oct_tc_close (octave-netcdf),
%  croco_tools functions by their oct_ versions.
%  Andres Sepulveda 2026 - Octave adaptations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

makepdf=0;       % make pdf file
tndx=11;
j=25;
%
% Read data
%
nc=oct_tc_open('basin_his.nc');
time=oct_tc_sq(oct_tc_var(nc,'scrum_time')(tndx),1,oct_tc_ndims(nc,'scrum_time'))/86400;
h=oct_tc_all(nc,'h');
x1=oct_tc_all(nc,'x_rho');
y1=oct_tc_all(nc,'y_rho');
x=squeeze(x1(j,:));
zeta=squeeze(oct_tc_sq(oct_tc_var(nc,'zeta')(tndx,:,:),3,oct_tc_ndims(nc,'zeta')));
t=squeeze(oct_tc_sq(oct_tc_var(nc,'temp')(tndx,:,j,:),4,oct_tc_ndims(nc,'temp')));
R0=30; TCOEF=0.28;
rho=R0-TCOEF*t;
[N,M]=size(t);
theta_s=oct_tc_att(nc,'theta_s');
theta_b=oct_tc_att(nc,'theta_b');
hc=oct_tc_att(nc,'hc');
oct_tc_close(nc);

zr=oct_zlevs(h,zeta,theta_s,theta_b,hc,N,'r');
zr=squeeze(zr(:,j,:));
xr=reshape(x,1,M);
xr=repmat(xr,[N 1])/1000;

%
% First plot
%
figure('position',[100 100 500 700])
subplot(2,1,1)
oct_contourf(xr,zr,rho,[29:0.1:30])
colorbar
caxis([29 30])
xlabel('X [km]')
ylabel('Z [m]')
title(['BASIN - \sigma_t [kg/m^3] vertical section at ',num2str(time),' days'])

%
% Second plot
%
subplot(2,1,2)
oct_contourf(x1(2:end-1,2:end-1)/1000,y1(2:end-1,2:end-1)/1000,...
         100*zeta(2:end-1,2:end-1),[-20:2:20])
caxis([-8 8])
colorbar
xlabel('X [km]')
ylabel('Y [km]')
title(['BASIN - sea surface elevation [cm] at ',num2str(time),' days'])

if makepdf
 oct_export_fig -transparent -pdf basin.pdf
end
