%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Animate Eddies from the eddy file
%
%
%  Pierrick Penven, IRD, 2011.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
clear all
close all
%
Re=6367442.76;
%
% Graphics options
%
coastfile='coastline_l.mat';
moviename='eddies_aviso';
%
Xfig=25; % Width of the Figure in cm
Yfig=20; % Height of the Figure in cm
msize=10;
%
% Range of SSH [cm]
%
zmin=-200;
dz=5;
zmax=200;
%
% Choose movie format
%
anim_gif=0;
anim_mpeg=1;
anim_fli=0;
%
% First date to process
%
day_start=20;
month_start=12;
year_start=2014;
%
% Last date to process
%
day_end=27;
month_end=12;
year_end=2014;
%
% Dates are defined as days since Yorig/1/1 00:00
%
Yorig=1900;
%
% Number of days between AVISO frames
% 
dt=1; 
%
% Domain limits 
%
lonmin =   8;   % Minimum longitude [degree east]
lonmax =  22;   % Maximum longitude [degree east]
latmin = -38;   % Minimum latitudeF  [degree north]
latmax = -26;   % Maximum latitude  [degree north]
%
% Eddies netcdf file name
%
eddyfile='eddies_aviso_2014_2014_select.nc';
%
% Eddies minimum life duration [days] 
% (to filter eddies out which have a too short duration)
%
eddy_life=7; % days
%
% AVISO absolute dynamic topography directory and names
%
%
AVISO_DIR='../AVISO/MADT_RENAME';
AVISO_TYPE='madt';
%
alti_prefix=[AVISO_DIR,'/',AVISO_TYPE,'_'];
alti_suffix='.nc';
%
% Topography file
%
usetopo=0; % option: 1 to use the topo (a topography file should be provided)
hmin=500;
%
TOPODIR = '../Topo/';
topofile = [TOPODIR,'etopo2.nc'];
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
%
% Check the number of eddy files
%
ncid = netcdf.open(eddyfile, 'NC_NOWRITE');
ID_all=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'ID'));
time_all=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time'));
lon_all=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon'));
lat_all=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat'));
Vort_all=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Vorticity'));
Radius_all=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Radius'));
U_all=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'U'));
V_all=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'V'));
netcdf.close(ncid);
%
% Select the eddies dates of birth and death for eddies who lived long enough
%
ngood=0;
for i=1:max(ID_all)

  indx=find(ID_all==i);
  teddy=time_all(indx);
  
  if teddy(end)-teddy(1)>=eddy_life

    ngood=ngood+1;
    ID_good(ngood)=i;  
    
    teddy_start(ngood)=teddy(1);
    teddy_end(ngood)=teddy(end);   

  end
end
%
% Time in days since 1/1/Yorig
%
tstart=oct_nearest_aviso_date(day_start,month_start,year_start,Yorig);
tend=oct_nearest_aviso_date(day_end,month_end,year_end,Yorig);
%
% Get the grid
%
strdate=datestr(tstart+datenum(Yorig,1,1),26);
date=strdate([1 2 3 4 6 7 9 10]);
fname_madt =[alti_prefix,date,alti_suffix];
[lon,lat,zeta]=oct_get_topex2014(lonmin,lonmax,latmin,latmax,fname_madt);
[lon,lat,f,pm,pn]=oct_get_tpx_grid(lon,lat);
[dx,dy]=oct_get_dx(lon,lat);
%
% Get the bottom topography
%
if usetopo==1
  h=interp_topo(lon,lat,dx,dy,toponame);
end
%
% Loop on time (and files)
%
fid = oct_fli_begin;
fr = 0;
for t=tstart:dt:tend
%
% Get the date
%
  strdate=datestr(t+datenum(Yorig,1,1),26);
  date=strdate([1 2 3 4 6 7 9 10]);
  disp(' ')
  disp(['Processing date ',strdate])
%
% Read SSH
%
  fname_madt =[alti_prefix,date,alti_suffix];
  [lon,lat,zeta]=oct_get_topex2014(lonmin,lonmax,latmin,latmax,fname_madt);
%
%
  h1=figure('Units','centimeters',...
            'Position',[1 1 Xfig Yfig],...
            'PaperPosition',[1 1 Xfig Yfig],...
            'PaperUnits','centimeters');
%
  m_proj('mercator',...
       'lon',[lonmin lonmax],...
       'lat',[latmin latmax]);
  h2=m_contour(lon,lat,100*zeta,[zmin:dz:zmax],'k');
%  shading flat
%  colorbar
  hold on
%
%  Select the proper eddies to plot
%
  ID_now=ID_good(teddy_start<=t & teddy_end>=t);
%
  for i=1:length(ID_now)
%
% Read 1 eddy
%
    eddy_indx=find(ID_all==ID_now(i));
    time_eddy=time_all(eddy_indx);
    lon_eddy=lon_all(eddy_indx);
    lat_eddy=lat_all(eddy_indx);
    Vort_eddy=Vort_all(eddy_indx);
    Radius_eddy=Radius_all(eddy_indx);
    U_eddy=U_all(eddy_indx);
    V_eddy=V_all(eddy_indx);
%    
    if sign(mean(Vort_eddy))==sign(mean(lat_eddy))
%
% This should be a cyclone : blue
%
      eddycol='b'; 
    else
%
% This should be an anticyclone : red
%
      eddycol='r'; 
    end
%
% Plot a line with the track of the eddy
%
    h3=m_plot(lon_eddy,lat_eddy,eddycol);
%    set(h3,'LineWidth',2)
%
% Plot the current status of the eddy
%
    n=find(time_eddy==t);
    Radi=(180/pi)*Radius_eddy(n)/(Re*cos(lat_eddy(n)*pi/180)) ;
    h4=oct_m_ellipse(Radi,Radi,0,lon_eddy(n),lat_eddy(n),eddycol); 
    m_plot(lon_eddy(n),lat_eddy(n),'o',...
	'MarkerEdgeColor',eddycol,'MarkerFaceColor',eddycol,'MarkerSize',5);
    set(h4,'lineWidth',2);
    h5=m_text(lon_eddy(n),lat_eddy(n),num2str(ID_now(i)));

    cff=10;
    h6=m_quiver(lon_eddy(n),lat_eddy(n),cff*U_eddy(n),cff*V_eddy(n),0);
    set(h6,'Color','m','LineWidth',1.5);

  end

  if usetopo==1
    m_contour(lon,lat,h,[hmin hmin],'y');
  end
  m_usercoast(coastfile,'patch',[.9 .9 .9]);
  m_grid('box','fancy','xtick',5,'ytick',5,'tickdir','out');
  title(['zeta [cm] ',strdate])
 
  hold off
  fr = fr + 1;
  oct_getframe_fli(fr,fid);
  close(h1)
end
%
% Get the movies...
%
if anim_mpeg==1
  system(['ppmtompeg ../Visualization_tools/inp_ppm2mpeg'])
  system(['mv movie.mpg ',moviename,'.mpg']);
end
if anim_gif==1
  system([' convert -delay 10 -loop 0 *.ppm ',moviename,'.gif'])
end
if anim_fli==1
  oct_fli_end(fid,[moviename,'.fli']);
else
  oct_clean_ppm('.ppm.list');
end
return
