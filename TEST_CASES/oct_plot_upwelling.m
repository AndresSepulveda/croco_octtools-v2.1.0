%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Make 1 plot from the results of the UPWELLING test case
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
%  Octave version (oct_plot_upwelling.m, 2026): old netcdf toolbox calls replaced by
%  oct_tc_open/oct_tc_var/oct_tc_att/oct_tc_dim/oct_tc_close (octave-netcdf),
%  croco_tools functions by their oct_ versions.
%  Andres Sepulveda 2026 - Octave adaptations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

makepdf=0;
tndx=5;
nc=oct_tc_open('upwelling_avg.nc');

time=(oct_tc_sq(oct_tc_var(nc,'scrum_time')(tndx),1,oct_tc_ndims(nc,'scrum_time')))/(24*3600);
h=oct_tc_all(nc,'h');
y=squeeze(oct_tc_sq(oct_tc_var(nc,'y_rho')(:,2),2,oct_tc_ndims(nc,'y_rho')));
zeta=squeeze(oct_tc_sq(oct_tc_var(nc,'zeta')(tndx,:,:),3,oct_tc_ndims(nc,'zeta')));
t=squeeze(oct_tc_sq(oct_tc_var(nc,'temp')(tndx,:,:,2),4,oct_tc_ndims(nc,'temp')));
u=squeeze(oct_tc_sq(oct_tc_var(nc,'u')(tndx,:,:,2),4,oct_tc_ndims(nc,'u')));
[N,M]=size(t);
theta_s=oct_tc_att(nc,'theta_s');
theta_b=oct_tc_att(nc,'theta_b');
hc=oct_tc_att(nc,'hc');
oct_tc_close(nc);

zr = oct_zlevs(h,zeta,theta_s,theta_b,hc,N,'r');
zr=squeeze(zr(:,:,1));
yr=reshape(y,1,M);
yr=repmat(yr,[N 1])/1000;

oct_contourf(yr,zr,t,[9:1:20],'linestyle','none')
colorbar
caxis([10 18])
hold on
[C1,h1,]=contour(yr,zr,100*u,[-100:20:100],'k');
clabel(C1,h1)
xlabel('X [km]')
ylabel('Z [m]')
title(['UPWELLING - temp [^oC] / u [cm/s] - day = ',num2str(time)])
set(gca,'fontsize',15)
if makepdf
 oct_export_fig -transparent -pdf upwelling.pdf
end


