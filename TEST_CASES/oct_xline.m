function h=oct_xline(v,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OCT_XLINE  xline of Matlab (not in Octave 8): lines at x = v
%               across the current axes, line spec and properties as plot
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
ax=gca; hs=ishold(ax); hold(ax,'on');
h=[];
for k=1:numel(v)
  if strcmp('x','x')
    h(end+1)=plot(ax,[v(k) v(k)],ylim(ax),varargin{:});
  else
    h(end+1)=plot(ax,xlim(ax),[v(k) v(k)],varargin{:});
  end
end
if ~hs, hold(ax,'off'); end
return
