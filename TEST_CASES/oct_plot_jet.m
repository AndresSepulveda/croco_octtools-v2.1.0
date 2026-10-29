%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Make a plot from the results of the JET test case
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
%  Copyright (c) 2005-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Ref: Penven, P., L. Debreu, P. Marchesiello and J.C. McWilliams,
%       Application of the ROMS embedding procedure for the Central 
%      California Upwelling System,  Ocean Modelling, 2006.
%
%  Octave version (oct_plot_jet.m, 2026): old netcdf toolbox calls replaced by
%  oct_tc_open/oct_tc_var/oct_tc_att/oct_tc_dim/oct_tc_close (octave-netcdf),
%  croco_tools functions by their oct_ versions.
%  Andres Sepulveda 2026 - Octave adaptations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%====================================================================
% User defined parameters
%
fname   = 'jet_his.nc';
tindex  = 19;
makepdf = 0;

%====================================================================
% Read variables
%====================================================================

nc=oct_tc_open(fname);
xr=1e-3*oct_tc_all(nc,'x_rho');
yr=1e-3*oct_tc_all(nc,'y_rho');
h=oct_tc_sq(oct_tc_var(nc,'h')(:,:),2,oct_tc_ndims(nc,'h'));
pm=oct_tc_sq(oct_tc_var(nc,'pm')(:,:),2,oct_tc_ndims(nc,'pm'));
pn=oct_tc_sq(oct_tc_var(nc,'pn')(:,:),2,oct_tc_ndims(nc,'pn'));
f=oct_tc_sq(oct_tc_var(nc,'f')(:,:),2,oct_tc_ndims(nc,'f'));
N=oct_tc_dim(nc,'s_rho');
tlen=length(oct_tc_all(nc,'scrum_time'));
tindex=min(tlen,tindex);
time=round(oct_tc_sq(oct_tc_var(nc,'scrum_time')(tindex),1,oct_tc_ndims(nc,'scrum_time'))/(24*3600));
disp(['Day : ',num2str(time),'  index:',num2str(tindex)])
zeta=squeeze(oct_tc_sq(oct_tc_var(nc,'zeta')(tindex,:,:),3,oct_tc_ndims(nc,'zeta')));
u=squeeze(oct_tc_sq(oct_tc_var(nc,'u')(tindex,:,:,:),4,oct_tc_ndims(nc,'u')));
v=squeeze(oct_tc_sq(oct_tc_var(nc,'v')(tindex,:,:,:),4,oct_tc_ndims(nc,'v')));
rho=squeeze(oct_tc_sq(oct_tc_var(nc,'temp')(tindex,:,:,:),4,oct_tc_ndims(nc,'temp')));
u0=squeeze(oct_tc_sq(oct_tc_var(nc,'u')(1,:,:,:),4,oct_tc_ndims(nc,'u')));
rho0=squeeze(oct_tc_sq(oct_tc_var(nc,'temp')(1,:,:,:),4,oct_tc_ndims(nc,'temp')));
oct_tc_close(nc)

[xu,xv,xp]=oct_rho2uvp(xr);  % horiz. fields
[yu,yv,yp]=oct_rho2uvp(yr);
[fu,fv,fp]=oct_rho2uvp(f);
R0=30; TCOEF=0.28;
t=(-rho+R0)./TCOEF;
t0=(-rho0+R0)./TCOEF;
sst=squeeze(t(N,:,:));
zr=oct_zlevs(h,zeta,5,0,100,N,'r');
us=squeeze(u(N,:,:));
vs=squeeze(v(N,:,:));
[vort]=oct_vorticity(us,vs,pm,pn);
vort=vort./fp;
ur=oct_u2rho_2d(squeeze(u(N,:,:)));
vr=oct_v2rho_2d(squeeze(v(N,:,:)));

XR=oct_tridim(xr,N);         % vert. sections
YR=oct_tridim(yr,N);
YU=0.5*(YR(:,:,1:end-1)+YR(:,:,2:end));
zu=0.5*(zr(:,:,1:end-1)+zr(:,:,2:end));
[M,L]=size(yr);
imid=round(L/2);
yrs=squeeze(YR(:,:,imid));
zrs=squeeze(zr(:,:,imid));
yus=squeeze(YU(:,:,imid));
zus=squeeze(zu(:,:,imid));
u0s=squeeze(u0(:,:,imid));
t0s=squeeze(t0(:,:,imid));

%====================================================================
% Plot
%====================================================================

%
%  Initial fields ......
%
figure
subplot(2,1,1)
colormap(jet)
oct_contourf(yrs,zrs,t0s,20);
caxis([9 18])
ylabel('Z [m]')
colorbar
title('Initial Temperature')
set(gca,'fontsize',15)
%
subplot(2,1,2)
oct_contourf(yus,zus,u0s,10);
caxis([-0.1 0.3])
xlabel('Y [km]')
ylabel('Z [m]')
colorbar
title('Initial Zonal Velocity')
set(gca,'fontsize',15)
if makepdf
 oct_export_fig -transparent -pdf jet_init.pdf
end

%
% Final dynamic fields .......
%
figure('position',[100 100 800 400])
%
subplot(1,3,1)  % SSH
oct_contourf(xr,yr,zeta,20);
colorbar
caxis([-1 1])
axis([0 500 0 2000])
xlabel('X [km]')
ylabel('Y [km]')
title(['SSH - day=',num2str(time)])
set(gca,'fontsize',12)
%
subplot(1,3,2)  % vort/f
colormap(jet)
oct_contourf(xp,yp,vort,20,'linestyle','none');
colorbar
caxis([-0.3 0.3])
axis([0 500 0 2000])
xlabel('X [km]')
title(['\xi/f - day=',num2str(time)])
set(gca,'fontsize',12)
%
subplot(1,3,3)  % Speed
spd=sqrt(ur.^2+vr.^2);
oct_contourf(xr,yr,spd,10,'linestyle','none'); 
hold on
quiver(xr,yr,ur,vr,3)
caxis([0 0.7])
axis([0 500 0 2000])
xlabel('X [km]')
colorbar
hold off
title(['Speed - day=',num2str(time)])
set(gca,'fontsize',12)
%
if makepdf
 oct_export_fig -transparent -pdf jet.pdf
end

%
% Time evolution of SST .......
%
if tindex>18
 nc=oct_tc_open(fname);
 lx=30; ly=15;
 figure('units','centimeters','position', ...
          [0 0 lx ly],'paperpositionmode','auto')
 tindex=[11;15;19];
 colormap(jet)
 for tndx=1:3;
  rhos=squeeze(oct_tc_sq(oct_tc_var(nc,'temp')(tindex(tndx),N,:,:),4,oct_tc_ndims(nc,'temp')));
  sst=(-rhos+R0)./TCOEF;
  if tndx==1,
   ax(1)=subplot(1,3,1);
  elseif tndx==2,
   ax(2)=subplot(1,3,2);
  elseif tndx==3,
   ax(3)=subplot(1,3,3);
  end
  oct_contourf(xr,yr,sst,20);
  if tndx==3,
    h=colorbar('eastoutside');
    set(h, 'Position', [.85 .35 .02 .3])
    for i=1:3
      pos=get(ax(i), 'Position');
      set(ax(i), 'Position', [.88*pos(1) pos(2) pos(3) pos(4)]);
    end
  end
  caxis([13 20])
  xlabel('X [km]')
  if tndx==1
   ylabel('Y [km]')
  end
  time=round(oct_tc_sq(oct_tc_var(nc,'scrum_time')(tindex(tndx)),1,oct_tc_ndims(nc,'scrum_time'))/(24*3600));
  title(['SST - day=',num2str(time)])
 end
 if makepdf
 oct_export_fig -transparent -pdf jet_multivor.pdf
 end
 oct_tc_close(nc)
end

return

