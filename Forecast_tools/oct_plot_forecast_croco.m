%*********************************************************
% plot CROCO forecast analysis at noon of each day
%*********************************************************
clear all
close all
oct_start
crocotools_param
as_consts % load constants

disp('Forecast analysis')
%********************************************************
%            User defined parameters
%
dirin     = './';
dirout    = './Figs/';
if ~exist(dirout,'dir'), mkdir(dirout); end
grdname   = [dirin,'SCRATCH/croco_grd.nc'];
frcname   = [dirin,'SCRATCH/croco_frc_GFS_0.nc'];
hisname   = [dirin,'SCRATCH/croco_his.nc'];
avgname   = [dirin,'SCRATCH/croco_avg.nc'];
coastfile = [dirin,'coastline_l.mat'];

skip_wnd  =  2;
skip_cur  =  2;
zoom      =  0;
fsize     = 14;   % Font size
nx        =  3;   % number of forecast days
%
titlemark = ['CROCO: ',datestr(now)];

mean_currents = 0;  % 1: plot 0-500 mean currents
                    % 0: surface currents

plot_fig_1 = 0; % wind
plot_fig_2 = 1; % surface currents
plot_fig_3 = 1; % SST + surface currents
plot_fig_4 = 1; % SSH
plot_fig_5 = 1; % HBL

% offset to convert UTC model time 
% into local matlab time [days]
days_off = timezone/24+datenum(Yorig,1,1); 
%
%************ End of users's defined parameter ************
%
today=floor(now);
%
% date in 'Yorig' time
%
rundate=datenum(today)-datenum(Yorig,1,1);
%
ncid = netcdf.open(grdname, 'NC_NOWRITE');
lon=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'));
lat=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'));
h=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'));
mask=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'));
angle=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'));
netcdf.close(ncid);
mask(mask==0)=NaN;
%
ncid = netcdf.open(avgname, 'NC_NOWRITE');
[~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
netcdf.close(ncid);
[M L]=size(lon);
Mu=M; Lu=L-1; Mv=M-1; Lv=L;
zeta(1:M,1:L)=0;
zw=oct_zlevs(h,zeta,theta_s,theta_b,hc,N,'w',vtransform);
zu=oct_rho2u_3d(zw);
zv=oct_rho2v_3d(zw);
dzu=zu(2:end,:,:)-zu(1:end-1,:,:);
dzv=zv(2:end,:,:)-zv(1:end-1,:,:);
%
% coastline
%bounds=[lonmin lonmax latmin latmax]; res='l';
%coastfile=oct_make_coast2(bounds,res)
%
barwidth=0.5;
barheight=0.04;
titleheight=0.01;
hmargin=0.025;
vmargin=0.10;
clear title;

if plot_fig_1,
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 1: wind
%
 disp('Plot winds ...')
 itime=0;
 cmin=0; cint=5; cmax=30; cff_wnd=.4; % winds
 [LON,LAT]=meshgrid([lonmin:1/3:lonmax],[latmin:1/3:latmax]);
 ncid = netcdf.open(frcname, 'NC_NOWRITE');
 smstime=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'sms_time'));
 smstime0=floor(now)-datenum(Yorig,1,1)-1/24-1;  %midday
 for tndx=hdays+1:nx+hdays
  smstime0=smstime0+1;
  itime=itime+1;
  disp(['Day ',num2str(itime)])
  outname=['WIND',num2str(itime)];
  close all
  figure('position',[5 5 1000 600]);
  subplot('position',[0 0.2 1 .75]);
  istr=max(find(smstime<=smstime0));
  iend=min(find(smstime>=smstime0));
  u1=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'sustr')));
  v1=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'svstr')));
  u2=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'sustr')));
  v2=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'svstr')));
  u=(u1*(smstime(iend)-smstime0)+u2*(smstime0-smstime(istr)))/ ...
                                (smstime(iend)-smstime(istr));
  v=(v1*(smstime(iend)-smstime0)+v2*(smstime0-smstime(istr)))/ ...
                                (smstime(iend)-smstime(istr));
  stress=sqrt((oct_u2rho_2d(u)).^2+(oct_v2rho_2d(v)).^2);
  [ur,vr,lonr,latr,maskr]=oct_uv_vec2rho(u,v,lon,lat,angle,mask,skip_wnd,[0 0 0 0]);

  spd=1.94384*sqrt(stress./(rho_air*1.15e-3));
  spdr=sqrt(ur.^2+vr.^2)./(rho_air*1.15e-3);
  ur=1.94384*ur./(rho_air*1.15e-3*spdr);
  vr=1.94384*vr./(rho_air*1.15e-3*spdr);

  U=interp2(lonr,latr,ur,LON,LAT);
  V=interp2(lonr,latr,vr,LON,LAT);

  m_proj('mercator',...
       'lon',[lonmin lonmax],...
       'lat',[latmin latmax]);
% [C0,h0]=oct_m_contourf(lon,lat,stress,[0:0.04:0.3],'k');
  [C0,h0]=oct_m_contourf(lon,lat,spd,[cmin:cint:cmax],'k');
  shading flat
  caxis([cmin cmax])
  hold on
  %h=m_quiver(lonr,latr,cff_wnd*ur,cff_wnd*vr,0,'k'); hold on;
  h=m_streamslice(LON,LAT,U,V,1); hold on;
  %m_streamslice(lonr,latr,ur,vr,1); hold on;
  set(h,'color','b');
  if ~isempty(coastfile)  
    m_usercoast(coastfile,'patch',[.0 .0 .0]);
    %m_usercoast(coastfile,'line', 'color', 'black', 'linewidth', 2);
  else
     m_gshhs_f('patch',[.7 .7 .7],'edgecolor','k')
  end
  hold off
  m_grid('box','fancy','tickdir','in','FontSize',fsize);
  set(findobj('tag','m_grid_color'),'facecolor','white')
  title([datestr(smstime0+days_off,1)],'FontSize',fsize+1)
  ht=m_text(lonmax,latmax+.5,titlemark);
  set(ht,'horizontalalignment','right','fontsize',fsize-4,'Color','b');
  set(gca,'Layer','top');
  subplot('Position',[0.5-0.5*barwidth vmargin barwidth barheight])
  colormap(1-copper)
  x=[0:1];
  y=[cmin:cint:cmax];
  [X,Y]=meshgrid(x,y);
  contourf(Y,X,Y,y)
  caxis([cmin cmax])
  set(gca,'XTick',[cmin:cint:cmax],'YTickLabel',[' '])
  set(gca,'FontSize',fsize)
  set(gca,'Layer','top');
%  xlabel('Wind Stress [N m^{-2}]','FontSize',fsize)
  xlabel('Wind [knots]','FontSize',fsize)
  set(gcf, 'PaperPositionMode', 'auto');

  export_fig -transparent file.jpg
  system([' mv -f file.jpg ',dirout,outname,'.jpg']);
  %eval(['print -bestfit -dpdf',dirout,outname,'.pdf']);
 end
netcdf.close(ncid);
end % plot_fig_1

if plot_fig_2,
%
% 2: Surface currents
%
disp('Plot surface currents ...')
itime=0;
cmin=0; cint=0.1; cmax=2.0; cff_cur=2; 
for tndx=hdays+1:nx+hdays
  itime=itime+1;
  disp(['Day ',num2str(itime)])
  outname=['FLOW',num2str(itime)];
  close all
  figure('position',[5 5 1000 600]);
  subplot('position',[0 0.2 1 .75]);

  ncid = netcdf.open(avgname, 'NC_NOWRITE');
  scrumtime=[];
  scrumtime=(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'scrum_time')))/86400+days_off;
  if ~isempty(scrumtime)
    U=zeros(Mu,Lu);
    V=zeros(Mv,Lv);
    [~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
    if mean_currents,
      u=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'u')));
      v=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'v')));
      for j=1:Mu; for i=1:Lu; for k=N:-1:1;
        if zu(k,j,i)>-500,
          U(j,i)=U(j,i)+u(k,j,i).*dzu(k,j,i);
          hu(j,i)=-zu(k,j,i);
        end;
      end; end; end;
      clear u; u=U./hu; clear U;
      for j=1:Mv; for i=1:Lv; for k=N:-1:1;
        if zv(k,j,i)>-500,
          V(j,i)=V(j,i)+v(k,j,i).*dzv(k,j,i);
          hv(j,i)=-zv(k,j,i);
        end;
      end; end; end;
      clear v; v=V./hv; clear V;
    else
      u=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'u')));
      v=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'v')));
    end
    netcdf.close(ncid);

    spd=1.94384*mask.*sqrt((oct_u2rho_2d(u)).^2+(oct_v2rho_2d(v)).^2);
    %spd=oct_get_missing_val(lon,lat,spd); % in batch mode, do not render properly with m_contour + m_usercoast
    [ur,vr,lonr,latr,maskr]=oct_uv_vec2rho(u,v,lon,lat,angle,mask,skip_cur,[0 0 0 0]);

    m_proj('mercator',...
       'lon',[lonmin lonmax],...
       'lat',[latmin latmax]);
    [C0,h0]=oct_m_contourf(lon,lat,spd,[cmin:cint:cmax],'k');
    shading flat
    caxis([cmin cmax])
    hold on
    m_quiver(lonr,latr,cff_cur*ur,cff_cur*vr,0,'k');
    if ~isempty(coastfile)  
        m_usercoast(coastfile,'patch',[.0 .0 .0]);
        %m_usercoast(coastfile,'line', 'color', 'black', 'linewidth', 2);
    else
     m_gshhs_f('patch',[.7 .7 .7],'edgecolor','k')
    end
    hold off
    m_grid('box','fancy','tickdir','in','FontSize',fsize);
    set(findobj('tag','m_grid_color'),'facecolor','white')
    title([datestr(scrumtime,1)],'FontSize',fsize+1)
    ht=m_text(lonmax,latmax+.5,titlemark);
    set(ht,'horizontalalignment','right','fontsize',fsize-3,'Color','b');
    set(gca,'Layer','top');
    subplot('Position',[0.5-0.5*barwidth vmargin barwidth barheight])
    colormap(1-copper)
    x=[0:1];
    y=[cmin:cint:cmax];
    [X,Y]=meshgrid(x,y);
    caxis([cmin cmax])
    contourf(Y,X,Y,y)
    set(gca,'XTick',[cmin:cint:cmax],'YTickLabel',[' '])
    set(gca,'FontSize',fsize)
    set(gca,'Layer','top');
    if mean_currents,
      xlabel('0-500m mean currents [Knots]','FontSize',fsize)
    else
      xlabel('Surface currents [Knots]','FontSize',fsize)
    end
    set(gcf, 'PaperPositionMode', 'auto');

    export_fig -transparent file.jpg
    system([' mv -f file.jpg ',dirout,outname,'.jpg']);
    %eval(['print -bestfit -dpdf ',dirout,outname,'.pdf
  end
end
end % plot_fig_2

if plot_fig_3,
%
% 3: SST and Surface Currents
%
disp('Plot SST and surface currents ...')
itime=0;
ncid = netcdf.open(avgname, 'NC_NOWRITE');
sst=mask.*squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'temp')));
netcdf.close(ncid);
cmin=floor(min(min(sst)));
cmax= ceil(max(max(sst)));
cint=1; cff_cur=1.5;
%cmin=13; cmax=20;
for tndx=hdays+1:nx+hdays
  itime=itime+1;
  disp(['Day ',num2str(itime)])
  outname=['SST',num2str(itime)];
  close all
  figure('position',[5 5 1000 600]);
  subplot('position',[0 0.2 1 .75]);

  ncid = netcdf.open(avgname, 'NC_NOWRITE');
  scrumtime=[];
  scrumtime=(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'scrum_time')))/86400+days_off;
  if ~isempty(scrumtime)
    [~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
    sst=mask.*squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'temp')));
    u=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'u')));
    v=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'v')));
    netcdf.close(ncid);
    [ur,vr,lonr,latr,maskr]=oct_uv_vec2rho(u,v,lon,lat,angle,mask,skip_cur,[0 0 0 0]);
    spdr=sqrt(ur.^2+vr.^2);
    %sst=oct_get_missing_val(lon,lat,sst); % in batch mode, do not render properly with m_contour + m_usercoast
    %ur=oct_get_missing_val(lonr,latr,ur); 
    %vr=oct_get_missing_val(lonr,latr,vr);

    %plot_res=1/3;
    %[LON,LAT]=meshgrid([lonmin:plot_res:lonmax],[latmin:plot_res:latmax]);
    %U=interp2(lonr,latr,ur,LON,LAT);
    %V=interp2(lonr,latr,vr,LON,LAT);

    m_proj('mercator',...
         'lon',[lonmin lonmax],...
         'lat',[latmin latmax]);
    [C0,h0]=oct_m_contourf(lon,lat,sst,[cmin:cint:cmax],'k');
    %m_pcolor(lon,lat,sst);
    shading flat
    caxis([cmin cmax])
    hold on
    m_quiver(lonr,latr,cff_cur*ur,cff_cur*vr,0,'k');
    %m_streamslice(LON,LAT,U,V,2);
    if ~isempty(coastfile)  
        m_usercoast(coastfile,'patch',[.0 .0 .0]);
        %m_usercoast(coastfile,'line', 'color', 'black', 'linewidth', 2);
    else
     m_gshhs_f('patch',[.7 .7 .7],'edgecolor','k')
    end
    hold off
    m_grid('box','fancy','tickdir','in','FontSize',fsize-2);
    set(findobj('tag','m_grid_color'),'facecolor','white')
    title([datestr(scrumtime,1)],'FontSize',fsize+1);
    ht=m_text(lonmax,latmax+.5,titlemark);
    set(ht,'horizontalalignment','right','fontsize',fsize-3,'Color','b');
    set(gca,'Layer','top');

    subplot('Position',[0.5-0.5*barwidth vmargin barwidth barheight])
    x=[0:1];
    y=[cmin:cint:cmax];
    [X,Y]=meshgrid(x,y);
    caxis([cmin cmax])
    contourf(Y,X,Y,y)
    set(gca,'XTick',[cmin:cint:cmax],'YTickLabel',[' '])
    set(gca,'FontSize',fsize)
    set(gca,'Layer','top');
    xlabel('SST [^{o}C]','FontSize',fsize)
    set(gcf, 'PaperPositionMode', 'auto');

    export_fig -transparent file.jpg
    system([' mv -f file.jpg ',dirout,outname,'.jpg']);
    %export_fig -transparent file.pdf
    %system([' mv -f file.pdf ',dirout,outname,'.pdf']);
    %eval(['print -bestfit -dpdf ',dirout,outname,'.pdf']);
  end
end
end % plot_fig_3
%
if plot_fig_4,
%
% 4: Sea Surface Height
%
disp('Plot SSH ...')
itime=0;
cmin=-50; cint=5; cmax=50;
for tndx=hdays+1:nx+hdays
  itime=itime+1;
  disp(['Day ',num2str(itime)])
  outname=['SSH',num2str(itime)];
  close all
  figure('position',[5 5 1000 600]);
  subplot('position',[0 0.2 1 .75]);

  ncid = netcdf.open(avgname, 'NC_NOWRITE');
  scrumtime=[];
  scrumtime=(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'scrum_time')))/86400+days_off;
  if ~isempty(scrumtime)
    [~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
    ssh=100*squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'zeta')));
    ssh=(ssh-mean(mean(ssh))).*mask;
    netcdf.close(ncid);
    %ssh=oct_get_missing_val(lon,lat,ssh); % in batch mode, do not render properly with m_contour + m_usercoast

    m_proj('mercator','lon',[lonmin lonmax],'lat',[latmin latmax]);
    [C0,h0]=oct_m_contourf(lon,lat,ssh,[cmin:cint:cmax]);
    shading flat
    caxis([cmin cmax])
    if ~isempty(coastfile)  
     m_usercoast(coastfile,'patch',[.0 .0 .0]);
     %m_usercoast(coastfile,'line', 'color', 'black', 'linewidth', 2);
    else
     m_gshhs_f('patch',[.7 .7 .7],'edgecolor','k')
    end
    m_grid('box','fancy','tickdir','in','FontSize',fsize-2);
    set(findobj('tag','m_grid_color'),'facecolor','white')
    title([datestr(scrumtime,1)],'FontSize',fsize+1)
	ht=m_text(lonmax,latmax+.5,titlemark);
    set(ht,'horizontalalignment','right','fontsize',fsize-3,'Color','b');
    set(gca,'Layer','top');

    subplot('Position',[0.5-0.5*barwidth vmargin barwidth barheight])
    x=[0:1];
    y=[cmin:cint:cmax];
    [X,Y]=meshgrid(x,y);
    caxis([cmin cmax])
    contourf(Y,X,Y,y)
    set(gca,'XTick',[cmin:cint:cmax],'YTickLabel',[' '])
    set(gca,'FontSize',fsize)
    set(gca,'Layer','top');
    xlabel('SSH [cm]','FontSize',fsize)
    set(gcf, 'PaperPositionMode', 'auto');

    export_fig -transparent file.jpg
    system([' mv -f file.jpg ',dirout,outname,'.jpg']);
    %eval(['print -bestfit -dpdf ',dirout,outname,'.pdf']);
  end
end
end % plot_fig_4

if plot_fig_5,
%
% 5: Surface Boundary Layer Depth
%
disp('Plot HBL ...')
itime=0;
cmin=0; cint=10; cmax=100;
for tndx=hdays+1:nx+hdays
  itime=itime+1;
  disp(['Day ',num2str(itime)])
  outname=['HBL',num2str(itime)];
  close all
  figure('position',[5 5 1000 600]);
  subplot('position',[0 0.2 1 .75]);

  ncid = netcdf.open(avgname, 'NC_NOWRITE');
  scrumtime=[];
  scrumtime=(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'scrum_time')))/86400+days_off;
  if ~isempty(scrumtime)
    hbl=mask.*squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'hbl')));
    netcdf.close(ncid);
    %hbl=oct_get_missing_val(lon,lat,hbl); % in batch mode, do not render properly with m_contour + m_usercoast

    m_proj('mercator','lon',[lonmin lonmax],'lat',[latmin latmax]);
    %[C0,h0]=oct_m_contourf(lon,lat,ssh,[cmin:cint:cmax]);
    %shading flat
    m_pcolor(lon,lat,hbl);shading flat;
    caxis([cmin cmax])
    if ~isempty(coastfile)  
     m_usercoast(coastfile,'patch',[.0 .0 .0]);
     %m_usercoast(coastfile,'line', 'color', 'black', 'linewidth', 2);
    else
     m_gshhs_f('patch',[.7 .7 .7],'edgecolor','k');
    end
    m_grid('box','fancy','tickdir','in','FontSize',fsize-2);
    set(findobj('tag','m_grid_color'),'facecolor','white')
    title([datestr(scrumtime,1)],'FontSize',fsize+1)
	ht=m_text(lonmax,latmax+.5,titlemark);
    set(ht,'horizontalalignment','right','fontsize',fsize-3,'Color','b');
    set(gca,'Layer','top');

    subplot('Position',[0.5-0.5*barwidth vmargin barwidth barheight])
    x=[0:1];
    y=[cmin:cint:cmax];
    [X,Y]=meshgrid(x,y);
    caxis([cmin cmax])
    contourf(Y,X,Y,y)
    set(gca,'XTick',[cmin:cint:cmax],'YTickLabel',[' '])
    set(gca,'FontSize',fsize)
    set(gca,'Layer','top');
    xlabel('HBL [m]','FontSize',fsize)
    set(gcf, 'PaperPositionMode', 'auto');

    export_fig -transparent file.jpg
    system([' mv -f file.jpg ',dirout,outname,'.jpg']);
    %eval(['print  -bestfit -dpdf ',dirout,outname,'.pdf']);
  end
end
end % plot_fig_5


