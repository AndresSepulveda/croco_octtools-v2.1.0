%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  oct_make_ERA5.m
%
%  Create and fill frc and bulk files with ERA5 data.
%  (ERA-5 Reanalysis)
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
%  Updated    D. Donoso, G. Cambon. P. Penven (Oct 2021)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Common parameters
%
crocotools_param
isoctave=(exist('OCTAVE_VERSION','builtin')~=0);
frc_prefix=[frc_prefix,'_ERA5_'];
blk_prefix=[blk_prefix,'_ERA5_'];
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
lon=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'))).';
lat=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'))).';
lonu=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_u'))).';
latu=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_u'))).';
lonv=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_v'))).';
latv=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_v'))).';
angle=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'))).';
netcdf.close(ncid);

%
% Get the ERA5 horizontal grids (it should be the same for every month)
%
ncid = netcdf.open([ERA5_dir,'LSM_Y',num2str(Ymin),'M',num2str(sprintf(Mth_format,Mmin)),'.nc'], 'NC_NOWRITE');
disp(['Use this land file :',char([ERA5_dir,'LSM_Y',num2str(Ymin),'M',num2str(sprintf(Mth_format,Mmin)),'.nc'])])

lon1=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon')));
lat1=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat')));
[lon1,lat1]=meshgrid(lon1,lat1);

mask=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'LSM'),[0 0 0],[size(lon1,2) size(lon1,1) 1])).'; %we take the first record (lat,lon)
mask(mask ~=0 ) = 1;
mask = 1-mask ;
mask(mask ==0 ) = NaN ;
netcdf.close(ncid);


if add_waves == 1
    %
    % get horizontal grid for ocean waves
    % for ERA5 wave variables, resolution change to 0.5° instead of 0.25°
    % for the atmo variable (0.25° x 0.25° (atmosphere)  vs  0.5° x 0.5° (ocean waves))
    %
    filein=[ERA5_dir,'SWH_Y',num2str(Ymin),'M',num2str(sprintf(Mth_format,Mmin)),'.nc'];
    ncid = netcdf.open(filein, 'NC_NOWRITE');
    lonwave=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon')));
    latwave=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat')));
    [lon1wave,lat1wave]=meshgrid(lonwave,latwave);
    maskwave=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'SWH'),[0 0 0],[length(lonwave) length(latwave) 1])).';  % first record (lat,lon)
    missvalue_wave = double(netcdf.getAtt(ncid, netcdf.inqVarID(ncid, 'SWH'), 'missing_value'));
    maskwave(maskwave ~= missvalue_wave ) = 1;
    maskwave(maskwave == missvalue_wave ) = NaN ;
    netcdf.close(ncid);

    % fix: PP1D doesn t have the same mask than SWH
    filein2=[ERA5_dir,'PP1D_Y',num2str(Ymin),'M',num2str(sprintf(Mth_format,Mmin)),'.nc'];
    ncid = netcdf.open(filein2, 'NC_NOWRITE');
    maskwave2=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'PP1D'),[0 0 0],[length(lonwave) length(latwave) 1])).';  % first record (lat,lon)
    missvalue_wave2 = double(netcdf.getAtt(ncid, netcdf.inqVarID(ncid, 'PP1D'), 'missing_value'));
    maskwave2(maskwave2 ~= missvalue_wave2 ) = 1;
    maskwave2(maskwave2 == missvalue_wave2 ) = NaN ;
    netcdf.close(ncid);
    %
else
    lon1wave = NaN;
    lat1wave = NaN;
    maskwave = NaN;
    maskwave2 = NaN;
end


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
            ' - month ',num2str(sprintf(Mth_format,M))])
        disp(' ')
        %-------------------------------------------------------------------%
        %
        % Process time (here in days), with SST file (minimum time step)
        %
        %-------------------------------------------------------------------%
        ncid = netcdf.open([ERA5_dir,'T2M_Y',num2str(Y),'M',num2str(sprintf(Mth_format,M)),'.nc'], 'NC_NOWRITE');
        ERA5_time=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time')));
        ERA5_time=ERA5_time(:).';
        netcdf.close(ncid);
        dt=mean(gradient(ERA5_time));
        disp(['dt=',num2str(dt)])
        %-----------------------------------------------------------
        %Variable overlapping timesteps : 2 at the beginning and 2 at the end
        %------------------------------------------------------------
        tlen0=length(ERA5_time);
        disp(['tlen0=',num2str(tlen0)])
        freq=1; % hourly
        itolap=freq*itolap_era5;
        tlen=tlen0+2*itolap;
        disp(['tlen=',num2str(tlen)])
        disp(['Overlap is ',num2str(itolap_era5),' records before and after'])
        time=0*(1:tlen);
        time(itolap+1:tlen0+itolap)=ERA5_time;
        disp(['====================='])
        disp('Compute time for croco file')
        disp(['====================='])
        for aa=1:itolap
            time(aa)=time(itolap+1)-(itolap+1-aa)*dt;
        end
        for aa=1:itolap
            time(tlen0+itolap+aa)=time(tlen0+itolap)+aa*dt;
        end
        %-------------------------------------------------------------------%
        %
        % Create the CROCO bulk forcing files
        %
        % ------------------------------------------------------------------%
        %
        disp(['====================='])
        disp('Create the frc/blk netcdf file')
        disp(['====================='])
        blkname=[blk_prefix,'Y',num2str(Y),...
            'M',num2str(sprintf(Mth_format,M)),nc_suffix];
        frcname=[frc_prefix,'Y',num2str(Y),...
            'M',num2str(sprintf(Mth_format,M)),nc_suffix];
        if makeblk==1
            disp(['Create a new bulk file: ' blkname])
            oct_create_bulk(blkname,grdname,CROCO_title,time,0,Yorig);
            oct_nc_add_globatt(blkname,Yorig,Mmin,Dmin,Hmin,Min_min,Smin,'ERA5');
            disp([' '])
        end
        if makefrc==1
            disp(['Create a new forcing file: ' frcname])
            disp([' '])
            oct_create_forcing(frcname,grdname,CROCO_title,...
                            time,0,0,...
                            0,0,0,...
                            0,0,0,0,0,0,Yorig)
        end
        % %
        % % Add the waves
        % %
        if makefrc==1 && add_waves==1 
            disp(['-> Add waves data previously downloaded'])
            disp(['   using Aforc_ERA5/ERA5_request.py'])
        end
        % %
        % %
        % % Add the tides
        % %
        if makefrc==1 && add_tides==1
            disp([' '])
            disp(['-> Add tidal data'])
            pot_tides=1;
            oct_add_tidal_data(tidename,grdname,frcname,Ntides,tidalrank,...
                            Yorig,Y,M,coastfileplot,makeplot,pot_tides)
        end
        %
        %
        % Open the CROCO forcing files
        if makefrc==1
            ncid_frc = netcdf.open(frcname, 'NC_WRITE');
        else
            ncid_frc=[];
        end

        % Open the CROCO bulk files
        if makeblk==1
            ncid_blk = netcdf.open(blkname, 'NC_WRITE');
        else
            ncid_blk=[];
        end
        %
        % Check if there are ERA5 files for the previous Month
        Mm=M-1;
        Ym=Y;
        if Mm==0
            Mm=12;
            Ym=Y-1;
        end
        %
        fname = [ERA5_dir,'TP_Y',num2str(Ym),'M',num2str(sprintf(Mth_format,Mm)),'.nc'];
        %nc=oct_netcdf([ERA5_dir,'TP_Y',num2str(Ym),'M',num2str(Mm),'.nc']);
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
            tprev=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time')));
            if makefrc==1
                for aa=1:itolap
                    netcdf.putVar(ncid_frc, netcdf.inqVarID(ncid_frc, 'sms_time'), aa-1, 1, tprev(tndx-(itolap-aa)));   % time(tndx-(itolap-aa)) of previous month
                end
            end
            %
            if makeblk==1
                for aa=1:itolap
                    netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'bulk_time'), aa-1, 1, tprev(tndx-(itolap-aa)));   % time(tndx-(itolap-aa)) of previous month
                end
            end
            netcdf.close(ncid);
        end
        %
        % Perform interpolations for the previous month or repeat the first one
        %
        for aa=1:itolap
            if exist(fname)==0
                aa0=aa;
            else
                aa0=tndx-(itolap-aa);
            end
            oct_interp_ERA5(ERA5_dir,Ym,Mm,Roa,interp_method,lon1,lat1,lon1wave,lat1wave, ...
                        mask,maskwave,maskwave2,aa0,ncid_frc,ncid_blk,lon,lat,angle,aa,add_waves)
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
            if mod(tndx,6)==0
                disp(['Step: ',num2str(tndx),' of ',num2str(tlen0)])
            end
            oct_interp_ERA5(ERA5_dir,Y,M,Roa,interp_method,lon1,lat1,lon1wave,lat1wave,...
                        mask,maskwave,maskwave2,tndx,ncid_frc,ncid_blk,lon,lat,angle,tndx+itolap,add_waves)
        end

        disp(' ')
        disp('======================================================')
        disp('Perform interpolations for next month')
        disp('======================================================')
        disp(' ')
        %######################################################################
        % Read ERA5 file for the next month
        %
        Mp=M+1;
        Yp=Y;
        if Mp==13
            Mp=1;
            Yp=Y+1;
        end

        fname=[ERA5_dir,'TP_Y',num2str(Yp),'M',num2str(sprintf(Mth_format,Mp)),'.nc'];

        if exist(fname)==0
            disp(['No data for the next month: using current month'])
            tndx=tlen0;
            Mp=M;
            Yp=Y;
        else
            ncid = netcdf.open(fname, 'NC_NOWRITE');
            tnext=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'time')));

            if makefrc==1
                disp('sms_time')
                for tndx=tlen0+itolap+1:tlen;
                    netcdf.putVar(ncid_frc, netcdf.inqVarID(ncid_frc, 'sms_time'), tndx-1, 1, tnext(tndx-tlen0-itolap));   % sms_time(tndx)=time(tndx-tlen0-itolap) of next month
                end;
            end

            if makeblk==1
                disp('bulk_time')
                for tndx=tlen0+itolap+1:tlen;
                    netcdf.putVar(ncid_blk, netcdf.inqVarID(ncid_blk, 'bulk_time'), tndx-1, 1, tnext(tndx-tlen0-itolap));   % bulk_time(tndx)=time(tndx-tlen0-itolap) of next month
                end
            end
            netcdf.close(ncid);
        end
        %
        % Perform the interpolations for the next month
        %
        disp('Last steps')
        for tndx=tlen0+itolap+1:tlen;
            disp(['tndx= ',num2str(tndx)])
            tout=tndx;
            disp(['tout=tndx ',num2str(tndx)])
            if Mp==M
                %tin=tlen0;       % persistency if current month is used
                tin=tndx-2*itolap;
                disp(['tin=',num2str(tin)])
            else
                tin=tndx-tlen0-itolap;
                disp(['tin=',num2str(tin)])
            end
            oct_interp_ERA5(ERA5_dir,Yp,Mp,Roa,interp_method,lon1,lat1,lon1wave,lat1wave,...
                        mask,maskwave,maskwave2,tin,ncid_frc,ncid_blk,lon,lat,angle,tout,add_waves)
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
%
% Spin-up: (reproduce the first year 'SPIN_Long' times)
% just copy the files for the first year and change the time
%
disp('======================================================')
if SPIN_Long>0
    disp('Add spin up phase')
    M=Mmin-1;
    Y=Ymin-SPIN_Long;
    for month=1:12*SPIN_Long
        M=M+1;
        if M==13
            M=1;
            Y=Y+1;
        end
        %
        % Bulk files
        %
        %
        % Copy the file
        %
        blkname=[blk_prefix,'Y',num2str(Ymin),'M',num2str(sprintf(Mth_format,M)),nc_suffix];
        blkname2=[blk_prefix,'Y',num2str(Y),'M',num2str(sprintf(Mth_format,M)),nc_suffix];
        disp(['Create ',blkname2])

        copyfile(blkname,blkname2);
        %
        % Change the time
        %
        ncid = netcdf.open(blkname2, 'NC_WRITE');
        time=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'bulk_time')))-365.*(Ymin-Y);%+datenum(Yorig,1,1);
        %[y,m,d,h,mi,s]=datevec(time);
        %dy=Ymin-Y;
        %y=y-dy;
        %time=datenum(y,m,d,h,mi,s)-datenum(Yorig,1,1);
        netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'bulk_time'), time);
        netcdf.close(ncid);
    end
end
%---------------------------------------------------------------
% Make a few plots
%---------------------------------------------------------------
if makeplot==1
    disp(' ')
    disp('======================================================')
    disp(' Make a few plots...')
    slides=[1 12 24 36];

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

