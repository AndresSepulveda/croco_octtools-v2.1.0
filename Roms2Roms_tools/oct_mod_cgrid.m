%--------------------------------------------------------------
%
%  Modify child grid topography such that it matches the interpolated
%  parent topography at the boundaries.
%
%  This script is for use with make_roms2roms.
%
%   (c) 2007 Jeroen Molemaker, UCLA
%
%   Script (variables cgrid, pgrid, obcflag from the caller, oct_make_h).
%   Octave version (Oct-2026): netcdf.* API of octave-netcdf (grids read
%   in Fortran order and transposed), oct_get_tri_coef, oct_distance.
%--------------------------------------------------------------
%
chdgrd=cgrid;
pargrd=pgrid;
% Only match to parent topography on open boundaries
%obcflag              = [1 0 1 1];      % open boundaries flag (1=open , [S E N W])


% End user-defined----------------------------------------------
%

% Get minimal parent subgrid bounds
ncc = netcdf.open(chdgrd,'NC_NOWRITE');
lonc = double(netcdf.getVar(ncc,netcdf.inqVarID(ncc,'lon_rho'))).';
latc = double(netcdf.getVar(ncc,netcdf.inqVarID(ncc,'lat_rho'))).';
hc   = double(netcdf.getVar(ncc,netcdf.inqVarID(ncc,'h'))).';
mask = double(netcdf.getVar(ncc,netcdf.inqVarID(ncc,'mask_rho'))).';
netcdf.close(ncc);
ncp = netcdf.open(pargrd,'NC_NOWRITE');
lonp  = double(netcdf.getVar(ncp,netcdf.inqVarID(ncp,'lon_rho'))).';
latp  = double(netcdf.getVar(ncp,netcdf.inqVarID(ncp,'lat_rho'))).';
hp    = double(netcdf.getVar(ncp,netcdf.inqVarID(ncp,'h'))).';
maskp = double(netcdf.getVar(ncp,netcdf.inqVarID(ncp,'mask_rho'))).';
netcdf.close(ncp);

lon0 = min(min(lonc));
lon1 = max(max(lonc));
lat0 = min(min(latc));
lat1 = max(max(latc));

g = lonp>=lon0&lonp<=lon1 & latp>=lat0&latp<=lat1;
jmin = min(find(any(g')));
jmax = max(find(any(g')));
imin = min(find(any(g)));
imax = max(find(any(g)));
clear g
% One more parent point on each side: with only the parent points inside
% the child box, the child points of the edges were outside the parent
% triangulation and got the value of their neighbour (Octave version).
[Mpp,Lpp] = size(lonp);
imin = max(1,imin-1); imax = min(Lpp,imax+1);
jmin = max(1,jmin-1); jmax = min(Mpp,jmax+1);
lj = length(jmin:jmax);
li = length(imin:imax);

figure; plot(lonp(jmin:jmax,imin:imax),latp(jmin:jmax,imin:imax),'.k')
hold on;plot(lonc,latc,'.r');hold off
drawnow

[Mc,Lc]=size(hc);

% Squeeze minimal parent subgrid
hp    = hp(jmin:jmax,imin:imax);
lonp  = lonp(jmin:jmax,imin:imax);
latp  = latp(jmin:jmax,imin:imax);
maskp = maskp(jmin:jmax,imin:imax);

% Get interpolation coefficient to go to (lonc,latc).
[elem,coef] = oct_get_tri_coef(lonp,latp,lonc,latc,maskp);
%% parent grid topo at child locations
hpi = sum(coef.*hp(elem),3);


if 0
    dist = zeros(Mc,Lc,4);
    for i = 1:Mc   %% north south
        for j = 1:Lc    %% east west
            dist(i,j,1) =      i/Mc + (1-obcflag(1))*1e6; % South
            dist(i,j,2) = (Lc-j)/Lc + (1-obcflag(2))*1e6; % East
            dist(i,j,3) = (Mc-i)/Mc + (1-obcflag(3))*1e6; % North
            dist(i,j,4) =      j/Lc + (1-obcflag(4))*1e6; % West
        end
    end
    dist = min(dist,[],3);
    
    alpha = 0.5*tanh(100*(dist-0.03))+0.5; %% Feel free to play with this function.
    alpha = 0.5*tanh( 50*(dist-0.06))+0.5; %% Feel free to play with this function.
else
    oct_distance
end

hcn = alpha.*hc + (1-alpha).*hpi;

if 1
    ncc = netcdf.open(chdgrd,'NC_WRITE');
    vid = netcdf.inqVarID(ncc,'h');
    netcdf.putVar(ncc,vid,hcn.');
    netcdf.reDef(ncc);
    netcdf.putAtt(ncc,vid,'notes1','Topo has been modified to match the parent grid topo at the boundaries');
    netcdf.endDef(ncc);
    netcdf.close(ncc);
    disp(['writing boundary matched h to: ' chdgrd])
end

%% Visualize the modification
  sc0 = min(min(hcn));
  sc1 = max(max(hcn));
  figure
  subplot(2,2,1)
  pcolor(lonc,latc,hpi);caxis([sc0 sc1]);colorbar;shading flat
  title('Interpolated Parent Topo')
  subplot(2,2,2)
  pcolor(lonc,latc,hcn);caxis([sc0 sc1]);colorbar;shading flat
  title('Boundary Smoothed Child Topo')
  subplot(2,2,3)
  pcolor(lonc,latc,hcn-hpi);colorbar;shading flat
  title('Difference between Parent and child Topo');
  subplot(2,2,4)
  pcolor(lonc,latc,alpha);colorbar;shading flat
  title('Parent/Child transition function');
