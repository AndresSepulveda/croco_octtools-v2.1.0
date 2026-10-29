%======================================================================
%
%     ---                 Moving Bathy Test Case               ---    
% 
%  Internal gravity waves are produced over an oscillating ridge
%  and Brunt-Vaisala frequency anomaly is compared with lab experiment 
%  (Fig. 1 in Auclair et al., 2014)
%
% Reference:
% ----------
%  Auclair et al., 2014: Implementation of a time-dependent bathymetry 
%   in a free-surface ocean model: Application to internal wave 
%   generation, Ocean Modelling, 80, 1-9.
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
%  Patrick Marchesiello - 2020
%======================================================================
clear all
close all
%================== User defined parameters ===========================

fname='movbat_his.nc';

tndx   = 49;  % output after 10 periods

makepdf= 0;
%======================================================================
%
% Read data
%
j=2;
g=9.8;
nc=oct_tc_open(fname);
time=oct_tc_all(nc,'scrum_time');
tndx=min(tndx,length(time));
disp([ 'tndx = ',num2str(tndx) ])
h=squeeze(oct_tc_sq(oct_tc_var(nc,'hmorph')(tndx,j,:),3,oct_tc_ndims(nc,'hmorph')));
x=squeeze(oct_tc_sq(oct_tc_var(nc,'x_rho')(j,:),2,oct_tc_ndims(nc,'x_rho')));
zeta=squeeze(oct_tc_sq(oct_tc_var(nc,'zeta')(tndx,j,:),3,oct_tc_ndims(nc,'zeta')));
L=length(zeta);
%
r =squeeze(oct_tc_sq(oct_tc_var(nc,'rho')(tndx,:,j,:),4,oct_tc_ndims(nc,'rho')));  % rho,u,w
r0=squeeze(oct_tc_sq(oct_tc_var(nc,'rho')(1,   :,j,:),4,oct_tc_ndims(nc,'rho')));
u =squeeze(oct_tc_sq(oct_tc_var(nc,'u')(tndx,:,j,:),4,oct_tc_ndims(nc,'u')));
w =squeeze(oct_tc_sq(oct_tc_var(nc,'w')(tndx,:,j,:),4,oct_tc_ndims(nc,'w')));
%
theta_s=oct_tc_att(nc,'theta_s');  % z grid
theta_b=oct_tc_att(nc,'theta_b');
rho0=oct_tc_att(nc,'rho0');
hc=oct_tc_att(nc,'hc');
Vtrans=oct_tc_all(nc,'Vtransform');
N=oct_tc_dim(nc,'s_rho');
oct_tc_close(nc);
%
zr=squeeze(oct_zlevs(h,zeta,theta_s,theta_b,hc,N,'r',Vtrans));
zw=squeeze(oct_zlevs(h,zeta,theta_s,theta_b,hc,N,'w',Vtrans));
zu(:,1:L-1)=0.5*(zr(:,1:L-1)+zr(:,2:L));
%
xr=repmat(x,[N 1]);
xw=repmat(x,[N+1 1]);
xu(:,1:L-1)=0.5*(xr(:,1:L-1)+xr(:,2:L));
%
% Compute Brunt-Vaisala frequency anomaly
%   bvf=-g/rho0*d(rho-rho_ini)/dz
%
r=r-r0;
bvf=zeros(size(zw)); 
bvf(2:end-1,:)=-g/rho0*( r(2:end,:)- r(1:end-1,:)) ...
                     ./(zr(2:end,:)-zr(1:end-1,:));
bvf(1,:)  =bvf(2,:);
bvf(end,:)=bvf(end-1,:);
bvf=bvf-mean(mean(bvf));
%
% Make plot
%
figure('position',[100 500 600 350]);  %  N2
colormap(gray)
oct_contourf(xw,zw,bvf,80,'linestyle','none')
hold on
line(xr,-h,'Linewidth',3)
hold off
colorbar
caxis([-0.05 0.05])
axis([-0.47 0.04 -0.4 0])
xticks([-0.4:0.1:0])
yticks([-0.4:0.1:0])
set(gca,'fontsize',15)
title(['Moving Bathy - N^2 (dx=8mm)'])
if makepdf
 oct_export_fig -transparent MovBat.pdf
end

return

%======================================================================
% Additional diagnostics
%

figure('position',[100 500 700 400]);   % Rhop
oct_contourf(xr,zr,r,20,'linestyle','none')
hold on
line(xr,-h,'Linewidth',2)
hold off
colorbar
axis([-0.5 0.5 -0.4 0])
title(['Moving Bathy - Rhop'])

figure('position',[100 500 700 400]);   %  U
oct_contourf(xu,zu,u,20,'linestyle','none')
hold on
line(xr,-h,'Linewidth',2)
hold off
colorbar
axis([-0.5 0.5 -0.4 0])
title(['Moving Bathy - U'])

if size(w,1)<size(zw,1),
 xw=xr; zw=zr;
end
figure('position',[100 500 700 400]);  %  W
oct_contourf(xw,zw,w,20,'linestyle','none')
hold on
line(xr,-h,'Linewidth',2)
hold off
colorbar
axis([-0.5 0.5 -0.4 0])
title(['Moving Bathy - W'])

tpas = 0; % tpas = 1 if passive tracer available
if tpas,
 nc=oct_tc_open(fname)
 t =squeeze(oct_tc_sq(oct_tc_var(nc,'tpas')(tndx,   :,j,:),4,oct_tc_ndims(nc,'tpas')));
 oct_tc_close(nc)
 figure('position',[100 500 700 400]);  %  TPAS
 pcolor(xr,zr,t)
 shading flat
 hold on
 colorbar
 axis([-0.5 0.5 -0.4 0])
 title(['Moving Bathy - TPAS'])
end

