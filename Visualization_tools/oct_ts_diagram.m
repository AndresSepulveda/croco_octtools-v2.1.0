function out=oct_ts_diagram(hisfile,gridfile,lonbox,latbox,tindex,ocean,Yorig,maxprof)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OCT_TS_DIAGRAM  T-S diagram of the CROCO temperature and salinity
%                  profiles at a point or in a region, with the main
%                  water masses of Emery and Meincke (1986)
%
%  oct_ts_diagram(hisfile,gridfile,lon0,lat0,tindex)          % point
%  oct_ts_diagram(hisfile,gridfile,[lon1 lon2],[lat1 lat2],tindex)
%                                                            % region
%  oct_ts_diagram(...,ocean,Yorig,maxprof)
%  S = oct_ts_diagram(...)     % structure with the profiles and the
%                              % water masses found
%
%  hisfile : CROCO history/average file (temp, salt, zeta)
%  gridfile: grid file ('' : hisfile)
%  lon0,lat0: point (the nearest sea point of the grid is used)
%  [lon1 lon2],[lat1 lat2]: region, all the sea points inside the box
%            (at most MAXPROF profiles, default 400, regularly
%            subsampled)
%  tindex  : time index (default 1)
%  ocean   : water mass table used: 'auto' (default: from the mean
%            longitude of the profiles: Atlantic, Indian or Pacific),
%            'Atlantic', 'Indian', 'Pacific' or 'all'. The circumpolar
%            (Southern Ocean) water masses are added when the profiles
%            are south of 35S, or with 'all'. North Atlantic/Pacific/
%            Indian water masses are not used south of 15S, South ones
%            not north of 15N (except with 'all').
%  Yorig   : year origin of the dates (NaN : days)
%
%  Each profile is drawn as a line in the (salinity, potential
%  temperature) plane, coloured by the depth of the points (cmocean
%  'deep' colormap). Grey lines: potential density anomaly sigma-theta
%  (UNESCO EOS-80 at p=0, kg/m3). Boxes: temperature-salinity ranges of
%  the water masses in Table 1 of
%    Emery, W. J. and J. Meincke (1986). Global water masses: summary
%    and review. Oceanologica Acta 9(4):383-391.
%  (upper waters 0-500 m: solid red; intermediate waters 500-1500 m:
%  dashed green; deep and abyssal waters 1500 m-bottom: dotted purple).
%  The list on the right gives, for each water mass of the table whose
%  T-S box contains points of the profiles, the percentage of the
%  points inside the box and their depth range. The boxes only use T
%  and S: points outside the depth layer of a water mass are counted
%  separately ("in layer" percentage). Regional water masses not in
%  Emery and Meincke (1986), e.g. the Equatorial Subsurface Water of
%  the Eastern South Pacific, are not drawn.
%
%  Octave version (Oct-2026).
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
%  Copyright (c) 2026 by Andres Sepulveda
%  Andres Sepulveda 2026 - Octave adaptations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<1, error('You must specify a file name'), end
if nargin<2 || isempty(gridfile), gridfile=hisfile; end
if nargin<3, lonbox=[]; end
if nargin<4, latbox=[]; end
if nargin<5 || isempty(tindex), tindex=1; end
if nargin<6 || isempty(ocean), ocean='auto'; end
if nargin<7 || isempty(Yorig), Yorig=NaN; end
if nargin<8 || isempty(maxprof), maxprof=400; end
%
% Grid, depths, temperature and salinity (Matlab order: N x M x L)
%
[lat,lon,mask]=oct_read_latlonmask(gridfile,'r');
if isempty(lonbox) || isempty(latbox)
  lonbox=mean(lon(mask>0)); latbox=mean(lat(mask>0));
end
z=oct_get_depths(hisfile,gridfile,tindex,'r');
nc=netcdf.open(hisfile,'NC_NOWRITE');
T=readvar(nc,'temp',tindex); S=readvar(nc,'salt',tindex);
netcdf.close(nc);
[N,M,L]=size(T);
sea=mask>0;
%
% Profiles
%
if numel(lonbox)==1                           % nearest sea point
  d=(lon-lonbox).^2*cos(latbox*pi/180)^2+(lat-latbox).^2;
  d(~sea)=Inf;
  [~,k]=min(d(:));
  ispoint=true;
else
  lo=sort(lonbox(1:2)); la=sort(latbox(1:2));
  k=find(sea & lon>=lo(1) & lon<=lo(2) & lat>=la(1) & lat<=la(2));
  if isempty(k), error('oct_ts_diagram: no sea point in the region'), end
  if numel(k)>maxprof
    k=k(unique(round(linspace(1,numel(k),maxprof))));
  end
  ispoint=false;
end
np=numel(k);
[jj,ii]=ind2sub([M L],k);
Tp=NaN(N,np); Sp=Tp; Dp=Tp;
for p=1:np
  Tp(:,p)=T(:,jj(p),ii(p)); Sp(:,p)=S(:,jj(p),ii(p)); Dp(:,p)=-z(:,jj(p),ii(p));
end
bad=~isfinite(Tp) | ~isfinite(Sp) | abs(Tp)>100 | Sp<=0 | Sp>50;
Tp(bad)=NaN; Sp(bad)=NaN;
%
% Water mass table
%
if strcmpi(ocean,'auto')
  l360=mod(mean(lon(k)),360);
  if l360>=120 && l360<290
    ocean='Pacific';
  elseif l360>=20 && l360<120
    ocean='Indian';
  else
    ocean='Atlantic';
  end
end
WM=water_masses();
use=strcmpi({WM.ocean},ocean) | strcmpi(ocean,'all');
if strcmpi(ocean,'all') || min(lat(k))<-35
  use=use | strcmpi({WM.ocean},'Southern');
end
mlat=mean(lat(k));
if ~strcmpi(ocean,'all')                      % hemisphere of the profiles
  if mlat<-15, use=use & ~strcmp({WM.hem},'N'); end
  if mlat>15,  use=use & ~strcmp({WM.hem},'S'); end
end
WM=WM(use);
if strcmpi(ocean,'all')                       % same mass in several oceans: once
  [~,u]=unique(strcat({WM.abbr},'_',sprintfc_ranges(WM)),'stable'); WM=WM(sort(u));
end
%
% Figure
%
[day,month,year,imonth,thedate]=oct_get_date(hisfile,tindex,Yorig);
fig=gcf; clf(fig);
set(fig,'Color','w');
ax=axes('Parent',fig,'Position',[0.08 0.11 0.56 0.78]);
hold(ax,'on');
okT=isfinite(Tp) & isfinite(Sp);
smin=min(Sp(okT)); smax=max(Sp(okT)); tmin=min(Tp(okT)); tmax=max(Tp(okT));
if isempty(smin), error('oct_ts_diagram: no valid temperature/salinity'), end
ds=max(smax-smin,0.2); dt=max(tmax-tmin,1);
xl=[smin-0.12*ds smax+0.12*ds]; yl=[tmin-0.08*dt tmax+0.08*dt];
%
% sigma-theta
%
[SS,TT]=meshgrid(linspace(xl(1),xl(2),120),linspace(yl(1),yl(2),120));
sig=sigma_theta(SS,TT);
lev=floor(min(sig(:))):0.5:ceil(max(sig(:)));
if numel(lev)>16, lev=floor(min(sig(:))):1:ceil(max(sig(:))); end
[C,hc]=contour(ax,SS,TT,sig,lev);
set(hc,'LineColor',[0.6 0.6 0.6],'LineWidth',0.5);
if ~isempty(C), clabel(C,hc,'FontSize',7,'Color',[0.45 0.45 0.45],'LabelSpacing',300); end
%
% Water mass boxes
%
lc={[0.80 0.15 0.10],[0.10 0.50 0.15],[0.45 0.15 0.60]};
ls={'-','--',':'};
found=struct('abbr',{},'name',{},'pct',{},'pctl',{},'dmin',{},'dmax',{},'layer',{});
for w=1:numel(WM)
  m=WM(w);
  if m.S(2)<xl(1) || m.S(1)>xl(2) || m.T(2)<yl(1) || m.T(1)>yl(2), continue, end
  plot(ax,m.S([1 2 2 1 1]),m.T([1 1 2 2 1]),'LineStyle',ls{m.layer},...
       'Color',lc{m.layer},'LineWidth',1.4);
  tx=max(m.S(1),xl(1))+0.01*diff(xl); ty=min(m.T(2),yl(2))-0.015*diff(yl);
  text(ax,tx,ty,m.abbr,'Color',lc{m.layer},'FontSize',8,'FontWeight','bold',...
       'VerticalAlignment','top','Clipping','on','Interpreter','none');
  in=okT & Sp>=m.S(1) & Sp<=m.S(2) & Tp>=m.T(1) & Tp<=m.T(2);
  if any(in(:))
    zr=[0 500; 500 1500; 1500 Inf];
    inl=in & Dp>=zr(m.layer,1) & Dp<zr(m.layer,2);
    found(end+1)=struct('abbr',m.abbr,'name',m.name,'pct',100*sum(in(:))/sum(okT(:)),...
                        'pctl',100*sum(inl(:))/sum(okT(:)),'dmin',min(Dp(in)),...
                        'dmax',max(Dp(in)),'layer',m.layer);
  end
end
%
% Profiles coloured by depth
%
dmax=max(Dp(okT)); if ~(dmax>0), dmax=1; end
X=[]; Y=[]; Cd=[];
for p=1:np
  g=okT(:,p);
  if ~any(g), continue, end
  X=[X; Sp(g,p); NaN]; Y=[Y; Tp(g,p); NaN]; Cd=[Cd; Dp(g,p); NaN];
end
lw=ifelse_ts(ispoint,2.5,1);
hs=surface(ax,[X X],[Y Y],zeros(numel(X),2),[Cd Cd],'EdgeColor','interp','FaceColor','none',...
           'LineWidth',lw,'Marker','none');
if ispoint
  scatter(ax,X(isfinite(X)),Y(isfinite(X)),14,Cd(isfinite(X)),'filled');
end
cm=oct_cmocean('deep',256);
colormap(ax,cm); caxis(ax,[0 dmax]);
cb=colorbar(ax,'eastoutside'); set(cb,'YDir','reverse');
set(ax,'Position',[0.08 0.11 0.56 0.78]); set(cb,'Position',[0.655 0.11 0.016 0.78]);
ylabel(cb,'Depth (m)');
hold(ax,'off');
set(ax,'XLim',xl,'YLim',yl,'Box','on','Layer','top','FontSize',9);
xlabel(ax,'Salinity');
ylabel(ax,'Potential temperature (\circC)');
if ispoint
  where=sprintf('%s %s (I=%d, J=%d), h=%.0f m',ll_str(lon(k),'EW',3),ll_str(lat(k),'NS',3),ii-1,jj-1,max(Dp(:,1)));
else
  where=sprintf('%s - %s, %s - %s, %d profiles',ll_str(lo(1),'EW',2),ll_str(lo(2),'EW',2),...
                ll_str(la(1),'NS',2),ll_str(la(2),'NS',2),np);
end
title(ax,{['T-S diagram - ',thedate],where},'FontSize',10);
%
% Water masses found
%
ax2=axes('Parent',fig,'Position',[0.75 0.11 0.24 0.78],'Visible','off','XLim',[0 1],'YLim',[0 1]);
y=0.99;
text(ax2,0,y,{'Water masses',sprintf('(Emery & Meincke 1986, %s%s)',ocean,...
     ifelse_ts(any(strcmpi({WM.ocean},'Southern')) && ~strcmpi(ocean,'all'),' + Southern',''))},...
     'FontWeight','bold','FontSize',8,'VerticalAlignment','top');
y=y-0.08;
if isempty(found)
  text(ax2,0,y,'no point in the T-S boxes','FontSize',8,'VerticalAlignment','top');
end
[~,o]=sort([found.pct],'descend'); found=found(o);
for f=1:numel(found)
  q=found(f);
  text(ax2,0,y,sprintf('%s: %.0f%% (%.0f%% in layer)',q.abbr,q.pct,q.pctl),'FontSize',8,...
       'FontWeight','bold','Color',lc{q.layer},'VerticalAlignment','top','Interpreter','none');
  text(ax2,0.04,y-0.03,sprintf('%s, %.0f-%.0f m',q.name,q.dmin,q.dmax),'FontSize',7,...
       'VerticalAlignment','top','Interpreter','none');
  y=y-0.075;
  if y<0.12, break, end
end
text(ax2,0,0.08,{'Boxes: upper (0-500 m, solid),','intermediate (500-1500 m, dashed),',...
     'deep (>1500 m, dotted) waters.','Grey: \sigma_\theta (kg m^{-3})'},'FontSize',7,'VerticalAlignment','top');
if nargout>0
  out=struct('lon',lon(k),'lat',lat(k),'I',ii-1,'J',jj-1,'temp',Tp,'salt',Sp,'depth',Dp,...
             'ocean',ocean,'watermasses',found,'ax',ax);
end
return
%
%---------------------------------------------------------------------
%
function X=readvar(nc,name,tindex)
vid=netcdf.inqVarID(nc,name);
[~,~,dims]=netcdf.inqVar(nc,vid);
n=zeros(1,numel(dims));
for d=1:numel(dims), [~,n(d)]=netcdf.inqDim(nc,dims(d)); end
st=zeros(1,numel(dims)); ct=n;
if numel(dims)==4, st(4)=tindex-1; ct(4)=1; end
X=double(netcdf.getVar(nc,vid,st,ct));
try, fv=double(netcdf.getAtt(nc,vid,'_FillValue')); X(X==fv)=NaN; end
try, sc=double(netcdf.getAtt(nc,vid,'scale_factor')); X=X*sc; end
try, of=double(netcdf.getAtt(nc,vid,'add_offset')); X=X+of; end
X=permute(X(:,:,:,1),[3 2 1]);                % (xi,eta,s) -> (s,eta,xi)
return
%
function s=sigma_theta(S,T)
%
% Potential density anomaly (kg/m3): UNESCO EOS-80 at p=0
%
rw=999.842594+6.793952e-2*T-9.095290e-3*T.^2+1.001685e-4*T.^3-1.120083e-6*T.^4+6.536332e-9*T.^5;
A=8.24493e-1-4.0899e-3*T+7.6438e-5*T.^2-8.2467e-7*T.^3+5.3875e-9*T.^4;
B=-5.72466e-3+1.0227e-4*T-1.6546e-6*T.^2;
s=rw+A.*S+B.*S.^1.5+4.8314e-4*S.^2-1000;
return
%
function s=ll_str(v,h,n)
if v<0, c=h(2); else, c=h(1); end
s=sprintf(['%.',num2str(n),'f\\circ%s'],abs(v),c);
return
%
function c=ifelse_ts(t,a,b)
if t, c=a; else, c=b; end
return
%
function s=sprintfc_ranges(WM)
s=arrayfun(@(m) sprintf('%g_%g_%g_%g',m.T,m.S),WM,'UniformOutput',false);
return
%
function WM=water_masses()
%
% Table 1 of Emery and Meincke (1986): temperature (degC) and salinity
% ranges. layer: 1 upper (0-500 m), 2 intermediate (500-1500 m),
% 3 deep and abyssal (1500 m-bottom). hemisphere: N (North
% Atlantic/Pacific/Indian masses), S (South), B (both / equatorial /
% spreading across the equator)
%
t={ ...
% ocean      layer hemisphere (N, S, B: both) abbr  name                                         T            S
'Atlantic'  1 'N' 'ENACW'  'Eastern North Atlantic Central Water'          [8.0 18.0]   [35.2 36.7]
'Atlantic'  1 'N' 'WNACW'  'Western North Atlantic Central Water'          [7.0 20.0]   [35.0 36.7]
'Atlantic'  1 'S' 'SACW'   'South Atlantic Central Water'                  [5.0 18.0]   [34.3 35.8]
'Atlantic'  1 'N' 'ASUW'   'Atlantic Subarctic Upper Water'                [0.0 4.0]    [34.0 35.0]
'Atlantic'  2 'N' 'WASIW'  'Western Atlantic Subarctic Intermediate Water' [3.0 9.0]    [34.0 35.1]
'Atlantic'  2 'N' 'EASIW'  'Eastern Atlantic Subarctic Intermediate Water' [3.0 9.0]    [34.4 35.3]
'Atlantic'  2 'B' 'AAIW'   'Antarctic Intermediate Water'                  [2.0 6.0]    [33.8 34.8]
'Atlantic'  2 'N' 'MW'     'Mediterranean Water'                           [2.6 11.0]   [35.0 36.2]
'Atlantic'  2 'N' 'AIW'    'Arctic Intermediate Water'                     [-1.5 3.0]   [34.7 34.9]
'Atlantic'  3 'B' 'NADW'   'North Atlantic Deep Water'                     [1.5 4.0]    [34.8 35.0]
'Atlantic'  3 'B' 'AABW'   'Antarctic Bottom Water'                        [-0.9 1.7]   [34.64 34.72]
'Atlantic'  3 'N' 'ABW'    'Arctic Bottom Water'                           [-1.8 -0.5]  [34.88 34.94]
'Indian'    1 'N' 'ASW'    'Arabian Sea Water'                             [24.0 30.0]  [35.5 36.8]
'Indian'    1 'N' 'BBW'    'Bengal Bay Water'                              [25.0 29.0]  [28.0 35.0]
'Indian'    1 'B' 'IEW'    'Indian Equatorial Water'                       [8.0 23.0]   [34.6 35.0]
'Indian'    1 'B' 'IUW'    'Indonesian Upper Water'                        [8.0 23.0]   [34.4 35.0]
'Indian'    1 'S' 'SICW'   'South Indian Central Water'                    [8.0 25.0]   [34.6 35.8]
'Indian'    2 'B' 'AAIW'   'Antarctic Intermediate Water'                  [2.0 10.0]   [33.8 34.5]
'Indian'    2 'B' 'RSPGIW' 'Red Sea-Persian Gulf Intermediate Water'       [5.0 14.0]   [34.8 35.4]
'Indian'    2 'B' 'IIW'    'Indonesian Intermediate Water'                 [3.5 5.5]    [34.6 34.7]
'Indian'    3 'B' 'CDW'    'Circumpolar Deep Water'                        [0.1 2.0]    [34.62 34.73]
'Pacific'   1 'N' 'PSUW'   'Pacific Subarctic Upper Water'                 [3.0 15.0]   [32.6 33.6]
'Pacific'   1 'N' 'WNPCW'  'Western North Pacific Central Water'           [10.0 22.0]  [34.2 35.2]
'Pacific'   1 'N' 'ENPCW'  'Eastern North Pacific Central Water'           [12.0 20.0]  [34.2 35.0]
'Pacific'   1 'N' 'ENPTW'  'Eastern North Pacific Transition Water'        [11.0 20.0]  [33.8 34.3]
'Pacific'   1 'B' 'PEW'    'Pacific Equatorial Water'                      [7.0 23.0]   [34.5 36.0]
'Pacific'   1 'S' 'WSPCW'  'Western South Pacific Central Water'           [6.0 22.0]   [34.5 35.8]
'Pacific'   1 'S' 'ESPCW'  'Eastern South Pacific Central Water'           [8.0 24.0]   [34.4 36.4]
'Pacific'   1 'S' 'ESPTW'  'Eastern South Pacific Transition Water'        [14.0 20.0]  [34.6 35.2]
'Pacific'   2 'N' 'PSIW'   'Pacific Subarctic Intermediate Water'          [5.0 12.0]   [33.8 34.3]
'Pacific'   2 'N' 'CIW'    'California Intermediate Water'                 [10.0 12.0]  [33.9 34.4]
'Pacific'   2 'S' 'ESPIW'  'Eastern South Pacific Intermediate Water'      [10.0 12.0]  [34.0 34.4]
'Pacific'   2 'B' 'AAIW'   'Antarctic Intermediate Water'                  [2.0 10.0]   [33.8 34.5]
'Pacific'   3 'B' 'CDW'    'Circumpolar Deep Water'                        [0.1 2.0]    [34.62 34.73]
'Southern'  1 'S' 'SASW'   'Subantarctic Surface Water'                    [3.2 15.0]   [34.0 35.5]
'Southern'  1 'S' 'AASW'   'Antarctic Surface Water'                       [-1.0 1.0]   [34.0 34.6]
};
WM=struct('ocean',t(:,1),'layer',t(:,2),'hem',t(:,3),'abbr',t(:,4),'name',t(:,5),'T',t(:,6),'S',t(:,7));
WM=WM(:)';
return
