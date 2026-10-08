clear all
close all

tindex=1;
oafile='croco_oa.nc';
coastfile='noumea_i.mat';

ncid = netcdf.open(oafile, 'NC_NOWRITE');
lon=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'));
lat=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'));
var=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'NO3')));
netcdf.close(ncid);
m_proj('mercator',...
       'lon',[min(min(lon)) max(max(lon))],...
       'lat',[min(min(lat)) max(max(lat))]);
m_pcolor(lon,lat,var);
shading flat
%caxis([33.8 35.8])
hold on
colorbar
m_usercoast(coastfile,'patch',[.9 .9 .9]);
m_grid('box','fancy',...
       'xtick',5,'ytick',5,'tickdir','out');
set(findobj('tag','m_grid_color'),'facecolor','none')
hold off
