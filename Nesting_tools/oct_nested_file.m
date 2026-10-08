function oct_nested_file(child_grd,parent_file,child_file,title,...
                         extrapmask,vertical_correc)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  oct_nested_file(child_grd,parent_file,child_file,title,...
%                  extrapmask,vertical_correc)
%
%  Generic interpolation of a CROCO parent file (forcing, bulk,
%  climatology, initial, restart, dust...) on an embedded child grid
%  created by oct_nested_grid.
%
%  1 - the child file is created with the structure of the parent file
%      (oct_create_nestedfile),
%  2 - every variable with horizontal dimensions is interpolated for
%      each record (and each vertical level) with oct_interpvar3d /
%      oct_interpvar4d. The C-grid position (rho, u, v, psi) is taken
%      from the dimension names,
%  3 - optionally, the 3D variables at s_rho levels are corrected for
%      the change of topography between parent and child
%      (oct_vert_correc).
%
%  extrapmask     : 1 to extrapolate the parent fields under the mask
%  vertical_correc: 1 to apply the vertical corrections
%
%  Octave version (Sep-2026): netcdf.* API of the octave-netcdf package.
%  This file is part of CROCOTOOLS (GNU General Public License).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin<5, extrapmask=0; end
if nargin<6, vertical_correc=0; end
disp(' ')
disp(title)
disp(' ')
%
% Read in the embedded grid
%
disp(' Read in the embedded grid...')
ncid = netcdf.open(child_grd, 'NC_NOWRITE');
parent_grd = netcdf.getAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'parent_grid');
grd_pos = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'grd_pos')));
imin=grd_pos(1); imax=grd_pos(2); jmin=grd_pos(3); jmax=grd_pos(4);
refinecoeff = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'refine_coef')));
netcdf.close(ncid);
%
% Read in the parent grid
%
disp(' Read in the parent grid...')
ncid = netcdf.open(parent_grd, 'NC_NOWRITE');
[~,Lp] = netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_rho'));
[~,Mp] = netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_rho'));
if extrapmask==1
  mask = double(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'mask_rho'))).';
else
  mask = [];
end
netcdf.close(ncid);
%
% Create the child file
%
disp(' ')
disp([' Create the file ',child_file,'...'])
oct_create_nestedfile(parent_file,child_file,child_grd,title)
%
% Parent and child index grids for the 4 C-grid positions
%
[igrd.r,jgrd.r]=meshgrid((1:1:Lp),(1:1:Mp));
[igrd.p,jgrd.p]=meshgrid((1:1:Lp-1),(1:1:Mp-1));
[igrd.u,jgrd.u]=meshgrid((1:1:Lp-1),(1:1:Mp));
[igrd.v,jgrd.v]=meshgrid((1:1:Lp),(1:1:Mp-1));
ipchild=(imin:1/refinecoeff:imax);
jpchild=(jmin:1/refinecoeff:jmax);
irchild=(imin+0.5-0.5/refinecoeff:1/refinecoeff:imax+0.5+0.5/refinecoeff);
jrchild=(jmin+0.5-0.5/refinecoeff:1/refinecoeff:jmax+0.5+0.5/refinecoeff);
[ichild.p,jchild.p]=meshgrid(ipchild,jpchild);
[ichild.r,jchild.r]=meshgrid(irchild,jrchild);
[ichild.u,jchild.u]=meshgrid(ipchild,jrchild);
[ichild.v,jchild.v]=meshgrid(irchild,jpchild);
%
% Interpolate all the variables with horizontal dimensions
%
disp(' ')
disp(' Do the interpolations...')
ng_id = netcdf.open(child_grd, 'NC_NOWRITE');
[~,ngv] = netcdf.inq(ng_id);
gridvars = cell(1,ngv);
for k=1:ngv
  gridvars{k} = netcdf.inqVar(ng_id, k-1);
end
netcdf.close(ng_id);
np_id = netcdf.open(parent_file, 'NC_NOWRITE');
nc_id = netcdf.open(child_file, 'NC_WRITE');
[~,nvars,~,unlimdim] = netcdf.inq(np_id);
for v=0:nvars-1
  [vname,~,dimids] = netcdf.inqVar(np_id, v);
  nd = numel(dimids);
  dnames = cell(1,nd);
  dlens  = zeros(1,nd);
  for k=1:nd
    [dnames{k},dlens(k)] = netcdf.inqDim(np_id, dimids(k));
  end
  if nd<2 || ~strncmp(dnames{1},'xi_',3) || ~strncmp(dnames{2},'eta_',4)
    continue                         % not a horizontal field
  end
%
% C-grid position from the dimension names
%
  if strcmp(dnames{1},'xi_u') || strcmp(dnames{1},'xi_psi')
    if strcmp(dnames{2},'eta_v') || strcmp(dnames{2},'eta_psi')
      pos='p';
    else
      pos='u';
    end
  elseif strcmp(dnames{2},'eta_v')
    pos='v';
  else
    pos='r';
  end
%
% Record dimension (last one if it is a time dimension)
%
  istime = (dimids(end)==unlimdim) || ~isempty(strfind(dnames{end},'time'));
  if nd==2 || (nd==3 && ~istime) || (nd==4 && ~istime)
%
%   Static field: already copied from the child grid if it exists there.
%   Otherwise interpolate it (2D only).
%
    if nd==2
      if any(strcmp(vname,gridvars))
        continue
      end
      var_par=double(netcdf.getVar(np_id, v)).';
      var_child=interp2(igrd.(pos),jgrd.(pos),var_par,ichild.(pos),jchild.(pos),'cubic');
      netcdf.putVar(nc_id, netcdf.inqVarID(nc_id, vname), var_child.');
    end
    continue
  end
  ntimes = dlens(end);
  disp(['  ',vname,' (',num2str(ntimes),' records)'])
  for tindex=1:ntimes
    if nd==3
      oct_interpvar3d(np_id,nc_id,igrd.(pos),jgrd.(pos),ichild.(pos),jchild.(pos),...
                      vname,mask,tindex)
    else
      oct_interpvar4d(np_id,nc_id,igrd.(pos),jgrd.(pos),ichild.(pos),jchild.(pos),...
                      vname,mask,tindex,dlens(3))
    end
  end
end
netcdf.close(np_id);
netcdf.close(nc_id);
%
% Vertical corrections
%
if vertical_correc==1
  oct_vert_correc(child_file,[],0,0,{''},{''})   % all s_rho fields, all records
end
disp(' ')
disp(' Done')
return
