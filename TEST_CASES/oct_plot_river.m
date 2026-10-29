%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Make 1 animation from the results of the RIVER test case
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
%  Octave version (oct_plot_river.m, 2026): old netcdf toolbox calls replaced by
%  oct_tc_open/oct_tc_var/oct_tc_att/oct_tc_dim/oct_tc_close (octave-netcdf),
%  croco_tools functions by their oct_ versions.
%  Andres Sepulveda 2026 - Octave adaptations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%
floats=0;
step=2;
vname='salt';
makemovie=0;
makepdf=0;
%
% Read data
%
nc=oct_tc_open('river_his.nc','r');
tis=oct_tc_all(nc,'scrum_time');
h=oct_tc_all(nc,'h');
x=(oct_tc_all(nc,'x_rho'))/1000;
y=(oct_tc_all(nc,'y_rho'))/1000;
N=oct_tc_dim(nc,'s_rho');
mask=oct_tc_all(nc,'mask_rho');

mask(mask==0)=NaN;
[M,L]=size(x);
[I,J]=meshgrid([0:L-1],[0:M-1]);
hmax=max(max(h));
map=colormap(jet);
NCOL=length(map(:,1));

if floats==1
  nf=oct_tc_open('floats.nc','r');
  nflt=oct_tc_dim(nf,'drifter');
  hflt=0*(1:nflt);
end


if makemovie==1
  tstart=1;
else 
  tstart=length(tis);  
end

for tndx=1:length(tis)
  s=squeeze(oct_tc_sq(oct_tc_var(nc,vname)(tndx,N,:,:),4,oct_tc_ndims(nc,vname)));
  u=squeeze(oct_tc_sq(oct_tc_var(nc,'u')(tndx,N,:,:),4,oct_tc_ndims(nc,'u')));
  v=squeeze(oct_tc_sq(oct_tc_var(nc,'v')(tndx,N,:,:),4,oct_tc_ndims(nc,'v')));
  pcolor(x,y,mask.*s)
  caxis([18 36]) 
  shading flat
  colorbar
  hold on
  [C1,h1]=contour(x,y,h,[0:25:300],'k');
  u=oct_u2rho_2d(u);
  v=oct_v2rho_2d(v);
  quiver(x(1:step:end,1:step:end),y(1:step:end,1:step:end),...
         u(1:step:end,1:step:end),v(1:step:end,1:step:end),1,'k');
  axis image
  axis([0 40 0 80]) 

  if floats==1    
    for i=1:nflt
      iflt=oct_tc_sq(oct_tc_var(nf,'Xgrid')(tndx,i),2,oct_tc_ndims(nf,'Xgrid'));
      jflt=oct_tc_sq(oct_tc_var(nf,'Ygrid')(tndx,i),2,oct_tc_ndims(nf,'Ygrid'));
      zflt=-oct_tc_sq(oct_tc_var(nf,'depth')(tndx,i),2,oct_tc_ndims(nf,'depth'));
      cndx=1+(NCOL-1)*zflt/hmax;
      if cndx<1 | ~isfinite(cndx)
        cndx=1;
      end
      if cndx>NCOL
        cndx=NCOL-0.01;
      end
      z1=floor(cndx);
      z2=floor(cndx)+1;
      v1=map(z1,:);
      v2=map(z2,:);
      v=(((v1-v2)*cndx+v2.*z1-v1.*z2)./(z1-z2));
      xflt=interp2(I,J,x,iflt,jflt,'cubic');
      yflt=interp2(I,J,y,iflt,jflt,'cubic');     
      hflt(i)=plot(xflt,yflt,'.');
      set(hflt(i),'Color',v)
    end
  end

  hold off
  title(['RIVER: ',vname,' - day = ',num2str(tis(tndx)/(24*3600))])

  if makemovie==1
    MOV(tndx) = getframe;
  end  
end

oct_tc_close(nc)
if floats==1
  oct_tc_close(nf)
end

if makemovie==1
  movie(MOV,1);
end
if makepdf
 print -dpdf river_salt.pdf
 system('pdfcrop river_salt.pdf river_salt.pdf')
end

