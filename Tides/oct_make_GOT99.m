%----------------------------------------------------------------------
% Read and store in a netcdf file the Self-attraction/Loading "tide" 
% amplitude and phase from the tide model GOT99.2b of R Ray/GSFC                          %                     
%  for principal constituents:
%         M2 S2 N2 K2 K1 O1 P1 Q1
% itide=  1  2  3  4  5  6  7  8 
%
% P. Marchesiello 2015
%----------------------------------------------------------------------
%
clear all
close all
%
SALname='GOT99_SAL.nc';
Ntides=8;
components = 'M2 S2 N2 K2 K1 O1 P1 Q1' ;
prefix=['m2'; 's2'; 'n2'; 'k2'; 'k1'; 'o1'; 'p1'; 'q1'];
%
%  Tidal loading grid:
%    size:  361  720
%   lat: -90.0000   90.0000
%   lon:   0.0000  359.5000
%   spval:  999.00
%
x=[0:0.5:359.5];
y=[-90:0.5:90];
L=length(x);
M=length(y);
%
% Create netcdf file ---------------------------------
%
nw_id = netcdf.create(SALname, 'NC_CLOBBER');
%
%  define dimensions
%
did_tide_period = netcdf.defDim(nw_id, 'tide_period', Ntides);
did_x = netcdf.defDim(nw_id, 'x', L);
did_y = netcdf.defDim(nw_id, 'y', M);
%
%  define variables and attributes
%
vid_lon = netcdf.defVar(nw_id, 'lon', 'NC_DOUBLE', did_x);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon'), 'long_name', 'longitude');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lon'), 'units', 'degree_east');

vid_lat = netcdf.defVar(nw_id, 'lat', 'NC_DOUBLE', did_y);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat'), 'long_name', 'latitude');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'lat'), 'units', 'degree_north');

vid_tide_period = netcdf.defVar(nw_id, 'tide_period', 'NC_DOUBLE', did_tide_period);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'tide_period'), 'long_name', 'Tide angular period');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'tide_period'), 'units', 'Hours');

vid_tide_SALamp = netcdf.defVar(nw_id, 'tide_SALamp', 'NC_DOUBLE', [did_x, did_y, did_tide_period]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'tide_SALamp'), 'long_name', 'Amplitude of Self-attraction/Loading tide');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'tide_SALamp'), 'units', 'Meter');

vid_tide_SALpha = netcdf.defVar(nw_id, 'tide_SALpha', 'NC_DOUBLE', [did_x, did_y, did_tide_period]);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'tide_SALpha'), 'long_name', 'Phase of Self-attraction/Loading tide');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.inqVarID(nw_id, 'tide_SALpha'), 'units', 'Degrees');
%
% Create global attributes
%
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'type', 'GOT99.2 tides loading file');
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'components', components);
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(nw_id, netcdf.getConstant('NC_GLOBAL'), 'date', date);
%
% Write grid
%
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lon'), x);
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'lat'), y);
% ----------------------------------------------------
%
%  Amplitude and Phase
%
for itide=1:Ntides

  fname=[prefix(itide,:),'sal.txt'];
  disp(['... Processing ',fname,' ...'])
  M=importdata(fname);

  for j=1:361
    for i=1:720
      j0=(j-1)*66+ceil(i/11);
      i0=mod(i,11);
      if i0==0, i0=11; end
      joff=floor(361*726/11);
      SALamp(j,i)=M(j0,i0)*0.001; % mm --> m
      SALpha(j,i)=M(j0+joff,i0);
    end
  end
  %
  % Perform extrapolation
  %
  SALamp(SALamp==999)=NaN;
  SALpha(SALpha==999)=NaN;
  SALamp=oct_get_missing_val(x,y,SALamp);
  SALpha=oct_get_missing_val(x,y,SALpha);
  %
  % Write data
  %
  netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'tide_SALamp'), itide,:,:-1, 1, SALamp);  % [conv] 0-based
  netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'tide_SALpha'), itide,:,:-1, 1, SALpha);  % [conv] 0-based

end
netcdf.close(nw_id);

%
%  Make a few plot
%
ncid = netcdf.open(SALname, 'NC_NOWRITE');
for itide=[1 5];
 SALamp=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'tide_SALamp')));
 SALpha=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'tide_SALpha')));
% AMP
 figure
 domaxis=[0 359 -80 80];
 m_proj('mercator',...
         'lon',[domaxis(1) domaxis(2)],...
         'lat',[domaxis(3) domaxis(4)]);
 m_pcolor(x,y,SALamp);
 shading flat;
 colorbar
 m_gshhs_c('color','r');
 m_gshhs_c('patch','k');
 m_grid('box','fancy',...
         'xtick',5,'ytick',5,...
         'fontsize',7);
 fname=[prefix(itide,:),'sal.txt'];
 title([fname(1:5),' AMPLITUDE'],'fontsize',16)
% PHASE
 figure
 domaxis=[0 359 -80 80];
 m_proj('mercator',...
         'lon',[domaxis(1) domaxis(2)],...
         'lat',[domaxis(3) domaxis(4)]);
 m_pcolor(x,y,SALpha);
 shading flat;
 colorbar
 m_gshhs_c('color','r');
 m_gshhs_c('patch','k');
 m_grid('box','fancy',...
         'xtick',5,'ytick',5,...
         'fontsize',7);
 fname=[prefix(itide,:),'sal.txt'];
 title([fname(1:5),' PHASE'],'fontsize',16)
end
netcdf.close(ncid);

