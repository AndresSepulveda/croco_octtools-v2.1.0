%======================================================================
%
%     ---                    IGW Test Case                ---     
%     ---     Internal Gravity Wave solution over a       ---
%     ---     continental slope and shelf (COMODO test)   ---
%
% Reference:
% ----------
% Pichon, A., 2007: Tests academiques de maree, Rapport interne 
% n 21 du 19 octobre 2007, Service Hydrographique et Oceanographique 
% de la Marine.
%
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
%  Patrick Marchesiello - 2015
%======================================================================
close all
clear all
%================== User defined parameters ===========================
%
makepdf=0;
%
hname = 'igw_his.nc';

jj    = 600;      % location of validation (over the shelf)
valid = 0;        % 1: valid against forcing data
%======================================================================
%
%  Process CROCO solutions
%

nc=oct_tc_open(hname,'r');
tndx=length(oct_tc_all(nc,'scrum_time'));
h=oct_tc_all(nc,'h');
hsec=squeeze(oct_tc_sq(oct_tc_var(nc,'h')(2,:),2,oct_tc_ndims(nc,'h')));
lonu=squeeze(oct_tc_sq(oct_tc_var(nc,'lon_u')(2,:),2,oct_tc_ndims(nc,'lon_u')));
lonr=squeeze(oct_tc_sq(oct_tc_var(nc,'lon_rho')(2,:),2,oct_tc_ndims(nc,'lon_rho')));
N=oct_tc_dim(nc,'s_rho');
theta_s=oct_tc_att(nc,'theta_s'); 
theta_b=oct_tc_att(nc,'theta_b'); 
hc=oct_tc_att(nc,'hc'); 
Vtransform=oct_tc_all(nc,'Vtransform');
ssh=squeeze(oct_tc_sq(oct_tc_var(nc,'zeta')(:,2,:),3,oct_tc_ndims(nc,'zeta')));
zeta=squeeze(oct_tc_sq(oct_tc_var(nc,'zeta')(tndx,:,:),3,oct_tc_ndims(nc,'zeta')));
u=squeeze(oct_tc_sq(oct_tc_var(nc,'ubar')(:,2,:),3,oct_tc_ndims(nc,'ubar')));
v=squeeze(oct_tc_sq(oct_tc_var(nc,'vbar')(:,2,:),3,oct_tc_ndims(nc,'vbar')));
usec=squeeze(oct_tc_sq(oct_tc_var(nc,'u')(tndx,:,2,:),4,oct_tc_ndims(nc,'u')));
vsec=squeeze(oct_tc_sq(oct_tc_var(nc,'v')(tndx,:,2,:),4,oct_tc_ndims(nc,'v')));
wsec=squeeze(oct_tc_sq(oct_tc_var(nc,'w')(tndx,:,2,:),4,oct_tc_ndims(nc,'w')));
tsec=squeeze(oct_tc_sq(oct_tc_var(nc,'temp')(tndx,:,2,:),4,oct_tc_ndims(nc,'temp')));
rsec=squeeze(oct_tc_sq(oct_tc_var(nc,'rho')(tndx,:,2,:),4,oct_tc_ndims(nc,'rho')));
drsec=rsec-squeeze(oct_tc_sq(oct_tc_var(nc,'rho')(1,:,2,:),4,oct_tc_ndims(nc,'rho')));
time=oct_tc_sq(oct_tc_var(nc,'scrum_time')(tndx),1,oct_tc_ndims(nc,'scrum_time'))/86400;
oct_tc_close(nc)

zeta_u=oct_rho2u_2d(zeta);
h_u=oct_rho2u_2d(h);
z=oct_zlevs(h_u,zeta_u,theta_s,theta_b,hc,N,'r',Vtransform);
zr=oct_zlevs(h,zeta,theta_s,theta_b,hc,N,'r',Vtransform);
zsec=squeeze(z(:,2,:));
xsec=repmat(lonu,N,1);
zrsec=squeeze(zr(:,2,:));
xrsec=repmat(lonr,N,1);

%---------------------------------------------------------
%  Plot internal tides section for u,w,rhop
%---------------------------------------------------------
figure('position',[500 500 700 700])
map=colormap(jet(20));
map(10:11,:)=[1 1 1; 1 1 1];
colormap(map)

subplot(3,1,1)
oct_contourf(xsec,zsec,usec,20,'linestyle','none'); 
hold on;
colorbar
plot(lonr,-hsec,'color','k','LineWidth',3);
hold off
caxis([-0.5 0.5])
ylabel('Z [m]')
title(['IGW - U [m/s] at ',num2str(time,'%4.1f'),' days'])
set(gca,'fontsize',15)
%
subplot(3,1,2)
oct_contourf(xrsec,zrsec,wsec,20,'linestyle','none');
hold on;
colorbar
plot(lonr,-hsec,'color','k','LineWidth',3);
hold off
caxis([-0.03 0.03])
ylabel('Z [m]')
title(['IGW - W [m/s] at ',num2str(time,'%4.1f'),' days'])
set(gca,'fontsize',15)
%
subplot(3,1,3)
oct_contourf(xrsec,zrsec,drsec,20,'linestyle','none'); 
hold on;
colorbar
plot(lonr,-hsec,'color','k','LineWidth',3);
hold off
caxis([-0.05 0.05])
xlabel('Longitude')
ylabel('Z [m]')
title(['IGW - \rho_a [kg/m^3] at ',num2str(time,'%4.1f'),' days'])
set(gca,'fontsize',15)
%
if makepdf
oct_export_fig -transparent IGW.pdf
end

%================================================
%  External tides validation
%================================================

if valid==1,
 %
 % Process forcing tidal data 
 %
 omega = 2.*pi/(12.*3600);   % S2 tide
 rad=pi/180;
 disp('  ssh...')
 fname0='IGW_FILES/amp_ssh_S2.cdf';
 nc=oct_tc_open(fname0);
 ssh_amp=squeeze(oct_tc_sq(oct_tc_var(nc,'amp_ssh_S2')(1,4,:),3,oct_tc_ndims(nc,'amp_ssh_S2')));
 oct_tc_close(nc)
 fname0='IGW_FILES/pha_ssh_S2.cdf';
 nc=oct_tc_open(fname0);
 ssh_pha=squeeze(oct_tc_sq(oct_tc_var(nc,'pha_ssh_S2')(1,4,:),3,oct_tc_ndims(nc,'pha_ssh_S2')));
 oct_tc_close(nc)
 for i=1:length(t)
   sshd(i,:)=ssh_amp.*cos(omega*t(i)-rad*ssh_pha);
 end
 %  or ...
 %  nc=netcdf(fname);
 %  ssh_amp=squeeze(nc{'tide_Eamp'}(1,2,:));
 %  ssh_pha=squeeze(nc{'tide_Ephase'}(1,2,:));
 %  close(nc)
 %  for i=1:length(t)
 %    sshd(i,:)=ssh_amp.*cos(omega*t(i)-rad*ssh_pha);
 %  end
 %
 % Process U
 disp('  u...')
 fname0='IGW_FILES/amp_u_S2.cdf';
 nc=oct_tc_open(fname0);
 uamp=squeeze(oct_tc_sq(oct_tc_var(nc,'amp_u_S2')(1,4,2:end),3,oct_tc_ndims(nc,'amp_u_S2')));
 oct_tc_close(nc)
 fname0='IGW_FILES/pha_u_S2.cdf';
 nc=oct_tc_open(fname0);
 upha=squeeze(oct_tc_sq(oct_tc_var(nc,'pha_u_S2')(1,4,2:end),3,oct_tc_ndims(nc,'pha_u_S2')));;
 oct_tc_close(nc)
 for i=1:length(t)
   ud(i,:)=uamp.*cos(omega*t(i)-rad*upha);
 end
 % Process V
 disp('  v...')
 fname0='IGW_FILES/amp_v_S2.cdf';
 nc=oct_tc_open(fname0);
 vamp=squeeze(oct_tc_sq(oct_tc_var(nc,'amp_v_S2')(1,5,:),3,oct_tc_ndims(nc,'amp_v_S2')));
 oct_tc_close(nc)
 fname0='IGW_FILES/pha_v_S2.cdf';
 nc=oct_tc_open(fname0);
 vpha=squeeze(oct_tc_sq(oct_tc_var(nc,'pha_v_S2')(1,5,:),3,oct_tc_ndims(nc,'pha_v_S2')));;
 oct_tc_close(nc)
 for i=1:length(t)
   vd(i,:)=vamp.*cos(omega*t(i)-rad*vpha);
 end
 %
 % Plot comparisons
 %
 hfig=figure('position',[300,300,700,400]);
 h1=plot(t,ssh(:,jj),'b'); hold on;
 h2=plot(t,sshd(:,jj),'b--'); hold on;
 h3=plot(t,u(:,jj),'k');
 h4=plot(t,ud(:,jj),'k--');
 h5=plot(t,v(:,jj),'r');
 h6=plot(t,vd(:,jj),'r--'); hold off
 hleg1=legend([h1 h3 h5],{'ssh','u','v'});
 new_handle = copyobj(hleg1,hfig);
 legend([h1 h2],{'model','data'},'location','southeast')
 title('Barotropic tides validation')
 set(gcf,'PaperPositionMode','auto');
 if makepdf
 oct_export_fig -transparent IGW_tides.pdf
 end
end


