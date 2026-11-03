%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Add N2O data in input CROCO files from Global Atlas (WOA or CARS)
%
%  N2O distribution from Nevison et al. (2003) formulation
%
%  Data input format (netcdf):
%     variable(T, Z, Y, X)
%     T : time [Months]
%     Z : Depth [m]
%     Y : Latitude [degree north]
%     X : Longitude [degree east]
%
%
%  Elodie Gutknecht, 2013
%  Gildas Cambon, 2013
%  Updated    Oct-2026 : Octave version (octave-netcdf, netcdf.* API)
%  Andres Sepulveda 2026 - Octave adaptations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%
%  Title
%
crocotools_param
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% options for oct_write_time_attributes
insecond =  0 ;
add_cycle = 1 ;
Yorig='';
%
% Initialize Yorig if not provided
if ~exist('Yorig', 'var') ,  Yorig = []; , end
%
% Get time attributes
[time_unit_att,time_second_unit_att,calendar_att]=...
    oct_get_time_attributes(Yorig);
%
%
%=========
if makeini
    nc=netcdf.open(grdname,'NC_NOWRITE');
    h = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'h'))).';
    netcdf.close(nc);
    % O2 initial conditions
    nc=netcdf.open(ininame,'NC_NOWRITE');
    theta_s = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'theta_s')));
    theta_b = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'theta_b')));
    Tcline  = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'Tcline')));
    [~,N]=netcdf.inqDim(nc,netcdf.inqDimID(nc,'s_rho'));
    try
        vtransform=double(netcdf.getVar(nc,netcdf.inqVarID(nc,'Vtransform')));
    catch
        vtransform=1; %Old Vtransform
        disp([' NO VTRANSFORM parameter found'])
        disp([' USE TRANSFORM default value vtransform = 1'])
    end
    % nc{'O2'}(:) : (time=1,N,M,L) squeezed -> (N,M,L)
    O2_ini = permute(double(netcdf.getVar(nc,netcdf.inqVarID(nc,'O2'))),[3 2 1]);
    netcdf.close(nc);
    type = 'initial conditions file' ;
    history = 'CROCO' ;
    [KK,LL,MM]=size(O2_ini);
    %
    zw_ini=oct_zlevs(h,0.*h,theta_s,theta_b,Tcline,N,'w',vtransform);
    N2O_ini=zeros(KK,LL,MM);N2O_ini=NaN;
    for k=1:KK
        for j=1:LL
            for i=1:MM
                N2O_ini(k,j,i)=oct_nevis_2003(squeeze(zw_ini(k,j,i)),squeeze(O2_ini(k,j,i)));
            end
        end
    end
    % Find NaN
    find(isnan(N2O_ini)==1);%
    %
    % open the ini file
    nc = netcdf.open(ininame,'NC_WRITE');
    % new variable
    netcdf.reDef(nc);
    %
    vid=oct_defvar(nc,'N2O','double',...
        [netcdf.inqDimID(nc,'xi_rho') netcdf.inqDimID(nc,'eta_rho') ...
         netcdf.inqDimID(nc,'s_rho') netcdf.inqDimID(nc,'time')]);
    netcdf.putAtt(nc,vid,'long_name','Nitrous oxide');
    netcdf.putAtt(nc,vid,'fields','NO2, scalar, series');
    netcdf.endDef(nc);
    % write new variable : (N,M,L) -> Fortran [L M N 1]
    netcdf.putVar(nc,vid,[0 0 0 0],[MM LL KK 1],permute(N2O_ini,[3 2 1]));
    % Synchronize on disk
    netcdf.close(nc);
end
%==========
if makeclim
    nc=netcdf.open(grdname,'NC_NOWRITE');
    h = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'h'))).';
    netcdf.close(nc);
    % O2 climatological conditions
    nc=netcdf.open(clmname,'NC_NOWRITE');
    theta_s = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'theta_s')));
    theta_b = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'theta_b')));
    Tcline  = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'Tcline')));
    [~,N]=netcdf.inqDim(nc,netcdf.inqDimID(nc,'s_rho'));
    try
        vtransform=double(netcdf.getVar(nc,netcdf.inqVarID(nc,'Vtransform')));
    catch
        vtransform=1; %Old Vtransform
        disp([' NO VTRANSFORM parameter found'])
        disp([' USE TRANSFORM default value vtransform = 1'])
    end
    vid_o2t = netcdf.inqVarID(nc,'o2_time');
    O2_clm  = permute(double(netcdf.getVar(nc,netcdf.inqVarID(nc,'O2'))),[4 3 2 1]);
    O2_time = double(netcdf.getVar(nc,vid_o2t));
    O2_cycle = double(netcdf.getAtt(nc,vid_o2t,'cycle_length'));
    zeta = permute(double(netcdf.getVar(nc,netcdf.inqVarID(nc,'zeta'))),[3 2 1]);
    netcdf.close(nc);
    [TT,KK,LL,MM]=size(O2_clm);
    for itps=1:length(O2_time)
        zw_clm(itps,:,:,:)=oct_zlevs(h,squeeze(zeta(itps,:,:)),theta_s,theta_b,Tcline,N,'w',vtransform);
    end
    N2O_clm=zeros(TT,KK,LL,MM); N2O_clm(:)=NaN;
    for t=1:TT
        for k=1:KK
            for j=1:LL
                for i=1:MM
                    zw= squeeze(zw_clm(t,k,j,i));
                    O2=squeeze(O2_clm(t,k,j,i));
                    % (the Matlab version passes the constant 02 instead of O2: typo fixed)
                    N2O_clm(t,k,j,i)=oct_nevis_2003(zw,O2);
                end
            end
        end
    end
    % Find NaN
    find(isnan(N2O_clm)==1);
    %
    % add N20 in climatological file
    type = 'climatological conditions file' ;
    history = 'CROCO' ;
    %
    % open the clm file
    %
    nc = netcdf.open(clmname,'NC_WRITE');
    %
    % new variable
    %
    netcdf.reDef(nc);
    did_t=oct_defdim(nc,'n2o_time',TT);
    vid_t=oct_defvar(nc,'n2o_time','double',did_t);
    netcdf.putAtt(nc,vid_t,'long_name','time climatological N2O');
    oct_write_time_attributes(nc,'n2o_time',O2_cycle,time_unit_att,time_second_unit_att,...
        calendar_att,0,1);
    vid=oct_defvar(nc,'N2O','double',...
        [netcdf.inqDimID(nc,'xi_rho') netcdf.inqDimID(nc,'eta_rho') ...
         netcdf.inqDimID(nc,'s_rho') did_t]);
    netcdf.putAtt(nc,vid,'long_name','Nitrous oxide');
    netcdf.putAtt(nc,vid,'units','mMol N2O m-3');
    netcdf.putAtt(nc,vid,'fields','NO2, scalar, series');
    netcdf.endDef(nc);
    %
    % write new variable : (T,N,M,L) -> Fortran [L M N T]
    %
    netcdf.putVar(nc,vid_t,0,TT,O2_time(:));
    netcdf.putVar(nc,vid,[0 0 0 0],[MM LL KK TT],permute(N2O_clm,[4 3 2 1]));
    %
    % Synchronize on disk
    %
    netcdf.close(nc);
end
%==========
if makebry
    % O2 boundary conditions
    nc=netcdf.open(grdname,'NC_NOWRITE');
    h = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'h'))).';
    netcdf.close(nc);
    nc=netcdf.open(bryname,'NC_NOWRITE');
    theta_s = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'theta_s')));
    theta_b = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'theta_b')));
    Tcline  = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'Tcline')));
    [~,N]=netcdf.inqDim(nc,netcdf.inqDimID(nc,'s_rho'));
    try
        vtransform=double(netcdf.getVar(nc,netcdf.inqVarID(nc,'Vtransform')));
    catch
        vtransform=1; %Old Vtransform
        disp([' NO VTRANSFORM parameter found'])
        disp([' USE TRANSFORM default value vtransform = 1'])
    end
    % (time,s_rho,eta|xi) variables -> Matlab order (T,N,npoints)
    O2_bry_west  = permute(double(netcdf.getVar(nc,netcdf.inqVarID(nc,'O2_west'))),[3 2 1]);
    O2_bry_east  = permute(double(netcdf.getVar(nc,netcdf.inqVarID(nc,'O2_east'))),[3 2 1]);
    O2_bry_south = permute(double(netcdf.getVar(nc,netcdf.inqVarID(nc,'O2_south'))),[3 2 1]);
    O2_bry_north = permute(double(netcdf.getVar(nc,netcdf.inqVarID(nc,'O2_north'))),[3 2 1]);
    vid_o2t  = netcdf.inqVarID(nc,'o2_time');
    O2_time  = double(netcdf.getVar(nc,vid_o2t));
    O2_cycle = double(netcdf.getAtt(nc,vid_o2t,'cycle_length'));
    % (time,eta|xi) -> (T,npoints)
    zeta_west  = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'zeta_west'))).';
    zeta_east  = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'zeta_east'))).';
    zeta_south = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'zeta_south'))).';
    zeta_north = double(netcdf.getVar(nc,netcdf.inqVarID(nc,'zeta_north'))).';
    netcdf.close(nc);
    % BRY
    [TT,KK,MM]=size(O2_bry_south); [TT,KK,LL]=size(O2_bry_west);
    type='w';
    zw_bry_west  = zeros(TT,KK+1);
    zw_bry_east  = zeros(TT,KK+1);
    zw_bry_south = zeros(TT,KK+1);
    zw_bry_north = zeros(TT,KK+1);
    N2O_bry_east  = zeros(TT,KK,LL); N2O_bry_east(:)=NaN  ;
    N2O_bry_west  = zeros(TT,KK,LL); N2O_bry_west(:)=NaN  ;
    N2O_bry_south = zeros(TT,KK,MM); N2O_bry_south(:)=NaN ;
    N2O_bry_north = zeros(TT,KK,MM); N2O_bry_north(:)=NaN ;
    for t=1:TT
        for j=1:LL
            h_west  = squeeze(h(j,1));
            h_east  = squeeze(h(j,end));
            zw_bry_west(t,:,j) = oct_zlevs_1d(h_west , squeeze(zeta_west(t,j)) , theta_s, theta_b, hc, N, type, vtransform);
            zw_bry_east(t,:,j)= oct_zlevs_1d(h_east , squeeze(zeta_east(t,j)) , theta_s, theta_b, hc, N, type, vtransform);
        end
    end
    for t=1:TT
        for i=1:MM
            h_south  = squeeze(h(1,i));
            h_north  = squeeze(h(end,i));
            zw_bry_south(t,:,i)= oct_zlevs_1d(h_south , squeeze(zeta_south(t,i)) , theta_s, theta_b, hc, N, type, vtransform);
            zw_bry_north(t,:,i)= oct_zlevs_1d(h_north , squeeze(zeta_north(t,i)) , theta_s, theta_b, hc, N, type, vtransform);
        end
    end
    for t=1:TT
        for k=1:KK
            for j=1:LL
                zw_east=zw_bry_east(t,k,j);
                zw_west=zw_bry_west(t,k,j);
                O2_east=O2_bry_east(t,k,j);
                O2_west=O2_bry_west(t,k,j);
                N2O_bry_east(t,k,j)= oct_nevis_2003(zw_east,O2_east);
                N2O_bry_west(t,k,j)= oct_nevis_2003(zw_west,O2_west);
            end
        end
    end
    for t=1:TT
        for k=1:KK
            for i=1:MM
                zw_north=zw_bry_north(t,k,i);
                zw_south=zw_bry_south(t,k,i);
                O2_north=O2_bry_north(t,k,i);
                O2_south=O2_bry_south(t,k,i);
                N2O_bry_north(t,k,i)=oct_nevis_2003(zw_north,O2_north);
                N2O_bry_south(t,k,i)=oct_nevis_2003(zw_south,O2_south);
            end
        end
    end
    T= O2_time ;% time in days
    cycle=O2_cycle;
    %
    % add N20 in bryfile file
    %
    type = 'boundary conditions file' ;
    history = 'CROCO' ;
    %
    % open the bry file
    %
    nc = netcdf.open(bryname,'NC_WRITE');
    % new variable
    %
    netcdf.reDef(nc);
    did_t=oct_defdim(nc,'n2o_time',length(T));
    vid_t=oct_defvar(nc,'n2o_time','double',did_t);
    netcdf.putAtt(nc,vid_t,'long_name','time climatological N2O');
    oct_write_time_attributes(nc,'n2o_time',O2_cycle,time_unit_att,time_second_unit_att,...
                        calendar_att,0,1);
    did_s=netcdf.inqDimID(nc,'s_rho');
    did_eta=netcdf.inqDimID(nc,'eta_rho');
    did_xi=netcdf.inqDimID(nc,'xi_rho');
    % (the Matlab version also sets units on misspelled 'N20_*' variables: skipped)
    for bnd={'east','west','south','north'}
      if any(strcmp(bnd{1},{'east','west'})), did_h=did_eta; else, did_h=did_xi; end
      vid=oct_defvar(nc,['N2O_',bnd{1}],'double',[did_h did_s did_t]);
      netcdf.putAtt(nc,vid,'long_name','Nitrous oxide');
      netcdf.putAtt(nc,vid,'units','mMol N2O m-3');
      netcdf.putAtt(nc,vid,'fields','NO2, scalar, series');
    end
    netcdf.endDef(nc);
    %
    % write new variable : (T,N,npoints) -> Fortran [npoints N T]
    %
    netcdf.putVar(nc,vid_t,0,length(T),T(:));
    netcdf.putVar(nc,netcdf.inqVarID(nc,'N2O_east'),[0 0 0],[LL KK TT],permute(N2O_bry_east,[3 2 1]));
    netcdf.putVar(nc,netcdf.inqVarID(nc,'N2O_west'),[0 0 0],[LL KK TT],permute(N2O_bry_west,[3 2 1]));
    netcdf.putVar(nc,netcdf.inqVarID(nc,'N2O_south'),[0 0 0],[MM KK TT],permute(N2O_bry_south,[3 2 1]));
    netcdf.putVar(nc,netcdf.inqVarID(nc,'N2O_north'),[0 0 0],[MM KK TT],permute(N2O_bry_north,[3 2 1]));
    %
    % Synchronize on disk
    %
    netcdf.close(nc);
end
