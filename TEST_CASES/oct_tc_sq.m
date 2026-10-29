function X=oct_tc_sq(X,nsub,ndv)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OCT_TC_SQ  Shape of the result of nc{'name'}(i,j,...) in the old Matlab
%             netcdf toolbox (UTILITIES/mexcdf/netcdf_toolbox, ncvar/
%             subsref): the hyperslab is read in Fortran order, Matlab
%             drops its trailing singleton dimensions, then the dimensions
%             are reversed. In C order: the LEADING singleton dimensions
%             are removed; if one dimension is left the result is a row
%             vector. E.g. zeta(t,j,:) -> 1 x L, bed_thick(t,:,1,1) ->
%             Nb x 1, u(t,N,:,:) -> M x L-1. A 1-D variable (e.g.
%             scrum_time) is a column vector, whatever the subscripts (the
%             toolbox ignores the subscripts beyond the number of
%             dimensions, as in scrum_time(:,:)).
%
%  X = oct_tc_sq(X,nsub,ndv)   X: oct_tc_var(nc,name)(i,j,...) (C order),
%                              nsub: number of subscripts, ndv: number of
%                              dimensions of the variable (oct_tc_ndims)
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
if ndv<=1
  X=X(:);                                      % 1-D variable: column
  return
end
if nsub~=ndv                                   % other subscripts: squeeze
  X=squeeze(X);
  if isvector(X) && ~isscalar(X), X=X(:).'; end
  return
end
c=ones(1,ndv);
for d=1:ndv, c(d)=size(X,d); end
k=find(c~=1,1);
if isempty(k), X=X(1); return, end            % scalar
s=c(k:end);
if numel(s)==1, s=[1 s]; end                  % one dimension left: row
X=reshape(X,[s 1]);
return
