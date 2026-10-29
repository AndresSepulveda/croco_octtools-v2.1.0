function X=oct_tc_var(nc,name)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OCT_TC_VAR  Variable of a netcdf file in the C order of the old Matlab
%              netcdf toolbox (time, s, eta, xi): replaces nc{'name'}
%
%  X = oct_tc_var(nc,name)            whole variable (nc{'name'}(:))
%  oct_tc_var(nc,name)(t,:,j,i0:end)  Octave indexing of the result
%                                     (nc{'name'}(t,:,j,i0:end)), 'end'
%                                     refers to the size of the variable
%
%  nc: structure of oct_tc_open (or a file name). Missing variable: []
%  (as the old toolbox). The values are not scaled (no scale_factor,
%  add_offset or _FillValue processing, as the old toolbox default).
%  The last variables read are kept in a cache (file, name, time of the
%  file), so that reading the same variable record by record in a loop
%  does not read the file again.
%
%  Part of the Octave port of the plotting scripts of the CROCO TEST_CASES.
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
%  Copyright (c) 2026 by Andres Sepulveda
%  Andres Sepulveda 2026 - Octave adaptations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
persistent C
if isempty(C), C=struct('key',{},'val',{}); end
if ischar(nc), nc=oct_tc_open(nc); cl=1; else, cl=0; end
d=dir(nc.file);
key=sprintf('%s|%s|%g',nc.file,name,d.datenum);
k=find(strcmp({C.key},key),1);
if ~isempty(k)
  X=C(k).val; C=[C(k) C([1:k-1 k+1:end])];
  if cl, oct_tc_close(nc); end
  return
end
try
  vid=netcdf.inqVarID(nc.id,name);
catch
  X=[];
  if cl, oct_tc_close(nc); end
  return
end
X=double(netcdf.getVar(nc.id,vid));
[~,~,dims]=netcdf.inqVar(nc.id,vid);
if numel(dims)>=2
  sz=ones(1,numel(dims));
  for i=1:numel(dims), [~,sz(i)]=netcdf.inqDim(nc.id,dims(i)); end
  X=reshape(X,[sz 1]);
  X=permute(X,[numel(dims):-1:1 numel(dims)+1:max(numel(dims),2)]);
end
if cl, oct_tc_close(nc); end
C=[struct('key',key,'val',X) C];
if numel(C)>12, C=C(1:12); end
return
