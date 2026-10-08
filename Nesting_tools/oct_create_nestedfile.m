function oct_create_nestedfile(parent_file,child_file,child_grd,title)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  oct_create_nestedfile(parent_file,child_file,child_grd,title)
%
%  Create an empty CROCO netcdf file for an embedded (child) grid with
%  the same structure as a parent file (forcing, bulk, climatology,
%  initial, restart, dust...): same dimensions, variables, types and
%  attributes. The horizontal dimensions (xi_*, eta_*) are taken from
%  the child grid file. The variables without horizontal dimensions
%  (times, s-coordinate parameters...) are copied from the parent file
%  and the static grid variables (h, pm, pn...) are copied from the
%  child grid file. The other variables are filled later by
%  oct_nested_file (interpolation from the parent file).
%
%  Octave version (Sep-2026) using the netcdf.* API of the
%  octave-netcdf package. It replaces the old create_nested* routines
%  whose variable lists and attributes were damaged by the previous
%  automatic conversion: here nothing is lost since the definitions
%  are read from the parent file itself.
%
%  This file is part of CROCOTOOLS (GNU General Public License).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Horizontal sizes of the child grid
%
ng = netcdf.open(child_grd, 'NC_NOWRITE');
hdims = {'xi_rho','eta_rho','xi_u','eta_u','xi_v','eta_v','xi_psi','eta_psi'};
hlen  = zeros(1,numel(hdims));
for k=1:numel(hdims)
  [~,hlen(k)] = netcdf.inqDim(ng, netcdf.inqDimID(ng, hdims{k}));
end
%
% Open the parent file
%
np = netcdf.open(parent_file, 'NC_NOWRITE');
[ndims,nvars,ngatts,unlimdim] = netcdf.inq(np);
%
% Create the child file
%
nc = netcdf.create(child_file, 'NC_CLOBBER');
%
% Dimensions (same ids order as in the parent file)
%
cdid = zeros(1,ndims);
for d=0:ndims-1
  [dname,dlen] = netcdf.inqDim(np, d);
  k = find(strcmp(dname,hdims));
  if ~isempty(k)
    dlen = hlen(k);
  end
  if d==unlimdim
    dlen = netcdf.getConstant('NC_UNLIMITED');
  end
  cdid(d+1) = netcdf.defDim(nc, dname, dlen);
end
%
% Variables and their attributes
%
gname = cell(1,nvars);
for v=0:nvars-1
  [vname,xtype,dimids,natts] = netcdf.inqVar(np, v);
  cvid = netcdf.defVar(nc, vname, xtype, cdid(dimids+1));
  for a=0:natts-1
    aname = netcdf.inqAttName(np, v, a);
    netcdf.copyAtt(np, v, aname, nc, cvid);
  end
  gname{v+1} = vname;
end
%
% Global attributes (copied, then updated)
%
gid = netcdf.getConstant('NC_GLOBAL');
for a=0:ngatts-1
  aname = netcdf.inqAttName(np, gid, a);
  netcdf.copyAtt(np, gid, aname, nc, gid);
end
netcdf.putAtt(nc, gid, 'title', title);
netcdf.putAtt(nc, gid, 'date', date);
netcdf.putAtt(nc, gid, 'grd_file', child_grd);
netcdf.putAtt(nc, gid, 'parent_file', parent_file);
netcdf.endDef(nc);
%
% Copy the data of the variables without horizontal dimension, and the
% static grid variables that are in the child grid file
%
for v=0:nvars-1
  [vname,~,dimids] = netcdf.inqVar(np, v);
  dnames = cell(1,numel(dimids));
  dlens  = zeros(1,numel(dimids));
  for k=1:numel(dimids)
    [dnames{k},dlens(k)] = netcdf.inqDim(np, dimids(k));
  end
  ishoriz = any(strncmp(dnames,'xi_',3) | strncmp(dnames,'eta_',4));
  if ~ishoriz
    if isempty(dimids)
      netcdf.putVar(nc, v, netcdf.getVar(np, v));
    elseif all(dlens>0)
      netcdf.putVar(nc, v, zeros(1,numel(dimids)), dlens, netcdf.getVar(np, v));
    end
  else
    istime = any(dimids==unlimdim) | any(~cellfun(@isempty,regexp(dnames,'time')));
    if ~istime
      try
        gvid = netcdf.inqVarID(ng, vname);
        gdata = netcdf.getVar(ng, gvid);
        [~,~,cdims] = netcdf.inqVar(nc, v);
        clen = 1;
        for k=1:numel(cdims)
          [~,lk] = netcdf.inqDim(nc, cdims(k));
          clen = clen*lk;
        end
        if numel(gdata)==clen      % putVar does not check the size
          netcdf.putVar(nc, v, gdata);
        end
      end
    end
  end
end
netcdf.close(np);
netcdf.close(ng);
netcdf.close(nc);
return
