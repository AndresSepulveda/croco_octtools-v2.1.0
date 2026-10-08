function [t,tx,ty,tair,rhum,prate,wspd,uwnd,vwnd,radlw,radlw_in,radsw]=...
         oct_get_GFS(fname,mask,tndx,jrange,i1min,i1max,...
	 i2min,i2max,i3min,i3max,missvalue)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Download one full subset of GFS for CROCO bulk for 1 time step
% Put them in the CROCO units
%
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
%  Copyright (c) 2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    9-Sep-2006 by Pierrick Penven
%  Updated    20-Aug-2008 by Matthieu Caillaud & P. Marchesiello
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trange=['[',num2str(min(tndx)),':',num2str(max(tndx)),']'];
%
% Get GFS variables for 1 time step
%
disp(' ')
disp('====================================================')
%disp('time...')
%disp(['TNDX=',num2str(tndx)])
%disp(['TRANGE=',num2str(trange)])
t=oct_readdap(fname,'time',trange);
disp(['TRANGE=',num2str(trange)])
disp(['GFS raw time=',sprintf('%5.3f',t)])
t=t+365; % put it in "matlab" time
disp(['GFS: ',datestr(datenum(t),'yyyy-mm-dd HH:MM:SS')])
disp('====================================================')

%disp('u...')
u=mask.*oct_getdap('',fname,'ugrd10m',trange,'',jrange,...
                i1min,i1max,i2min,i2max,i3min,i3max);
u(abs(u)>=missvalue)=NaN;
pause(2)

%disp('v...')
v=mask.*oct_getdap('',fname,'vgrd10m',trange,'',jrange,...
                i1min,i1max,i2min,i2max,i3min,i3max);
v(abs(v)>=missvalue)=NaN;
pause(2)

%disp('tx...')
tx=mask.*oct_getdap('',fname,'uflxsfc',trange,'',jrange,...
                i1min,i1max,i2min,i2max,i3min,i3max);
tx(abs(tx)>=missvalue)=NaN;
pause(2)

%disp('ty...')
ty=mask.*oct_getdap('',fname,'vflxsfc',trange,'',jrange,...
                i1min,i1max,i2min,i2max,i3min,i3max);
ty(abs(ty)>=missvalue)=NaN;
pause(2)

%disp('tair...')
tair=mask.*oct_getdap('',fname,'tmp2m',trange,'',jrange,...
                i1min,i1max,i2min,i2max,i3min,i3max);
tair(abs(tair)>=missvalue)=NaN;
pause(2)

%disp('rhum...')
rhum=mask.*oct_getdap('',fname,'rh2m',trange,'',jrange,...
                i1min,i1max,i2min,i2max,i3min,i3max);
rhum(abs(rhum)>=missvalue)=NaN;
pause(2)

%disp('prate...')
prate=mask.*oct_getdap('',fname,'pratesfc',trange,'',jrange,...
                i1min,i1max,i2min,i2max,i3min,i3max);
prate(abs(prate)>=missvalue)=NaN;
pause(2)

%disp('down radlw...')
dradlw=mask.*oct_getdap('',fname,'dlwrfsfc',trange,'',jrange,...
                i1min,i1max,i2min,i2max,i3min,i3max);
dradlw(abs(dradlw)>=missvalue)=NaN;
pause(2)

%disp('up radlw...')
uradlw=mask.*oct_getdap('',fname,'ulwrfsfc',trange,'',jrange,...
                i1min,i1max,i2min,i2max,i3min,i3max);
uradlw(abs(uradlw)>=missvalue)=NaN;
pause(2)

%disp('down radsw...')
dradsw=mask.*oct_getdap('',fname,'dswrfsfc',trange,'',jrange,...
                i1min,i1max,i2min,i2max,i3min,i3max);
dradsw(abs(dradsw)>=missvalue)=NaN;
pause(2)

%disp('up radsw...')
uradsw=mask.*oct_getdap('',fname,'uswrfsfc',trange,'',jrange,...
                i1min,i1max,i2min,i2max,i3min,i3max);
uradsw(abs(uradsw)>=missvalue)=NaN;
pause(2)
%
% Transform the variables
%
%
% 1: Air temperature: Convert from Kelvin to Celsius
%
tair=tair-273.15;
%
% 2: Relative humidity: Convert from % to fraction
%
rhum=rhum/100;
%
% 3: Precipitation rate: Convert from [kg/m^2/s] to cm/day
%
prate=prate*0.1*(24*60*60.0);
prate(abs(prate)<1.e-4)=0;
%
% 4: Net shortwave flux: [W/m^2]
%    CROCO convention: positive downward: same as GFS
% ?? albedo ??
%
radsw=dradsw - uradsw;
radsw(radsw<1.e-10)=0;
%
% 5: Net outgoing Longwave flux:  [W/m^2]
%    CROCO convention: positive upward (opposite to nswrs)
%    GFS convention: positive downward --> * (-1)
%    input: downward longwave rad. and
%    skin temperature.
%
%skt=skt-273.15; 
%radlw=-lwhf(skt,radlw); 
radlw = uradlw - dradlw;
radlw_in=dradlw;

%
% 6: Wind speed
%
wspd=sqrt(u.^2+v.^2);
% 7:  Wind vectors
uwnd=u; % rho point
vwnd=v; % rho point
% %
% % 7: Compute the stress following large and pond
% %
% [Cd,uu]=cdnlp(wspd,10.);
% rhoa=air_dens(tair,rhum*100);
% tx=Cd.*rhoa.*u.*wspd;
% ty=Cd.*rhoa.*v.*wspd;
%
return
