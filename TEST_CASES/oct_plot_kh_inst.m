%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Make plot for Kelvin-Helmholtz Instability test case (KH_INST)
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
%  Octave version (oct_plot_kh_inst.m, 2026): old netcdf toolbox calls replaced by
%  oct_tc_open/oct_tc_var/oct_tc_att/oct_tc_dim/oct_tc_close (octave-netcdf),
%  croco_tools functions by their oct_ versions.
%  Andres Sepulveda 2026 - Octave adaptations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
warning off
%================== User defined parameters ===========================
%
% --- model params ---
%
fname     = 'khinst_his.nc';  % croco file name

makemovie = 0;             % make movie using QTWriter
makepdf   = 0;             % make pdf file

%======================================================================

% ---------------------------------------------------------------------
% --- get grid from numerical model ---
% ---------------------------------------------------------------------

nc=oct_tc_open(fname,'r');
tindex=length(oct_tc_all(nc,'scrum_time')); % reads last record

if makemovie,
 tstr=1;
 tend=tindex;
 movObj = oct_QTWriter('khinst.mov');
else
 tstr=tindex;
 tend=tstr;
end

hf = figure('position',[500 500 700 500]);
set(gca,'FontSize',15)
axis tight; % (DoubleBuffer: not an Octave property)
%set(gca,'nextplot','replacechildren');

cmin=15.5; cmax=18.5; nbcol=100;

for tindex=tstr:tend % ---------------------------------------------

 if tindex==tstr
  h2d=oct_tc_sq(oct_tc_var(nc,'h')(:,:),2,oct_tc_ndims(nc,'h'));
  h=squeeze(oct_tc_sq(oct_tc_var(nc,'h')(2,:),2,oct_tc_ndims(nc,'h')));
  xl=oct_tc_all(nc,'xl');
  x=squeeze(oct_tc_sq(oct_tc_var(nc,'x_rho')(2,:),2,oct_tc_ndims(nc,'x_rho')));
  pm=squeeze(oct_tc_sq(oct_tc_var(nc,'pm')(2,:),2,oct_tc_ndims(nc,'pm')));
  N=oct_tc_dim(nc,'s_rho');
  zeta2d=squeeze(oct_tc_sq(oct_tc_var(nc,'zeta')(tindex,:,:),3,oct_tc_ndims(nc,'zeta')));
  rho=squeeze(oct_tc_sq(oct_tc_var(nc,'rho')(tindex,:,2,:),4,oct_tc_ndims(nc,'rho')));

  [N,M]=size(rho);
  theta_s=oct_tc_att(nc,'theta_s');
  theta_b=oct_tc_att(nc,'theta_b');
  hc=oct_tc_att(nc,'hc');
  z=oct_zlevs(h2d,zeta2d,theta_s,theta_b,hc,N,'r',2);
  z=squeeze(z(:,2,:));
  x=reshape(x,1,M);
  x=repmat(x,[N 1]);
 end

 time=oct_tc_sq(oct_tc_var(nc,'scrum_time')(tindex),1,oct_tc_ndims(nc,'scrum_time'))/60;
 rho=squeeze(oct_tc_sq(oct_tc_var(nc,'rho')(tindex,:,2,:),4,oct_tc_ndims(nc,'rho')));

 %============================================================
 % --- plot ---
 %=============================================================
 cint=(cmax-cmin)/nbcol;
 colormap(jet)
 set(gcf,'color','w');
 set(gca,'fontsize',15);

 [C,hh]=oct_contourf(x,z,rho,[cmin:cint:cmax],'LineStyle','none'); 
 %pcolor(x,z,rho); shading flat
 shading flat; colorbar;
 axis([0 256 -256 0])
 caxis([cmin cmax])
 thour=floor(time/60);
 tmin=floor(time)-60*thour;
 clock=[num2str(thour),' h ',num2str(tmin),' min '];
 title(['Time: ',clock],'fontsize',15)
 xlabel('X [m]')
 ylabel('Z [m]')
 disp(['Plot for time: ',clock,' (Record: ',num2str(tindex),')'])
 set(gcf,'PaperPositionMode','auto');

 if makemovie,  
  % Write each frame to the file
  movObj.FrameRate =  5;
  writeMovie(movObj,getframe(hf));
  clf('reset')
 end

%----------------------------------

end % time loop

oct_tc_close(nc);

if makemovie,  
    movObj.Loop = 'loop'; % Set looping flag
    close(movObj);        % Finish writing movie and close file
end

if makepdf, 
    oct_export_fig -transparent khinst.pdf
end

return





