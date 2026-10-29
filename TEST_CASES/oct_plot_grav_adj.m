%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Make 1 plot from the results of the GRAV_ADJ test case
% 
%  Further Information:  
%  http://www.brest.ird.fr/Roms_tools/
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
%  Octave version (oct_plot_grav_adj.m, 2026): old netcdf toolbox calls replaced by
%  oct_tc_open/oct_tc_var/oct_tc_att/oct_tc_dim/oct_tc_close (octave-netcdf),
%  croco_tools functions by their oct_ versions.
%  Andres Sepulveda 2026 - Octave adaptations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%================== User defined parameters ===========================
%
fname     = 'gravadj_his.nc';
tindex    = [10;20;50];    % record indices to plot
nbq       = 0;             % 0/1: hydro/nonhydro case
plot_psi  = 0;             % plot streamfunction
makepdf   = 0;             % make pdf file
%
%======================================================================

hFig = figure;
colormap('jet')
nplot=length(tindex);
set(hFig, 'Position', [200 500 700 150*nplot])

for it=1:length(tindex); % --------------- time loop

tndx=tindex(it);

% -------------------------------------
%  --- Read model data ---
% -------------------------------------
nc=oct_tc_open(fname,'r');
tndx=min(tndx,length(oct_tc_all(nc,'scrum_time')));
disp(['tndx = ',num2str(tndx)'']);
h=oct_tc_all(nc,'h');
x=squeeze(oct_tc_sq(oct_tc_var(nc,'x_rho')(2,:),2,oct_tc_ndims(nc,'x_rho')));
zeta=squeeze(oct_tc_sq(oct_tc_var(nc,'zeta')(tndx,:,:),3,oct_tc_ndims(nc,'zeta')));
t=squeeze(oct_tc_sq(oct_tc_var(nc,'temp')(tndx,:,2,:),4,oct_tc_ndims(nc,'temp')));
[N,M]=size(t);
w=1000*squeeze(oct_tc_sq(oct_tc_var(nc,'w')(tndx,1:N,2,:),4,oct_tc_ndims(nc,'w')));
theta_s=oct_tc_att(nc,'theta_s');
theta_b=oct_tc_att(nc,'theta_b');
hc=oct_tc_att(nc,'hc');
oct_tc_close(nc);

zr = oct_zlevs(h,zeta,theta_s,theta_b,hc,N,'r',2);
zr=squeeze(zr(:,2,:));
xr=reshape(x,1,M);
if nbq,
 xr=repmat(xr,[N 1]);
else
 xr=repmat(xr,[N 1])/1000 - 32;
end

psi=zeros(size(w));
for i=2:M;
  psi(:,i)=psi(:,i-1)-w(:,i).*(xr(:,i)-xr(:,i-1));
end

t(t==0)=NaN;

% -------------------------------------
%  --- Plot ---
% -------------------------------------

subplot(length(tindex),1,it)
[C,h] = oct_contourf(xr,zr,t,[10:1:40]); hold on
set(h,'LineColor','none')
if plot_psi
 hold on
 contour(xr,zr,psi,'k');
 hold off
end
if nbq,
 xlabel('X [m]')
else
 xlabel('X [km]')
end
ylabel('Depth [m]')
caxis([15 35])
colorbar
if it==1,
 title('Gravitational adjustment')
end

end % ----------------------- time loop

if makepdf
 oct_export_fig -transparent -pdf gravadj.pdf
end




