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
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
wstate_=warning('off','all');
isoctave=(exist('OCTAVE_VERSION','builtin')~=0);

%
% Title
%
disp(' ')
disp([' Making the grid: ',grdname])
disp(' ')
disp([' Title: ',CROCO_title])
disp(' ')
disp([' Resolution: 1/',num2str(1/dl),' deg'])

%
% Link the GSHHS coastline private data 
% for crude, low, intermediate, high and full resolution
%
oct_make_gshhs_link ; 

%
% Choose interactive tool for making grid (rotated grid)
%
r='n';
%
% In Octave the interactive tools need the qt graphics toolkit
% (octave with GUI or octave --no-gui, not octave-cli)
%
has_gui=(isoctave==0);
if isoctave
  has_gui=any(strcmp(available_graphics_toolkits(),'qt'));
  if has_gui, graphics_toolkit('qt'); end
end
if has_gui
disp(' ')
r=input(sprintf([' Do you want to use interactive grid maker ?', ...
         '\n (e.g., for grid rotation or parameter adjustments) : y,[n] ']),'s');
end

if strcmp(r,'y')

 disp(' ')
 disp(' Use Easy interactive grid maker:')
 fig_easy=oct_easy;
 disp(' Update grid and click "Apply" in "Easy" window')
 disp(' (-> new parameters will be saved in easy_grid_params.mat)')
 disp(' ... oct_make_grid goes on when the "Easy" window is closed');
 if ~isempty(fig_easy) && ishghandle(fig_easy)
   waitfor(fig_easy);
 end
 if ~exist(grdname,'file')
   error(['oct_make_grid: ',grdname,' not created (click "Apply" in the Easy window)'])
 end

 % netcdf.getVar returns (xi,eta): transpose to the CROCO (eta,xi) layout
 ncid = netcdf.open(grdname,'NC_NOWRITE');
 Lonr = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lon_rho'))).';
 Latr = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lat_rho'))).';
 Lonu = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lon_u'))).';
 Latu = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'lat_u'))).';
 netcdf.close(ncid);
 [Mp,Lp]=size(Lonr);
 L=Lp-1; M=Mp-1;
 disp([' LLm = ',num2str(L-1)])
 disp([' MMm = ',num2str(M-1)])

else

%
% Get the longitude
%
lonr=(lonmin:dl:lonmax);
%
% Get the latitude for an isotropic grid
%
i=1;
latr(i)=latmin;
while latr(i)<=latmax
  i=i+1;
  latr(i)=latr(i-1)+dl*cos(latr(i-1)*pi/180);
end
[Lonr,Latr]=meshgrid(lonr,latr);
[Lonu,Lonv,Lonp]=oct_rho2uvp(Lonr); 
[Latu,Latv,Latp]=oct_rho2uvp(Latr);
%
% Create the grid file
%
disp(' ')
disp(' Create the grid file...')
[M,L]=size(Latp);
disp([' LLm = ',num2str(L-1)])
disp([' MMm = ',num2str(M-1)])
oct_create_grid(L,M,grdname,CROCO_title)
%
% Fill the grid file
% (2D fields are (eta,xi) in memory; netcdf.putVar expects (xi,eta) -> .')
%
disp(' ')
disp(' Fill the grid file...')
 ncid = netcdf.open(grdname,'NC_WRITE');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lat_u'),Latu.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lon_u'),Lonu.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lat_v'),Latv.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lon_v'),Lonv.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lat_rho'),Latr.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lon_rho'),Lonr.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lat_psi'),Latp.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'lon_psi'),Lonp.');
 netcdf.close(ncid);

end % end choice for interactive grid maker

%
%  Compute the metrics
%
disp(' ')
disp(' Compute the metrics...')
[pm,pn,dndx,dmde]=oct_get_metrics(grdname);
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
f=4*pi*sin(pi*Latr/180)*366.25/(24*3600*365.25);
%
% Fill the grid file
%
disp(' ')
disp(' Fill the grid file...')
 ncid = netcdf.open(grdname,'NC_WRITE');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'pm'),pm.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'pn'),pn.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'dndx'),dndx.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'dmde'),dmde.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'x_u'),xu.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'y_u'),yu.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'x_v'),xv.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'y_v'),yv.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'x_rho'),xr.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'y_rho'),yr.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'x_psi'),xp.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'y_psi'),yp.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'angle'),angle.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'f'),f.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'spherical'),'T');
 netcdf.close(ncid);
%
%
%  Add topography from topofile
%
disp(' ')
disp(' Add topography...')
h=oct_add_topo(grdname,topofile);
%
% Compute the mask
%
maskr=h>0;
maskr=oct_process_mask(maskr);
[masku,maskv,maskp]=oct_uvp_mask(maskr);
%
%  Write it down
%
 ncid = netcdf.open(grdname,'NC_WRITE');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'h'),h.');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'hraw'),h.');     % raw (unsmoothed) topography
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'mask_u'),double(masku).');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'mask_v'),double(maskv).');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'mask_psi'),double(maskp).');
 netcdf.putVar(ncid,netcdf.inqVarID(ncid,'mask_rho'),double(maskr).');
 netcdf.close(ncid);

%
% Coastline and interactive mask editing. In Octave it needs the qt
% graphics toolkit (octave with GUI or octave --no-gui, not octave-cli)
%
can_edit=(isoctave==0);
if isoctave
  can_edit=any(strcmp(available_graphics_toolkits(),'qt'));
  if can_edit, graphics_toolkit('qt'); end
end
if can_edit
%
% Create the coastline
%
if ~isempty(coastfileplot)
  try
    oct_make_coast(grdname,coastfileplot);
  catch err
    disp([' Coastline not created: ',err.message])
  end
end
%

r=input(sprintf('\n Do you want to use editmask ? y,[n] '),'s');
if strcmp(r,'y')
  disp(' Editmask:')
  disp(' Edit manually the land mask.')
  disp(' ... ')
  if ~isempty(coastfileplot)
    fig_em=oct_editmask(grdname,coastfilemask);
  else
    fig_em=oct_editmask(grdname);
  end
  disp(' Close the Editmask window to finalize the grid...');
  if ~isempty(fig_em) && ishghandle(fig_em)
    waitfor(fig_em);   % Octave: the script continues when the window is closed
  end
end
%
close all
end % can_edit
%
%  Smooth the topography
%

ncid = netcdf.open(grdname,'NC_NOWRITE');
h     = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'h'))).';
maskr = double(netcdf.getVar(ncid,netcdf.inqVarID(ncid,'mask_rho'))).';
netcdf.close(ncid);
%
if topo_smooth==1,
 h=oct_smoothgrid(h,maskr,hmin,hmax_coast,hmax,...
              rtarget,n_filter_deep_topo,n_filter_final);
else
 h=oct_smoothgrid_new(h,maskr,hmin,hmax_coast,hmax,...
                  rtarget,n_filter_deep_topo,n_filter_final);
end
%
%  Write it down
%
disp(' ')
disp(' Write it down...')
ncid = netcdf.open(grdname,'NC_WRITE');
netcdf.putVar(ncid,netcdf.inqVarID(ncid,'h'),h.');
netcdf.close(ncid);
%
% make a plot
%
if (isoctave == 0)
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
warning(wstate_);
end
%
% End
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

