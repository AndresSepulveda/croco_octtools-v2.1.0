%======================================================================
%
%     ---               Sed toy consolid Test Case                ---     
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
%  Patrick Marchesiello - 2012
%======================================================================
clear all
close all
%================== User defined parameters ===========================

fname='sed_toy_consolid_his.nc';

%======================================================================
%
% Read data
%

idy=1;
idx=1;
depth=20; % 20m water column depth
beddepth=0.041; %  4cm sediment depth
srho=2650; % rho sediment classes
nl=41; % 41 sediment layer
a=1; % to compute The equilibrium bulk critical stress for the erosion profile
slope=2;
offset=3.4;
masslayer0=0;

days=[0.5 2 32 38];
tplot=[7 25 385 457]; % record to plot
ntplot=size(tplot,2);

%
nc=oct_tc_open(fname);

h=squeeze(oct_tc_sq(oct_tc_var(nc,'h')(idy,idx),2,oct_tc_ndims(nc,'h')));
bostr=squeeze(oct_tc_sq(oct_tc_var(nc,'bostr')(:,idy,idx),3,oct_tc_ndims(nc,'bostr')));

T=squeeze(oct_tc_sq(oct_tc_var(nc,'scrum_time')(:,:),2,oct_tc_ndims(nc,'scrum_time')))/86400;
[nt,t0]=size(T);

zbed=zeros(nl,4);
taucb=zeros(nl,4);
bedtaucrit=zeros(nl,4);
for it0 =1:ntplot
  itime=tplot(it0);
  bedthick=squeeze(oct_tc_sq(oct_tc_var(nc,'bed_thick')(itime,:,idy,idx),4,oct_tc_ndims(nc,'bed_thick')));
  NL=size(bedthick,1);
  fracs1=squeeze(oct_tc_sq(oct_tc_var(nc,'bed_frac_sand_01')(itime,:,idy,idx),4,oct_tc_ndims(nc,'bed_frac_sand_01')));
  fracs2=squeeze(oct_tc_sq(oct_tc_var(nc,'bed_frac_sand_02')(itime,:,idy,idx),4,oct_tc_ndims(nc,'bed_frac_sand_02')));
  fracm1=squeeze(oct_tc_sq(oct_tc_var(nc,'bed_frac_mud_01')(itime,:,idy,idx),4,oct_tc_ndims(nc,'bed_frac_mud_01')));
  fracm2=squeeze(oct_tc_sq(oct_tc_var(nc,'bed_frac_mud_02')(itime,:,idy,idx),4,oct_tc_ndims(nc,'bed_frac_mud_02')));

  %The instantaneous profile of bulk critical stress for erosion
  bedtaucrit(:,it0)=squeeze(oct_tc_sq(oct_tc_var(nc,'bed_tau_crit')(itime,:,idy,idx),4,oct_tc_ndims(nc,'bed_tau_crit')));

  %The equilibrium bulk critical stress for the erosion profile
  masslayer=zeros(nl,1);
  for k = 1:nl;
    masslayer(k)=srho*fracs1(k)*bedthick(k)+srho*fracs2(k)*bedthick(k)+srho*fracm1(k)*bedthick(k)+srho*fracm2(k)*bedthick(k);
  end

  massdepth=[masslayer0;cumsum(masslayer(2:end))];
  taucb(:,it0)=a*exp( (log(massdepth) - offset )/slope);

  zbed0=[-beddepth;-beddepth+cumsum(flipud(bedthick(2:end,:)),1)];
  zbed(:,it0)=flipud(zbed0)*100; %cm

end

oct_tc_close(nc);


%----------------------------------------------------------
%  Plot 
%----------------------------------------------------------
figure('Position',[1 1 1100 800])


subplot(2,4,[1 2 3 4])


% bostr
plot(T,bostr,'linewidth',1)
title('Sequence of depth-limited erosion, deposition, and compaction')
ylabel('Bottom stress (Pa)','fontsize',12);
xlabel('Days');
hold on
plot(T(tplot),bostr(tplot),'r*');
grid on

for it0 =1:ntplot
  itime=tplot(it0);

  subplot(2,4,it0+4)

  % zbed vs bed_tau_crit
  % to plot The critical stress for the erosion profile
  plot(squeeze(bedtaucrit(:,it0)),zbed(:,it0))
  hold on

  % to plot The equilibrium bulk critical stress for the erosion profile
  plot(squeeze(taucb(:,it0)),zbed(:,it0))
  xlim([0 1.5])
  ylim([-2.5 0])
  if it0==1
    ylabel(sprintf('Z(cm) vs \n Critical shear stress for erosion (N/m2)'),'fontsize',12);
  end
  xlabel([num2str(days(it0)),' days']);

  oct_yline(zbed(:,it0),'--')
  hold off
  grid on
end

set(gcf,'PaperPositionMode','auto');

oct_export_fig -transparent sed_toy_consolid.pdf


return

