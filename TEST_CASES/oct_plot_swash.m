%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Make plot from the results of the SHOREFACE test case
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
%  Ref: Penven, P., L. Debreu, P. Marchesiello and J.C. McWilliams,
%       Application of the CROCO embedding procedure for the Central 
%      California Upwelling System,  Ocean Modelling, 2006.
%
%  Patrick Marchesiello, IRD 2013
%
%  Octave version (oct_plot_swash.m, 2026): old netcdf toolbox calls replaced by
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
fname     = 'swash_his.nc';   % croco history file name
varname   = 'u';              % var name [ 'u' 'w' ]

makemovie = 0;                % make movie using QTWriter
makepdf   = 0;                % make pdf file
%
%======================================================================

yindex = 2;
g = 9.81;

% ---------------------------------------------------------------------
% --- get grid from numerical model ---
% ---------------------------------------------------------------------

nc=oct_tc_open(fname);
tindex=length(oct_tc_all(nc,'scrum_time')); % reads last record

if makemovie,
 movObj = oct_QTWriter('swash.mov');
 tstr=1;
 tend=tindex;
else,
 tstr=tindex;
 tend=tstr;
end

hf = figure('position',[1000 500 800 400]);
axis tight; % (DoubleBuffer: not an Octave property)
set(gca,'nextplot','replacechildren');

for tindex=tstr:tend % ---------------------------------------------
%
% horizontal grid
 hr=squeeze(oct_tc_sq(oct_tc_var(nc,'h')(yindex,:),2,oct_tc_ndims(nc,'h')));
 L=length(hr);
 xr=squeeze(oct_tc_sq(oct_tc_var(nc,'x_rho')(yindex,:),2,oct_tc_ndims(nc,'x_rho')));
 yr=squeeze(oct_tc_sq(oct_tc_var(nc,'y_rho')(yindex,:),2,oct_tc_ndims(nc,'y_rho')));
 dx=xr(2)-xr(1);
 xmin=min(xr);
 xmax=max(xr);
 Dcrit=oct_tc_all(nc,'Dcrit');
%
% vertical grid
 N=oct_tc_dim(nc,'s_rho');
 theta_s=oct_tc_att(nc,'theta_s'); 
 theta_b=oct_tc_att(nc,'theta_b'); 
 hc=oct_tc_att(nc,'hc'); 
 zeta=squeeze(oct_tc_sq(oct_tc_var(nc,'zeta')(tindex,yindex,:),3,oct_tc_ndims(nc,'zeta')));
 zr=squeeze(oct_zlevs(hr,zeta,theta_s,theta_b,hc,N,'r',2));
 zw=squeeze(oct_zlevs(hr,zeta,theta_s,theta_b,hc,N,'w',2));
 dzr=zr(2:end,:)-zr(1:end-1,:);         % ---> zw(2:N,:)
 zru=0.5*(zr(:,1:end-1)+zr(:,2:end));
 dzru=zru(2:end,:)-zru(1:end-1,:);      % ---> zwu(2:N,:)
 dzw=zw(2:end,:)-zw(1:end-1,:);         % ---> zr
 zwu=0.5*(zw(:,1:end-1)+zw(:,2:end));
 dzwu=zwu(2:end,:)-zwu(1:end-1,:);      % ---> zru
%
 xr2d=repmat(xr,[N 1]);
 D=hr+zeta;
 D2d=repmat(D,[N 1]);
%
 xmin= min(xr); xmax=90;
 zmin=-max(hr); zmax=0.4*max(hr);

 % ---------------------------------------------------------------------
 % --- read/compute numerical model fields (index 1) ---
 % ---------------------------------------------------------------------
 time=oct_tc_sq(oct_tc_var(nc,'scrum_time')(tindex),1,oct_tc_ndims(nc,'scrum_time'));

 % ... zonal velocity ...                         ---> xu,zru
 u=squeeze(oct_tc_sq(oct_tc_var(nc,'u')(tindex,:,yindex,:),4,oct_tc_ndims(nc,'u')));
 u(:,2:L-1)=0.5*(u(:,1:L-2)+u(:,2:L-1));
 u(:,1)=u(:,2);u(:,L)=u(:,L-1);

 % ... vertical velocity ...                      ---> xr,zw
 w=squeeze(oct_tc_sq(oct_tc_var(nc,'w')(tindex,2:end,yindex,:),4,oct_tc_ndims(nc,'w')));

 %=============================================================
 % --- plot ---
 %=============================================================
 
 if varname(:,1)=='u', var=u;   end
 if varname(:,1)=='w', var=w;   end

 if varname(:,1)=='u', cmin=-1.50; cmax=-cmin; nbcol=20; end % u
 if varname(:,1)=='w', cmin=-0.70; cmax=-cmin; nbcol=20; end % w
 cint=(cmax-cmin)/nbcol;

 Dcrit=Dcrit+1.e-6;
 var(D2d<Dcrit)=NaN;

 ztop=squeeze(zw(end,:,:));
 ztop(D<Dcrit+0.01)=NaN;

 map=colormap(jet(nbcol));
 map(nbcol/2  ,:)=[1 1 1];
 map(nbcol/2+1,:)=[1 1 1];
 colormap(map);
 
 oct_contourf(xr2d,zr,var,[cmin:cint:cmax],'LineStyle','none'); hold on
 colorbar;
 plot(xr,-hr,'color','k','LineWidth',3);
 hn=plot(xr,ztop,'color','r','LineWidth',2);
 grid on
 axis([xmin xmax zmin zmax])
 caxis([cmin cmax])
 tmin=floor(time/60);
 title(['SWASH: ',varname,' at ',num2str(time),' sec'])
 hold off
 set(gca,'fontsize',15);
 set(gcf,'PaperPositionMode','auto');

 if makemovie,  
  % Write each frame to the file
  movObj.FrameRate =  5;
  writeMovie(movObj,getframe(hf));
  clf('reset')
 end
%----------------------------------

end % time loop

if makemovie,  
    movObj.Loop = 'loop'; % Set looping flag
    close(movObj);        % Finish writing movie and close file
end

if makepdf
 oct_export_fig -transparent swash.pdf
end

return




