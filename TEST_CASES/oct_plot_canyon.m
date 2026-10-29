%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Make plots from the results of the CANYON test case
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
%  Octave version (oct_plot_canyon.m, 2026): old netcdf toolbox calls replaced by
%  oct_tc_open/oct_tc_var/oct_tc_att/oct_tc_dim/oct_tc_close (octave-netcdf),
%  croco_tools functions by their oct_ versions.
%  Andres Sepulveda 2026 - Octave adaptations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all

makepdf=0;
tndx=3;
i=32;
%
% Read data
%
nc=oct_tc_open('canyon_his.nc');
time=oct_tc_sq(oct_tc_var(nc,'scrum_time')(tndx),1,oct_tc_ndims(nc,'scrum_time'))/86400;
h=oct_tc_all(nc,'h');
x1=oct_tc_all(nc,'x_rho');
y1=oct_tc_all(nc,'y_rho');
y=squeeze(y1(:,i));
zeta=squeeze(oct_tc_sq(oct_tc_var(nc,'zeta')(tndx,:,:),3,oct_tc_ndims(nc,'zeta')));
t=squeeze(oct_tc_sq(oct_tc_var(nc,'rho')(tndx,:,:,i),4,oct_tc_ndims(nc,'rho')));
[N,M]=size(t);
sst=squeeze(oct_tc_sq(oct_tc_var(nc,'temp')(tndx,N,:,:),4,oct_tc_ndims(nc,'temp')));
u=squeeze(oct_tc_sq(oct_tc_var(nc,'u')(tndx,N,:,:),4,oct_tc_ndims(nc,'u')));
v=squeeze(oct_tc_sq(oct_tc_var(nc,'v')(tndx,N,:,:),4,oct_tc_ndims(nc,'v')));
ur=oct_u2rho_2d(u);
vr=oct_v2rho_2d(v);
theta_s=oct_tc_att(nc,'theta_s');
theta_b=oct_tc_att(nc,'theta_b');
hc=oct_tc_att(nc,'hc');
oct_tc_close(nc);

zr = oct_zlevs(h,zeta,theta_s,theta_b,hc,N,'r');
zr=squeeze(zr(:,:,i));
yr=reshape(y,1,M);
yr=repmat(yr,[N 1])/1000;

%
% First plot
%
figure('position',[100 100 500 700])
subplot(2,1,1)
oct_contourf(yr,zr,t,[28:0.1:32])
colorbar
title(['CANYON -  \sigma_t [kg/m^3] vertical section at ',num2str(time),' days'])
caxis([28 31])
%
% Second plot
%
subplot(2,1,2)
oct_contourf(x1(2:end-1,2:end-1)/1000,y1(2:end-1,2:end-1)/1000,...
         100*zeta(2:end-1,2:end-1),[-0.5:0.1:2],'linestyle','none')
caxis([-0.1 1])
colorbar
hold on
contour(x1(2:end-1,2:end-1)/1000,y1(2:end-1,2:end-1)/1000,...
        h(2:end-1,2:end-1),'k')
hold off
title(['CANYON - sea surface elevation [cm] at ',num2str(time),' days'])

if makepdf
 oct_export_fig -transparent -pdf canyon.pdf
end

