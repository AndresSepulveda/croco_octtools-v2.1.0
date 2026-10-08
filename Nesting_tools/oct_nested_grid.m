function [imin,imax,jmin,jmax]=oct_nested_grid(parent_grd,child_grd,imin,imax,jmin,jmax,refinecoeff,...
    topofile,newtopo,rtarget,nband,hmin,matchvolume,...
    hmax_coast,n_filter_deep,n_filter_final)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  compute the embedded grid
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
%  Copyright (c) 2004-2006 by Pierrick Penven
%  e-mail:Pierrick.Penven@ird.fr
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% file_title
%
file_title=['Grid embedded in ',parent_grd,...
    ' - positions in the parent grid: ',num2str(imin),' - ',...
    num2str(imax),' - ',...
    num2str(jmin),' - ',...
    num2str(jmax),'; refinement coefficient : ',num2str(refinecoeff)];
disp(file_title)
%
imax_orig=imax;
imin_orig=imin;
jmax_orig=jmax;
jmin_orig=jmin;
disp(['======================='])
disp(['Original nest limits   '])
disp(['imin= ',num2str(imin_orig)])
disp(['imax= ',num2str(imax_orig)])
disp(['jmin= ',num2str(jmin_orig)])
disp(['jmax= ',num2str(jmax_orig)])
disp(['======================='])

%
% Read in the parent grid
%
disp(' ')
disp(' Read in the parent grid...')
ncid = netcdf.open(parent_grd, 'NC_NOWRITE');
latp_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_psi'))).';
lonp_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_psi'))).';
xp_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'x_psi'))).';
yp_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'y_psi'))).';
maskp_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_psi'))).';
%
latu_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_u'))).';
lonu_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_u'))).';
xu_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'x_u'))).';
yu_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'y_u'))).';
masku_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_u'))).';
%
latv_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_v'))).';
lonv_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_v'))).';
xv_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'x_v'))).';
yv_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'y_v'))).';
maskv_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_v'))).';
%
latr_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'))).';
lonr_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'))).';
xr_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'x_rho'))).';
yr_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'y_rho'))).';
maskr_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'))).';
%
h_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'))).';
f_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'f'))).';
angle_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'))).';
pm_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'pm'))).';
pn_parent=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'pn'))).';
%
netcdf.close(ncid);
%
if isempty(hmin) | newtopo==0
    hmin = min(min(h_parent));
end
disp(' ')
disp(['  hmin = ',num2str(hmin)])
%
hmax = max(h_parent(:));
disp(' ')
disp(['  hmax = ',num2str(hmax)])
%
% Parent indices
%
[Mp,Lp]=size(h_parent);
[igrd_r,jgrd_r]=meshgrid((1:1:Lp),(1:1:Mp));
[igrd_p,jgrd_p]=meshgrid((1:1:Lp-1),(1:1:Mp-1));
[igrd_u,jgrd_u]=meshgrid((1:1:Lp-1),(1:1:Mp));
[igrd_v,jgrd_v]=meshgrid((1:1:Lp),(1:1:Mp-1));
%
% Test if correct
%
if imin>=imax
    error(['imin >= imax - imin = ',...
        num2str(imin),' - imax = ',num2str(imax)])
end
if jmin>=jmax
    error(['jmin >= jmax - jmin = ',...
        num2str(jmin),' - jmax = ',num2str(jmax)])
end
if jmax>(Mp-1)
    error(['jmax > M - M = ',...
        num2str(Mp-1),' - jmax = ',num2str(jmax)])
end
if imax>(Lp-1)
    error(['imax > L - L = ',...
        num2str(Lp-1),' - imax = ',num2str(imax)])
end

bbound_east=1;
bbound_west=1;
bbound_south=1;
bbound_north=1;


while (bbound_east | bbound_west | bbound_south | bbound_north)
    %
    % the children indices
    %
    ipchild=(imin:1/refinecoeff:imax);
    jpchild=(jmin:1/refinecoeff:jmax);
    irchild=(imin+0.5-0.5/refinecoeff:1/refinecoeff:imax+0.5+0.5/refinecoeff);
    jrchild=(jmin+0.5-0.5/refinecoeff:1/refinecoeff:jmax+0.5+0.5/refinecoeff);
    [ichildgrd_p,jchildgrd_p]=meshgrid(ipchild,jpchild);
    [ichildgrd_r,jchildgrd_r]=meshgrid(irchild,jrchild);
    [ichildgrd_u,jchildgrd_u]=meshgrid(ipchild,jrchild);
    [ichildgrd_v,jchildgrd_v]=meshgrid(irchild,jpchild);
    %
    % interpolations
    %
    disp(' ')
    disp(' Do the  interpolations...')
    lonpchild=interp2(igrd_p,jgrd_p,lonp_parent,ichildgrd_p,jchildgrd_p,'cubic');
    latpchild=interp2(igrd_p,jgrd_p,latp_parent,ichildgrd_p,jchildgrd_p,'cubic');
    xpchild=interp2(igrd_p,jgrd_p,xp_parent,ichildgrd_p,jchildgrd_p,'cubic');
    ypchild=interp2(igrd_p,jgrd_p,yp_parent,ichildgrd_p,jchildgrd_p,'cubic');
    %
    lonuchild=interp2(igrd_u,jgrd_u,lonu_parent,ichildgrd_u,jchildgrd_u,'cubic');
    latuchild=interp2(igrd_u,jgrd_u,latu_parent,ichildgrd_u,jchildgrd_u,'cubic');
    xuchild=interp2(igrd_u,jgrd_u,xu_parent,ichildgrd_u,jchildgrd_u,'cubic');
    yuchild=interp2(igrd_u,jgrd_u,yu_parent,ichildgrd_u,jchildgrd_u,'cubic');
    %
    lonvchild=interp2(igrd_v,jgrd_v,lonv_parent,ichildgrd_v,jchildgrd_v,'cubic');
    latvchild=interp2(igrd_v,jgrd_v,latv_parent,ichildgrd_v,jchildgrd_v,'cubic');
    xvchild=interp2(igrd_v,jgrd_v,xv_parent,ichildgrd_v,jchildgrd_v,'cubic');
    yvchild=interp2(igrd_v,jgrd_v,yv_parent,ichildgrd_v,jchildgrd_v,'cubic');
    %
    lonrchild=interp2(igrd_r,jgrd_r,lonr_parent,ichildgrd_r,jchildgrd_r,'cubic');
    latrchild=interp2(igrd_r,jgrd_r,latr_parent,ichildgrd_r,jchildgrd_r,'cubic');
    xrchild=interp2(igrd_r,jgrd_r,xr_parent,ichildgrd_r,jchildgrd_r,'cubic');
    yrchild=interp2(igrd_r,jgrd_r,yr_parent,ichildgrd_r,jchildgrd_r,'cubic');
    %
    anglechild=interp2(igrd_r,jgrd_r,angle_parent,ichildgrd_r,jchildgrd_r,'cubic');
    fchild=interp2(igrd_r,jgrd_r,f_parent,ichildgrd_r,jchildgrd_r,'cubic');
    h_parent_fine=interp2(igrd_r,jgrd_r,h_parent,ichildgrd_r,jchildgrd_r,'cubic');
    %
    h_coarse=interp2(igrd_r,jgrd_r,h_parent,ichildgrd_r,jchildgrd_r,'nearest');
    maskr_coarse=interp2(igrd_r,jgrd_r,maskr_parent,ichildgrd_r,jchildgrd_r,'nearest');
    pm_coarse=interp2(igrd_r,jgrd_r,pm_parent,ichildgrd_r,jchildgrd_r,'nearest');
    pn_coarse=interp2(igrd_r,jgrd_r,pn_parent,ichildgrd_r,jchildgrd_r,'nearest');

    [Mc,Lc]=size(maskr_coarse);
    %---------------------
    
    eastchk = abs(maskr_coarse(:,end-1)-maskr_coarse(:,end));
    westchk = abs(maskr_coarse(:,1)-maskr_coarse(:,2));
    southchk = abs(maskr_coarse(1,:)-maskr_coarse(2,:));
    northchk = abs(maskr_coarse(end-1,:)-maskr_coarse(end,:));
    %---------------------
%     disp(['Mc=',num2str(Mc)])
%     disp(['Lc=',num2str(Lc)])
%     disp(['imin= ',num2str(imin)])
%     disp(['imax= ',num2str(imax)])
%     disp(['jmin= ',num2str(jmin)])
%     disp(['jmax= ',num2str(jmax)])

    if sum(eastchk)~=0
        imax=imax+1;
        bbound_east=1;
        disp(['==> East limits displacement +1'])
    else
        bbound_east=0;
    end
    if sum(westchk)~=0
        imin=imin-1;
        bbound_west=1;
        disp(['==> West limits displacement -1'])
    else
        bbound_west=0;
    end
    if sum(southchk)~=0
        jmin=jmin-1;
        bbound_south=1;
        disp(['==> South limits displacement -1'])
    else
        bbound_south=0;
    end
    if sum(northchk)~=0
        jmax=jmax+1;
        bbound_north=1;
        disp(['==> North limits displacement +1'])
    else
        bbound_north=0;
    end
    
%     disp(['imin= ',num2str(imin)])
%     disp(['imax= ',num2str(imax)])
%     disp(['jmin= ',num2str(jmin)])
%     disp(['jmax= ',num2str(jmax)])
%     disp(['======================='])
    %
end  %============> while

if (imin~=imin_orig)
  disp(' ')  
  disp('=======')
  disp(['New imin= ',num2str(imin)])  
  disp(' ') 
end
if (imax~=imax_orig)
   disp(' ')   
   disp('=======')
   disp(['New imax= ',num2str(imax)])  
   disp(' ') 
end   
if (jmin~=jmin_orig)
   disp(' ')  
   disp('=======')
   disp(['New jmin= ',num2str(jmin)]) 
   disp(' ')  
end  
if (jmax~=jmax_orig)
   disp(' ') 
   disp('=======')
   disp(['New jmax= ',num2str(jmax)])  
   disp(' ') 
end  

%
% New file_title

%
file_title=['Grid embedded in ',parent_grd,...
    ' - positions in the parent grid: ',num2str(imin),' - ',...
    num2str(imax),' - ',...
    num2str(jmin),' - ',...
    num2str(jmax),'; refinement coefficient : ',num2str(refinecoeff)];
disp(file_title)
%
% Create the grid file
%
disp(' ')
disp(' Create the grid file...')
[Mchild,Lchild]=size(latpchild);
oct_create_nestedgrid(Lchild,Mchild,child_grd,parent_grd,file_title)
%
% Fill the grid file
%
disp(' ')
disp(' Fill the grid file...')
ncid = netcdf.open(child_grd, 'NC_WRITE');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'refine_coef'), int32(refinecoeff));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'grd_pos'), int32([imin,imax,jmin,jmax]));
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat_u'), (latuchild).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon_u'), (lonuchild).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'x_u'), (xuchild).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'y_u'), (yuchild).');
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat_v'), (latvchild).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon_v'), (lonvchild).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'x_v'), (xvchild).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'y_v'), (yvchild).');
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'), (latrchild).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'), (lonrchild).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'x_rho'), (xrchild).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'y_rho'), (yrchild).');
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lat_psi'), (latpchild).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'lon_psi'), (lonpchild).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'x_psi'), (xpchild).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'y_psi'), (ypchild).');
%
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'hraw'), [0 0 0], [Lchild+1 Mchild+1 1], h_parent_fine.');  % hraw(1,:,:)
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'angle'), (anglechild).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'f'), (fchild).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'spherical'), 'T');
%
netcdf.close(ncid);
%
%  Compute the metrics
%
disp(' ')
disp(' Compute and add the metrics...')
[pm,pn,dndx,dmde]=oct_get_metrics(child_grd);
%
ncid = netcdf.open(child_grd, 'NC_WRITE');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'pm'), (pm).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'pn'), (pn).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'dndx'), (dndx).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'dmde'), (dmde).');
netcdf.close(ncid);
%
%  Add the topography
%
disp(' ')
if newtopo==1
    disp(' Add topography...')
    hetopo=oct_add_topo(child_grd,topofile);
    hnew=hetopo;
else
    disp(' Just interp parent topography...')
    hnew=h_parent_fine;
end
%
% Compute the mask
%
maskrchild=double(oct_get_embeddedmask(maskr_coarse,hnew,refinecoeff,newtopo));
[maskuchild,maskvchild,maskpchild]=oct_uvp_mask(maskrchild);
%
%  Smooth the topography
%
if newtopo==1
    %  hnew = oct_smoothgrid(hnew,hmin,rtarget);
    hnew = oct_smoothgrid(hnew,maskrchild,hmin,hmax_coast,hmax,rtarget,...
        n_filter_deep,n_filter_final);
    disp(' ')
    disp(' Connect the topography...')
    if hmin<0, 
     hnew=hnew-hmin+1;  % wet/dry case
     h_parent_fine=h_parent_fine-hmin+1;
     h_coarse=h_coarse-hmin+1;
    end
    [hnew,alph]=oct_connect_topo(hnew,h_parent_fine,h_coarse,maskrchild,maskr_coarse,...
        pm_coarse,pn_coarse, ...
        pm,pn,nband,refinecoeff,matchvolume);
    if hmin<0, 
      hnew=hnew+hmin-1;
      h_parent_fine=h_parent_fine+hmin-1;
      h_coarse=h_coarse+hmin-1;
    end
else
    alph=1+0.*hnew;
    if matchvolume==1
        if hmin<0, 
         hnew=hnew-hmin+1;  % wet/dry case
         h_coarse=h_coarse-hmin+1;
        end
        hnew=oct_connect_volume(hnew,h_coarse,maskr_coarse,...
            pm_coarse,pn_coarse,...
            pm,pn,refinecoeff);
        if hmin<0, 
         hnew=hnew+hmin-1;
         h_coarse=h_coarse+hmin-1;
        end
    end
end
%
%  Write it down
%
disp(' ')
disp(' Write it down...')
ncid = netcdf.open(child_grd, 'NC_WRITE');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'h'), (hnew).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'mask_u'), double(maskuchild).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'mask_v'), double(maskvchild).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'mask_psi'), double(maskpchild).');
netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'), double(maskrchild).');
netcdf.close(ncid);
disp(' ')
disp(['  Size of the grid:  LLm = ',...
    num2str(Lchild-1),' - MMm = ',num2str(Mchild-1)])

%
% make a plot
%
disp(' ')
disp(' Do a plot...')
%
% (the plot is only informative: a graphics error must not stop the
%  nesting procedure)
%
try

lonbox=cat(1,lonp_parent(jmin:jmax,imin),  ...
    lonp_parent(jmax,imin:imax)' ,...
    lonp_parent(jmax:-1:jmin,imax),...
    lonp_parent(jmin,imax:-1:imin)' );
latbox=cat(1,latp_parent(jmin:jmax,imin),  ...
    latp_parent(jmax,imin:imax)' ,...
    latp_parent(jmax:-1:jmin,imax),...
    latp_parent(jmin,imax:-1:imin)' );
loncbox=cat(1,lonpchild(1:Mchild,1),  ...
    lonpchild(Mchild,1:Lchild)' ,...
    lonpchild(Mchild:-1:1,Lchild),...
    lonpchild(1,Lchild:-1:1)' );
latcbox=cat(1,latpchild(1:Mchild,1),  ...
    latpchild(Mchild,1:Lchild)' ,...
    latpchild(Mchild:-1:1,Lchild),...
    latpchild(1,Lchild:-1:1)' );
figure(1)
themask=double(maskrchild);
themask(maskrchild==0)=NaN;
%contourf(lonrchild,latrchild,themask.*alph,[0:0.1:1])
pcolor(lonrchild,latrchild,themask.*alph)
caxis([0 1])
shading flat
colorbar
axis image
hold on
[C1,h1]=contour(lonrchild,latrchild,hnew,...
    [10 100 200 500 1000 2000 4000],'y');
[C2,h2]=contour(lonrchild,latrchild,h_parent_fine,...
    [10 100 200 500 1000 2000 4000],'k');
if newtopo==1
    [C3,h3]=contour(lonrchild,latrchild,hetopo,...
        [10 100 200 500 1000 2000 4000],'b');
end
[C4,h4]=contour(lonrchild,latrchild,maskrchild,[0.5 0.5],'r');
[C5,h5]=contour(lonrchild,latrchild,maskr_coarse,[0.5 0.5],'r:');
h6=plot(lonbox,latbox,'k');
h7=plot(loncbox,latcbox,'y:');
plot(lonrchild(maskr_coarse==0),latrchild(maskr_coarse==0),'k.')
plot(lonrchild(maskrchild==0),latrchild(maskrchild==0),'ro')

h8=plot(lonr_parent,latr_parent,'g.');
hold off
title('alpha parameter : 0<alpha<1')
axis([min(min(lonrchild)) max(max(lonrchild)),...
      min(min(latrchild)) max(max(latrchild))])
wstate_=warning('off','all');
try   % legend of empty contour groups fails with the qt toolkit
if newtopo==1
    legend([h1(1),h2(1),h3(1),h4(1),h5(1),h8(1)],...
        'Child topo','Parent topo','Raw topo','Child mask','Parent mask',...
        'Parent rho points')
else
    legend([h1(1),h2(1),h4(1),h5(1),h8(1)],...
        'Child topo','Parent topo','Child mask','Parent mask',...
        'Parent rho points')
end
end
warning(wstate_);
catch err
  disp(['  plot not done: ',err.message])
end
return
