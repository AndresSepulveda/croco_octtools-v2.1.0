function [my_latriv,my_lonriv,my_flow,my_rivername,number_river]=oct_runoff_glob_extract(grdfile,global_clim_river);
%
%  [my_latriv,my_lonriv,my_flow,my_rivername,number_river]=oct_runoff_glob_extract(grdfile,global_clim_river);
%  Read all the rivers from the netcdf global climatology file
%  Select the ones located into the model grid
%
disp(' ')
disp(['Reading the global monthly climatological run-off dataset... '])
disp(' ')
%
%  Read the grid
%
[latr,lonr,maskr]=oct_read_latlonmask(grdfile,'r');
dl=0.0;
minlat=min(min(latr))-dl;
maxlat=max(max(latr))+dl;
minlon=min(min(lonr))-dl;
maxlon=max(max(lonr))+dl;
%
%  Read the global rivers
%
% netcdf.getVar returns Fortran order: 2D variables are transposed
ncidriv = netcdf.open(global_clim_river, 'NC_NOWRITE');
time=double(netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'time')));
lonriv_mou=double(netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'lon_mou')));
latriv_mou=double(netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'lat_mou')));
ct_name=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'ct_name')).';   % (station,chars)
cn_name=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'cn_name')).';   % (station,chars)
wstate_=warning('off','all');
riv_name=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'riv_name')).';   % (station,chars)
ocn_name=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'ocn_name')).';   % (station,chars)
stn_name=netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'stn_name')).';   % (station,chars)
warning(wstate_);
FLOW_clm=double(netcdf.getVar(ncidriv, netcdf.inqVarID(ncidriv, 'FLOW_clm'))).';   % (twelve,station)
netcdf.close(ncidriv);
%size(FLOW_clm)
%
% Select the rivers in the domain grid
%-------------------------------------
%
%========================================
%River selection criteria
maxmaxflow=(max(max(FLOW_clm)));
maxflow=(max(FLOW_clm)');  % attention transpose

meanflowmax=mean(FLOW_clm(:,1));    % for the biggest
meanflow=oct_nanmean(FLOW_clm(:,:),1)'; % for others
%

%==========================================================================================================
%% => by default : all rivers in the domain 
rivdetectype='DEFAULT';
my_riv=find(latriv_mou>=minlat & latriv_mou<=maxlat & lonriv_mou >= minlon & lonriv_mou <= maxlon);

%==
% => megatl : rivers in the boxes + max value >= 20%*max val of the flow amazonia peak)
%rivdetectype='MEGATL';
%thold=0.1;
%thold=0.03;
%my_riv=find(latriv_mou>=minlat & latriv_mou<=maxlat & lonriv_mou >= minlon & lonriv_mou <= maxlon & meanflow >= thold.*meanflowmax);

% % => arvor : rivers in the boxes + max value >= 20%*max val of the flow orinoco peak)
% rivdetectype='ARVOR';
% %thold=0.1;
% thold=0.03;
% my_riv=find(latriv_mou>=minlat & latriv_mou<=maxlat & lonriv_mou >= minlon & lonriv_mou <= maxlon & meanflow >= thold.*meanflowmax);

%========================================
%
disp(['There are ',num2str(length(my_riv)),' rivers in the domain : '])
disp(['===='])
disp(' ')
disp([' => Rivers detection type : ',rivdetectype,' (see in oct_runoff_glob_extract.m)'])
disp(' ')
disp(['===='])
disp(['There are ',num2str(length(my_riv)),' rivers in the domain : '])
disp(['Domain contains rivers :'])
for k=1:length(my_riv)
   disp([num2str(k),' - ',riv_name(my_riv(k),:),' flowing in ocean ',ocn_name(my_riv(k),1:4)])
end
my_flow=FLOW_clm(:,my_riv);
my_rivername=riv_name(my_riv,:);
number_river=length(my_riv);
my_latriv=latriv_mou(my_riv);
my_lonriv=lonriv_mou(my_riv);
%
% make a figure
%
if ~isempty(my_flow)
    figure(100)
    plot([1:12],my_flow)
    legend(my_rivername,'location','northeastoutside')
    box on, grid on
    title(['\bf Monthly clim of the domain run off'])
    xlabel(['\bf Month']);ylabel(['\bf Discharge in m3/s'])
    set(gca,'Xtick',[0.5:11.5],'XtickLabel',['J';'F';'M';'A';'M';'J';'J';'A';'S';'O';'N';'D']);
end
%
return
