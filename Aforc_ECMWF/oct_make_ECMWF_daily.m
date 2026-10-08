%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  oct_make_ECMWF_daily.m
% 
%  Create and fill frc and bulk files with ECMWF data.
%  (ERA INTERIM Reanalysis)
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
%  Copyright (c) 2005-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
% 
%  Adapted from a previous verions from
%  Alvaro Peliz (U. Aveiro) & Patrick Marchesiello (IRD) - 2005
%  Created by Serena Illig 2010
%
%  Updated    January 2016 (S. Illig and E. Cadier)
%  Updated    November 2016 (P. Marchesiello)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Common parameters
%
crocotools_param
%
  frc_prefix=[frc_prefix,'_ECMWF_'];                           
  blk_prefix=[blk_prefix,'_ECMWF_'];
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% end of user input  parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
disp(' ')
disp([' Read the grid in ',grdname])
ncid = netcdf.open(grdname, 'NC_NOWRITE');
[~,Lp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_rho'));
[~,Mp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_rho'));
lon=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'));
lat=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'));
lonu=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_u'));
latu=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_u'));
lonv=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_v'));
latv=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_v'));
angle=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'));
netcdf.close(ncid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract data from global Grib format saved on my computer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if Reformat_ECMWF==1
  %
  % Download ECMWF
  %
  disp(['===================='])
  disp('Get ECMWF data from my DOWNLAODED data')
  disp(['===================='])

  oct_reformat_ECMWF_daily(Ymin,Ymax,Mmin,Mmax,lonmin,lonmax,latmin,latmax,...
                ECMWF_dir,Yorig,My_ECMWF_dir)
  disp(['====================='])
  disp(['REFORMAT STEP FINISH'])
  disp(['====================='])
end

if makefrc==1 | makeblk==1
  %
  % Get the ECMWF horizontal grids (it should be the same for every month)
  %
  ncid = netcdf.open([ECMWF_dir,'land_Y',num2str(Ymin),'M',num2str(Mmin),'.nc'], 'NC_NOWRITE');
  disp(['Use this land file :',char([ECMWF_dir,'land_Y',num2str(Ymin),'M',num2str(Mmin),'.nc'])])

  lon1=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon'));
  lat1=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat'));
  [lon1,lat1]=meshgrid(lon1,lat1);
  
  
  mask=1-squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'land')));
  mask(mask==0)=NaN;  
  netcdf.close(ncid);
  
  %
  %Loop on the years and the months
  %
  disp(['====================='])
  disp(['INTERPOLATION STEP'])
  disp(['====================='])
  disp(['Loop on the years and the months'])

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
      disp(' ')
      disp(['Processing  year ',num2str(Y),...
            ' - month ',num2str(M)])
      disp(' ')
      %-------------------------------------------------------------------%
      %
      % Process time (here in days), with SST file (minimum time step)
      %
      %-------------------------------------------------------------------%
      ncid = netcdf.open([ECMWF_dir,'SSTK_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
      ECMWF_time=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time'));
      netcdf.close(ncid);
      dt=mean(gradient(ECMWF_time));
      disp(['dt=',num2str(dt)])
      %-----------------------------------------------------------
      %Variable overlapping timesteps : 2 at the beginning and 2 at the end
      %------------------------------------------------------------
      tlen0=length(ECMWF_time);
      disp(['tlen0=',num2str(tlen0)])
      tlen=tlen0+2*itolap_ecmwf;
      disp(['tlen=',num2str(tlen)])
      disp(['Overlap is ',num2str(itolap_ecmwf),' days'])
      disp(['Overlap is ',num2str(itolap_ecmwf),' days before and after'])     
      time=0*(1:tlen);
      time(itolap_ecmwf+1:tlen0+itolap_ecmwf)=ECMWF_time;   
      disp(['====================='])
      disp('Compute time for croco file')
      disp(['====================='])
      for aa=1:itolap_ecmwf
        time(aa)=time(itolap_ecmwf+1)-(itolap_ecmwf+1-aa)*dt;
      end
      
      for aa=1:itolap_ecmwf
	    time(tlen0+itolap_ecmwf+aa)=time(tlen0+itolap_ecmwf)+aa*dt;
      end
      %-------------------------------------------------------------------%
      %
      % Create the CROCO forcing files
      %
      % ------------------------------------------------------------------%
      %
      disp(['====================='])
      disp('Create the frc/blk netcdf file')
      disp(['====================='])
      %
      blkname=[blk_prefix,'Y',num2str(Y),...
               'M',num2str(sprintf(Mth_format,M)),nc_suffix];
      frcname=[frc_prefix,'Y',num2str(Y),...
               'M',num2str(sprintf(Mth_format,M)),nc_suffix];
      if makeblk==1
        disp(['Create a new bulk file: ' blkname])
        oct_create_bulk(blkname,grdname,CROCO_title,time,0);
        oct_nc_add_globatt(blkname,Yorig,Mmin,Dmin,Hmin,Min_min,Smin,'ERAI'); 
	      disp([' '])
      end
      if makefrc==1
        disp(['Create a new forcing file: ' frcname])
	      disp([' '])
        oct_create_forcing(frcname,grdname,CROCO_title,...
                       time,0,0,0,0,0,0,0,0,0,0,0) 
        oct_nc_add_globatt(frcname,Yorig,Mmin,Dmin,Hmin,Min_min,Smin,'ERAI'); 
        if add_tides==1
          oct_add_tidal_data(tidename,grdname,frcname,Ntides,tidalrank,...
                         Yorig,Y,M,coastfileplot,0,1,1,salname)
        end
      end
      %
      % Open the CROCO forcing files
      if makefrc==1
        ncid_frc = netcdf.open(frcname, 'NC_WRITE');
      else
        ncid_frc=[];
      end
      if makeblk==1
        ncid_blk = netcdf.open(blkname, 'NC_WRITE');
      else
        ncid_blk=[];
      end
      %
      % Check if there are ECMWF files for the previous Month
      Mm=M-1;
      Ym=Y;
      if Mm==0
        Mm=12;
        Ym=Y-1;
      end
      %
	  fname =   [ECMWF_dir,'TP_Y',num2str(Ym),'M',num2str(Mm),'.nc'];
	  %nc=oct_netcdf([ECMWF_dir,'TP_Y',num2str(Ym),'M',num2str(Mm),'.nc']);
      %
      disp(' ')
      disp('======================================================')
      disp('Perform interpolations for the previous month')      
      disp('======================================================')
      disp(' ')
      if exist(fname)==0
        disp(['No data for the previous month: using current month'])
        tndx=1;
        Mm=M;
        Ym=Y;
      else
        ncid = netcdf.open(fname, 'NC_NOWRITE');
        [~,tndx]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'time'));
	    if makefrc==1
          for aa=1:itolap_ecmwf
	     netcdf.putVar(ncid_frc, netcdf.inqVarID(ncid_frc, 'sms_time'), aa-1, 1, netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time'))));  % [conv] 0-based
          end
        end
	    %
        if makeblk==1
          for aa=1:itolap_ecmwf
	      netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'bulk_time'), aa-1, 1, netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time'))));  % [conv] 0-based
	  end
        end
	    netcdf.close(ncid);
      end
      %
      % Perform interpolations for the previous month or repeat the first one
      %
      for aa=1:itolap_ecmwf
	    aa0=itolap_ecmwf-aa; 
	    oct_interp_ECMWF(ECMWF_dir,Ym,Mm,Roa,interp_method,lon1,lat1,...
		    mask,tndx-aa0,ncid_frc,ncid_blk,lon,lat,angle,aa)
      end  
      %######################################################################      
      %   
      disp(' ')
      disp('======================================================')
      disp('Perform interpolations for the current month')
      disp('======================================================')
      disp(' ')

      % Perform interpolations for the current month
      %

      for tndx=1:tlen0
        if mod(tndx,5)==0
          disp(['Step: ',num2str(tndx),' of ',num2str(tlen0)])
        end
	    oct_interp_ECMWF(ECMWF_dir,Y,M,Roa,interp_method,lon1,lat1,...
		    mask,tndx,ncid_frc,ncid_blk,lon,lat,angle,tndx+itolap_ecmwf)	
      end

      disp(' ')      
      disp('======================================================')
      disp('Perform interpolations for next month')    
      disp('======================================================')
      disp(' ')
      %######################################################################
      % Read ECMWF file for the next month
      %
      Mp=M+1;
      Yp=Y;
      if Mp==13
        Mp=1;
        Yp=Y+1;
      end
      
      fname=[ECMWF_dir,'TP_Y',num2str(Yp),'M',num2str(Mp),'.nc'];
      
      if exist(fname)==0
        disp(['No data for the next month: using current month'])
        tndx=tlen0;
        Mp=M;
        Yp=Y;
      else
	ncid = netcdf.open(fname, 'NC_NOWRITE');
	if makefrc==1
	   disp('sms_time')
	   for tndx=tlen0+itolap_ecmwf+1:tlen;
	      netcdf.putVar(ncid_frc, netcdf.inqVarID(ncid_frc, 'sms_time'), tndx-1, 1, netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time'))));  % [conv] 0-based
	   end;
	end
	%
        if makeblk==1
	   disp('bulk_time')
           for tndx=tlen0+itolap_ecmwf+1:tlen;
              netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'bulk_time'), tndx-1, 1, netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time'))));  % [conv] 0-based
           end;
        end
        netcdf.close(ncid);
      end
      %
      % Perform the interpolations for the next month
      %
      disp('Last steps')
      for tndx=tlen0+itolap_ecmwf+1:tlen;
        disp(['tndx= ',num2str(tndx)])
        tout=tndx;
    	disp(['tout=tndx ',num2str(tndx)])
        if Mp==M
          tin=tlen0; % persistency if current month is used
	      disp(['tin=',num2str(tin)])
        else
          tin=tndx-tlen0-itolap_ecmwf;
	      disp(['tin=',num2str(tin)])
        end
        oct_interp_ECMWF(ECMWF_dir,Yp,Mp,Roa,interp_method,lon1,lat1,...
		    mask,tin,ncid_frc,ncid_blk,lon,lat,angle,tout)           
      end;
      %
      % Close the CROCO forcing files
      %
      if ~isempty(ncid_frc)
        netcdf.close(ncid_frc);
      end
      if ~isempty(ncid_blk)
        netcdf.close(ncid_blk);
      end
    end
   end
 end
%
% Spin-up: (reproduce the first year 'SPIN_Long' times)
% just copy the files for the first year and change the time
%
disp('======================================================')
disp('Add spin up phase')      
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
      frcname=[frc_prefix,'Y',num2str(Ymin),'M',num2str(sprintf(Mth_format,M)),nc_suffix];
      frcname2=[frc_prefix,'Y',num2str(Y),'M',num2str(sprintf(Mth_format,M)),nc_suffix];
      disp(['Create ',frcname2]) 
      system(['cp ',frcname,' ',frcname2]) 
      %
      % Change the time
      %
      ncid = netcdf.open(frcname2, 'NC_WRITE');
      time=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'sms_time'))-365.*(Ymin-Y);%+datenum(Yorig,1,1);
      %[y,m,d,h,mi,s]=datevec(time);
      %dy=Ymin-Y;
      %y=y-dy;
      %time=datenum(y,m,d,h,mi,s)-datenum(Yorig,1,1);
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
      blkname=[blk_prefix,'Y',num2str(Ymin),'M',num2str(sprintf(Mth_format,M)),nc_suffix];
      blkname2=[blk_prefix,'Y',num2str(Y),'M',num2str(sprintf(Mth_format,M)),nc_suffix];
      disp(['Create ',blkname2]) 
      system(['cp ',blkname,' ',blkname2]) 
      %
      % Change the time
      %
      ncid = netcdf.open(blkname2, 'NC_WRITE');
      time=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'bulk_time'))-365.*(Ymin-Y);%+datenum(Yorig,1,1);
      %[y,m,d,h,mi,s]=datevec(time);
      %dy=Ymin-Y;
      %y=y-dy;
      %time=datenum(y,m,d,h,mi,s)-datenum(Yorig,1,1);
      netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'bulk_time'), time);
      netcdf.close(ncid);
    end
  end
end
%---------------------------------------------------------------
% Create MC file
%---------------------------------------------------------------
%if createmc==1
%    if makefrc
%       make_mc_forcing('ECMWF',21600.,itolap_ecmwf);
%   end
%   if makeblk
%       make_mc_bulk('ECMWF',21600.,itolap_ecmwf);
%   end
%end
%
%---------------------------------------------------------------
% Make a few plots
%---------------------------------------------------------------
if makeplot==1
  disp(' ')
  disp('======================================================')
  disp(' Make a few plots...')
  slides=[1 12 24 36];
  if makeblk
    oct_test_forcing(blkname,grdname,'tair',slides,3,coastfileplot)
    figure
    oct_test_forcing(blkname,grdname,'rhum',slides,3,coastfileplot)
    figure
    oct_test_forcing(blkname,grdname,'prate',slides,3,coastfileplot)
    figure
    oct_test_forcing(blkname,grdname,'uwnd',slides,3,coastfileplot)
    figure
    oct_test_forcing(blkname,grdname,'vwnd',slides,3,coastfileplot)
    figure
    oct_test_forcing(blkname,grdname,'wspd',slides,3,coastfileplot)
    figure
    oct_test_forcing(blkname,grdname,'radlw',slides,3,coastfileplot)
    figure
    oct_test_forcing(blkname,grdname,'radsw',slides,3,coastfileplot)
  end
  if makefrc
    figure
    oct_test_forcing(frcname,grdname,'sustr',slides,3,coastfileplot)
    figure
    oct_test_forcing(frcname,grdname,'svstr',slides,3,coastfileplot)  
    figure
    oct_test_forcing(frcname,grdname,'Awave',slides,3,coastfileplot)
    figure
    oct_test_forcing(frcname,grdname,'Dwave',slides,3,coastfileplot)
    figure
    oct_test_forcing(frcname,grdname,'Pwave',slides,3,coastfileplot)
  end
end

