%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Add the tides to the CROCO forcing file for tidal forcing
%  by the boundary conditions.
%
%  Further Information:  
%  http://www.crocoagrif.org/croco_tools/
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
%  Copyright (c) 2003-2006 by Patrick Marchesiello and Meinte Blass
%
%  Updated   1-Sep-2006 by P. Penven (generalisation of crocotools_param.m)
%  Updated   3-Oct-2006 by P. Penven (cleaning + phase lag for Yorig time)
%  Updated  20-Jun-2015 by P. Marchesiello (added tidal potential)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
% Common parameters
%
crocotools_param

pot_tides=1;            % Potential tidal forcing
if ~exist('sal_tides'), % if Self-Attraction/Loading not in 
  sal_tides=0;          % crocotools_param, set to none
end
%
%%%%%%%~%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Get start time of simulation in fractional oct_mjd for nodal correction
%
date_mjd=oct_mjd(Ymin,Mmin,Dmin);
[pf,pu,t0,phase_mkB]=oct_egbert_correc(date_mjd,Hmin,Min_min,Smin);
deg=180.0/pi;
rad=pi/180.0;
%
% Add a phase correction to be consistent with the 'Yorig' time
%
t0=t0-24.*oct_mjd(Yorig,1,1);
%
% Read in CROCO grid.
%
disp('Reading CROCO grid parameters ...');
ncid = netcdf.open(grdname, 'NC_NOWRITE');
lonr=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_rho'))).';
latr=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_rho'))).';
lonu=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_u'))).';
latu=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_u'))).';
lonv=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lon_v'))).';
latv=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'lat_v'))).';
rangle=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'angle'))).'; % should be used ....
h=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'h'))).';
rmask=double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'))).';
netcdf.close(ncid);
%
% Read in TPXO file
%
ncidtides = netcdf.open(tidename, 'NC_NOWRITE');
periods=double(netcdf.getVar(ncidtides, netcdf.inqVarID(ncidtides, 'periods')));
cmpt=netcdf.getAtt(ncidtides, netcdf.getConstant('NC_GLOBAL'), 'components');
netcdf.close(ncidtides);
Nmax=length(periods);
Ntides=min([Nmax Ntides]);
%
% Tidal potential:
%
%  includes the direct astronomical contribution from the sun and moon 
%  (amplitudes A), the contributions from solid Earth body tide
%  (elasticity factor B), and the self-attraction of ocean tide 
%  + load tide (read in 'salname' : global array of each constituants 
%  from GOT99.2b). 
%  --> See, e.g., book chapter on tides from Kantha and Clayson (2000).
%
%    amplitudes and elasticity factors for:
%        M2 S2 N2 K2 K1 O1 P1 Q1 Mf Mm
%
A=[0.242334 0.113033 0.046398 0.030704 ...
   0.141565 0.100514 0.046843 0.019256 ...
   0.041742 0.022026];                       % Amplitude (Schwiderski, 1978)
B=[0.693 0.693 0.693 0.693 ...
   0.736 0.695 0.706 0.695 ...
   0.693 0.693];                             % Elasticity factor (Wahr, 1981)
%
coslat2=cos(rad*latr).^2;                    % Phase arrays
sin2lat=sin(2.*rad*latr);
%
% Prepare the forcing file
%
for i=1:Ntides
  components(3*i-2:3*i)=[cmpt(3*tidalrank(i)-2:3*tidalrank(i)-1),' '];
end
disp(['Tidal components : ',components])
%
% The tides are added to the forcing file frcname. If it does not exist
% (e.g. when only a bulk file was made: makefrc=0, makeblk=1), a
% tide-only forcing file is created first.
%
if ~exist(frcname,'file')
  disp(['Forcing file ',frcname,' not found: create a tide-only forcing file'])
  oct_create_forcing_tideonly(frcname,grdname,CROCO_title)
end
oct_nc_add_tides(frcname,Ntides,date_mjd,components)
ncidfrc = netcdf.open(frcname, 'NC_WRITE');
[Mp,Lp]=size(lonr);   % tide_* are (tide_period,eta_rho,xi_rho): count [Lp Mp 1]
% 
%----------------------------------------------------------
%               Loop on tidal components
%----------------------------------------------------------
%
for itide=1:Ntides
  it=tidalrank(itide);
  disp(['Processing tide : ',num2str(itide),' of ',num2str(Ntides)])
  netcdf.putVar(ncidfrc, netcdf.inqVarID(ncidfrc, 'tide_period'), itide-1, 1, periods(it));
%
% Get phase corrections
%
  correc_amp=pf(it);
  correc_phase=-phase_mkB(it)-pu(it)+360.*t0./periods(it);
%
% Process surface elevation
%
  disp('  ssh...')
  ur=oct_ext_data_tpxo(tidename,'ssh_r',it,lonr,latr,'r',Roa);
  ui=oct_ext_data_tpxo(tidename,'ssh_i',it,lonr,latr,'r',Roa);
  ei=complex(ur,ui);
  netcdf.putVar(ncidfrc, netcdf.inqVarID(ncidfrc, 'tide_Ephase'), [0 0 itide-1], [Lp Mp 1], (mod(-deg*angle(ei)+correc_phase,360.0)).');
  netcdf.putVar(ncidfrc, netcdf.inqVarID(ncidfrc, 'tide_Eamp'), [0 0 itide-1], [Lp Mp 1], (abs(ei)*correc_amp).');
%
% Process U
%
  disp('  u...')
  ur=oct_ext_data_tpxo(tidename,'u_r',it,lonr,latr,'u',Roa);
  ui=oct_ext_data_tpxo(tidename,'u_i',it,lonr,latr,'u',Roa);
  ei=complex(ur,ui);
  upha=mod(-deg*angle(ei)+correc_phase,360.0); 
  uamp=abs(ei)*correc_amp;
%
% Process V
%
  disp('  v...')
  ur=oct_ext_data_tpxo(tidename,'v_r',it,lonr,latr,'v',Roa);
  ui=oct_ext_data_tpxo(tidename,'v_i',it,lonr,latr,'v',Roa);
  ei=complex(ur,ui);
  vpha=mod(-deg*angle(ei)+correc_phase,360.0); 
  vamp=abs(ei)*correc_amp;
%
% Convert to tidal ellipses
%
  disp('Convert to tidal ellipse parameters...')
  [major,eccentricity,inclination,phase]=oct_ap2ep(uamp,upha,vamp,vpha);
  netcdf.putVar(ncidfrc, netcdf.inqVarID(ncidfrc, 'tide_Cmin'), [0 0 itide-1], [Lp Mp 1], (major.*eccentricity).');
  netcdf.putVar(ncidfrc, netcdf.inqVarID(ncidfrc, 'tide_Cmax'), [0 0 itide-1], [Lp Mp 1], (major).');
  netcdf.putVar(ncidfrc, netcdf.inqVarID(ncidfrc, 'tide_Cangle'), [0 0 itide-1], [Lp Mp 1], (inclination).');
  netcdf.putVar(ncidfrc, netcdf.inqVarID(ncidfrc, 'tide_Cphase'), [0 0 itide-1], [Lp Mp 1], (phase).');
%
  if pot_tides,
%
% Process equilibrium tidal potential
%
   disp('Process equilibrium tidal potential...')
   if periods(it)<13.0                 % semidiurnal
     Pamp=correc_amp*A(it)*B(it)*coslat2;
     Ppha=mod(-2.*lonr+correc_phase,360.0);
   elseif periods(it)<26.0             % diurnal
     Pamp=correc_amp*A(it)*B(it)*sin2lat;
     Ppha=mod(-lonr+correc_phase,360.0);
   else                                % long-term
     Pamp=correc_amp*A(it)*B(it)*(1-1.5*coslat2);
     Ppha=mod(correc_phase,360.0)+0*lonr;   % full 2D field (no scalar broadcast in putVar)
   end
%
% Process tidal loading and self-attraction potential
%            from GOT99.2b model
%
   if sal_tides & it<9
    disp('Process tidal loading and self-attraction potential...')
    [SALamp,SALpha]=oct_ext_data_sal(grdname,salname, ...
                                 'tide_SALamp','tide_SALpha',it);
    SALamp=SALamp*correc_amp;
    SALpha=mod(SALpha+correc_phase,360.0);
%
% --> Get total tidal potential = Eq + load
%
    disp('Get total tidal potential...')
    Ptot=Pamp.*exp(1i*Ppha*rad) + SALamp.*exp(1i*SALpha*rad);
    Pamp=abs(Ptot);
    Ppha=deg*angle(Ptot);
    Ppha(Pamp<0.0001)=0.;
    Ppha=mod(Ppha,360.0);
   end
%
% Write tidal potential into file
%
   netcdf.putVar(ncidfrc, netcdf.inqVarID(ncidfrc, 'tide_Pamp'), [0 0 itide-1], [Lp Mp 1], (Pamp).');
   netcdf.putVar(ncidfrc, netcdf.inqVarID(ncidfrc, 'tide_Pphase'), [0 0 itide-1], [Lp Mp 1], (Ppha).');

  end % <-- if pot_tides
%
end % <-- itide ----
%
% Close file
%
netcdf.close(ncidfrc);
%
%------------------------------------------------
%                 Make plots 
%------------------------------------------------
%
% Plot tidal harmonics
%
if makeplot==1
  wstate_=warning('off','all');
  if Ntides>=5, 
   tiderg=[1 5];
  else
   tiderg=1;
  end
  for itide=tiderg;
    figure
    oct_plot_tide(grdname,frcname,itide,0.5,2,coastfileplot)
  end
 
  figure
  oct_clm_tides(grdname,frcname,Ntides,Ymin,Mmin,Dmin,...
            Hmin,Min_min,Smin,Yorig,lon0,lat0,Z0)
  warning(wstate_);
  if pot_tides
%
%  Plot tidal potential
%
    ncidfrc = netcdf.open(frcname, 'NC_NOWRITE');
    domaxis=[min(min(lonr)) max(max(lonr)) min(min(latr)) max(max(latr))];
% M2 AMP
    Pamp=double(netcdf.getVar(ncidfrc, netcdf.inqVarID(ncidfrc, 'tide_Pamp'),[0 0 0],[size(lonr,2) size(lonr,1) 1])).';
    figure
    m_proj('mercator',...
           'lon',[domaxis(1) domaxis(2)],...
           'lat',[domaxis(3) domaxis(4)]);
    m_pcolor(lonr,latr,Pamp);
    shading flat;
    colorbar
    m_gshhs_i('color','r');
    m_gshhs_i('patch','k');
    m_grid('box','fancy','xtick',5,'ytick',5,'fontsize',7);
    fname=['Potential Tides: M2 Amplitude [m]'];
    title(fname,'fontsize',16)
% M2 PHASE
    Ppha=double(netcdf.getVar(ncidfrc, netcdf.inqVarID(ncidfrc, 'tide_Pphase'),[0 0 0],[size(lonr,2) size(lonr,1) 1])).';
    figure
    m_proj('mercator',...
           'lon',[domaxis(1) domaxis(2)],...
           'lat',[domaxis(3) domaxis(4)]);
    m_pcolor(lonr,latr,Ppha);
    shading flat;
    colorbar
    m_gshhs_i('color','r');
    m_gshhs_i('patch','k');
    m_grid('box','fancy','xtick',5,'ytick',5,'fontsize',7);
    fname=['Potential Tides: M2 Phase [deg]'];
    title(fname,'fontsize',16)

    if Ntides>=5
% K1 AMP
     Pamp=double(netcdf.getVar(ncidfrc, netcdf.inqVarID(ncidfrc, 'tide_Pamp'),[0 0 4],[size(lonr,2) size(lonr,1) 1])).';
     figure
     m_proj('mercator',...
            'lon',[domaxis(1) domaxis(2)],...
            'lat',[domaxis(3) domaxis(4)]);
     m_pcolor(lonr,latr,Pamp);
     shading flat;
     colorbar
     m_gshhs_i('color','r');
     m_gshhs_i('patch','k');
     m_grid('box','fancy','xtick',5,'ytick',5,'fontsize',7);
     fname=['Potential Tides: K1 Amplitude [m]'];
     title(fname,'fontsize',16)
% K1 PHASE
     Ppha=double(netcdf.getVar(ncidfrc, netcdf.inqVarID(ncidfrc, 'tide_Pphase'),[0 0 4],[size(lonr,2) size(lonr,1) 1])).';
     figure
     m_proj('mercator',...
            'lon',[domaxis(1) domaxis(2)],...
            'lat',[domaxis(3) domaxis(4)]);
     m_pcolor(lonr,latr,Ppha);
     shading flat;
     colorbar
     m_gshhs_i('color','r');
     m_gshhs_i('patch','k');
     m_grid('box','fancy','xtick',5,'ytick',5,'fontsize',7);
     fname=['Potential Tides: K1 Phase [deg]'];
     title(fname,'fontsize',16)
     netcdf.close(ncidfrc);
    end
  end  % <-- pot_tides

end  % <-- makeplot
