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
    ncid = netcdf.open(grdname, 'NC_NOWRITE');
    h = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'));
    netcdf.close(ncid);
    % O2 initial conditions
    ncid = netcdf.open(ininame, 'NC_NOWRITE');
    theta_s = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_s'));
    theta_b = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_b'));
    Tcline = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Tcline'));
    [~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
    vtransform=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Vtransform'));
    if  ~exist('vtransform')
        vtransform=1; %Old Vtransform
        disp([' NO VTRANSFORM parameter found'])
        disp([' USE TRANSFORM default value vtransform = 1'])
    end
    O2_ini   = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'O2'));
    netcdf.close(ncid);
    type = 'initial conditions file' ;
    history = 'CROCO' ;
    [KK,LL,MM]=size(O2_ini);
    %
    zw_ini=oct_zlevs(h,0.,theta_s,theta_b,Tcline,N,'w',vtransform);
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
    ncid = netcdf.open(ininame, 'NC_WRITE');
    % new variable
    %%redef(nc);
    %
    vid_N2O = netcdf.defVar(ncid, 'N2O', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_time]);
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'N2O'), 'long_name', 'Nitrous oxide');
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'N2O'), 'fields', 'NO2, scalar, series');
    %%endef(nc);
    % write new variable
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'N2O'), :,:,:-1, 1, N2O_ini);  % [conv] 0-based
    % Synchronize on disk
    netcdf.close(ncid);
end

%==========
if makeclim
    ncid = netcdf.open(grdname, 'NC_NOWRITE');
    h = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'));
    netcdf.close(ncid);
    % O2 climatological conditions
    ncid = netcdf.open(clmname, 'NC_NOWRITE');
    theta_s = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_s'));
    theta_b = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_b'));
    Tcline = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Tcline'));
    [~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
    vtransform=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Vtransform'));
    if  ~exist('vtransform')
        vtransform=1; %Old Vtransform
        disp([' NO VTRANSFORM parameter found'])
        disp([' USE TRANSFORM default value vtransform = 1'])
    end
    O2_clm  = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'O2'));
    O2_time = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'o2_time'));
    O2_cycle = netcdf.getAtt(ncid, netcdf.inqVarID(ncid, 'o2_time'), 'cycle_length');
    zeta = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'zeta'));
    netcdf.close(ncid);
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
                    N2O_clm(t,k,j,i)=oct_nevis_2003(zw,02);
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
    ncid = netcdf.open(clmname, 'NC_WRITE');
    %
    % new variable
    %
    %%redef(nc);
    did_n2o_time = netcdf.defDim(ncid, 'n2o_time', TT);
    vid_n2o_time = netcdf.defVar(ncid, 'n2o_time', 'NC_DOUBLE', did_n2o_time);
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'n2o_time'), 'long_name', 'time climatological N2O');
    oct_write_time_attributes(ncid,'n2o_time',O2_cycle,time_unit_att,time_second_unit_att,...
        calendar_att,0,1);

    vid_N2O = netcdf.defVar(ncid, 'N2O', 'NC_DOUBLE', [did_xi_rho, did_eta_rho, did_s_rho, did_n2o_time]);
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'N2O'), 'long_name', 'Nitrous oxide');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'N2O'), 'units', 'mMol N2O m-3');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'N2O'), 'fields', 'NO2, scalar, series');
    %%endef(nc);
    %
    % write new variable
    %
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'n2o_time'), O2_time(:));
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'N2O'), :,:,:,:-1, 1, N2O_clm(:));  % [conv] 0-based
    %
    % Synchronize on disk
    %
    netcdf.close(ncid);
end

%==========
if makebry
    % O2 boundary conditions
    ncid = netcdf.open(grdname, 'NC_NOWRITE');
    h = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'));
    netcdf.close(ncid);

    ncid = netcdf.open(bryname, 'NC_NOWRITE');
    theta_s = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_s'));
    theta_b = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_b'));
    Tcline = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Tcline'));
    [~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
    vtransform=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Vtransform'));
    if  ~exist('vtransform')
        vtransform=1; %Old Vtransform
        disp([' NO VTRANSFORM parameter found'])
        disp([' USE TRANSFORM default value vtransform = 1'])
    end
    O2_bry_west = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'O2_west'));
    O2_bry_east = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'O2_east'));
    O2_bry_south = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'O2_south'));
    O2_bry_north = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'O2_north'));
    O2_time = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'o2_time'));
    O2_cycle = netcdf.getAtt(ncid, netcdf.inqVarID(ncid, 'o2_time'), 'cycle_length');
    zeta_west  = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'zeta_west'));
    zeta_east  = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'zeta_east'));
    zeta_south = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'zeta_south'));
    zeta_north = netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'zeta_north'));
    netcdf.close(ncid);

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
    ncid = netcdf.open(bryname, 'NC_WRITE');
    % new variable
    %
    %%redef(nc);
    did_n2o_time = netcdf.defDim(ncid, 'n2o_time', length(T));
    vid_n2o_time = netcdf.defVar(ncid, 'n2o_time', 'NC_DOUBLE', did_n2o_time);
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'n2o_time'), 'long_name', 'time climatological N2O');
    oct_write_time_attributes(ncid,'n2o_time',O2_cycle,time_unit_att,time_second_unit_att,...
                        calendar_att,0,1);

    vid_N2O_east = netcdf.defVar(ncid, 'N2O_east', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_n2o_time]);
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'N2O_east'), 'long_name', 'Nitrous oxide');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'N2O_east'), 'units', 'mMol N2O m-3');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'N2O_east'), 'fields', 'NO2, scalar, series');

    vid_N2O_west = netcdf.defVar(ncid, 'N2O_west', 'NC_DOUBLE', [did_eta_rho, did_s_rho, did_n2o_time]);
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'N2O_west'), 'long_name', 'Nitrous oxide');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'N2O_west'), 'units', 'mMol N2O m-3');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'N2O_west'), 'fields', 'NO2, scalar, series');

    vid_N2O_south = netcdf.defVar(ncid, 'N2O_south', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_n2o_time]);
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'N2O_south'), 'long_name', 'Nitrous oxide');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'N2O_south'), 'units', 'mMol N2O m-3');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'N2O_south'), 'fields', 'NO2, scalar, series');

    vid_N2O_north = netcdf.defVar(ncid, 'N2O_north', 'NC_DOUBLE', [did_xi_rho, did_s_rho, did_n2o_time]);
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'N2O_north'), 'long_name', 'Nitrous oxide');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'N2O_north'), 'units', 'mMol N2O m-3');
    % [conv] línea ncchar duplicada omitida
    netcdf.putAtt(ncid, netcdf.inqVarID(ncid, 'N2O_north'), 'fields', 'NO2, scalar, series');

    %
    % write new variable
    %
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'n2o_time'), T);
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'N2O_east'), :,:,:,:-1, 1, N2O_bry_east);  % [conv] 0-based
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'N2O_west'), :,:,:,:-1, 1, N2O_bry_west);  % [conv] 0-based
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'N2O_south'), :,:,:,:-1, 1, N2O_bry_south);  % [conv] 0-based
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'N2O_north'), :,:,:,:-1, 1, N2O_bry_north);  % [conv] 0-based
    %
    % Synchronize on disk
    %
    netcdf.close(ncid);
end






