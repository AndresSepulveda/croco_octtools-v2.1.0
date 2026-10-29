%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Make 1 plot from the results of the SEAMOUNT test case
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
%  Octave version (oct_plot_seamount.m, 2026): old netcdf toolbox calls replaced by
%  oct_tc_open/oct_tc_var/oct_tc_att/oct_tc_dim/oct_tc_close (octave-netcdf),
%  croco_tools functions by their oct_ versions.
%  Andres Sepulveda 2026 - Octave adaptations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
makepdf=0;
tndx=6;
N=1;

nc=oct_tc_open('seamount_his.nc','r');
time=(oct_tc_sq(oct_tc_var(nc,'scrum_time')(tndx),1,oct_tc_ndims(nc,'scrum_time')))/(24*3600);
h=oct_tc_all(nc,'h');
x=oct_tc_all(nc,'x_rho')/1000;
y=oct_tc_all(nc,'y_rho')/1000;
u=squeeze(oct_tc_sq(oct_tc_var(nc,'u')(tndx,N,:,:),4,oct_tc_ndims(nc,'u')));
v=squeeze(oct_tc_sq(oct_tc_var(nc,'v')(tndx,N,:,:),4,oct_tc_ndims(nc,'v')));
oct_tc_close(nc);
spd=1000*sqrt( oct_u2rho_2d(u).^2+oct_v2rho_2d(v).^2);
oct_contourf(x,y,spd,[0:0.5:5],'linestyle','none')
axis image
axis([0 500 0 500])
caxis([0 3])
xlabel('X [km]')
ylabel('Y [km]')
hold on
contour(x,y,h,[1000:500:4000],'k')
colorbar
hold off
set(gca,'fontsize',15)
title(['SEAMOUNT - bottom speed [mm/s] - day = ',num2str(time,'%4.1f')], ...
       'fontsize',14)
if makepdf
 oct_export_fig -transparent -pdf seamount.pdf
end


