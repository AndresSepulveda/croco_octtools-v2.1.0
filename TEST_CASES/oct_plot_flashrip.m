%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Make plot from the results of the FLASH_RIP test case
% 
%  Further Information:  
%  http://www.crocoagrif.org/
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
%  Ref: Penven, P., L. Debreu, P. Marchesiello and J.C. McWilliams,
%       Application of the ROMS embedding procedure for the Central 
%      California Upwelling System,  Ocean Modelling, 2006.
%
%  Patrick Marchesiello, IRD 2025
%
%  Octave version (oct_plot_flashrip.m, 2026): old netcdf toolbox calls replaced by
%  oct_tc_open/oct_tc_var/oct_tc_att/oct_tc_dim/oct_tc_close (octave-netcdf),
%  croco_tools functions by their oct_ versions.
%  Andres Sepulveda 2026 - Octave adaptations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%================== User defined parameters ===========================
%
% --- model params ---
%
hisname     = 'rip_his.nc';
avgname     = 'rip_avg.nc';

makepdf     = 0;  % make pdf file
%
%======================================================================

% ---------------------------------------------------------------------
% --- get model grid and variables ---
% ---------------------------------------------------------------------

nc=oct_tc_open(hisname);
tindex=length(oct_tc_all(nc,'scrum_time')); % reads last record
time=oct_tc_sq(oct_tc_var(nc,'scrum_time')(tindex),1,oct_tc_ndims(nc,'scrum_time'))/60;

h=oct_tc_all(nc,'h');
xl=oct_tc_all(nc,'xl');
x=oct_tc_all(nc,'x_rho')-xl;
y=oct_tc_all(nc,'y_rho');
pm=oct_tc_all(nc,'pm');
pn=oct_tc_all(nc,'pn');
N=oct_tc_dim(nc,'s_rho');
Dcrit=oct_tc_all(nc,'Dcrit');
zeta=oct_tc_sq(oct_tc_var(nc,'zeta')(tindex,:,:),3,oct_tc_ndims(nc,'zeta'));
oct_tc_close(nc)

nc=oct_tc_open(avgname);
u=oct_tc_sq(oct_tc_var(nc,'u')(tindex-1,N,:,:),4,oct_tc_ndims(nc,'u'));
v=oct_tc_sq(oct_tc_var(nc,'v')(tindex-1,N,:,:),4,oct_tc_ndims(nc,'v'));
oct_tc_close(nc);

% Vorticity
vort=oct_psi2rho(oct_vorticity(u,v,pm,pn));

% Zeta
zeta(h<Dcrit)=zeta(h<Dcrit)-Dcrit;
mask=zeta./zeta;
% ---------------------------------------------------------------------
% --- plot ---
% ---------------------------------------------------------------------

hf = figure('position',[500 500 800 500]);
set(gca,'FontSize',15)

subplot(1,2,1)
cmin=-0.7; cmax=-cmin; cint=0.07;
nbcol=40; cint=(cmax-cmin)/nbcol;
map=colormap(jet(nbcol));
colormap(map);
zeta=max(min(zeta,cmax),cmin);
zeta(zeta==0.)=NaN;
oct_contourf(x,y,zeta,[cmin:cint:cmax],'linestyle','none'); 
colorbar;
axis([-250 -10 0 300])
caxis([cmin cmax])
title(['Sea Level'])
set(gca,'FontSize',15)

subplot(1,2,2)
cmin=-0.07; cmax=-cmin;
nbcol=20; cint=(cmax-cmin)/nbcol;
vort=max(min(vort,cmax),cmin);
vort=vort.*mask;
oct_contourf(x,y,vort,[cmin:cint:cmax],'linestyle','none'); 
colorbar;
axis([-250 -10 0 300])
caxis([cmin cmax])
title(['Wave-mean Vorticity'])
set(gca,'FontSize',15)

%----------------------------------

if makepdf, 
    set(gcf,'PaperPositionMode','auto');
    set(gcf,'color','w');
    oct_export_fig flashrip.pdf
end

return





