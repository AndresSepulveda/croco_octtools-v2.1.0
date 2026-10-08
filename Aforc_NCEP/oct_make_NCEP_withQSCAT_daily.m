%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Build a CROCO forcing file
%
%  The program take the NCEP forcing [and bulk (optional)] file[s] 
%  and replace tx, ty[, u, w, w] with the QSCAT data 
%  
%  Usage : First use the oct_make_NCEP, then do the
%  oct_make_NCEP_withQSCAT_daily.m

%  Extrapole and interpole surface data to get surface boundary
%  conditions for CROCO (forcing netcdf file)
%
%  Data input format (netcdf):
%     taux(T, Y, X)
%     T : time [Months]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%  Data source : IRI/LDEO Climate Data Library 
%                (Atlas of Surface Marine Data 1994)
%
%    http://ingrid.ldgo.columbia.edu/
%    http://iridl.ldeo.columbia.edu/SOURCES/.DASILVA/
%
%  Pierrick Penven, IRD, 2002. 
%  Modified by Marchesiello, 2005, to use 
%             IFREMER/CERSAT MWF QuikSCAT daily winds.
%  Modified by Penven, jan 2007, to use OPENDAP.
%  Modified by S.Illig, March 2008
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Common parameters
%
crocotools_param
%
%
if NCEP_version==1
  ncep_frc_prefix=[frc_prefix,'_NCEP1_'];                           
  ncep_blk_prefix=[blk_prefix,'_NCEP1_'];
elseif NCEP_version==2
  ncep_frc_prefix=[frc_prefix,'_NCEP2_'];                           
  ncep_blk_prefix=[blk_prefix,'_NCEP2_'];
end
%
%
%
QSCAT_frc_prefix=[ncep_frc_prefix,'wQS_'];
QSCAT_blk_prefix=[ncep_blk_prefix,'wQS_'];
%
%
%
taux_name='taux';
tauy_name='tauy';


if QSCAT_blk==1
  uwnd_name='uwnd';
  vwnd_name='vwnd';
  wnds_name='wnds';
end
%
%
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Title
%
disp(' ')
disp(CROCO_title)
%
if level==0
  nc_suffix='.nc';
else
  nc_suffix=['.nc.',num2str(level)];
  grdname=[grdname,'.',num2str(level)];
end
%
% Get the model grid
%
ncid = netcdf.open(grdname, 'NC_NOWRITE');
lon=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'));
lat=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'));
angle=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'));
netcdf.close(ncid);
cosa = cos(angle);
sina = sin(angle);
%
[MMp,LLp]=size(lon);
%
% Extract data over the internet
%
if Download_data==1
  %
  % Get the model limits
  %
  lonmin=min(min(lon));
  lonmax=max(max(lon));
  latmin=min(min(lat));
  latmax=max(max(lat));
  %
  % Download QSCAT
  % 
  disp('Download QSCAT data with OPENDAP')
  oct_download_QSCAT(Ymin,Ymax,Mmin,Mmax,lonmin,lonmax,latmin,latmax,...
                 QSCAT_dir,Yorig,QSCAT_blk)
end
%
% Loop on the years and the months
%
for Y=Ymin:Ymax
  if Y==Ymin 
    mo_min=Mmin;
  else
    mo_min=1;
  end
  if Y==Ymax
    mo_max=Mmax;
  else
    mo_max=12;
  end
  for M=mo_min:mo_max
    disp('====================================================== ')
    disp(' ')
    disp(['Processing  year ',num2str(Y),' - month ',num2str(M)])
    disp(' ')
    
    %
    % Copy forcing and bulk NCEP files to NCEP modified by  QSCAT wind and
    % stress forcing and bulk file
    %    
    file_frc_ncep=[ncep_frc_prefix,'Y',num2str(Y),'M',num2str(sprintf(Mth_format,M)),'.nc'];
    file_frc_qscat=[QSCAT_frc_prefix,'Y',num2str(Y),'M',num2str(sprintf(Mth_format,M)),'.nc'];
    disp(['Copying NCEP file ',file_frc_ncep,' in NCEP_wQS file : ',file_frc_qscat])     
    copyfile(file_frc_ncep,file_frc_qscat,'f')

    if QSCAT_blk==1 
      file_blk_ncep=[ncep_blk_prefix,'Y',num2str(Y),'M',num2str(sprintf(Mth_format,M)),'.nc'];
      file_blk_qscat=[QSCAT_blk_prefix,'Y',num2str(Y),'M',num2str(sprintf(Mth_format,M)),'.nc'];    
      disp(['Copying NCEP file ',file_blk_ncep,' in NCEP_wQS file : ',file_blk_qscat])     
      copyfile(file_blk_ncep,file_blk_qscat,'f')
    end
    %
    % Process the QuickSCAT time (here in days)
    %
    ncid = netcdf.open([QSCAT_dir,'tauxY',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
    QSCAT_time=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time'));
    netcdf.close(ncid);
    dt=round(mean(gradient(QSCAT_time)));  
    %
    %   Add Overlapping points. 
    % 
    tlen0=length(QSCAT_time);
    tlen=tlen0+2*itolap_qscat;
    disp(['tlen=',num2str(tlen)])
    disp(['Overlap is ',num2str(itolap_qscat),' it of 1 days (time res. QSCAT)'])

    time=0*(1:tlen);
    time(itolap_qscat+1:end-itolap_qscat)=QSCAT_time;


    for aa=1:itolap_qscat
      time(aa)=time(itolap_qscat+1)-(itolap_qscat+1-aa)*dt;
    end    


    for aa=1:itolap_qscat
      time(tlen0+itolap_qscat+aa)=time(tlen0+itolap_qscat) + aa*dt;
    end     
    %
    % Initialize array 
    %
    u=zeros(MMp,LLp,tlen);
    v=u;
    if QSCAT_blk==1  
      xu=u;    
      yv=u;
      ws=u;
    end
    %
    % Create a CROCO forcing/bulk file for each month
    %
    ncid_frc = netcdf.open(file_frc_qscat, 'NC_WRITE');
    sms_time_ncep=netcdf.getVar(ncid_frc, netcdf.inqVarID(ncid_frc, 'sms_time'));

    if QSCAT_blk==1  
      ncid_blk = netcdf.open(file_blk_qscat, 'NC_WRITE');
      blk_time_ncep=netcdf.getVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'bulk_time')); 
    end
    %
    % Add the wind
    %
    % 1. Check if there are QSCAT files for the previous Month
    %
    Mm=M-1;
    Ym=Y;
    if Mm==0
      Mm=12;
      Ym=Y-1;
    end
    taux_file=[QSCAT_dir,'tauxY',num2str(Ym),'M',num2str(Mm),'.nc'];
    if exist(taux_file)==0
      disp(['   No data for the previous month: using current month'])
      tindex=ones(1,itolap_qscat);%on repete l''index tempo itolap_qscat fois !
      Mm=M;
      Ym=Y;
    else
      ncid = netcdf.open(taux_file, 'NC_NOWRITE');
      [~,pp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'time'));
      tindex=[pp-itolap_qscat+1:1:pp];
      %On prend les derniers pas de temps
      %ie les itolap_qscat denier pas de temps du mois prec.
      netcdf.close(ncid);
    end
    %
    % 2. Perform the interpolations for the previous month
    %
    disp(['-------'])
    disp(['Perform the interpolations for the previous month, quite long...'])
    disp(['-------'])
    taux_file=[QSCAT_dir,'tauxY',num2str(Ym),'M',num2str(Mm),'.nc'];
    tauy_file=[QSCAT_dir,'tauyY',num2str(Ym),'M',num2str(Mm),'.nc'];

    for i=1:itolap_qscat
      u(:,:,i)=oct_ext_data(taux_file,taux_name,tindex(i),...
                        lon,lat,[],Roa,2);
      v(:,:,i)=oct_ext_data(tauy_file,tauy_name,tindex(i),...
                        lon,lat,[],Roa,2);
    end

    if QSCAT_blk==1
      uwnd_file=[QSCAT_dir,'uwndY',num2str(Ym),'M',num2str(Mm),'.nc'];
      vwnd_file=[QSCAT_dir,'vwndY',num2str(Ym),'M',num2str(Mm),'.nc']; 
      wnds_file=[QSCAT_dir,'wndsY',num2str(Ym),'M',num2str(Mm),'.nc'];          
      
      for       i=1:itolap_qscat        
        xu(:,:,i)=oct_ext_data(uwnd_file,uwnd_name,tindex(i),...
                           lon,lat,[],Roa,2);
        yv(:,:,i)=oct_ext_data(vwnd_file,vwnd_name,tindex(i),...
                           lon,lat,[],Roa,2); 
        ws(:,:,i)=oct_ext_data(wnds_file,wnds_name,tindex(i),...
                           lon,lat,[],Roa,2); 
        
      end
      
    end
    %
    % 3. Perform the interpolations for the current month
    %
    disp(['-------'])
    disp(['Perform the interpolations for the current month ...'])
    disp(['-------'])
    taux_file=[QSCAT_dir,'tauxY',num2str(Y),'M',num2str(M),'.nc'];
    tauy_file=[QSCAT_dir,'tauyY',num2str(Y),'M',num2str(M),'.nc'];
    for tindex=itolap_qscat+1:tlen-itolap_qscat
      u(:,:,tindex)=oct_ext_data(taux_file,taux_name,tindex-itolap_qscat,...
                             lon,lat,[],Roa,2);
      v(:,:,tindex)=oct_ext_data(tauy_file,tauy_name,tindex-itolap_qscat,...
                             lon,lat,[],Roa,2);
    end

    if QSCAT_blk==1 
      uwnd_file=[QSCAT_dir,'uwndY',num2str(Y),'M',num2str(M),'.nc'];
      vwnd_file=[QSCAT_dir,'vwndY',num2str(Y),'M',num2str(M),'.nc']; 
      wnds_file=[QSCAT_dir,'wndsY',num2str(Y),'M',num2str(M),'.nc'];
      
      for tindex=itolap_qscat+1:tlen-itolap_qscat
        xu(:,:,tindex)=oct_ext_data(uwnd_file,uwnd_name,tindex-itolap_qscat,...
                                lon,lat,[],Roa,2);
        yv(:,:,tindex)=oct_ext_data(vwnd_file,vwnd_name,tindex-itolap_qscat,...
                                lon,lat,[],Roa,2); 
        ws(:,:,tindex)=oct_ext_data(wnds_file,wnds_name,tindex-itolap_qscat,...
                                lon,lat,[],Roa,2); 
      end
    end
    %
    % 4. Read the QSCAT file for the next month
    %
    Mp=M+1;
    Yp=Y;
    if Mp==13
      Mp=1;
      Yp=Y+1;
    end
    taux_file=[QSCAT_dir,'tauxY',num2str(Yp),'M',num2str(Mp),'.nc'];
    if exist(taux_file)==0
      disp(['No data for the next month: using current month'])
      %      tindex=tlen-2;
      tindex = (tlen-2*itolap_qscat).*ones(1,itolap_qscat)
      Mp=M;
      Yp=Y;
    else
      tindex=[1:itolap_qscat];
    end
    %
    % 5. Perform the interpolations for the next month
    %
    disp(['-------'])
    disp(['Perform the interpolations for the next month ...'])
    disp(['-------'])
    taux_file=[QSCAT_dir,'tauxY',num2str(Yp),'M',num2str(Mp),'.nc'];
    tauy_file=[QSCAT_dir,'tauyY',num2str(Yp),'M',num2str(Mp),'.nc'];

    for i=tlen-itolap_qscat+1 : tlen
      %    disp(['i - (itolap_qscat+tlen0)=',num2str( i - (itolap_qscat+tlen0) )])
      %    disp(['tindex(i - (itolap_qscat+tlen0))=',num2str( tindex(i - (itolap_qscat+tlen0)) )])
      u(:,:,i)=oct_ext_data(taux_file,taux_name,tindex(i - (itolap_qscat+tlen0)  ),...
                        lon,lat,[],Roa,2);
      v(:,:,i)=oct_ext_data(tauy_file,tauy_name,tindex(i - (itolap_qscat+tlen0) ),...
                        lon,lat,[],Roa,2);
    end
    %    
    if QSCAT_blk==1 
      uwnd_file=[QSCAT_dir,'uwndY',num2str(Yp),'M',num2str(Mp),'.nc'];
      vwnd_file=[QSCAT_dir,'vwndY',num2str(Yp),'M',num2str(Mp),'.nc']; 
      wnds_file=[QSCAT_dir,'wndsY',num2str(Yp),'M',num2str(Mp),'.nc'];
      
      for i=tlen-itolap_qscat+1 : tlen  
        xu(:,:,i)=oct_ext_data(uwnd_file,uwnd_name,tindex(i - (itolap_qscat+tlen0) ),lon,lat,[],Roa,2);
        yv(:,:,i)=oct_ext_data(vwnd_file,vwnd_name,tindex(i - (itolap_qscat+tlen0) ),lon,lat,[],Roa,2); 
        ws(:,:,i)=oct_ext_data(wnds_file,wnds_name,tindex(i - (itolap_qscat+tlen0) ),lon,lat,[],Roa,2);
      end
    end    
    %
    % Initialisation of fields for the time interpolation
    % QSCAT TIME (1per day -->  NCEP_TIME 4 per day)
    %
    disp(['-------'])
    disp(['Initialization of field to be interpolated in time'])
    disp(['-------'])

    ny=size(u,1);
    nx=size(u,2); 
    nt=size(u,3); 
    nt2=size(sms_time_ncep,1);
    %
    uu=zeros(ny,nx,nt2);
    vv=zeros(ny,nx,nt2); 

	if QSCAT_blk==1
	  uuwnd=zeros(ny,nx,nt2);
	  vvwnd=zeros(ny,nx,nt2);
	  wwnds=zeros(ny,nx,nt2);
	end
    %
    %
    % Proceed the time interpolation of QSCAT-modified NCEP frc/bulk file
    % (u,v,w for bulk and ustr and vstr for frc) on the NCEP time axis
    % 4X daily generaly
    %

    disp('--------------')
    disp(['Proceed time interpolation on NCEP time axis...'])    
    disp('--------------')

    tic
    for ii=1:nx
      for jj=1:ny
        uu(jj,ii,:)=interp1(time,squeeze(u(jj,ii,:)),sms_time_ncep,'cubic');  
        vv(jj,ii,:)=interp1(time,squeeze(v(jj,ii,:)),sms_time_ncep,'cubic'); 
        
        if QSCAT_blk==1   
          uuwnd(jj,ii,:)=interp1(time,squeeze(xu(jj,ii,:)),blk_time_ncep,'cubic');  
          vvwnd(jj,ii,:)=interp1(time,squeeze(yv(jj,ii,:)),blk_time_ncep,'cubic');  
          wwnds(jj,ii,:)=interp1(time,squeeze(ws(jj,ii,:)),blk_time_ncep,'cubic');
        end
        
      end
    end
    toc
    %
    % Fill the frc and/or bulk file 
    %
    disp('--------------')
    disp('Fill the frc and/or bulk file')
    disp('--------------')

    for ll=1:nt2
      u=squeeze(uu(:,:,ll));
      v=squeeze(vv(:,:,ll));      
      netcdf.putVar(ncid_frc, netcdf.inqVarID(ncid_frc, 'sustr'), ll,:,:-1, 1, oct_rho2u_2d(u.*cosa + v.*sina));  % [conv] 0-based
      netcdf.putVar(ncid_frc, netcdf.inqVarID(ncid_frc, 'svstr'), ll,:,:-1, 1, oct_rho2v_2d(v.*cosa - u.*sina));  % [conv] 0-based
      
      if QSCAT_blk==1  
        netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'sustr'), ll,:,:-1, 1, oct_rho2u_2d(u.*cosa + v.*sina));  % [conv] 0-based
        netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'svstr'), ll,:,:-1, 1, oct_rho2v_2d(v.*cosa - u.*sina));  % [conv] 0-based

        u=squeeze(uuwnd(:,:,ll));
        v=squeeze(vvwnd(:,:,ll));      
        netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'uwnd'), ll,:,:-1, 1, oct_rho2u_2d(u.*cosa + v.*sina));  % [conv] 0-based
        netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'vwnd'), ll,:,:-1, 1, oct_rho2v_2d(v.*cosa - u.*sina));  % [conv] 0-based
        
        
        netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'wspd'), ll,:,:-1, 1, squeeze(wwnds(:,:,ll)));  % [conv] 0-based
      end
      
    end
    netcdf.close(ncid_frc);
    %
    if QSCAT_blk==1
      netcdf.close(ncid_blk);
    end
    %
  end
end
disp('--------------')
disp(['Finish, you have now NCEP file (frc and/or bulk files) with',...
      ' wind speed and wind stress from QSCAT'])
disp('--------------')  

%
% Spin-up: (reproduce the first year 'SPIN_Long' times)
% just copy the files for the first year and change the time
%
if SPIN_Long>0
  M=Mmin-1;
  Y=Ymin-SPIN_Long;
  for month=1:12*SPIN_Long
    M=M+1;
    if M==13
      M=1; 
      Y=Y+1;
    end
    %
    % Forcing files
    %
    if makefrc==1
      %
      % Copy the file
      %
      frcname=[QSCAT_frc_prefix,'Y',num2str(Ymin),'M',num2str(sprintf(Mth_format,M)),nc_suffix];
      frcname2=[QSCAT_frc_prefix,'Y',num2str(Y),'M',num2str(sprintf(Mth_format,M)),nc_suffix];
      disp(['Create ',frcname2]) 
      system(['cp ',frcname,' ',frcname2]) 
      %
      % Change the time
      %
      ncid = netcdf.open(frcname2, 'NC_WRITE');
      time=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'sms_time'))+datenum(Yorig,1,1);
      [y,m,d,h,mi,s]=datevec(time);
      dy=Ymin-Y;
      y=y-dy;
      time=datenum(y,m,d,h,mi,s)-datenum(Yorig,1,1);
      %      disp(datestr(time+datenum(Yorig,1,1)))
      netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'sms_time'), time);
      netcdf.close(ncid);
    end
    %
    % Bulk files
    %
    if makeblk==1
      %
      % Copy the file
      %
      blkname=[QSCAT_blk_prefix,'Y',num2str(Ymin),'M',num2str(sprintf(Mth_format,M)),nc_suffix];
      blkname2=[QSCAT_blk_prefix,'Y',num2str(Y),'M',num2str(sprintf(Mth_format,M)),nc_suffix];
      disp(['Create ',blkname2]) 
      system(['cp ',blkname,' ',blkname2]) 
      %
      % Change the time
      %
      ncid = netcdf.open(blkname2, 'NC_WRITE');
      time=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'bulk_time'))+datenum(Yorig,1,1);
      [y,m,d,h,mi,s]=datevec(time);
      dy=Ymin-Y;
      y=y-dy;
      time=datenum(y,m,d,h,mi,s)-datenum(Yorig,1,1);
      %      disp(datestr(time+datenum(Yorig,1,1)))
      netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'bulk_time'), time);
      netcdf.close(ncid);
    end
  end
end


%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---------------------------------------------------------------
% Make a few plots
%---------------------------------------------------------------
if makeplot==1
  disp(' ')
  disp(' Make a few plots...')
  slides=[1 25 50 75];
  oct_test_forcing(file_frc_qscat,grdname,'svstr',slides,3,coastfileplot)
  figure
  oct_test_forcing(file_frc_qscat,grdname,'sustr',slides,3,coastfileplot)
  if QSCAT_blk==1  
    figure
    oct_test_forcing(file_blk_qscat,grdname,'uwnd',slides,3,coastfileplot)
    figure
    oct_test_forcing(file_blk_qscat,grdname,'vwnd',slides,3,coastfileplot)
    figure
    oct_test_forcing(file_blk_qscat,grdname,'wspd',slides,3,coastfileplot)
  end
end
