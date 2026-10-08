%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  oct_make_NCEP.m
%
%  Create and fill frc and bulk files with NCEP data.
%  (NCEP Reanalysis)
%
%  The on-line reference to NCEP is at
%  http://www.cdc.noaa.gov/cdc/reanalysis/
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
%
%  Updated    6-Sep-2006 by Pierrick Penven
%  Updated    Feb-2008 by Jerome Lefevre --- change OpenDap server ---
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%start
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Common parameters
%
crocotools_param
%
if NCEP_version==1
    frc_prefix=[frc_prefix,'_NCEP1_'];
    blk_prefix=[blk_prefix,'_NCEP1_'];
elseif NCEP_version==2
    frc_prefix=[frc_prefix,'_NCEP2_'];
    blk_prefix=[blk_prefix,'_NCEP2_'];
end
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
disp([' Read in the grid ',grdname])
ncid = netcdf.open(grdname, 'NC_NOWRITE');
[~,Lp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_rho'));
[~,Mp]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_rho'));
lon=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'));
lat=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'));
angle=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'));
netcdf.close(ncid);
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
    % Download NCEP
    %
    disp([' '])
    disp(['!!!!!!!!!!!!!!!!!!!!!'])
    disp(['====================='])
    disp(['BEGIN DOWNLOAD STEP'])
    disp(['====================='])
    disp(['!!!!!!!!!!!!!!!!!!!!!'])
    disp([' '])
    
    disp(['===================='])
    disp('Download NCEP data with OPENDAP or my FTP data')
    disp(['===================='])
    oct_download_NCEP(Ymin,Ymax,Mmin,Mmax,lonmin,lonmax,latmin,latmax,...
        NCEP_dir,NCEP_version,Yorig,Get_My_Data,My_NCEP_dir)
    disp(['====================='])
    disp(['DOWNLOAD STEP FINISH'])
    disp(['====================='])
end
%
if makefrc==1 | makeblk==1
    %
    % Get the NCEP horizontal grids (it should be the same for every month)
    %
    
    if Get_My_Data~=1
        ncid = netcdf.open([NCEP_dir,'landsfc_Y',num2str(Ymin),'M',num2str(Mmin),'.nc'], 'NC_NOWRITE');
        disp(['Use this land file :',char([NCEP_dir,'landsfc_Y',num2str(Ymin),'M',num2str(Mmin),'.nc'])])
    elseif Get_My_Data==1
        ncid = netcdf.open([NCEP_dir,'land_Y',num2str(Ymin),'M',num2str(Mmin),'.nc'], 'NC_NOWRITE');
        disp(['Use this land file :',char([NCEP_dir,'land_Y',num2str(Ymin),'M',num2str(Mmin),'.nc'])])
    end
    
    lon1=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon'));
    lat1=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat'));
    [lon1,lat1]=meshgrid(lon1,lat1);
    
    if Get_My_Data~=1
        mask=1-squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'landsfc')));
    elseif Get_My_Data==1
        mask=1-squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'land')));
    end
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
            %
            % Process time (here in days)
            %
            if Get_My_Data~=1
                ncid = netcdf.open([NCEP_dir,'tmp2m_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
            elseif Get_My_Data==1
                ncid = netcdf.open([NCEP_dir,'prate_Y',num2str(Y),'M',num2str(M),'.nc'], 'NC_NOWRITE');
            end
            
            NCEP_time=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time'));
            netcdf.close(ncid);
            dt=mean(gradient(NCEP_time));
            disp(['dt=',num2str(dt)])
            %-----------------------------------------------------------
            %Variable overlapping timeesteps : 2 at the beginning and 2 at the end
            %------------------------------------------------------------
            tlen0=length(NCEP_time);
            disp(['tlen0=',num2str(tlen0)])
            tlen=tlen0+2*itolap_ncep;
            disp(['tlen=',num2str(tlen)])
            disp(['Overlap is ',num2str(itolap_ncep),' it of 6 hours'])
            disp(['Overlap is ',num2str(itolap_ncep/4),' days before and after'])
            time=0*(1:tlen);
            time(itolap_ncep+1:tlen0+itolap_ncep)=NCEP_time;
            disp(['====================='])
            disp('Compute time for croco file')
            disp(['====================='])
            for aa=1:itolap_ncep
                time(aa)=time(itolap_ncep+1)-(itolap_ncep+1-aa)*dt;
            end
            
            for aa=1:itolap_ncep
                time(tlen0+itolap_ncep+aa)=time(tlen0+itolap_ncep)+aa*dt;
            end
            
            disp(['====================='])
            disp('Create the frc/blk netcdf file')
            disp(['====================='])
            % Create the CROCO forcing files
            blkname=[blk_prefix,'Y',num2str(Y),...
                'M',num2str(sprintf(Mth_format,M)),nc_suffix];
            frcname=[frc_prefix,'Y',num2str(Y),...
                'M',num2str(sprintf(Mth_format,M)),nc_suffix];
            if makeblk==1
                disp(['Create a new bulk file: ' blkname])
                oct_create_bulk(blkname,grdname,CROCO_title,time,0);
                disp([' '])
            end
            if makefrc==1
                disp(['Create a new forcing file: ' frcname])
                disp([' '])
                oct_create_forcing(frcname,grdname,CROCO_title,...
                    time,0,0,...
                    0,0,0,...
                    0,0,0,0,0,0)
            end
            %
            % Add the tides (needs to be tested for this version of oct_make_NCEP)
            %
            if add_tides==1
                disp(['Add tidal data'])
                disp(['=============='])
                %oct_add_tidal_data(tidename,grdname,frcname,Ntides,tidalrank,...
                %                   Y,M,Dmin,Hmin,Min_min,Smin,coastfileplot)
                add_tides(tidename,grdname,frcname,Ntides,tidalrank,...
                                               Yorig,Y,M,coastfileplot)
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
            % Check if there are NCEP files for the previous Month
            Mm=M-1;
            Ym=Y;
            if Mm==0
                Mm=12;
                Ym=Y-1;
            end
            
            if Get_My_Data~=1
                fname = [NCEP_dir,'tmp2m_Y',num2str(Ym),'M',num2str(Mm),'.nc'];
                %nc=oct_netcdf([NCEP_dir,'tmp2m_Y',num2str(Ym),'M',num2str(Mm),'.nc']);
                
            elseif Get_My_Data==1
                fname = [NCEP_dir,'prate_Y',num2str(Ym),'M',num2str(Mm),'.nc'];
                %nc=oct_netcdf([NCEP_dir,'prate_Y',num2str(Ym),'M',num2str(Mm),'.nc']);
            end
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
                    for aa=1:itolap_ncep
                        netcdf.putVar(ncid_frc, netcdf.inqVarID(ncid_frc, 'sms_time'), aa-1, 1, netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time'))));  % [conv] 0-based
                    end
                end
                %
                if makeblk==1
                    for aa=1:itolap_ncep
                        netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'bulk_time'), aa-1, 1, netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time'))));  % [conv] 0-based
                    end
                end
                netcdf.close(ncid);
            end
            %
            % Perform interpolations for the previous month or repeat the first one
            %
            for aa=1:itolap_ncep
                aa0=itolap_ncep-aa;
                oct_interp_NCEP(NCEP_dir,Ym,Mm,Roa,interp_method,lon1,lat1,...
                    mask,tndx-aa0,ncid_frc,ncid_blk,lon,lat,angle,aa,Get_My_Data)
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
                if mod(tndx,20)==0
                    disp(['Step: ',num2str(tndx),' of ',num2str(tlen0)])
                end
                oct_interp_NCEP(NCEP_dir,Y,M,Roa,interp_method,lon1,lat1,...
                    mask,tndx,ncid_frc,ncid_blk,lon,lat,angle,tndx+itolap_ncep,Get_My_Data)
            end
            
            disp(' ')
            disp('======================================================')
            disp('Perform interpolations for next month')
            disp('======================================================')
            disp(' ')
            %######################################################################
            % Read NCEP file for the next month
            %
            Mp=M+1;
            Yp=Y;
            %
            % Perform the interpolations for the next month
            %
            disp('Last steps')
            if Mp==13
                Mp=1;
                Yp=Y+1;
            end
            
            if Get_My_Data~=1
                fname=[NCEP_dir,'tmp2m_Y',num2str(Yp),'M',num2str(Mp),'.nc'];
            elseif Get_My_Data==1
                fname=[NCEP_dir,'prate_Y',num2str(Yp),'M',num2str(Mp),'.nc'];
            end
            
            if exist(fname)==0
                disp(['No data for the next month: using current month'])
                tndx=tlen0;
                Mp=M;
                Yp=Y;
            else
                ncid = netcdf.open(fname, 'NC_NOWRITE');
                if makefrc==1
                    disp('sms_time')
                    for tndx=tlen0+itolap_ncep+1:tlen;
                        netcdf.putVar(ncid_frc, netcdf.inqVarID(ncid_frc, 'sms_time'), tndx-1, 1, netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time')));  % [conv] 0-based
                    end;
                end
                %
                if makeblk==1
                    disp('bulk_time')
                    for tndx=tlen0+itolap_ncep+1:tlen;
                        netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'bulk_time'), tndx-1, 1, netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time')));  % [conv] 0-based
                    end;
                end
                netcdf.close(ncid);
            end
            %
            for tndx=tlen0+itolap_ncep+1:tlen;
                disp(['tndx= ',num2str(tndx)])
                tout=tndx;
                disp(['tout=tndx ',num2str(tndx)])
                if Mp==M
                    tin=tlen0; % persistency if current month is used
                    disp(['tin=',num2str(tin)])
                else
                    tin=tndx-tlen0-itolap_ncep;
                    disp(['tin=',num2str(tin)])
                end
                oct_interp_NCEP(NCEP_dir,Yp,Mp,Roa,interp_method,lon1,lat1,...
                    mask,tin,ncid_frc,ncid_blk,lon,lat,angle,tout,Get_My_Data)
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
	    time=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'sms_time'))-365.*(Ymin-Y);
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
	    time=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'bulk_time'))-365.*(Ymin-Y);
            netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'bulk_time'), time);
            netcdf.close(ncid);
        end
    end
end
%---------------------------------------------------------------
% Make a few plots
%---------------------------------------------------------------
if makeplot==1
    disp(' ')
    disp('======================================================')
    disp(' Make a few plots...')
    slides=[1 25 50 75];
    if makeblk
        figure
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
    end
end

