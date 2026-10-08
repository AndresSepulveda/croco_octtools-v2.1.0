clear all
close all

gloabalriverfile='coastal-stns-Vol-monthly.updated-oct2007.nc';
fillval=-999;

ncidriv = netcdf.open(gloabalriverfile, 'NC_NOWRITE');
time=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'time'));
station=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'station'));
chars=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'chars'));
lonriv=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'lon'));
latriv=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'lat'));
lonriv_mou=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'lon_mou'));
latriv_mou=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'lat_mou'));
area_stn=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'area_stn'));
area_mou=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'area_mou'));
vol_stn=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'vol_stn'));
ratio_m2s=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'ratio_m2s'));
xnyr=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'xnyr'));
yrb=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'yrb'));
yre=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'yre'));
elev=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'elev'));
ct_name=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'ct_name'));
cn_name=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'cn_name'));
riv_name=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'riv_name'));
ocn_name=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'ocn_name'));
stn_name=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'stn_name'));
FLOW=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'FLOW'));
time_1800=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'time_1800'));
station_1800=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'station_1800'));
index_id_1800=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'index_id_1800'));
FLOW_1800=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'FLOW_1800'));
netcdf.close(ncidriv);

% On ne s'occupe que des data depuis 1900 Compute a climatology
my_time=time;
time_char=num2str(time)
month=str2num(time_char(:,5:6));
 for k=1:12
     if k<10
     disp(['my_time==0',num2str(k)])
     eval(['ind_month(k,:)=find(month==0',num2str(k),');'])
     else
       disp(['my_time==',num2str(k)])  
     eval(['ind_month(k,:)=find(month==',num2str(k),');'])
     end
 end
% ind_month(12:107) contient les indices des differents mois.

% Compute the clim, first remove the NaN
FLOW(FLOW==fillval)=NaN;
for riv=1:925
    disp(['Compute river# ',num2str(riv)])
    disp(['############################'])
    for k=1:12
       % disp(['Compute month ',num2str(k)])
        FLOW_clm(riv,k) =  oct_nanmean(FLOW(ind_month(k,:),riv),1);
    end
end
FLOW_clm=FLOW_clm';


%Create climatological CROCOTOOLS netcdf file
runoff_global_clim='runoff_global_clim.nc';
nw_id = netcdf.create(runoff_global_clim, 'NC_CLOBBER');
result = redef(nw_id);
%
%  Create dimensions
%
did_time = netcdf.defDim(nw_id, 'time', 1284);
did_station = netcdf.defDim(nw_id, 'station', 925);
did_chars = netcdf.defDim(nw_id, 'chars', 30);
did_twelve = netcdf.defDim(nw_id, 'twelve', 12);
%
%  Create variables and attributes
%
vid_time = netcdf.defVar(nw_id, 'time', 'NC_INT', did_time);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'time'), 'long_name', 'time as YYYYMM');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'time'), 'FillValue', -999);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'time'), 'units', 'unitless');

vid_lon_mou = netcdf.defVar(nw_id, 'lon_mou', 'NC_DOUBLE', did_station);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon_mou'), 'long_name', 'river mouth longitude');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon_mou'), 'units', 'degrees_east');

vid_lat_mou = netcdf.defVar(nw_id, 'lat_mou', 'NC_DOUBLE', did_station);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat_mou'), 'long_name', 'river mouth latitude');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat_lou'), 'units', 'degrees_north');

vid_lon = netcdf.defVar(nw_id, 'lon', 'NC_DOUBLE', did_station);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon'), 'long_name', 'station longitude');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon'), 'units', 'degrees_east');

vid_lat = netcdf.defVar(nw_id, 'lat', 'NC_DOUBLE', did_station);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat'), 'long_name', 'station latitude');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat'), 'units', 'degrees_north');

vid_riv_name = netcdf.defVar(nw_id, 'riv_name', 'NC_CHAR', [did_chars, did_station]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'riv_name'), 'long_name', 'river name');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'riv_name'), 'units', 'degrees_east');

vid_ocn_name = netcdf.defVar(nw_id, 'ocn_name', 'NC_CHAR', [did_chars, did_station]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'ocn_name'), 'long_name', 'ocean name of river discharge');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'ocn_name'), 'units', ' ');

vid_ct_name = netcdf.defVar(nw_id, 'ct_name', 'NC_CHAR', [did_chars, did_station]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'ct_name'), 'long_name', 'country of station');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'ct_name'), 'units', ' ');

vid_cn_name = netcdf.defVar(nw_id, 'cn_name', 'NC_CHAR', [did_chars, did_station]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'cn_name'), 'long_name', 'continent of station');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'cn_name'), 'units', ' ');

vid_stn_name = netcdf.defVar(nw_id, 'stn_name', 'NC_CHAR', [did_chars, did_station]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'stn_name'), 'long_name', 'station name');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'stn_name'), 'units', ' ');

vid_FLOW = netcdf.defVar(nw_id, 'FLOW', 'NC_DOUBLE', [did_station, did_time]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'FLOW'), 'long_name', 'monthly mean volume at station');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'FLOW'), 'FillValue', -999);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'FLOW'), 'units', 'm3/s');

vid_FLOW_clm = netcdf.defVar(nw_id, 'FLOW_clm', 'NC_DOUBLE', [did_station, did_twelve]);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'FLOW_clm'), 'long_name', 'monthly clim  volume at station');
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'FLOW_clm'), 'FillValue', -999);
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'FLOW_clm'), 'units', 'm3/s');
%
% Create global attributes
%
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'title', 'Monthly clim from monthly streamflow from downstream stations for World\''s 925 ocean-reaching rivers. Dai and Trenberth, 2002');
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'source_file', 'coastal-stns-Vol-monthly.nc; http://www.cgd.ucar.edu/cas/catalog/surface/dai-runoff/index.html');
result = endef(nw_id);
netcdf.close(nw_id);
%
% Write time variables
%
nw_id = netcdf.open(runoff_global_clim, 'NC_WRITE');
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'FLOW_clm'), FLOW_clm(:));
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'FLOW'), FLOW(:));
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'stn_name'), stn_name(:));
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'cn_name'), cn_name(:));
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'ct_name'), ct_name(:));
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'ocn_name'), ocn_name(:));
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'riv_name'), riv_name(:));
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lat'), latriv(:));
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lon'), lonriv(:));
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lat_mou'), latriv_mou(:));
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lon_mou'), lonriv_mou(:));
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'time'), time(:));
netcdf.close(nw_id);
