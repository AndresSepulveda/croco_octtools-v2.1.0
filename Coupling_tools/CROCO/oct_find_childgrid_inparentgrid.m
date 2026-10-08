

clear all
close all


%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
crocotools_param
prt_grd=[RUN_dir,'/CROCO_FILES/croco_grd.nc'];
chd_grd=[RUN_dir,'/CROCO_FILES/croco_grd.nc.1'];
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
warning off
%
% Title
%
disp(' ')
disp([' Find ', chd_grd, ' in ',prt_grd])
disp(' ')
%
% Load data
%
ncid = netcdf.open(prt_grd, 'NC_NOWRITE');
Plonp=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_psi')));
Platp=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_psi')));
netcdf.close(ncid);

ncid = netcdf.open(chd_grd, 'NC_NOWRITE');
Clonp=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_psi')));
Clatp=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_psi')));
netcdf.close(ncid);
%
% Test if correct
%
if Clonp(1)<Plonp(1)
    error(['Child Western boundary not in parent'])
end

if Clonp(end)>Plonp(end)
    error(['Child Eastern boundary not in parent'])
end

if Clatp(1)<Platp(1)
    error(['Child Southern boundary not in parent'])
end

if Clatp(end)>Platp(end)
    error(['Child Northern boundary not in parent'])
end
%
% Find index
%
[val,i_min] = min(abs(Plonp(:)-Clonp(1)));
[val,i_max] = min(abs(Plonp(:)-Clonp(end)));
[val,j_min] = min(abs(Platp(:)-Clatp(1)));
[val,j_max] = min(abs(Platp(:)-Clatp(end)));
%
%some change in some specific cases
disp([sprintf('%0.8f',Clonp(1)),' ',sprintf('%0.8f',Plonp(i_min))])
disp([sprintf('%0.8f',Clonp(end)),' ',sprintf('%0.8f',Plonp(i_max))])
disp([sprintf('%0.8f',Clatp(1)),' ',sprintf('%0.8f',Platp(j_min))])
disp([sprintf('%0.8f',Clatp(end)),' ',sprintf('%0.8f',Platp(j_max))])

%

%
% Find refinement level
%
refinecoeff=0;
for k = 1:(size(Clonp,2)-2)
    if abs(Plonp(i_min+1)-Clonp(k))>min(abs(Plonp(i_min+1)-Clonp(:)))
        refinecoeff=refinecoeff+1;
    else
        break
    end

    if k == (size(Clonp,2)-2)
        error(['End of child grid was reached without finding second parent point --> please check your grids'])
    end
end
%
disp(' ')
disp(['The refinement coefficient between Prt and Chd is ',num2str(refinecoeff)])
disp(' ')

%
% Rewrite netcdf
%
ncid = netcdf.open(chd_grd, 'NC_NOWRITE');
latp=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_psi'));
lonp=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_psi'));
xp=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'x_psi'));
yp=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'y_psi'));
maskp=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_psi'));
%
latu=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_u'));
lonu=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_u'));
xu=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'x_u'));
yu=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'y_u'));
masku=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_u'));
%
latv=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_v'));
lonv=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_v'));
xv=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'x_v'));
yv=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'y_v'));
maskv=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_v'));
%
latr=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'));
lonr=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'));
xr=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'x_rho'));
yr=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'y_rho'));
maskr=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'));
%
h=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'));
f=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'f'));
alpha=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'alpha'));
dndx=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'dndx'));
dmde=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'dmde'));
angle=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'));
pm=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'pm'));
pn=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'pn'));
%
[Mp,Lp]=size(lonp);
netcdf.close(ncid);
%
oct_create_nestedgrid(Lp,Mp,chd_grd,prt_grd,'title')
%
nw_id = netcdf.open(chd_grd, 'NC_WRITE');
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'refine_coef'), refinecoeff);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'grd_pos'), [i_min,i_max,j_min,j_max]);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lat_u'), latu);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lon_u'), lonu);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'x_u'), xu);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'y_u'), yu);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'mask_u'), masku);
%
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lat_v'), latv);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lon_v'), lonv);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'x_v'), xv);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'y_v'), yv);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'mask_v'), maskv);
%
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lat_rho'), latr);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lon_rho'), lonr);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'x_rho'), xr);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'y_rho'), yr);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'mask_rho'), maskr);
%
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lat_psi'), latp);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lon_psi'), lonp);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'x_psi'), xp);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'y_psi'), yp);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'mask_psi'), maskp);
%
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'h'), h);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'pm'), pm);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'pn'), pn);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'hraw'), 1,:,:-1, 1, h);  % [conv] 0-based
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'angle'), angle);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'f'), f);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'spherical'), 'T');
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'dndx'), dndx);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'dmde'), dmde);
%
%Create global attributes
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'title', CROCO_title);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'date', date);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'parent_grid', grdname);

netcdf.close(nw_id);
