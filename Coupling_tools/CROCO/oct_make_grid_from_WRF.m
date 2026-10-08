%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO grid file
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
%  Contributions of P. Marchesiello (IRD) and X. Capet (UCLA)
%
%  Updated    Aug-2006 by Pierrick Penven
%  Updated    24-Oct-2006 by Pierrick Penven (mask correction)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
crocotools_param
% WRF grid file used to create croco grid (input)
wrf_file=[RUN_dir,'/WRF_FILES/WPS_DATA/geo_em.d01.nc'];
% CROCO grid filen (output)
croco_file=[RUN_dir, '/CROCO_FILES/croco_grd.nc'];
% Refinement coefficient:
%  coef=1: CROCO grid is similar to WRF grid
%  coef=N: Each WRF cell is divided into N CROCO cells in x and y
%  Only works with odd number; otherwise rho/M points can not match
coef=1
% number of points to remove close to the boundary to avoid WRF 'sponge'
nbdy=0
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
warning off

if rem(coef,2)==0
  error('To have a perfect match coefficient need to be an odd number') 
end
%
% Title
%
disp(' ')
disp([' Origin grid: ', wrf_file])
disp(' ')
disp([' Making the grid: ',croco_file])
disp(' ')
disp([' Title: ',CROCO_title])
disp(' ')
disp([' Refine coefficient from WRF is : ',num2str(coef)])

%
% Link the GSHHS coastline private data 
% for crude, low, intermediate, high and full resolution
%
oct_make_gshhs_link ; 

%
% Get the Longitude
%
ncid = netcdf.open(wrf_file, 'NC_NOWRITE');
Lonp0=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'XLONG_C')));
Lonr0=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'XLONG_M')));
Latp0=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'XLAT_C')));
Latr0=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'XLAT_M')));
Lonp0(Lonp0<0)=Lonp0(Lonp0<0)+360;
Lonr0(Lonr0<0)=Lonr0(Lonr0<0)+360;
netcdf.close(ncid);

Lonp=zeros((coef*(size(Lonp0,1)-(nbdy+1)*2)-(coef-1)),(coef*(size(Lonp0,2)-(nbdy+1)*2)-(coef-1)));
dx = (Lonp0(1,2+nbdy:end-1-nbdy)-Lonp0(1,1+nbdy:end-2-nbdy))/coef;

for n = 1:size(Lonp,1)
    Lonp(n,1:coef:end)=Lonp0(1,2+nbdy:end-1-nbdy);
end

cpt=1;
for j = 1:coef:(size(Lonp,2)-2)
    for n = 1:coef-1
        Lonp(:,j+n)=Lonp(:,j)+n*dx(cpt);
    end
    cpt=cpt+1;
end

%
%
Latp=zeros((coef*(size(Latp0,1)-(nbdy+1)*2)-(coef-1)),(coef*(size(Latp0,2)-(nbdy+1)*2)-(coef-1)));

dy=(Latp0(2+nbdy:end-1-nbdy,1)-Latp0(1+nbdy:end-2-nbdy,1))/coef;
for n = 1:size(Latp,2)
    Latp(1:coef:end,n)=Latp0(2+nbdy:end-1-nbdy,1);
end

cpt=1;
for j = 1:coef:(size(Latp,1)-2)
    for n = 1:coef-1
        Latp(j+n,:)=Latp(j,:)+n*dy(cpt);
    end
    cpt=cpt+1;
end
%
% Make rho-grid
%

Lonr=zeros([size(Lonp,1)+1,size(Lonp,2)+1]);
Latr=zeros([size(Latp,1)+1,size(Latp,2)+1]);

[M,L]=size(Lonp);
Mp=M+1;
Lp=L+1;
Mm=M-1;
Lm=L-1;

Lonr(2:M,2:L)=0.25*(Lonp(1:Mm,1:Lm)+Lonp(1:Mm,2:L)+Lonp(2:M,1:Lm)+Lonp(2:M,2:L));
Lonr(1,:)=Lonr(2,:);
Lonr(Mp,:)=Lonr(M,:);
Lonr(:,1)=Lonr(:,2)-dx(1);
Lonr(:,Lp)=Lonr(:,L)+dx(end);

Latr(2:M,2:L)=0.25*(Latp(1:Mm,1:Lm)+Latp(1:Mm,2:L)+Latp(2:M,1:Lm)+Latp(2:M,2:L));
Latr(1,:)=Latr(2,:)-dy(1);
Latr(Mp,:)=Latr(M,:)+dy(end);
Latr(:,1)=Latr(:,2);
Latr(:,Lp)=Latr(:,L);

Lonu=oct_rho2u_2d(Lonr);
Lonv=oct_rho2v_2d(Lonr);
Latu=oct_rho2u_2d(Latr);
Latv=oct_rho2v_2d(Latr);


%
% Create the grid file
%
disp(' ')
disp(' Create the grid file...')
[M,L]=size(Latp);
disp([' LLm = ',num2str(L-1)])
disp([' MMm = ',num2str(M-1)])
oct_create_grid(L,M,croco_file,CROCO_title)
%
% Fill the grid file
%
disp(' ')
disp(' Fill the grid file...')
ncid = netcdf.open(croco_file, 'NC_WRITE');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat_u'), Latu);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon_u'), Lonu);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat_v'), Latv);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon_v'), Lonv);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'), Latr);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'), Lonr);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat_psi'), Latp);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon_psi'), Lonp);
netcdf.close(ncid);
disp(' ')
disp(' Compute the metrics...')
[pm,pn,dndx,dmde]=oct_get_metrics(croco_file);
xr=0.*pm;
yr=xr;
for i=1:L
  xr(:,i+1)=xr(:,i)+2./(pm(:,i+1)+pm(:,i));
end
for j=1:M
  yr(j+1,:)=yr(j,:)+2./(pn(j+1,:)+pn(j,:));
end
[xu,xv,xp]=oct_rho2uvp(xr);
[yu,yv,yp]=oct_rho2uvp(yr);
dx=1./pm;
dy=1./pn;
dxmax=max(max(dx/1000));
dxmin=min(min(dx/1000));
dymax=max(max(dy/1000));
dymin=min(min(dy/1000));
disp(' ')
disp([' Min dx=',num2str(dxmin),' km - Max dx=',num2str(dxmax),' km'])
disp([' Min dy=',num2str(dymin),' km - Max dy=',num2str(dymax),' km'])
%
%  Angle between XI-axis and the direction
%  to the EAST at RHO-points [radians].
%
angle=oct_get_angle(Latu,Lonu);
%
%  Coriolis parameter
%
f=4*pi*sin(pi*Latr/180)/(24*3600);
%
% Fill the grid file
%
disp(' ')
disp(' Fill the grid file...')
ncid = netcdf.open(croco_file, 'NC_WRITE');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'pm'), pm);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'pn'), pn);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'dndx'), dndx);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'dmde'), dmde);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'x_u'), xu);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'y_u'), yu);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'x_v'), xv);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'y_v'), yv);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'x_rho'), xr);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'y_rho'), yr);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'x_psi'), xp);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'y_psi'), yp);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'angle'), angle);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'f'), f);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'spherical'), 'T');
netcdf.close(ncid);
%
%
%  Add topography from topofile
%
disp(' ')
disp(' Add topography...')
h=oct_add_topo(croco_file,topofile);

%
% Compute the mask
%
%nc=oct_netcdf(wrf_file);
%maskr0=squeeze(nc{'LANDMASK'}(1,:,:));

%maskr=zeros(size(Lonr,1),size(Lonr,2));
%size(maskr)
%size(maskr0)
%[Mp,Lp]=size(maskr0);
%[igrd_r,jgrd_r]=meshgrid((3:1:Lp+2),(3:1:Mp+2));
%irchild=(1:1/coef:Lp+3);
%jrchild=(1:1/coef:Mp+3);
%[ichildgrd_r,jchildgrd_r]=meshgrid(irchild,jrchild);
%maskr_coarse=interp2(igrd_r,jgrd_r,maskr0,ichildgrd_r,jchildgrd_r,'nearest');
%maskr_coarse(1:10,4)
% To avoid some problem at the boundaries
%maskr_coarse(1,:)=maskr_coarse(2,:);
%maskr_coarse(end,:)=maskr_coarse(end-1,:);
%maskr_coarse(:,1)=maskr_coarse(:,2);
%maskr_coarse(:,end)=maskr_coarse(:,end-1);
%
%maskr(2:end-1,2:end-1)=oct_get_embeddedmask(maskr_coarse,h(2:end-1,2:end-1),coef,0);


%maskr(:,1)=maskr(:,2);
%maskr(:,end)=maskr(:,end-1);

%maskr(1,:)=maskr(2,:);
%maskr(end,:)=maskr(end-1,:);
%maskr2=maskr;

%maskr(maskr2==0)=1;
%maskr(maskr2==1)=0;
%clear mask
%clone(nc)


maskr=h>0;
maskr=oct_process_mask(maskr);
%
[masku,maskv,maskp]=oct_uvp_mask(maskr);
%
%  Write it down
%
ncid = netcdf.open(croco_file, 'NC_WRITE');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'h'), h);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'mask_u'), masku);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'mask_v'), maskv);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'mask_psi'), maskp);
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'), maskr);
netcdf.close(ncid);
%
% Create the coastline
%
if ~isempty(coastfileplot)
  oct_make_coast(croco_file,coastfileplot);
end
%
r=input('Do you want to use editmask ? y,[n]','s');
if strcmp(r,'y')
  disp(' Editmask:')
  disp(' Edit manually the land mask.')
  disp(' Press enter when finished.')
  disp(' ')
  if ~isempty(coastfileplot)
    fig_em=oct_editmask(croco_file,coastfilemask);
  else
    fig_em=oct_editmask(croco_file);
  end
  disp(' Close the Editmask window to finalize the grid...');
  if ~isempty(fig_em) && ishghandle(fig_em)
    waitfor(fig_em);   % Octave: the script continues when the window is closed
  end
end
%
close all
%
%  Smooth the topography
%
ncid = netcdf.open(croco_file, 'NC_WRITE');
h=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'));
maskr=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'));
%
h=oct_smoothgrid(h,maskr,hmin,hmax_coast,hmax,...
                        rtarget,n_filter_deep_topo,n_filter_final);
%
%  Write it down
%
disp(' ')
disp(' Write it down...')
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'h'), h);
netcdf.close(ncid);
%
% make a plot
%
if makeplot==1
  disp(' ')
  disp(' Do a plot...')
  themask=ones(size(maskr));
  themask(maskr==0)=NaN;
  domaxis=[min(min(Lonr)) max(max(Lonr)) min(min(Latr)) max(max(Latr))];
  colaxis=[min(min(h)) max(max(h))];
  oct_fixcolorbar([0.25 0.05 0.5 0.03],colaxis,...
              'Topography',10)
  width=1;
  height=0.8;
  subplot('position',[0. 0.14 width height])
  m_proj('mercator',...
         'lon',[domaxis(1) domaxis(2)],...
         'lat',[domaxis(3) domaxis(4)]);
  m_pcolor(Lonr,Latr,h.*themask);
  shading flat
  caxis(colaxis)
  hold on
  [C1,h1]=m_contour(Lonr,Latr,h,[hmin 100 200 500 1000 2000 4000],'k');
  clabel(C1,h1,'LabelSpacing',1000,'Rotation',0,'Color','r')
  if ~isempty(coastfileplot)
    m_usercoast(coastfileplot,'color','r');
    %m_usercoast(coastfileplot,'speckle','color','r');
  else
    m_gshhs_l('color','r');
    m_gshhs_l('speckle','color','r');
  end
  m_grid('box','fancy',...
         'xtick',5,'ytick',5,'tickdir','out',...
         'fontsize',7);
  hold off
end

