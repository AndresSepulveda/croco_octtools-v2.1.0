clear all
close all

% In this programm the monthly data for river runoff are written into a
% netcdf file

% data from the Mekong River Commission (2005): mean monthly value btw 1960
% and 2004, m3/s
debit_at_kratie=[3620  2730 2290 2220 3640 11200 22200 35500 36700 22000 10900 5710]
debit_mekong=100/91*debit_at_kratie

% data from Annales de Géographie, Pardé, 1938: average over 1912-1935.
% mean : 3917m3/s
debit_redriv=[1229 1125 1052 1089 1735 4802 8557 11243 6573 5065 2875 1657]

% data from wikipedia for Xi at wuzhou
debit_wuzhou= [1761 1743 2216 4527 9384 14211 14835 14410 8853 5346 3687 2605]
%debit_wuzhou=/mean(debit_wuzhou)

temp_src0=[11 9 9 12 20 20 24 25 21 18 13 12];
temp_src=[temp_src0;temp_src0+2;temp_src0+2.8];

salt_src0=[8 3 5 1 5 3 2 1 4 2 1 2];
salt_src=[salt_src0;salt_src0+2;salt_src0+2.8];

no3_src00=[30.09  29.25  28.85  24.19  22.88  21.26  16.91  12.4  10.76  13.76  22.44  28.06]
no3_src01=[34.67  34.97  34.42  36.61  35.64  36.65  35.3  34.61  30.09  27.74  30.76  33.32]
no3_src02=no3_src01+3;
no3_src=[no3_src00;no3_src01;no3_src02];

qbar_name= ['R1';'R2';'R3'];
A=[debit_mekong;debit_redriv;debit_wuzhou]

figure
subplot(211)
plot(A')
legend(qbar_name)
grid on; box on
title(['\bf Run-off'])

subplot(212)
hold on
plot(no3_src')
legend(qbar_name)
grid on; box on
title(['\bf NO3 conc'])

nw_id = netcdf.create('croco_runoff_monthly.nc', 'NC_CLOBBER');
% Dimension 
did_qbar_time = netcdf.defDim(nw_id, 'qbar_time', 12);
did_n_qbar = netcdf.defDim(nw_id, 'n_qbar', 3);
did_runoffname_StrLen = netcdf.defDim(nw_id, 'runoffname_StrLen', 2);

% Variable and Attribute
vid_qbar_time = netcdf.defVar(nw_id, 'qbar_time', 'NC_DOUBLE', did_qbar_time);
% [conv] línea ncchar duplicada omitida
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'qbar_time'), 'cycle_length', 360);

vid_temp_src_time = netcdf.defVar(nw_id, 'temp_src_time', 'NC_DOUBLE', did_qbar_time);
% [conv] línea ncchar duplicada omitida
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'temp_src_time'), 'cycle_length', 360);

vid_salt_src_time = netcdf.defVar(nw_id, 'salt_src_time', 'NC_DOUBLE', did_qbar_time);
% [conv] línea ncchar duplicada omitida
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'salt_src_time'), 'cycle_length', 360);

vid_no3_src_time = netcdf.defVar(nw_id, 'no3_src_time', 'NC_DOUBLE', did_qbar_time);
% [conv] línea ncchar duplicada omitida
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'no3_src_time'), 'cycle_length', 360);

vid_Qbar = netcdf.defVar(nw_id, 'Qbar', 'NC_DOUBLE', [did_qbar_time, did_n_qbar]);
% [conv] línea ncchar duplicada omitida
% [conv] línea ncchar duplicada omitida

vid_temp_src = netcdf.defVar(nw_id, 'temp_src', 'NC_DOUBLE', [did_qbar_time, did_n_qbar]);
% [conv] línea ncchar duplicada omitida
% [conv] línea ncchar duplicada omitida

vid_salt_src = netcdf.defVar(nw_id, 'salt_src', 'NC_DOUBLE', [did_qbar_time, did_n_qbar]);
% [conv] línea ncchar duplicada omitida
% [conv] línea ncchar duplicada omitida

vid_NO3_src = netcdf.defVar(nw_id, 'NO3_src', 'NC_DOUBLE', [did_qbar_time, did_n_qbar]);
% [conv] línea ncchar duplicada omitida
% [conv] línea ncchar duplicada omitida

vid_runoff_name = netcdf.defVar(nw_id, 'runoff_name', 'NC_CHAR', [did_runoffname_StrLen, did_n_qbar]);
% [conv] línea ncchar duplicada omitida
%%result = endef(nw);

% Fill th value
%
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'qbar_time'), [15:30:365]);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'temp_src_time'), [15:30:365]);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'salt_src_time'), [15:30:365]);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'no3_src_time'), [15:30:365]);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'Qbar'), A.*10');
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'temp_src'), temp_src);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'salt_src'), salt_src);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'NO3_src'), no3_src);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'runoff_name'), qbar_name);
netcdf.close(nw_id);
  
%Localisation des points source :

R_i= [32 36 28];
R_j= [20 14 33];
grdfile='CROCO_FILES/croco_grd.nc';
[lat, lon, mask]=oct_read_latlonmask(grdfile,'r');

figure
pcolor(mask)
hold on
plot(R_i,R_j,'or')




