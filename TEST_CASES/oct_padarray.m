function y=oct_padarray(x,n,method,direction)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OCT_PADARRAY  padarray(x,n,'replicate',direction) of the Matlab image
%                toolbox (n: scalar or vector of pads per dimension,
%                direction 'pre', 'post' or 'both'); only 'replicate'
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
if nargin<3, method='replicate'; end
if nargin<4, direction='both'; end
if ~strcmpi(method,'replicate'), error('oct_padarray: only the replicate method'); end
y=x;
for d=1:numel(n)
  if n(d)==0, continue, end
  idx=repmat({':'},1,max(ndims(y),d));
  sz=size(y,d);
  if any(strcmpi(direction,{'pre','both'}))
    idx{d}=ones(1,n(d)); y=cat(d,y(idx{:}),y); sz=size(y,d);
  end
  if any(strcmpi(direction,{'post','both'}))
    idx{d}=sz*ones(1,n(d)); y=cat(d,y,y(idx{:}));
  end
end
return
