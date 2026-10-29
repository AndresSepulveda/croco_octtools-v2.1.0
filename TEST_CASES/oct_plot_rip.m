%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Make plot from the results of the RIP test case
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
%  Patrick Marchesiello, IRD 2013,2017
%   uses QTwriter.m for creating .mov video files if desired
%
%  Octave version (oct_plot_rip.m, 2026): old netcdf toolbox calls replaced by
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
fname     = 'rip_his.nc';  % croco file name
makemovie = 0;             % make movie using QTWriter (for tidal case)
makepdf   = 0;             % make pdf file
pltvort   = 0;             % plot vort (else plot u)
%
%======================================================================

% ---------------------------------------------------------------------
% --- get grid from numerical model ---
% ---------------------------------------------------------------------

nc=oct_tc_open(fname);
tindex=length(oct_tc_all(nc,'scrum_time')); % read last record
tstr=2;
tend=tindex;

if makemovie,
 movObj = oct_QTWriter('rip.mov');
else
 tstr=tindex;
end

h=oct_tc_all(nc,'h');
x=oct_tc_all(nc,'x_rho');
y=oct_tc_all(nc,'y_rho');
pm=oct_tc_all(nc,'pm');
pn=oct_tc_all(nc,'pn');
N=oct_tc_dim(nc,'s_rho');

% min depth in wetting-drying scheme
Dcrit=oct_tc_all(nc,'Dcrit');

% initialize plot
hf = figure;
axis tight; % (DoubleBuffer: not an Octave property)
set(gca,'nextplot','replacechildren');

% ---------------------------------------------------------------------
% --- get variables and plot in time loop ---
% ---------------------------------------------------------------------

for tindex=tstr:tend  % ---

 disp(['Tindex = ',num2str(tindex)])

 time=oct_tc_sq(oct_tc_var(nc,'scrum_time')(tindex),1,oct_tc_ndims(nc,'scrum_time'))/86400;
 zeta=oct_tc_sq(oct_tc_var(nc,'zeta')(tindex,:,:),3,oct_tc_ndims(nc,'zeta'));
 u=oct_tc_sq(oct_tc_var(nc,'u')(tindex,N,:,:),4,oct_tc_ndims(nc,'u'));
 v=oct_tc_sq(oct_tc_var(nc,'v')(tindex,N,:,:),4,oct_tc_ndims(nc,'v'));
 ub=oct_tc_sq(oct_tc_var(nc,'ubar')(tindex,:,:),3,oct_tc_ndims(nc,'ubar'))+oct_tc_sq(oct_tc_var(nc,'ust2d')(tindex,:,:),3,oct_tc_ndims(nc,'ust2d'));
 vb=oct_tc_sq(oct_tc_var(nc,'vbar')(tindex,:,:),3,oct_tc_ndims(nc,'vbar'))+oct_tc_sq(oct_tc_var(nc,'vst2d')(tindex,:,:),3,oct_tc_ndims(nc,'vst2d'));

 mask=ones(size(zeta));
 mask((h+zeta)<=Dcrit)=NaN;
 ur=oct_u2rho_2d(ub);
 vr=oct_v2rho_2d(vb);
 if pltvort,
  vort=mask.*oct_psi2rho(oct_vorticity(u,v,pm,pn));
 else
  speed=mask.*ur;  
 end

 %======================================
 % --- plot ---
 %======================================

 if pltvort,
  cmin=-0.01; cmax=0.01; nbcol=10;
 else
  cmin=-0.25; cmax=0.25; nbcol=10;
 end
 cint=(cmax-cmin)/nbcol;
 map=colormap(cool(nbcol));
 colormap(map);
 set(gcf,'color','w');
 hold on

 if pltvort,
  [C,hh]=oct_contourf(x,y,vort,[cmin:cint:cmax],'linestyle','none');
 else
  [C,hh]=oct_contourf(x,y,speed,[cmin:cint:cmax],'linestyle','none');
 end
 colorbar;

 I = ~(sqrt(ur.^2+vr.^2)<0.05);
 quiver(x(I),y(I),ur(I),vr(I)); hold off
 axis([100 760 10 760])
 caxis([cmin cmax])
 thour=floor(time*24);
 title(['Rip Test Case - time = ',num2str(thour),' h'],'fontsize',14)
 xlabel('Cross-shore distance [m]','fontsize',14)
 ylabel('Along-shore distance [m]','fontsize',14)
 set(gca,'fontsize',14)
 hold off

 if makemovie,  
  % Write each frame to the file
  movObj.FrameRate =  5;
  writeMovie(movObj,getframe(hf));
  clf('reset')
 end

end % time loop -------------------------------------------------------

oct_tc_close(nc);

if makemovie,  
    movObj.Loop = 'loop'; % Set looping flag
    close(movObj);        % Finish writing movie and close file
end

if makepdf
 oct_export_fig -transparent rip.pdf
end

return





